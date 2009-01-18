From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: 2.6.27.9: splice_to_pipe() hung (blocked for more than 120 seconds)
Date: Sun, 18 Jan 2009 15:10:01 +0100
Message-ID: <19f34abd0901180610k430a3e4bpe18af036357ca642@mail.gmail.com>
References: <19f34abd0901161055l2edd9274n4b2d8c93e7760488@mail.gmail.com>
	 <4970F2B6.1060508@cosmosbay.com>
	 <19f34abd0901180412w39d70ccqd0c10698bc70e6e9@mail.gmail.com>
	 <19f34abd0901180544g617b29c1nc41c760f8803de0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:35884 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760617AbZAROKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 09:10:03 -0500
In-Reply-To: <19f34abd0901180544g617b29c1nc41c760f8803de0e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 2:44 PM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
> So in short: Is it possible that inode_double_lock() in
> splice_from_pipe() first locks the pipe mutex, THEN locks the
> file/socket mutex? In that case, there should be a lock imbalance,
> because pipe_wait() would unlock the pipe while the file/socket mutex
> is held.
>
> That would possibly explain the sporadicity of the lockup; it depends
> on the actual order of the double lock.
>
> Why doesn't lockdep report that? Hm. I guess it is because these are
> both inode mutexes and lockdep can't detect a locking imbalance within
> the same lock class?
>
> Anyway, that's just a theory. :-) Will try to confirm by simplifying
> the test-case.

Hm, I do believe this _is_ evidence in favour of the theory:

top - 09:03:57 up  2:16,  2 users,  load average: 129.27, 49.28, 21.57
Tasks: 161 total,   1 running,  95 sleeping,   1 stopped,  64 zombie

:-)

#define _GNU_SOURCE

#include <sys/socket.h>
#include <sys/types.h>

#include <fcntl.h>
#include <errno.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int sock_fd[2];
static int pipe_fd[2];

#define N 16384

static void *do_write(void *unused)
{
	unsigned int i;

	for (i = 0; i < N; ++i)
		write(pipe_fd[1], "x", 1);

	return NULL;
}

static void *do_read(void *unused)
{
	unsigned int i;
	char c;

	for (i = 0; i < N; ++i)
		read(sock_fd[0], &c, 1);

	return NULL;
}

static void *do_splice(void *unused)
{
	unsigned int i;

	for (i = 0; i < N; ++i)
		splice(pipe_fd[0], NULL, sock_fd[1], NULL, 1, 0);

	return NULL;
}

int main(int argc, char *argv[])
{
	pthread_t writer;
	pthread_t reader;
	pthread_t splicer[2];

	while (1) {
		if (socketpair(AF_UNIX, SOCK_STREAM, 0, sock_fd) == -1)
			exit(EXIT_FAILURE);

		if (pipe(pipe_fd) == -1)
			exit(EXIT_FAILURE);

		pthread_create(&writer, NULL, &do_write, NULL);
		pthread_create(&reader, NULL, &do_read, NULL);
		pthread_create(&splicer[0], NULL, &do_splice, NULL);
		pthread_create(&splicer[1], NULL, &do_splice, NULL);

		pthread_join(writer, NULL);
		pthread_join(reader, NULL);
		pthread_join(splicer[0], NULL);
		pthread_join(splicer[1], NULL);

		printf("failed to deadlock, retrying...\n");
	}

	return EXIT_SUCCESS;
}

$ gcc splice.c -lpthread
$ ./a.out &
$ ./a.out &
$ ./a.out &
(as many as you want; then wait for a bit -- ten seconds works for me)
$ killall -9 a.out
(not all will die -- those are now zombies)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
