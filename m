From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 0/6 net-next][V3] Rework inet_csk_get_port
Date: Wed, 11 Jan 2017 15:06:05 -0500
Message-ID: <1484165171-19210-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37757 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751810AbdAKUG3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 15:06:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry the holidays delayed this a bit.  I've made the changes requested and I
also sat down and wrote a reproducer so everybody could see what was happening.
Without my patches my reproducer takes about 50 seconds to run on my 48 CPU
devel box.  With my patches it takes 8 seconds.

V2->V3:
-Dropped the fastsock from the tb and instead just carry the saddrs, family, and
 ipv6 only flag.
-Reworked the helper functions to deal with this change so I could still use
 them when checking the fast path.
-Killed tb->num_owners as per Eric's request.
-Attached a reproducer to the bottom of this email.

V1->V2:
-Added a new patch 'inet: collapse ipv4/v6 rcv_saddr_equal functions into one'
 at Hannes' suggestion.
-Dropped ->bind_conflict and just use the new helper.
-Fixed a compile bug from the original ->bind_conflict patch.

The original description of the series follows

=========================================================

At some point recently the guys working on our load balancer added the ability
to use SO_REUSEPORT.  When they restarted their app with this option enabled
they immediately hit a softlockup on what appeared to be the
inet_bind_bucket->lock.  Eventually what all of our debugging and discussion led
us to was the fact that the application comes up without SO_REUSEPORT, shuts
down which creates around 100k twsk's, and then comes up and tries to open a
bunch of sockets using SO_REUSEPORT, which meant traversing the inet_bind_bucket
owners list under the lock.  Since this lock is needed for dealing with the
twsk's and basically anything else related to connections we would softlockup,
and sometimes not ever recover.

To solve this problem I did what you see in Path 5/5.  Once we have a
SO_REUSEPORT socket on the tb->owners list we know that the socket has no
conflicts with any of the other sockets on that list.  So we can add a copy of
the sock_common (really all we need is the recv_saddr but it seemed ugly to copy
just the ipv6, ipv4, and flag to indicate if we were ipv6 only in there so I've
copied the whole common) in order to check subsequent SO_REUSEPORT sockets.  If
they match the previous one then we can skip the expensive
inet_csk_bind_conflict check.  This is what eliminated the soft lockup that we
were seeing.

Patches 1-4 are cleanups and re-workings.  For instance when we specify port ==
0 we need to find an open port, but we would do two passes through
inet_csk_bind_conflict every time we found a possible port.  We would also keep
track of the smallest_port value in order to try and use it if we found no
port our first run through.  This however made no sense as it would have had to
fail the first pass through inet_csk_bind_conflict, so would not actually pass
the second pass through either.  Finally I split the function into two functions
in order to make it easier to read and to distinguish between the two behaviors.

I have tested this on one of our load balancing boxes during peak traffic and it
hasn't fallen over.  But this is not my area, so obviously feel free to point
out where I'm being stupid and I'll get it fixed up and retested.  Thanks,

Josef


#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <sys/un.h>
#include <errno.h>
#include <netdb.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

static int ready = 0;
static int done = 0;

static void sigint_handler(int s)
{
	ready = 1;
}

static int create_sock(int socktype, int soreuseport)
{
	struct addrinfo hints;
	struct addrinfo *ai, *ai_orig;
	const char *addrs[] = {"::", "0.0.0.0", NULL};
	const char *port = "9999";
	int sock;
	int num_socks = 0;
	int i, ret;

	memset(&hints, 0, sizeof(hints));
	hints.ai_flags = AI_PASSIVE | AI_ADDRCONFIG;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_family = (socktype == 0) ? AF_INET6 : AF_INET;
	hints.ai_protocol = IPPROTO_TCP;
	ret = getaddrinfo(addrs[socktype], port, &hints, &ai);
	if (ret < 0) {
		fprintf(stderr, "couldn't get addr info %d\n", errno);
		return -1;
	}
	ai_orig = ai;
	while (ai != NULL) {
		int yes = 1;
		sock = socket(ai->ai_family, ai->ai_socktype,
			      ai->ai_protocol);
		if (sock < 0) {
			fprintf(stderr, "socket failed %d\n", errno);
			goto next;
		}
		if (soreuseport) {
			if (setsockopt(sock, SOL_SOCKET, SO_REUSEPORT, &yes,
				       sizeof(yes)) < 0) {
				fprintf(stderr, "setsockopt failed %d\n", errno);
				close(sock);
				goto next;
			}
		}
		if (bind(sock, ai->ai_addr, ai->ai_addrlen)) {
			fprintf(stderr, "bind failed %d\n", errno);
			close(sock);
			goto next;
		}
		if (listen(sock, 1024) < 0) {
			fprintf(stderr, "listen failed %d\n", errno);
			close(sock);
			goto next;
		}
		num_socks++;
		break;
next:
		ai = ai->ai_next;
	}
	freeaddrinfo(ai_orig);

	if (!num_socks) {
		fprintf(stderr, "failed to open any sockets\n");
		return -1;
	}
	return sock;
}

#define SOCK_PATH "THIS_SHIT_IS_FUCKING_INSANE"
#define TAKEOVER_REQUEST	1
#define CLOSE_REQUEST		2

static int *takeover_sockets(int *num_fds_ret)
{
	struct sockaddr_un remote;
	struct msghdr msg = {};
	struct cmsghdr *cmsg;
	struct iovec iov;
	int *fds;
	int req, num_fds, fd, i, len;
	char *buf;

	*num_fds_ret = 0;

	if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
		fprintf(stderr, "Couldn't open our unix sock\n");
		return NULL;
	}

	remote.sun_family = AF_UNIX;
	strcpy(remote.sun_path, SOCK_PATH);
	len = strlen(remote.sun_path) + sizeof(remote.sun_family);
	if (connect(fd, (struct sockaddr *)&remote, len) < 0) {
		fprintf(stderr, "Couldn't connect, %d\n", errno);
		close(fd);
		return NULL;
	}

	req = TAKEOVER_REQUEST;
	if (send(fd, &req, sizeof(req), 0) < 0) {
		fprintf(stderr, "Couldn't send our request, %d\n", errno);
		close(fd);
		return NULL;
	}

	buf = malloc(CMSG_SPACE(sizeof(int) * 32));
	if (!buf) {
		fprintf(stderr, "Failed to allocate cmsg buffer\n");
		free(fds);
		close(fd);
		return NULL;
	}

	iov.iov_base = &num_fds;
	iov.iov_len = sizeof(num_fds);

	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;
	msg.msg_control = buf;
	msg.msg_controllen = CMSG_SPACE(sizeof(int) * 1);
	if (recvmsg(fd, &msg, 0) < 0) {
		fprintf(stderr, "Couldn't get our array of fd's, %d\n", errno);
		free(fds);
		close(fd);
		return NULL;
	}

	fds = malloc(sizeof(int) * num_fds);
	if (!fds) {
		fprintf(stderr, "Couldn't allocate an array for %d fd's\n", num_fds);
		close(fd);
		return NULL;
	}

	for (cmsg = CMSG_FIRSTHDR(&msg); cmsg != NULL; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
		int *fdsptr = (int *)CMSG_DATA(cmsg);
		for (i = 0; i < num_fds; i++) {
			int newfd = fdsptr[i];
			int yes = 1;
			if (newfd < 0) {
				fprintf(stderr, "Couldn't dup the old socket, %d\n", errno);
				close(fd);
				num_fds = i;
				break;
			}
			if (setsockopt(newfd, SOL_SOCKET, SO_REUSEPORT, &yes,
				       sizeof(yes)) < 0) {
				fprintf(stderr, "setsockopt failed on taken over socket %d\n",
					errno);
				close(newfd);
				close(fd);
				break;
			}
			fds[i] = newfd;
		}
	}
	req = CLOSE_REQUEST;
	if (send(fd, &req, sizeof(req), 0) < 0)
		fprintf(stderr, "Couldn't send the close request, %d\n", errno);

	close(fd);
	*num_fds_ret = num_fds;
	return fds;
}

static int listen_for_takeover(pid_t child, int *fds, int num_fds)
{
	struct sockaddr_un local, remote;
	int sock, len;

	if ((sock = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
		fprintf(stderr, "Couldn't open unix sock %d\n", errno);
		kill(child, SIGINT);
		return -1;
	}

	local.sun_family = AF_UNIX;
	strcpy(local.sun_path, SOCK_PATH);
	unlink(local.sun_path);
	len = strlen(local.sun_path) + sizeof(local.sun_family);
	if (bind(sock, (struct sockaddr *)&local, len) < 0) {
		fprintf(stderr, "Couldn't bind to unix sock %d\n", errno);
		kill(child, SIGINT);
		return -1;
	}

	if (listen(sock, 1) < 0) {
		fprintf(stderr, "Couldn't listen on unix sock %d\n", errno);
		kill(child, SIGINT);
		return -1;
	}

	kill(child, SIGINT);
	while (!done) {
		int newsock, req, len = sizeof(remote);

		if ((newsock = accept(sock, (struct sockaddr *)&remote,
				      &len)) < 0) {
			fprintf(stderr, "Couldn't accept connection %d\n", errno);
			return -1;
		}
		while (recv(newsock, &req, sizeof(req), 0) > 0) {
			if (req == TAKEOVER_REQUEST) {
				struct msghdr msg = {};
				struct cmsghdr *cmsg;
				struct iovec iov = {.iov_base = &num_fds, .iov_len = sizeof(num_fds), };
				char *buf;
				int *fdptr;

				buf = malloc(CMSG_SPACE(sizeof(int) * num_fds));
				if (!buf) {
					fprintf(stderr, "Couldn't allocate cmsg buf\n");
					return -1;
				}
				msg.msg_iov = &iov;
				msg.msg_iovlen = 1;
				msg.msg_control = buf;
				msg.msg_controllen = CMSG_SPACE(sizeof(int) * num_fds);
				cmsg = CMSG_FIRSTHDR(&msg);
				cmsg->cmsg_level = SOL_SOCKET;
				cmsg->cmsg_type = SCM_RIGHTS;
				cmsg->cmsg_len = CMSG_LEN(sizeof(int) * num_fds);
				fdptr = (int *)CMSG_DATA(cmsg);
				memcpy(fdptr, fds, num_fds * sizeof(int));
				msg.msg_controllen = cmsg->cmsg_len;
				if (sendmsg(newsock, &msg, 0) < 0) {
					fprintf(stderr, "Failed to send fds %d\n", errno);
					return -1;
				}
			} else if (req == CLOSE_REQUEST) {
				break;
			}
		}
		done = 1;
	}
	return 0;
}

static void *thread_main(void *arg)
{
	int i;

	for (i = 0; i < 256; i++) {
		int fd = create_sock(0, 1);
		if (fd < 0)
			return (void *)(unsigned long)fd;
	}
	return NULL;
}

static int do_spawn_threads(int num_threads)
{
	struct sigaction sa;
	pthread_t *threads;
	int *fds;
	int num_fds;
	int error = 0;
	int i;

	threads = calloc(sizeof(pthread_t), num_threads);
	if (!threads) {
		fprintf(stderr, "Not enough memory\n");
		return -1;
	}

	sa.sa_handler = sigint_handler;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_RESTART;
	if (sigaction(SIGINT, &sa, NULL) < 0) {
		fprintf(stderr, "Couldn't set our sigaction\n");
		return -1;
	}

	while (!ready)
		sleep(1);

	fds = takeover_sockets(&num_fds);

	printf("Starting new threads\n");
	for (i = 0; i < num_threads; i++) {
		if (pthread_create(&threads[i], NULL, thread_main, NULL) < 0) {
			done = 1;
			break;
		}
	}

	while (i--) {
		void *retval;
		pthread_join(threads[i], &retval);
		if ((unsigned long)retval != 0)
			error = (int)(unsigned long)retval;
	}
	return error;
}

int main(int argc, char **argv)
{
	int *fds;
	int num_fds;
	pthread_t *threads;
	unsigned long i;
	int ret = -1;
	int childstatus;
	pid_t child;

	child = fork();
	if (child < 0) {
		fprintf(stderr, "Failed to create child! %d\n", errno);
		return -1;
	}

	if (!child) {
		return do_spawn_threads(64);
	}

	fds = malloc(sizeof(int));
	if (!fds) {
		kill(child, SIGINT);
		goto out;
	}

	fds[0] = create_sock(0, 0);
	if (fds[0] < 0) {
		free(fds);
		kill(child, SIGINT);
		fprintf(stderr, "Couldn't create a socket\n");
		goto out;
	}
	ret = listen_for_takeover(child, fds, 1);
out:
	waitpid(child, &childstatus, 0);
	if (!ret)
		ret = WEXITSTATUS(childstatus);
	return ret;
}
