From: Brent Casavant <bcasavan@sgi.com>
Subject: AF_UNIX MSG_PEEK bug?
Date: Tue, 8 Jan 2008 16:27:50 -0600 (CST)
Message-ID: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:54884 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751343AbYAHW1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 17:27:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was coding an application which passes variable-length messages
over an AF_UNIX SOCK_STREAM socket.  As such I would pass a message
length embedded as the first element in the message, use recv(...,MSG_PEEK)
to determine the message length, and perform the necessary allocation
on the receiving end before performing the real recv().

However, the program would occasionally get into a situation where
a call to recv(sockfd, &buf, len, MSG_PEEK) returns some number
of bytes less than the requested length, and persists in this state
(i.e. retrying the call continues to return the same amount of data)
even when more than sufficient data is known to have been successfully
written to the socket.

By my reading of the af_unix.c kernel code, I believe the problem lies in
unix_stream_recvmsg().  Here we find that, under MSG_PEEK, only a single
skb is pulled from the receive queue and the data copied into the user
buffer.  This fails to account for the fact that this skb could contain less
data than is necessary to satisfy the MSG_PEEK request.  The "short" skb
is then pushed back onto the queue, and thus a retried MSG_PEEK will again
return a short response.  The only way to clear this condition is to
perform a recv() without specifying MSG_PEEK.

I'll be happy to submit a patch to fix this, but would like to first
confirm with others that A) this is incorrect behavior for MSG_PEEK
semantics and B) my approach to the fix sounds reasonable.

What I propose as a fix is, for MSG_PEEK operations, dequeueing enough
skbs to satisfy the operation (checking of course that there is enough
data in the queue in the first place), copying out the requested data
to the user buffer, then pushing those skbs back onto the receive queue.

I'm not terribly familiar with the Linux networking code, so if the
above approach sounds misguided, please feel free to let me know.

Below you'll find an example program (not the real program, I know
there's some no-nos in here, this was written simply to demonstrate
the bug) that demonstrates the problem.  It fails quite reliably and
quickly on an SGI Altix IA64, though given the nature of the problem I
don't believe it's architecture-specific.  Running the program with
no arguments produces output similar to the following:

consumer: recv of message size is not progressing at time 1199829455094356.
consumer: want 8 bytes, but only receiving 5.
consumer: SIOCOUTQ=0, SIOCINQ=202421
consumer: had 36985 successes
producer: sendmsg failed at time 1199829455094571

The meaning of the first two lines is obvious (UNIX time in microseconds).
The third line gives the output and input queue lengths for the AF_UNIX
socket at the time of the error message, to confirm that there is indeed
sufficient data available for satisfying the MSG_PEEK operation.  The
fourth line details how many iterations of the main loop of the program
were successful until we got hung up on the MSG_PEEK.  The final line
simply confirms that the producer failed as a result of the consumer
closing the socket, not the other way around.

Thanks,
Brent Casavant

#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/un.h>

#include <linux/sockios.h>

#define SOCKNAME "/tmp/peektest.sock"
#define MAXLEN 2048
#define NUMMSG 64
#define ERRLOOPS 50000

struct sockmsg {
	size_t length;
	char payload[MAXLEN];
};

struct sockmsg messages[NUMMSG];
struct iovec iov[NUMMSG];

void
do_consumer(char *socketname) {
	struct stat sb;
	int status;
	int sockfd, fd;
	struct sockaddr_un su;
	ssize_t bytes;
	struct msghdr msg = { .msg_name = NULL, .msg_namelen = 0,
			      .msg_iov = iov, .msg_iovlen = 1,
			      .msg_control = NULL, .msg_controllen = 0,
			      .msg_flags = 0 };
	int successes = 0;

	/* Wait for socket to become available */
	do {
		sleep(1);
		status = stat(socketname, &sb);
	} while ((status < 0) && (ENOENT == errno));
	if ((status < 0) && (ENOENT != errno)) {
		printf("consumer: stat failed\n");
		return;
	}
	if (!S_ISSOCK(sb.st_mode)) {
		printf("consumer: %s is not a socket\n", socketname);
		return;
	}

	/* Connect to the producer */
	sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (sockfd < 0) {
		printf("consumer: socket() failed\n");
		return;
	}
	su.sun_family = PF_UNIX;
	strcpy(su.sun_path, socketname);
	if (connect(sockfd, (struct sockaddr*) &su, SUN_LEN(&su)) < 0) {
		printf("consumer: connect() failed\n");
		return;
	}

	/* Main loop here.  Inspect the first size_t in the incoming
	 * message to determine the message length.  Then read in
	 * the entire message.
	 */
	do {
		size_t msglen;
		int loops;

		/* XXX: Here's where the trouble occurs. Even though the
		 * socket gets filled up quite plentifully by the producer,
		 * the recv(..., MSG_PEEK) operation eventually will get
		 * stuck returning less bytes than requested and never
		 * return any more.
		 * Note that including or not MSG_WAITALL in the flags
		 * makes no difference.
		 */
		/* Get length of next message */
		loops = 0;
		do {
			int outq, inq;
			bytes = recv(sockfd, &msglen, sizeof(size_t),
							MSG_PEEK|MSG_WAITALL);
			if (loops++ > ERRLOOPS) {
				struct timeval tv;
				gettimeofday(&tv, NULL);
				printf("consumer: recv of message size is "
				       "not progressing at time %ld.\n",
				       tv.tv_sec*1000000 + tv.tv_usec);
				printf("consumer: want %d bytes, but only "
				       "receiving %d.\n", sizeof(size_t),
				       bytes);
				ioctl(sockfd, SIOCOUTQ, &outq);
				ioctl(sockfd, SIOCINQ, &inq);
				printf("consumer: SIOCOUTQ=%d, SIOCINQ=%d\n",
				       outq, inq);
				printf("consumer: had %d successes\n",
				       successes);
				return;
			}
			/* Just in case, give the producer a little time to
			 * fill the queue if we're not making progress.
			 */
			if ((bytes < sizeof(size_t)) && (0 == (loops % 10000)))
				sleep(1);
		} while (bytes < sizeof(size_t));

		/* Receive the message */
		iov[0].iov_len = msglen;
		bytes = recvmsg(sockfd, &msg, MSG_WAITALL);
		if (bytes < 0) {
			printf("consumer: recvmsg failed\n");
			return;
		} else if (bytes != msglen) {
			printf("consumer: short recvmsg\n");
			return;
		}
		/* Discard what we receive, we don't really care
		 * about it.
		 */
		successes++;
	} while(1);
}

void
do_producer(char *socketname) {
	int sockfd, fd;
	struct sockaddr_un su;
	struct msghdr msg = { .msg_name = NULL, .msg_namelen = 0,
			      .msg_iov = iov, .msg_iovlen = NUMMSG,
			      .msg_control = NULL, .msg_controllen = 0,
			      .msg_flags = 0 };
	ssize_t sent;

	/* Remove any leftover socket with each run */
	unlink(SOCKNAME);

	/* Create/bind/listen/accept socket */
	sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (sockfd < 0) {
		printf("producer: socket() failed\n");
		return;
	}
	su.sun_family = PF_UNIX;
	strcpy(su.sun_path, socketname);
	if (bind(sockfd, (struct sockaddr*) &su, SUN_LEN(&su)) < 0) {
		printf("producer: bind() failed\n");
		return;
	}
	if (listen(sockfd, 5) < 0) {
		printf("producer: listen() failed\n");
		return;
	}
	while ((fd = accept(sockfd, NULL, 0)) < 0)
		printf("producer: accept() failed\n");

	/* Don't leave it laying around when we exit */
	unlink(SOCKNAME);

	/* Main loop here.  Set message lengths, and send them over the
	 * socket.
	 */
	srand(getpid());
	do {
		int i;
		size_t tosend;
		struct timeval tv;

		/* Set up each IOV/message */
		tosend = 0;
		for (i = 0; i < msg.msg_iovlen; i++) {
			/* Send random lengths of data */
			messages[i].length =
					(rand() % MAXLEN) + sizeof(size_t);
			iov[i].iov_len = messages[i].length;
			tosend += messages[i].length;
		}

		/* Send the message */
		sent = sendmsg(fd, &msg, MSG_NOSIGNAL);
		if (sent < 0) {
			gettimeofday(&tv, NULL);
			printf("producer: sendmsg failed at time %ld\n",
			       tv.tv_sec*1000000 + tv.tv_usec);
			return;
		}
		if (sent < tosend) {
			gettimeofday(&tv, NULL);
			printf("producer: short sendmsg at time %ld\n",
			       tv.tv_sec*1000000 + tv.tv_usec);
			return;
		}
	} while(1);
}

int
main(int argc, char *argv[]) {
	pid_t pid;
	int i;

	/* Initialize messages and IOVs */
	for (i = 0; i < NUMMSG; i++) {
		memset(&messages[i], 0, sizeof(struct sockmsg));
		iov[i].iov_base = &messages[i];
		iov[i].iov_len = sizeof(struct sockmsg);
	}

	/* With no arguments, start both producer and consumer */
	if (argc < 2) {
		if ((pid = fork()) < 0) {
			printf("Problem with fork\n");
			return 1;
		} else if (0 == pid)
			do_producer(SOCKNAME);
		else
			do_consumer(SOCKNAME);
		return 0;
	}

	/* Otherwise start the specified role */
	if (0 == strcmp(argv[1], "producer"))
		do_producer(SOCKNAME);
	else if (0 == strcmp(argv[1], "consumer"))
		do_consumer(SOCKNAME);
	else {
		printf("Error: Must specify \"producer\" or \"consumer\" "
		       "on command line.\n");
		return 1;
	}

	return 0;
}

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
