From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Wed, 14 Aug 2002 00:32:46 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020813143246.GA20943@anakin.wychk.org>
References: <20020813113450.GA19058@anakin.wychk.org> <200208131347.RAA21080@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208131347.RAA21080@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=big5
Content-Disposition: inline

On Tue, Aug 13, 2002 at 05:47:14PM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > Ah, yes you're right. I was feeling stupid and I forgot to clear the
> > errno because re-trying the connect().
> 
> Good. :-)
> 
> Could you repeat corrected test with repreated nonblocking connect()
> on those OSes?
> 

Alright, it looks like I've been smoking too much pot. I'm going to post
the source code [ugly] here as well so what you see is what you get (no more
oops-I-forgot-to-clear-errno oddities again :-)


Let's redo the experiment from the start:

This is the following OS I will test against:

SunOS 5.6
OSF1 4.0
Linux v2.4.18

Source files:
connect.c
connect3.c

connect.c tests for interruptibility with a particular OS.
connect3.c tests for what connect returns if the socket is set 
into non-blocking mode.


First off, we note the behavior of the with regard to interruptibility 
of connect. I use SIGALRM, sigaction with SA_RESTART, and connect to a 
valid IP where the host is down / no host is present. Default blocking
behavior.

SunOS 5.6:

sighandler called, connect fails with -EINTR


OSF1 4.0

sighandler called, connect fails with -EINTR

(I have no idea why I "corrected" myself before that it's restartable,
possibly some cruft I left behind with a read() following connect. So
a return of -EINTR is my Final Answer. Sorry for that confusion.)

Linux 2.4.18:

sighandler is called, but we see that the program does not exit, this
seems to imply that the connect is restarted.


Now, we try with no signals, connect to a valid IP where host is up with
a valid port listening. We use fcntl() to set the socket to
non-blocking mode.



SunOS 5.6

-EINPROGRESS, -EALREADY, -EISCONN, in that order.


OSF1 4.0


-EINPROGRESS, -EALREADY, -EISCONN in that order.



Linux 2.4.18

-EINPROGRESS, -EALREADY, 0 (Success), -EISCONN, in that order.


So Linux does indeed return 0, and this is the magic value that
we are looking for. People writing portably will be required to
handle 0 in Linux, as well as possibly an error of -EISCONN (this
error is ok and seems to be expected in OSF1 4.0 and SunOS 5.6).




	-- G.

--x+6KMIRAuhnl3hBn
Content-Type: text/x-csrc; charset=big5
Content-Disposition: attachment; filename="connect.c"

#include <sys/socket.h>

#include <netinet/in.h>

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>

#include <unistd.h>

#define PORT 22
#define HOST "129.94.44.44"

void handler(int);

int main(int argc, char **argv)
{


	struct sockaddr_in saddr;
	int ret;
	int c;
	int fd;
	char buf[BUFSIZ];
	int val;
	size_t len;
	struct sigaction act, oact;
	char *host = HOST;
	unsigned short port = PORT;

	val = 0;
	len = sizeof(val);

	while ((c = getopt(argc, argv, "h:p:")) != -1) {
                switch (c) {
                        case 'h':
                                host = strdup(optarg);
                                break;
                        case 'p':
                                port = atoi(optarg);
                                break;
                        default:
                                break;
                }
        }      

	bzero(&act, sizeof(struct sigaction));
	bzero(&oact, sizeof(struct sigaction));

	act.sa_flags |= SA_RESTART;
	act.sa_handler = handler;

	ret = sigaction(SIGALRM, &act, &oact);


	if (ret < 0) {

		printf("sigaction\n");
		exit(1);
	}

	memset(&saddr, 0, sizeof(struct sockaddr_in));

	saddr.sin_family = AF_INET;
	saddr.sin_port   = htons(port);
	saddr.sin_addr.s_addr = inet_addr(host);

	fd = socket(AF_INET, SOCK_STREAM, 0);

	if (fd < 0) {
		printf("socket\n");
		exit(1);
	}
	


	alarm(1);

	errno = 0;

	ret = connect(fd, (struct sockaddr *)&saddr, 
		sizeof(struct sockaddr));

	printf("returned from connect\n");

	if (ret < 0) {
		printf("connect\n");
		printf("%s\n", strerror(errno));

	}

	close(fd);

	return(0);
}

void handler(int signo)
{

	printf("in signal hander\n");
	return ;

}

--x+6KMIRAuhnl3hBn
Content-Type: text/x-csrc; charset=big5
Content-Disposition: attachment; filename="connect3.c"

#include <sys/socket.h>

#include <netinet/in.h>

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>

#include <unistd.h>

#define HOST "192.168.0.1"
#define PORT 22

void handler(int);

int main(int argc, char **argv)
{
	struct sockaddr_in saddr;
	int ret;
	int fd;
	int i;
	char buf[BUFSIZ];
	int val;
	int c;
	unsigned short port = PORT;
	size_t len;
	char *host = HOST;

	val = 0;
	len = sizeof(val);

	while ((c = getopt(argc, argv, "h:p:")) != -1) {
		switch (c) {
			case 'h':
				host = strdup(optarg);
				break;
			case 'p':
				port = atoi(optarg);
				break;
			default:
				break;
		}
	}
	
	memset(&saddr, 0, sizeof(struct sockaddr_in));

	saddr.sin_family = AF_INET;
	saddr.sin_port   = htons(port);
	saddr.sin_addr.s_addr = inet_addr(host);

	fd = socket(AF_INET, SOCK_STREAM, 0);

	if (fd < 0) {
		printf("socket\n");
		exit(1);
	}

	val = fcntl(fd, F_GETFL);

	if (val < 0) {
		printf("fcntl get\n");
		exit(1);
	}

	ret = fcntl(fd, F_SETFL, val | O_NONBLOCK);


	if (ret < 0) {
		printf("fcntl set\n");	
		exit(1);
	}



	for (i = 1 ;; i++) {

		errno = 0;

		printf("entering %d connect\n", i);
		ret = connect(fd, (struct sockaddr *)&saddr, 
			sizeof(struct sockaddr_in));

		printf("leaving %d connect, error %d msg = %s\n",
			i, errno, strerror(errno));

		if (errno == EISCONN)
			break;
	
	}

	close(fd);

	exit(0);
}

void handler(int signo)
{

	alarm(1);
	printf("in signal hander\n");
	return ;

}

--x+6KMIRAuhnl3hBn--
