From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [REGRESSION][PATCH v1] bpf jit: Let the arm jit handle negative
 memory references
Date: Sat, 7 Apr 2012 01:30:44 +0200
Message-ID: <4F7F7CA4.9080107@googlemail.com>
References: <4F75CA89.4010709@googlemail.com> <4F7F3C7D.1040007@googlemail.com> <4F7F6DF9.5010902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Russell King" <linux@arm.linux.org.uk>
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F7F6DF9.5010902@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mircea Gherzan schrieb:
> Hi,
> 

Hi

> Am 06.04.2012 20:57, schrieb Jan Seiffert:
>> The arm jit has the same problem as the other two jits.
>> It only tests for negative absolute memory references, and if it sees
>> one bails out to let the interpreter handle the filter program.
>>
>> But this fails if the X register contains a negative memory reference
>> and is used for an indirect load.
> 
> I don't think that there's any use case for negative values in X.

<mode temper="elevated" reason="had that discussion already">

There is.
Say you have a bpf filter on an UDP socket. You want to filter bogus
Source addresses in kernel to prevent the context switch and copying.
Since ipv6 has a v4 mapped space, you have to make the same tests for
the v6-mapped space as for v4, so you can use one program for v4 & v6
to begin with.
You can solve it without a negative offset in X, it's is just very
helpful. Still you have negative offsets, which means no jit.

struct bpf_insn udp_filter[] = {
        /*   0 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(12)),
        /*   1 */ BPF_STMT(BPF_LD|BPF_B|BPF_ABS, -1048576+(0)),
        /*   2 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xf0),
        /*   3 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x40, 23 - 4, 0),
        /*   4 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x60, 5 - 5, 41 - 5),
        /*   5 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(8)),
        /*   6 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 13 - 7, 0),
        /*   7 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x20010DB8, 41 - 8, 0),
        /*   8 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x20010002, 19 - 9, 0),
        /*   9 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xfffffff0),
        /*  10 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x20010010, 41 - 11, 0),
        /*  11 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xff000000),
        /*  12 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xff000000, 41 - 13, 39 - 13),
        /*  13 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(12)),
        /*  14 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 0, 39 - 15),
        /*  15 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(16)),
        /*  16 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xffff, 22 - 17, 0),
        /*  17 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x0064FF9B, 22 - 18, 0),
        /*  18 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 41 - 19, 39 - 19),
        /*  19 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(12)),
        /*  20 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xffff0000),
        /*  21 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 41 - 22, 39 - 22),
        /*  22 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(20)),
        /*  23 */ BPF_STMT(BPF_LD|BPF_W|BPF_IND, 0),
        /*  24 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xffffffff, 41 - 25, 0),
        /*  25 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xffffff00),
        /*  26 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC0000000, 41 - 27, 0),
        /*  27 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC0000200, 41 - 28, 0),
        /*  28 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC6336400, 41 - 29, 0),
        /*  29 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xCB007100, 41 - 30, 0),
        /*  30 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC0586300, 41 - 31, 0),
        /*  31 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xfffe0000),
        /*  32 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC6120000, 41 - 33, 0),
        /*  33 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xff000000),
        /*  34 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 41 - 35, 0),
        /*  35 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xf0000000),
        /*  36 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xE0000000, 41 - 37, 0),
        /*  37 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xF0000000, 41 - 38, 0),
        /*  38 */ BPF_JUMP(BPF_JMP|BPF_JA, 39 - 39, 0, 0),
        /*  39 */ BPF_STMT(BPF_LD|BPF_W|BPF_LEN, 0),
        /*  40 */ BPF_STMT(BPF_RET|BPF_A, 0),
        /*  41 */ BPF_STMT(BPF_RET|BPF_K, 0),
};

I already had that discussion with Eric, he said it is a valid use case.
http://marc.info/?l=linux-netdev&m=133296726719053&w=2

The patch for x86 is already in, ppc is being reviewed, i only heard of the
arm jit to late, or you would have been in the loop from the beginning.


> In both the original BPF design and in the LSF interpreter, A and X are
> considered unsigned.

Then use the following test program (filter not usefull, just to show the problem):

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

This is a regression in the interface in my book.
The interpreter handles this perfectly fine.

> The role of X is mainly to allow variable length
> headers (load the length -> unsigned).
> 
> "Negative" K values are permitted for ancillary data loads based on the
> fact that we're not going to see 2GB packets any time soon.
> 

Exactly, and how do i handle both at the same time? (The ancillary space
contains not only cpu_id and such stuff, but the link layer header and the network
space, which is important when you use LSF on arbitrary sockets, not just raw
sockets, maybe the new syscall filter thingy also wants a new ancillary space)

> Mircea
> 

Have some nice holidays :-)

Greetings
	Jan
