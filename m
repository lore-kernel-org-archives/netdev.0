From: Eric Wong <normalperson@yhbt.net>
Subject: splice() giving unexpected EOF in 3.7.3 and 3.8-rc4+
Date: Sat, 19 Jan 2013 04:49:57 +0000
Message-ID: <20130119044957.GA25395@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, Willy Tarreau <w@1wt.eu>
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the following flow, I'm sometimes getting an unexpected EOF on the
pipe reader even though I never close the pipe writer:

  tcp_wr -write-> tcp_rd -splice-> pipe_wr -> pipe_rd -splice-> /dev/null

I encounter this in in 3.7.3, 3.8-rc3, and the latest from Linus
3.8-rc4+(5da1f88b8b727dc3a66c52d4513e871be6d43d19)

It takes longer (about 20s) to reproduce this issue on my KVM (2 cores)
running the latest Linus kernel, so maybe real/faster hardware is needed.
My dual-core laptop (on 3.7.3) which hosts the VM does encounter this
issue within a few seconds (or even <1s).

Using schedtool to pin to a single core (any CPU core) on real hardware
seems to avoid this issue on real hardware.  Not sure how KVM uses CPUs,
but schedtool doesn't help inside my VM (not even schedtool on the KVM
process).

Example code below (and via: git clone git://bogomips.org/spliceeof )

Expected outout from ./spliceeof:
	done writing
	splice(in) EOF (expected)

Output I get from ./spliceeof:
	splice(out) EOF (UNEXPECTED)
	in left: 47716 # the byte value varies

I've successfully run similar code within the past year on some 3.x
kernels, so I think this issue is fairly recent (Cc-ing folks who
have touched splice lately).

Any likely candidates before I start bisection?  Thanks for reading.

-------------------------------- 8< ------------------------------
#define _GNU_SOURCE
#include <poll.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>
#include <limits.h>
#include <sys/times.h>

static void tcp_socketpair(int sv[2], int accept_flags)
{
	struct sockaddr_in addr;
	socklen_t addrlen = sizeof(addr);
	int l = socket(PF_INET, SOCK_STREAM, 0);
	int c = socket(PF_INET, SOCK_STREAM, 0);
	int a;

	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = INADDR_ANY;
	addr.sin_port = 0;
	assert(0 == bind(l, (struct sockaddr*)&addr, addrlen));
	assert(0 == listen(l, 5));
	assert(0 == getsockname(l, (struct sockaddr *)&addr, &addrlen));
	assert(0 == connect(c, (struct sockaddr *)&addr, addrlen));
	a = accept4(l, NULL, NULL, accept_flags);
	assert(a >= 0);
	close(l);
	sv[0] = a;
	sv[1] = c;
}

static void * write_loop(void * fdp)
{
	int fd = *(int *)fdp;
	char buf[16384];
	ssize_t w;
	size_t want = ULONG_MAX; /* try changing this around */

	while (want > 0) {
		size_t to_write = want > sizeof(buf) ? sizeof(buf) : want;

		w = write(fd, buf, to_write);

		if (w < 0) {
			dprintf(2, "write returned zero with %zu left\n", want);
			goto fail;
		} else if (w == 0) {
			dprintf(2, "write failed: %m with %zu left\n", want);
			goto fail;
		} else {
			want -= (size_t)w;
		}
	}
	dprintf(2, "done writing\n");
fail:
	close(fd);
	return NULL;
}

static void io_wait(int fd, short events)
{
	struct pollfd p;
	int rc;

	p.fd = fd;
	p.events = events;

	rc = poll(&p, 1, -1);
	assert(rc == 1 && "poll failed");
}

int main(void)
{
	int tcp_pair[2];
	int pbuf[2];
	pthread_t wt;
	int dst = open("/dev/null", O_WRONLY);
	size_t len = 1024 * 1024;
	ssize_t in, out;
	size_t in_total = 0;
	size_t out_total = 0;
	int fl = SPLICE_F_NONBLOCK;

	assert(dst >= 0 && "open(/dev/null) failed");
	tcp_socketpair(tcp_pair, SOCK_NONBLOCK);
	assert(0 == pthread_create(&wt, NULL, write_loop, &tcp_pair[1]));
	assert(0 == pipe2(pbuf, O_NONBLOCK));

	for (;;) {
		in = splice(tcp_pair[0], NULL, pbuf[1], NULL, len, fl);

		if (in < 0) {
			if (errno == EAGAIN) {
				io_wait(tcp_pair[0], POLLIN);
				io_wait(pbuf[1], POLLOUT);
				continue;
			}
			dprintf(2, "splice(in) err: %m\n");
			break;
		} else if (in == 0) {
			dprintf(2, "splice(in) EOF (expected)\n");
			break;
		}

		in_total += in;
		while (in > 0) {
			out = splice(pbuf[0], NULL, dst, NULL, (size_t)in, fl);
			if (out < 0) {
				dprintf(2, "splice(out) err: %m\n");
				exit(1);
			} else if (out == 0) {
				dprintf(2, "splice(out) EOF (UNEXPECTED)\n");
				dprintf(2, "in left: %zd\n", in);
				exit(1);
			} else {
				in -= out;
				out_total += out;
			}
		}
	}
	assert(0 == pthread_join(wt, NULL));
	return 0;
}
-------------------------------- 8< ------------------------------
