From: Willy Tarreau <w@1wt.eu>
Subject: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 24 Dec 2008 16:28:41 +0100
Message-ID: <20081224152841.GB13113@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1257 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbYLXP2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2008 10:28:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jens,

I'm facing a data corruption problem with splice() between two
non-blocking TCP sockets on 2.6.27.10. I could finally write a
simpler proof of concept, and capture a snapshot of the issue
with the associated strace result.

My program does the following :
  - accept an incoming connection
  - connect to a remote server
  - forward all data from the server to the client using splice()

The data count is always correct, but some parts are corrupted and
contain data which seem to come from random memory locations (this
raises a security concern BTW). It *sometimes* happens that a few
megabytes can be transferred without any problem, but most of the
time, corruption happens for a few hundreds of bytes every few
hundreds of kilobytes.

I first noticed that sometimes the corrupted part sized a multiple of
the MSS. But now it's more precise. Each time I observe the problem,
it is when the splice from the pipe to the outgoing socket has sent
two chunks at once.

For my test, I run my PoC program on my laptop. I connect to it using
netcat from localhost, then it connects to another machine on which
netcat is waiting for an incoming connection. The source of gcc-4.1.2
is then feed on stdin, and transferred via my program to the client-
side netcat. Both NICs are tg3, but the problem was first observed
with ixgbe NICs, then reproduced on sky2, so I don't think there's a
relation.

Here's an example of what I observed. This trace is really nice
because the problem happened very early (after about 14kB). 20k1 is an
"od -vAx -tx1" output of the original file, 20k2 is an output of the
corrupted one :

--- 20k1.hex    2008-12-24 11:35:36 +0100
+++ 20k2.hex    2008-12-24 14:48:26 +0100
@@ -883,17 +883,17 @@
 003720 05 06 78 1b e8 0f 3b 88 6f 96 e1 99 93 51 fd 07
 003730 a7 e9 d6 f6 9f b4 b4 78 ff 7f ea 3b b9 79 cc 4c
 003740 65 d8 9e de 49 e5 fa 45 ab b4 3f 95 d4 42 23 e1
-003750 a8 19 22 c4 fd 6a 8c 8e 08 24 01 29 1c f5 65 86
-003760 7d be de 81 d2 07 41 44 40 3a 31 1c b9 6e ce 19
-003770 e6 a0 5c 81 f6 40 6e 1b a1 9f 58 61 9d 37 c7 d5
-003780 e3 10 83 b7 3f 36 e3 26 fd 22 e3 03 50 8c 3d 54
-003790 f0 f3 d4 73 cc 7e 61 96 43 04 13 e6 d3 96 eb 2a
-0037a0 f5 37 9e 09 9f d2 25 e5 73 ec f3 88 08 47 ca 3f
-0037b0 b0 27 e9 ae 7d a0 04 db 3a c3 c4 2f f8 23 05 04
-0037c0 76 c7 7f 90 65 56 ed 4f 31 03 fb 3b a6 de b5 01
-0037d0 48 02 55 f2 d0 38 89 03 7f 90 cf 5a a6 01 04 18
-0037e0 5b ae 62 c6 84 4b f2 ff 82 04 12 18 4f 32 6e 4f
-0037f0 2e 01 15 14 51 23 81 de 53 9a 86 a6 71 50 47 ee
+003750 a8 19 22 c4 02 00 00 00 00 00 00 00 08 00 00 00
+003760 00 00 00 00 4d 69 63 00 00 00 00 00 00 00 00 00
+003770 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+003780 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+003790 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+0037a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+0037b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+0037c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+0037d0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+0037e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+0037f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 003800 fe 0a 4b 11 82 07 55 32 e6 44 21 e6 19 07 d2 38
 003810 77 8f 5a 8f 9c 7b 9f 1e 72 01 04 fc 6a 88 c9 cf
 003820 f3 6c e0 f8 a0 fe 43 76 50 13 5e d1 b2 08 7c e9

As you can see, the first corrupted byte starts at offset 0x3754 =
14164 and the corruption remains for 172 bytes.

Now let's take a look at the strace output :

socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
bind(3, {sa_family=AF_INET, sin_port=htons(4000), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
listen(3, 10)                           = 0
accept(3, 0, NULL)                      = 4

socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 5
connect(5, {sa_family=AF_INET, sin_port=htons(4001), sin_addr=inet_addr("10.1.1.1")}, 16) = 0
fcntl64(4, F_SETFL, O_RDONLY|O_NONBLOCK) = 0
fcntl64(5, F_SETFL, O_RDONLY|O_NONBLOCK) = 0
pipe([6, 7])                            = 0

select(6, [5], [], NULL, NULL)          = 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1024
select(6, [5], [4], NULL, NULL)         = 2 (in [5], out [4])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
splice(0x6, 0, 0x4, 0, 0x9b4, 0x3)      = 2484
select(6, [5], [], NULL, NULL)          = 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
select(6, [5], [4], NULL, NULL)         = 2 (in [5], out [4])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
splice(0x6, 0, 0x4, 0, 0xb68, 0x3)      = 2920
select(6, [5], [], NULL, NULL)          = 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
select(6, [5], [4], NULL, NULL)         = 2 (in [5], out [4])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
splice(0x6, 0, 0x4, 0, 0xb68, 0x3)      = 2920
select(6, [5], [], NULL, NULL)          = 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
select(6, [5], [4], NULL, NULL)         = 2 (in [5], out [4])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
splice(0x6, 0, 0x4, 0, 0xb68, 0x3)      = 2920
select(6, [5], [], NULL, NULL)          = 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
select(6, [5], [4], NULL, NULL)         = 2 (in [5], out [4])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
splice(0x6, 0, 0x4, 0, 0xb68, 0x3)      = 2920

==> at this point, exactly 14164 bytes have been transferred from the
    server to the client, ie exactly the amount of data before the
    corruption.

select(6, [5], [], NULL, NULL)          = 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 172

==> we have a read of 172 bytes, exactly the number of corrupted bytes. 

select(6, [5], [4], NULL, NULL)         = 2 (in [5], out [4])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
splice(0x6, 0, 0x4, 0, 0x660, 0x3)      = 1632

==> and here, we write the last two chunks at once and the reader
    observes random data for the first chunk.

select(6, [5], [], NULL, NULL)          = 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
select(6, [5], [4], NULL, NULL)         = 2 (in [5], out [4])
splice(0x5, 0, 0x7, 0, 0x10000, 0x3)    = 1460
splice(0x6, 0, 0x4, 0, 0xb68, 0x3)      = 2920
...


I tried to replace either socket with a file, and in both cases, the
problem disappears (which explains why we have not seen reports of
corruption on sendfile). So it's really between TCP and TCP the the
problem lies.

I tried to disable SPLICE_F_MOVE, it did not change anything.
Disabling SPLICE_F_NONBLOCK makes the code unusable as it blocks when
the pipe is full, while the same process is supposed to flush it.

It looks like the corruption happens between sockets and/or pipes,
because the first time it was noticed on a production system, the
system was running haproxy (reverse-proxy load-balancer), and we found
multiple copies of request and response headers in a data file. I
don't know however if those were from other active splices or from
earlier ones running on the same FDs.

Also, it's very hard to reproduce the problem under strace, so I feel
really lucky to have caught this trace. I think it's just a timing
problem.

Another method I found to quickly detect corruption is to feed
/dev/zero to netcat on the server side, and pipe the output to "od",
which will only show sequences of non-zeroes. Hmm just did it right
now again and I got a complete capture of the output of the "top"
utility that I just started in another window.

At first, I thought that blocking reads when there are data in the
pipe would make the problem go away, but it's not the case. I modified
my program to stop polling for reads when "bytes" is not null, and I
finally got on my socket a complete output of strace running in
another xterm.

I found an analysis [1] for a potential corruption problem between two
sockets, but I noticed there were no responses and I did not fully
understand the report anyway.

What can I do to help debug the problem ? I'm really willing to help
getting this fixed, and I also have at least one user who definitely
wants splice() to work because the recv/send model currently limits
haproxy to 3 Gbps on his machines, while I have no problem reaching
10 Gbps with splice().

Please find the attached program. The server's address is hard-coded
to 10.1.1.1:4001. It accepts connections on port 4000. Here's how you
can try to reproduce :

# server :
# nc -lp 4000 </dev/zero

# test machine :
# ./splice-net-to-net

# test machine (again) :
# nc 127.1 4000 | od -Ax -tx1

If you don't get the problem, start strace on splice-net-to-net, here
it seems to help (probably the timing race again).

Thanks in advance,
Willy

----
[1] http://lkml.org/lkml/2008/2/26/210


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="splice-net-to-net.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <asm/unistd.h>

#define LISTEN_ADDR	"0.0.0.0"
#define LISTEN_PORT	4000

#define CONNECT_ADDR	"10.1.1.1"
#define CONNECT_PORT	4001

#define PIPESIZE	65536

#ifndef __NR_splice
/* x86_32 only ! */
#define __NR_splice             313

#define SPLICE_F_MOVE           (0x01)  /* move pages instead of copying */
#define SPLICE_F_NONBLOCK       (0x02)  /* don't block on the pipe splicing (but */
#define SPLICE_F_MORE           (0x04)  /* expect more data */
#define SPLICE_F_GIFT           (0x08)  /* pages passed in are a gift */

_syscall6(int, splice, int, fdin, loff_t *, off_in, int, fdout, loff_t *, off_out, size_t, len, unsigned long, flags)
#endif

#define MAX(a, b) (((a) > (b)) ? (a) : (b))

static char buffer[32768];

void die(const char *msg)
{
	if (msg)
		fprintf(stderr, "%s\n", msg);
	exit(1);
}

int main(int argc, char **argv)
{
	int one = 1;
	int zero = 0;

        int pipes[2];
        fd_set rfd, wfd;

	struct sockaddr_in listen_addr;
	struct sockaddr_in connect_addr;
	int listen_fd;
	int accept_fd;
	int connect_fd;
        long len0, len1;
	int bytes, pipefull;

	/* prepare ourselves to accept an incoming connection */
	listen_addr.sin_family = AF_INET;
	listen_addr.sin_addr.s_addr = inet_addr(LISTEN_ADDR);
	listen_addr.sin_port = htons(LISTEN_PORT);

	listen_fd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (listen_fd < 0)
		die("listen_fd");

	setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

	if (bind(listen_fd, (struct sockaddr *)&listen_addr, sizeof(listen_addr)) < 0)
		die("bind");

	if (listen(listen_fd, 10) < 0)
		die("listen");

	accept_fd = accept(listen_fd, NULL, 0);
	if (accept_fd < 0)
		die("accept");

	/* now connect to the remote host */

	connect_addr.sin_family = AF_INET;
	connect_addr.sin_addr.s_addr = inet_addr(CONNECT_ADDR);
	connect_addr.sin_port = htons(CONNECT_PORT);

	connect_fd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (connect_fd < 0)
		die("connect_fd");

	if (connect(connect_fd, (struct sockaddr *)&connect_addr, sizeof(connect_addr)) < 0)
		die("connect");

	/* OK we're connected */

        fcntl(accept_fd, F_SETFL, O_NONBLOCK);
        fcntl(connect_fd, F_SETFL, O_NONBLOCK);

        pipe(pipes);

	bytes = 0;
	pipefull = 0;
	while (1) {
		FD_ZERO(&rfd);
		FD_ZERO(&wfd);

		if (/*!bytes*/!pipefull)
			FD_SET(connect_fd, &rfd);
		if (bytes)
			FD_SET(accept_fd, &wfd);

		select(MAX(accept_fd, connect_fd) + 1, &rfd, &wfd, NULL, NULL);

		if (FD_ISSET(connect_fd, &rfd)) {
			len0 = splice(connect_fd, NULL, pipes[1], NULL, PIPESIZE,
				      SPLICE_F_MOVE|SPLICE_F_NONBLOCK);
			if (len0 == 0) {
				// connection closed
				if (bytes)
					pipefull = 1;
				else
					break;
			}
			if (len0 == -1) {
				if (errno == EAGAIN) {
					// we can get EAGAIN on end of read, pipe full or close.
					if (bytes) {
						pipefull = 1;
					} else {
						// the pipe is empty and we cannot write, the connection closed.
						break;
					}
				}
				else
					break;
			} else {
				bytes += len0;
			}
		}
			
		if (FD_ISSET(accept_fd, &wfd)) {
			len1 = splice(pipes[0], NULL, accept_fd, NULL, bytes,
				      SPLICE_F_MOVE|SPLICE_F_NONBLOCK);
			if (len1 == 0)
				break;
			if (len1 == -1) {
				if (errno != EAGAIN)
					break;
			} else {
				bytes -= len1;
				pipefull = 0;
			}
		}
        }
	close(connect_fd);
	close(accept_fd);
        return 0;
}

--CE+1k2dSO48ffgeK--
