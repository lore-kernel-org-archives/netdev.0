From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Re: [PATCH] connect() return value.
Date: Wed, 14 Aug 2002 09:51:03 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020813235103.GA28432@anakin.wychk.org>
References: <20020813143246.GA20943@anakin.wychk.org> <200208131528.TAA21381@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208131528.TAA21381@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=big5
Content-Disposition: inline

On Tue, Aug 13, 2002 at 07:28:41PM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > First off,
> et al.
> 
> Great, I think we will change this too.
> 


What are you intending to change? :-) connect behaivor or read behavior?


> Could you repeat that test with read() after incomplete connect?
> That your test was apparently invalid because of the same errno mistake,
> so results may be different. Only, please, use read() with non-zero length.
> 


Sure.
(though I don't think it should matter since with connect() the test
was bogus because I forgot to reset errno everytime I went through
the loop).

I will test for write as well, because read and write should be
consistent with each other.

Again, I will be attaching the programs that I used for this test.

In this mail:

connect-read.c (test for 0 length read)
connect-write.c (test for 0 length write)

Both are modified versions of the original connect.c.


Tested operating systems:


SunOS 5.6
OSF1 4.0
Linux 2.4.18


In this test we will be using the programs to connect to a open TCP
port on a host. We connect to a host on the WAN in an attempt to
maximize the connect process.

First we create a socket and we set it to non-blocking. We connect once,
and test for an errno of EINPROGRESS (expected). We set the errno value
to 0, to guarantee that should read / write return an error it is from
the read / write call. After that, we then we issue a 0 length
read / write, and test for an error. Finally, we issue a second connect,
to make sure that we get an EALREADY for errno, to make sure that the 3 way
handshake is not complete and we indeed tried to write to / read from
a in-progress socket.



SunOS 5.6

We find the errno after the first connect is indeed EINPROGRESS. A 
read with 0 length returns -1, with an errno of 134. That corresponds
to ENOTCONN on Solaris. The second connect returns EALREADY, and we
are sure that the 3 way handshake is not complete.

Similarly for write, when we issue a zero-length write, we find write
returns -1 with an errno of 134 (ENOTCONN).



OSF1 4.0


We find that we get a expected EINPROGRESS after the first connect.
For read, it returns 0. On the second connect, it returns EALREADY.

It is interesting to note that on OSF1 4.0, write returns an errno
of 57 (ENOTCONN). Behavior is not consistent with their socket read
and write. We have found a bug in Digital UNIX.


Linux 2.4.18

We find that we indeed get a EINPROGRESS after the first connected.
After a read, we find that read returns 0. On second connect, it
returns an error with errno set to EALREADY.

Similarly for write, when we issue a zero-length write, we find
write returns 0.


So to summarize:

To write portably to test for a connected socket, you can:

* use connect, but be prepared to handle an errno of 0 from Linux;
* handle the differences between read / write. In particular Digital
  UNIX has the extremely unsocial behaivor of returning something
  totally different with read and write.
* Use getpeername. We expect ENOTCONN if it is not completed, or
  some error occurred. Another implementation detail: OSF1 4.0
  and Solaris require getpeername's second argument to be valid, or
  -EBADF will be returned. Linux does not require this and returns
  -ENOTCONN even if the second argument is NULL. SunOS 5.6 and OSF1 4.0
  both return -ENOTCONN if you run getpeername with a non-NULL second
  argument.


  i.e.
  getpeername(fd, NULL, NULL) --> ok on linux, not ok on OSF1/SunOS
  getpeername(fd, &peeraddr, NULL) --> ok on all



Non-blocking sockets is as non-portable as it can be. :-)


  
	-- G.
  



	-- G.
	

--rwEMma7ioTxnRzrJ
Content-Type: text/x-csrc; charset=big5
Content-Disposition: attachment; filename="connect-read.c"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <netinet/in.h>


extern char *optarg;

#define HOST "192.168.0.1"
#define PORT 0

void handler(int);

int main(int argc, char **argv)
{
	struct sockaddr_in saddr;
	int ret;
	int fd;
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
				host = (char *)strdup(optarg);
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



	ret = connect(fd, (struct sockaddr *)&saddr, 
			sizeof(struct sockaddr_in));

	if (ret < 0) {
		if (errno == EINPROGRESS) {
			printf("connect: EINPROGRESS (expected)\n");
		} else {
			printf("unexpected errno from connect, errno = %d"
			    " msg = %s\n", errno, strerror(errno));
		}
	}

	/* make sure errno is 0 */
	errno = 0;

	val = read(fd, buf, 0);
		printf("read() returns %d, errno = %d, msg = %s\n", 
			val, errno, (val < 0) ? strerror(errno) : "");

	errno = 0;
	ret = connect(fd, (struct sockaddr *)&saddr,
		sizeof(struct sockaddr_in));

	printf("connect returns %d, err = %s\n", ret, strerror(errno));

	close(fd);

	exit(0);
}

--rwEMma7ioTxnRzrJ
Content-Type: text/x-csrc; charset=big5
Content-Disposition: attachment; filename="connect-write.c"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <netinet/in.h>


extern char *optarg;

#define HOST "192.168.0.1"
#define PORT 0

void handler(int);

int main(int argc, char **argv)
{
	struct sockaddr_in saddr;
	int ret;
	int fd;
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
				host = (char *)strdup(optarg);
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


	ret = connect(fd, (struct sockaddr *)&saddr, 
			sizeof(struct sockaddr_in));


	if (ret < 0) {
                if (errno == EINPROGRESS) {
                        printf("connect: EINPROGRESS (expected)\n");
                } else {
                        printf("unexpected errno from connect, errno = %d"
                            " msg = %s\n", errno, strerror(errno));
                }
        }

        /* make sure errno is 0 */
        errno = 0;

	val = write(fd, "1", 0);
		printf("write() returns %d, errno = %d, msg = %s\n", 
			val, errno, (val < 0) ? strerror(errno) : "");

	errno = 0;

	ret = connect(fd, (struct sockaddr *)&saddr,
		sizeof(struct sockaddr_in));

	printf("connect returns %d, err = %s\n", ret, strerror(errno));

	close(fd);

	exit(0);
}

--rwEMma7ioTxnRzrJ--
