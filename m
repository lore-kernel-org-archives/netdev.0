From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] virtio: orphan skbs if we're relying on timer to free them
Date: Mon, 25 May 2009 20:31:47 +0930
Message-ID: <200905252031.47868.rusty@rustcorp.com.au>
References: <200905182218.47975.rusty@rustcorp.com.au> <200905211627.05814.rusty@rustcorp.com.au> <20090521.001503.90069315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_bqnGKLdx9TAjGig"
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57583 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbZEYLDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2009 07:03:08 -0400
In-Reply-To: <20090521.001503.90069315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_bqnGKLdx9TAjGig
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, 21 May 2009 04:45:03 pm David Miller wrote:
> Probably the most profitable avenue is to see if this is a real issue
> afterall (see above).  If we can get away with having the socket
> buffer represent socket --> device space only, that's the most ideal
> solution.  It will probably also improve performance a lot across the
> board, especially on NUMA/SMP boxes as our TX complete events tend to
> be in difference places than the SKB producer.

OK, hacked in skb_orphan() and couldn't see any behavior change here.

Details: I wrote a little test program to do a 1 byte ping pong on a TCP
socket while doing 1k writes to a number of udp sockets.  We never completely
starve the TCP connection, though that may be because it begins at the same
time as the others and gets some traffic before the buffers fill up.

Running it with 0 to 20 sockets, from my gigabit laptop to my 100Mbit
desktop.  Sorry about the attachment, but sometimes a graph is worth about
1k words.

Not sure why write rate shoots up on serious overload though.  Perhaps we're
discarding earlier in the path?

Cheers,
Rusty.

diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1677,6 +1677,8 @@ int dev_hard_start_xmit(struct sk_buff *
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc;
 
+	skb_orphan(skb);
+
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);

Sender: for i in `seq 0 20`; do ~/devel/junk/udpstress 9999 $i debussy 5; sleep 1; done
Receiver: for i in `seq 0 20`; do ./udpstress -r 9999 $i; done

/* udpstress.c: Simple server & client to test multiple UDP streams. */
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sendfile.h>
#include <sys/time.h>
#include <time.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <err.h>
#include <netdb.h>

static volatile unsigned int bytes;

static void dumpstats(int signal)
{
	char buffer[128];

	sprintf(buffer, "%u\n", bytes);
	write(STDOUT_FILENO, buffer, strlen(buffer));
	_exit(0);
}

static void tcp_dumpstats(int signal)
{
	char buffer[128];

	sprintf(buffer, "TCP: %u\n", bytes);
	write(STDOUT_FILENO, buffer, strlen(buffer));
	_exit(0);
}

static void udp_receiver(unsigned int port)
{
	struct sockaddr_in saddr;
	int sock, ret;
	char buffer[65536];
	int val = 1;

	sock = socket(PF_INET, SOCK_DGRAM, 0);
	if (sock < 0)
		err(1, "creating socket");

	if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(&val)) != 0)
		err(1, "setsockopt(SO_REUSEADDR)");

	/* Wait for incoming. */
	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(port);
	saddr.sin_addr.s_addr = INADDR_ANY;
	if (bind(sock, (struct sockaddr *)&saddr, sizeof(saddr)) != 0)
		err(1, "bind to port %u", port);

	/* Read packets until we get signal. */
	signal(SIGALRM, dumpstats);

	while ((ret = read(sock, buffer, sizeof(buffer))) > 0)
		bytes += ret;
	err(1, "Short read %i", ret);
}

static void udp_client(unsigned int ip, unsigned int port, int fd)
{
	/* We're going to send UDP packets to that addr. */
	struct sockaddr_in saddr;
	int sock, ret;
	char buffer[1024];

	sock = socket(PF_INET, SOCK_DGRAM, 0);
	if (sock < 0)
		err(1, "creating socket");

	/* Connect to remote. */
	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(port);
	saddr.sin_addr.s_addr = ip;
	if (connect(sock, (struct sockaddr *)&saddr, sizeof(saddr)))
		err(1, "connecting socket");

	/* Write packets until we get signal. */
	signal(SIGALRM, dumpstats);

	/* Wait for "go" signal. */
	if (read(fd, buffer, 1) != 1)
		err(1, "Reading go signal");

	while ((ret = write(sock, buffer, sizeof(buffer))) > 0)
		bytes += ret;
	err(1, "Short write %i", ret);
}

/* Exits when tcp socket closes. */
static void tcp_receiver(unsigned int port)
{
	/* We're going to send TCP packets to that addr. */
	struct sockaddr_in saddr;
	int sock;
	char c;
	int val = 1;

	sock = socket(PF_INET, SOCK_STREAM, 0);
	if (sock < 0)
		err(1, "creating socket");

	if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(&val)) != 0)
		err(1, "setsockopt(SO_REUSEADDR)");

	/* Wait for incoming. */
	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(port);
	saddr.sin_addr.s_addr = INADDR_ANY;
	if (bind(sock, (struct sockaddr *)&saddr, sizeof(saddr)) != 0)
		err(1, "bind to port %u", port);

	if (listen(sock, 1) != 0)
		err(1, "listen");

	sock = accept(sock, NULL, NULL);
	if (sock < 0)
		err(1, "Accepting");

	while (read(sock, &c, 1) > 0) {
		bytes++;
		if (write(sock, &c, 1) != 1)
			break;
	}
}

static void tcp_client(unsigned int ip, unsigned int port, int fd)
{
	/* We're going to send TCP packets to that addr. */
	struct sockaddr_in saddr;
	int sock;
	char c;

	sock = socket(PF_INET, SOCK_STREAM, 0);
	if (sock < 0)
		err(1, "creating socket");

	/* Connect to remote. */
	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(port);
	saddr.sin_addr.s_addr = ip;
	if (connect(sock, (struct sockaddr *)&saddr, sizeof(saddr)))
		err(1, "connecting socket");

	/* Write packets until we get signal. */
	signal(SIGALRM, tcp_dumpstats);

	/* Wait for "go" signal. */
	if (read(fd, &c, 1) != 1)
		err(1, "Reading go signal");

	while (write(sock, &c, 1) > 0) {
		bytes++;
		if (read(sock, &c, 1) != 1)
			err(1, "Short read");
	}
	err(1, "Short write");
}

static unsigned int host_to_ipaddr(const char *name)
{
	struct hostent *host;
	unsigned int ip = 0;

	host = gethostbyname(name);
	if (!host)
		err(1, "gethostbyname(%s)", name);

	if (host->h_addrtype != AF_INET ||
	    host->h_length != sizeof(struct in_addr))
		errx(1, "gethostbyname gave wrong type");

	memcpy(&ip, host->h_addr_list[0], 4);
	return ip;
}

static void usage(void)
{
	errx(1,
	     "Usage: udpstress -r portnum number OR\n"
	     "	udpstress portnum number ipaddr timeout");
}

int main(int argc, char *argv[])
{
	unsigned int ip, i, port, kids;
	int fds[2];

	if (argc < 4)
		usage();

	if (pipe(fds) != 0)
		err(1, "Creating pipe");

	signal(SIGALRM, SIG_IGN);
	setsid();

	if (strcmp(argv[1], "-r") == 0) {
		port = atoi(argv[2]);
		kids = atoi(argv[3]);
		for (i = 0; i < kids; i++) {
			switch (fork()) {
			case 0:
				udp_receiver(port + i);
			case -1:
				err(1, "forking");
			}
		}

		/* Finally, receive TCP until the sender finishes. */
		tcp_receiver(port);
		{
			char buffer[128];

			/* Don't just use printf here; gets overwritten by
			 * other children when writing to file. */
			sprintf(buffer, "TCP: %u\n", bytes);
			write(STDOUT_FILENO, buffer, strlen(buffer));
		}
	} else {
		char buffer[kids = atoi(argv[2])+1];
		port = atoi(argv[1]);
		ip = host_to_ipaddr(argv[3]);
		for (i = 0; i < kids - 1; i++) {
			switch (fork()) {
			case 0:
				udp_client(ip, port + i, fds[0]);
			case -1:
				err(1, "forking");
			}
		}
		/* Finally, TCP sender. */
		switch (fork()) {
		case 0:
			tcp_client(ip, port, fds[0]);
		case -1:
			err(1, "forking");
		}

		/* Wait for them to settle. */
		sleep(1);

		if (write(fds[1], buffer, kids) != kids)
			errx(1, "Short write on pipe");
		sleep(atoi(argv[4]));
	}

	/* Kill kids. */
	kill(-getpid(), SIGALRM);

	/* We want to exit last. */
	for (i = 0; i < kids; i++)
		wait(NULL);
	return 0;
}


--Boundary-00=_bqnGKLdx9TAjGig
Content-Type: application/x-gnumeric;
  name="results.gnumeric"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="results.gnumeric"

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

--Boundary-00=_bqnGKLdx9TAjGig--
