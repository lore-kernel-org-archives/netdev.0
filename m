From: Erik Hensema <erik@hensema.net>
Subject: Demonstration code on how to trigger tcp6_sock leak
Date: Sat, 24 Jan 2004 14:13:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124131307.GB2666@bender.home.hensema.net>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I wrote some quick&dirty code showing the tcp6_sock leak in Linux 2.6.x.
The server part listens for incoming connections and accept()'s them. The
client will simply connect() to the server and close the connection.

Do a 'grep tcp6_sock /proc/slabinfo' before and after running the programs,
and you will clearly see the leak.

-- 
Erik Hensema (erik@hensema.net)

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="server.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <strings.h>
#include <stdio.h>

#define port 4000

int
main(
		int argc,
		char **argv
    )
{
	int fd;
	struct sockaddr_in6 myaddr;
	struct sockaddr addr;
	socklen_t len;
	int i;

	if((fd = socket(PF_INET6, SOCK_STREAM, 0)) < 0) {
		perror("socket");
	}

	bzero(&myaddr, sizeof(myaddr));
	myaddr.sin6_family = AF_INET6;
	myaddr.sin6_port = htons(port);
	myaddr.sin6_addr = in6addr_any;

	if(bind(fd, (struct sockaddr *)&myaddr, sizeof(myaddr)) < 0) {
		perror("bind");
	}

	if(listen(fd, 32) < 0) {
		perror("listen");
	}

	for(i = 0; i < 1000; i++) {
		if(accept(fd, &addr, &len) < 0) {
			perror("accept");
		} else {
			printf("Accept: %d\n", i);
		}
	}

	return 0;
}

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="client.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define port 4000

int
main(
		int argc,
		char **argv
    )
{
	int fd;
	struct sockaddr_in6 srvaddr;
	int i;


	bzero(&srvaddr, sizeof(srvaddr));

	srvaddr.sin6_family = AF_INET6;
	srvaddr.sin6_port = htons(port);
	srvaddr.sin6_addr = in6addr_loopback;

	for(i = 0; 1; i++) {
		if((fd = socket(PF_INET6, SOCK_STREAM, 0)) < 0) {
			perror("socket");
			exit(0);
		}

		if(connect(fd, (const struct sockaddr *)&srvaddr, sizeof(srvaddr)) < 0) {
			perror("connect");
		} else {
			printf("Connect %d\n", i);
			close(fd);
		}
	}

	return 0;
}

--fdj2RfSjLxBAspz7--
