From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Fri, 16 Aug 2002 11:08:09 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020816010809.GA28446@anakin.wychk.org>
References: <20020815032543.GA3083@gandalf.chinesecodefoo.org> <20020814.201514.30457132.davem@redhat.com> <20020815110210.GA15218@anakin.wychk.org> <20020815.142337.95077599.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020815.142337.95077599.davem@redhat.com>
List-Id: netdev.vger.kernel.org


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=big5
Content-Disposition: inline

On Thu, Aug 15, 2002 at 02:23:37PM -0700, David S. Miller wrote:
>    From: Geoffrey Lee <glee@gnupilgrims.org>
>    Date: Thu, 15 Aug 2002 21:02:10 +1000
> 
>    On Wed, Aug 14, 2002 at 08:15:14PM -0700, David S. Miller wrote:
>    > How extensive are your notes on poll() behavior on TCP
>    > sockets? :-)
> 
>    Hmm, in which regard?
>    
>    Is there something specific that you are searching for? :-)
> 
> POLLHUP in particular.  I remember we verified that our behavior
> matched Solaris but no checks were performed against others.


In all honesty, none for that. But it would be a worthwhile experiment
I think. Let us see what happens.


Today, we are going to see what happens with POLLHUP on different Unix
implementations. Source code is provided.

poll.c (server that uses poll)
linger.c (our client to invoke the POLLHUP condition)

Note in poll.c I used size_t as the 3rd argument to accept instead
of socklen_t, as only Linux had socklen_t.

We also see that we get a compile warning when compiling the client as
on SunOS 5.6 the 4th argument to setsockopt is a char *. But we can
ignore that warning.


The following operating systems will be tested against:

OSF1 4.0 (Digital UNIX)
SunOS 5.6 (Solaris)
Linux 2.4.18


We will start the server on a machine with some specified port. We 
call listen for the specified socket, and accept. Next, we block
in the call to poll with fd set to the socket descriptor returned
by accept, and events and revents zeroed. On the call to poll, we 
specify -1 as a senitel that we want to block forever until something
interesting arrives (the error condition).

On the client, we connect to the server to the specified port
as normal. We specify the SO_LINGER option, with l_onoff set to 1 and
linger time set to 0. After we successfully connect to the server, we
call the close call immediately, to issue a RST to the server.


This is what happens on Linux 2.4.18:

$ ./poll -p 8888 
accept ok.
poll: POLLERR set
poll: POLLHUP set
sever terminating
$ 

On the client side:

$ ./linger -h [ip] -p 8888
connecting ..
closing ...
closed.
$ 


So, sending a RST will trigger POLLHUP and POLLERR on Linux.


On OSF1 4.0, we get this:

On the server:
$ ./poll -p 8888
accept ok.

On the client side:
$ ./linger -h [ip] -p 8888
connecting ..
closing ...
closed.
$ 


So on Digital UNIX, it blocks forever in the call to poll.

That's strange. Let's see what happens on SunOS 5.6:

./poll -p 8888
accept ok.


On the client side:

./linger -h [ip] -p 8888
connecting ..
closing ...
closed.
$ 


So on SunOS 5.6, it also blocks forever.


Do you know which Solaris was tested the last time it was found that
Linux behaves the same way as Solaris?

By the way, while we are on the subject of poll, what should one include
to get POLLRDNORM and INFTIM?

I found on OSF1 4.0 one can have both by including <poll.h>,
on SunOS 5.6, one can get POLLRDNORM by including <poll.h>, for INFTIM,
one must include <sys/stropts.h> as well.

On Linux, one will not be able to get them by including both <poll.h>
or <sys/stropts.h>. <sys/poll.h> will not work either. by including 
<linux/poll.h>, then one can get POLLRDNORM defined. But I could not
find INFTIM anywhere on Linux.


	-- G.



--AqsLC8rIMeq19msA
Content-Type: text/x-csrc; charset=big5
Content-Disposition: attachment; filename="linger.c"

#include <sys/socket.h>

#include <netinet/in.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> /* getopt */

#define HOST "192.168.0.1"
#define PORT (22)

int main(argc, argv)
	int argc;
	char *argv[];
{
	int sockfd;
	int c;
	struct linger ling;
	struct sockaddr_in servaddr;
	char *host = HOST;
	unsigned short port = PORT;
	


	while ((c = getopt(argc, argv, "h:p:")) != -1) {
		switch (c) {
			case 'h':
				host = (char *)strdup(optarg);
				break;
			case 'p':
				port = atoi(optarg);
				break;
			default:
				break;
		}
	}

	sockfd = socket(AF_INET, SOCK_STREAM, 0);

	if (sockfd < 0) {
		printf("socket\n");
		exit(1);
	}

	bzero(&servaddr, sizeof(struct sockaddr_in));

	servaddr.sin_family = AF_INET;
	servaddr.sin_port   = htons(port);
	servaddr.sin_addr.s_addr   = inet_addr(host);

	ling.l_onoff = 1;
	ling.l_linger = 0;

	if (setsockopt(sockfd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling)) < 0) {
		printf("setsockopt\n");
		exit(1);
	}

	printf("connecting ..\n");
	if (connect(sockfd, (struct sockaddr *)&servaddr, sizeof(struct sockaddr_in)) < 0) {
		printf("connect: %s\n", strerror(errno));
		exit(1);
	}

	printf("closing ...\n");
	close(sockfd);	/* send RST */
	printf("closed.\n");

	exit(0);
}

--AqsLC8rIMeq19msA
Content-Type: text/x-csrc; charset=big5
Content-Disposition: attachment; filename="poll.c"

#include <poll.h>
#include <sys/socket.h>

#include <netinet/in.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> /* strdup */
#include <unistd.h> /* getopt */

#define PORT (22)

#define BACKLOG 20

#ifndef INFTIM
#define INFTIM (-1)
#endif


extern char *optarg;

int main(argc, argv)
	int argc;
	char *argv[];
{
	struct pollfd nfd;
	struct sockaddr_in saddr, caddr;
	int fd;
	int c;
	int clientfd;
	size_t len;
	unsigned short port = PORT;

	
	bzero(&saddr, sizeof(struct sockaddr_in));
	bzero(&caddr, sizeof(struct sockaddr_in));

	while ((c = getopt(argc, argv, "h:p:")) != -1) {
		switch (c) {
			case 'p':
				port = atoi(optarg);
				break;
			default:
				break;
		}
	}

	saddr.sin_family = AF_INET;
	saddr.sin_port   = htons(port);
	saddr.sin_addr.s_addr   = INADDR_ANY;

	fd = socket(AF_INET, SOCK_STREAM, 0);

	if (fd < 0) {
		printf("socket\n");
		exit(1);
	}

	if (bind(fd, (struct sockaddr *)&saddr, sizeof(struct sockaddr_in)) < 0) {
		printf("bind\n");
		exit(1);
	}

	if (listen(fd, BACKLOG) < 0) {
		printf("listen\n");
		exit(1);
	}

	len = sizeof(struct sockaddr_in);

	if ((clientfd = accept(fd, (struct sockaddr *)&caddr, &len)) < 0) {
		printf("accept: %s\n", strerror(errno)), exit(1);
	}

	printf("accept ok.\n");

	/* reset */	
	nfd.fd = clientfd;
	nfd.events = 0;
	nfd.revents = 0;

	if (poll(&nfd, 1, INFTIM) < 0) 
		printf("poll: %s\n", strerror(errno)), exit(1);

	if (nfd.revents & POLLERR) 
		printf("poll: POLLERR set\n");

	if (nfd.revents & POLLHUP)
		printf("poll: POLLHUP set\n");

	if (nfd.revents & POLLNVAL)
		printf("poll: POLLNVAL set\n"); /* should not happen */

	close(clientfd);
	printf("sever terminating\n");
	exit(0);
}

--AqsLC8rIMeq19msA--
