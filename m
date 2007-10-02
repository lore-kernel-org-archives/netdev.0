From: John Heffner <jheffner@psc.edu>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 11:06:23 -0400
Message-ID: <47025E6F.8080503@psc.edu>
References: <20070929142517.EC6AB5FB21@work.bitmover.com> <alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org> <20070929172639.GB7037@bitmover.com> <alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org> <20071002005917.GB5480@bitmover.com> <alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org> <20071002022059.GE7037@bitmover.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020708060504080702080900"
To: lm@bitmover.com, Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:49483 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116AbXJBPHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 11:07:04 -0400
In-Reply-To: <20071002022059.GE7037@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020708060504080702080900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Larry McVoy wrote:
> A short summary is "can someone please post a test program that sources
> and sinks data at the wire speed?"  because apparently I'm too old and
> clueless to write such a thing.

Here's a simple reference tcp source/sink that's I've used for years. 
For example, on a couple gigabit machines:

$ ./tcpsend -t10 dew
Sent 1240415312 bytes in 10.033101 seconds
Throughput: 123632294 B/s

   -John


--------------020708060504080702080900
Content-Type: text/plain;
 name="discard.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="discard.c"

/*
 * discard.c
 * A simple discard server.
 *
 * Copyright 2003 John Heffner.
 */

#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/poll.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/param.h>
#include <netinet/in.h>

#if 0
#define RATELIMIT
#define RATE		100000	/* bytes/sec */
#define WAIT_TIME	(1000000/HZ-1)
#define READ_SIZE	(RATE/HZ)
#else
#define READ_SIZE	(1024*1024)
#endif

void child_handler(int sig)
{
	int status;
	
	wait(&status);
}

int main(int argc, char *argv[])
{
	int port = 9000;
	int lfd;
	struct sockaddr_in laddr;
	int newfd;
	struct sockaddr_in newaddr;
	int pid;
	socklen_t len;
	
	if (argc > 2) {
		fprintf(stderr, "usage: discard [port]\n");
		exit(1);
	}
	if (argc == 2) {
		if (sscanf(argv[1], "%d", &port) != 1 || port < 0 || port > 65535) {
			fprintf(stderr, "discard: error: not a port number\n");
			exit(1);
		}
	}
	
	if (signal(SIGCHLD, child_handler) == SIG_ERR) {
		perror("signal");
		exit(1);
	}
	
	memset(&laddr, 0, sizeof (laddr));
	laddr.sin_family = AF_INET;
	laddr.sin_port = htons(port);
	laddr.sin_addr.s_addr = INADDR_ANY;
	
	if ((lfd = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		perror("socket");
		exit(1);
	}
	if (bind(lfd, (struct sockaddr *)&laddr, sizeof (laddr)) != 0) {
		perror("bind");
		exit(1);
	}
	if (listen(lfd, 5) != 0) {
		perror("listen");
		exit(1);
	}
	
	for (;;) {
		if ((newfd = accept(lfd, (struct sockaddr *)&newaddr, &len)) < 0) {
			if (errno == EINTR)
				continue;
			perror("accept");
			exit(1);
		}
		
		if ((pid = fork()) < 0) {
			perror("fork");
			exit(1);
		} else if (pid == 0) {
			int n;
			char buf[READ_SIZE];
			int64_t data_rcvd = 0;
			struct timeval stime, etime;
			float time;
			
			gettimeofday(&stime, NULL);
			while ((n = read(newfd, buf, READ_SIZE)) > 0) {
				data_rcvd += n;
#ifdef RATELIMIT
				usleep(WAIT_TIME);
#endif
			}
 			gettimeofday(&etime, NULL);
			close(newfd);
			
			time = (float)(1000000*(etime.tv_sec - stime.tv_sec) + etime.tv_usec - stime.tv_usec) / 1000000.0;
			printf("Received %lld bytes in %f seconds\n", (long long)data_rcvd, time);
			printf("Throughput: %d B/s\n", (int)((float)data_rcvd / time));
			
			exit(0);
		}
		
		close(newfd);
	}
	
	return 1;
}

--------------020708060504080702080900
Content-Type: text/plain;
 name="tcpsend.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcpsend.c"

/*
 * tcpsend.c
 * Send pseudo-random data through a TCP connection.
 *
 * Copyright 2003 John Heffner.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/stat.h>
#ifdef __linux__
#include <sys/sendfile.h>
#endif

#define SNDSIZE	(1024 * 10)
#define BUFSIZE	(1024 * 1024)

#define max(a,b)	(a > b ? a : b)
#define min(a,b)	(a < b ? a : b)

int time_done = 0;
int interrupt_done = 0;

struct timeval starttime;

void int_handler(int sig)
{
	interrupt_done = 1;
}

void alarm_handler(int sig)
{
	time_done = 1;
}

static void usage_error(int err) {
	fprintf(stderr, "usage: tcpsend [-z] [-b max_bytes] [-t max_time] hostname [port]\n");
	exit(err);
}

static void cleanup_exit(int fd, char *filename, int status)
{
	if (fd > 0)
		close(fd);
	if (filename)
		unlink(filename);
	exit(status);
}

int main(int argc, char *argv[])
{
	char *hostname = "localhost";
	int port = 9000;
	int max_time = -1;
	int max_bytes = -1;
	int zerocopy = 0;
	
	int sockfd;
	struct sockaddr_in addr;
	struct hostent *hent;
	struct sigaction act;
	int i;
	int arg_state;
	char *tmp;
	int add;
	char *buf;
	int64_t data_sent;
	int n;
	off_t start;
	int amt;
	struct timeval etime;
	float time;
	int err;
	char *namebuf = NULL;
	int fd = -1;
	
	/* Read in args */
	if (argc == 2 && strcmp(argv[1], "-h") == 0)
		usage_error(0);
	
	for (arg_state = 0, i = 1; i < argc; i++) {
		if (argv[i][0] == '-') {
			if (arg_state != 0)
				usage_error(1);
			if (strlen(argv[i]) < 2)
				usage_error(1);
			
			add = 0;
			if (argv[i][1] == 'z') {
				zerocopy = 1;
			} else if (argv[i][1] == 'b' ||
			           argv[i][1] == 't') {
				if (strlen(argv[i]) > 2) {
					tmp = &(argv[i][2]);
				} else {
					add = 1;
					if (i + 1 >= argc)
						usage_error(1);
					tmp = argv[i + 1];
				}
				
				if (argv[i][1] == 'b') {
					if (sscanf(tmp, "%d", &max_bytes) != 1 ||
					    max_bytes < 0)
						usage_error(1);
				} else {
					if (sscanf(tmp, "%d", &max_time) != 1 ||
					    max_time < 0)
						usage_error(1);
				}
			} else {
				usage_error(1);
			}
			
			i += add;
		} else {
			switch (arg_state) {
			case 0:
				arg_state = 1;
				hostname = argv[i];
				break;
			case 1:
				arg_state = 2;
				if (sscanf(argv[i], "%d", &port) != 1 ||
				    port < 0 || port > 65535)
					usage_error(1);
				break;
			default:
				usage_error(1);
			}
		}
	}
	if (arg_state < 1)
		usage_error(1);
	
#ifndef __linux__
	if (zerocopy) {
		fprintf(stderr, "Zero-copy is only supported under Linux.\n");
		exit(1);
	}
#endif
	
	/* Set up addr struct from hostname and port */
	if ((hent = gethostbyname(hostname)) == NULL) {
		fprintf(stderr, "tcpsend: gethostbyname error\n");
		exit(1);
	}
	memset(&addr, 0, sizeof (addr));
	addr.sin_family = AF_INET;
	memcpy(&addr.sin_addr, hent->h_addr_list[0], 4);
	addr.sin_port = htons(port);
	
	
	/* Create buffer and fill with random data */
	if (gettimeofday(&starttime, NULL) < 0) {
		perror("gettimeofday");
		exit(1);
	}
	srand((unsigned int)(starttime.tv_usec + 1000000 * starttime.tv_sec));
	if ((buf = (char *)malloc(BUFSIZE)) == NULL) {
		fprintf(stderr, "malloc failed\n");
		exit(1);
	}
	for (i = 0; i < BUFSIZE; i += sizeof (int)) {
		*(int *)&buf[i] = rand();
	}
	if (zerocopy) {
		if ((namebuf = malloc(64)) == NULL) {
			fprintf(stderr, "malloc failed\n");
			exit(1);
		}
		sprintf(namebuf, "/tmp/tcpsend%d", getpid());
		if ((fd = open(namebuf, O_RDWR | O_CREAT, 0600)) < 0) {
			perror("open");
			exit(1);
		}
		for (amt = BUFSIZE; amt > 0; ) {
			if ((n = write(fd, buf, amt)) < 0) {
				perror("write");
				cleanup_exit(fd, namebuf, 1);
			}
			amt -= n;
		}
	}
	
	
	/* Open connection */
	if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		perror("socket");
		cleanup_exit(fd, namebuf, 1);
	}
	if (connect(sockfd, (struct sockaddr *)&addr, sizeof (addr)) != 0) {
		perror("connect");
		cleanup_exit(fd, namebuf, 1);
	}
	
	
	/* Set up signal handlers */
	if (max_time >= 0) {
		if (sigaction(SIGALRM, NULL, &act) != 0) {
			perror("sigaction: SIGALRM");
			cleanup_exit(fd, namebuf, 1);
		}
		act.sa_handler = alarm_handler;
		act.sa_flags = 0;
		if (sigaction(SIGALRM, &act, NULL) != 0) {
			perror("sigaction: SIGALRM");
			cleanup_exit(fd, namebuf, 1);
		}
		alarm(max_time);
	}
	if (sigaction(SIGINT, NULL, &act) != 0) {
		perror("sigaction: SIGINT");
		cleanup_exit(fd, namebuf, 1);
	}
	act.sa_handler = int_handler;
	act.sa_flags = 0;
	if (sigaction(SIGINT, &act, NULL) != 0) {
		perror("sigaction: SIGINT");
		cleanup_exit(fd, namebuf, 1);
	}
	
	
	/* Send random data until we hit a max */
	data_sent = 0;
	while ((max_bytes < 0 ? 1 : data_sent < max_bytes) &&
	       !time_done && !interrupt_done) {
		start = rand() / (RAND_MAX / (BUFSIZE - SNDSIZE) + 1);
		if (max_bytes < 0)
			amt = SNDSIZE;
		else
			amt = min(SNDSIZE, max_bytes - data_sent);
		if (zerocopy) {
#ifdef __linux__			
			if ((n = sendfile(sockfd, fd, &start, amt)) < 0 && errno != EINTR) {
				perror("sendfile");
				cleanup_exit(fd, namebuf, 1);
			} else if (n == 0) {
				fprintf(stderr, "tcpsend: socket unexpectedly closed\n");
				cleanup_exit(fd, namebuf, 1);
			}
#endif
		} else {
			if ((n = write(sockfd, &buf[start], amt)) < 0 && errno != EINTR) {
				perror("write");
				cleanup_exit(fd, namebuf, 1);
			} else if (n == 0) {
				fprintf(stderr, "tcpsend: socket unexpectedly closed\n");
				cleanup_exit(fd, namebuf, 1);
			}
		}
		
		data_sent += n;
	}
	
	/* Close the socket and wait for the remote host to close */
	if (shutdown(sockfd, SHUT_WR) != 0) {
		perror("shutdown");
		cleanup_exit(fd, namebuf, 1);
	}
	err = read(sockfd, buf, 1);
	if (err < 0) {
		perror("read");
		cleanup_exit(fd, namebuf, 1);
	} else if (err > 0) {
		fprintf(stderr, "warning: data read on socket\n");
	}
	
	gettimeofday(&etime, NULL);
	time = (float)(1000000*(etime.tv_sec - starttime.tv_sec) +
	       etime.tv_usec - starttime.tv_usec) / 1000000.0;
	printf("Sent %lld bytes in %f seconds\n", (long long)data_sent, time);
	printf("Throughput: %d B/s\n", (int)((float)data_sent / time));
	
	cleanup_exit(fd, namebuf, 0);
	return 0;
}

--------------020708060504080702080900
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="Makefile"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Makefile"

CFLAGS = -g -O2 -Wall

all: tcpsend discard

clean:
	rm -f tcpsend discard

--------------020708060504080702080900--
