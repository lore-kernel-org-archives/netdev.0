From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: [REGRESSION][PATCH V4 0/3] bpf jit drops the ball on negative memory
 references
Date: Fri, 30 Mar 2012 17:00:25 +0200
Message-ID: <4F75CA89.4010709@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	"Matt Evans" <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uhura.skim.hs-owl.de ([193.174.118.81]:58066 "EHLO
	uhura.skim.hs-owl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251Ab2C3QyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 12:54:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider the following test program:

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pcap-bpf.h>

#define die(x) do {perror(x); return 1;} while (0)
struct bpf_insn udp_filter[] = {
	/*   0 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(0)), /* leax	net[0] */
	/*   1 */ BPF_STMT(BPF_LD|BPF_B|BPF_IND, 0),             /* ldb	[x+0] */
	/*   2 */ BPF_STMT(BPF_RET|BPF_A, 0),                    /* ret	a */
};

int main(int argc, char *argv[])
{
	char buf[512];
	struct sockaddr_in addr;
	struct bpf_program prg;
	socklen_t addr_s;
	ssize_t res;
	int fd;

	addr.sin_family = AF_INET;
	addr.sin_port = htons(5000);
	addr.sin_addr.s_addr = 0;
	addr_s = sizeof(addr);
	prg.bf_len = sizeof(udp_filter)/sizeof(udp_filter[0]);
	prg.bf_insns = udp_filter;
	if(-1 == (fd = socket(AF_INET, SOCK_DGRAM, 0)))
		die("socket");
	if(-1 == bind(fd, (struct sockaddr *)&addr, sizeof(addr)))
		die("bind");
	if(-1 == setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &prg, sizeof(prg)))
		die("setsockopt");
	res = recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr *)&addr, &addr_s);
	if(res != -1)
		printf("packet received: %zi bytes\n", res);
	else
		die("recvfrom");
	return 0;
}

when used with the bpf jit disabled works:
console 1 $ ./bpf
console 2 $ echo "hello" | nc -u localhost 5000
console 1: packet received: 6 bytes

When the bpf jit gets enabled (echo 100 >
/proc/sys/net/core/bpf_jit_enable) the same program stops working:
console 1 $ ./bpf
console 2 $ echo "hello" | nc -u localhost 5000
console 1:

The reason is that both jits (x86 and powerpc) do not handle negative
memory references like SKF_NET_OFF or SKF_LL_OFF, only the simple
ancillary data references are supported (by mapping to special
instructions).
In the case of an absolute reference, the jit aborts the translation
if a negative reference is seen, also a negative k on the indirect
load aborts the translation, but if X is negative to begin with, only
the error handler is reached at runtime which drops the whole packet.

Such a setup is useful to say filter bogus source addresses on an UDP
socket.

I propose the following patch series to fix this situation.
Patch 1 exports the helper function the interpreter uses.
Patch 2 incorporates the helper into the x86 jit (so it depends on patch 1).
Patch 3 incorporates the helper into the powerpc jit (so it depends on patch 1).

Lightly tested on x86, but the powerpc asm part is prop. wrong, could
need assistance.


Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>
