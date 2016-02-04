From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 11:56:09 +0100
Message-ID: <20160204105609.GA7870@gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
 <20160204093021.GB1553@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org,
	kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160204093021.GB1553@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@kernel.org> wrote:

> s/!CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> 
> > +
> > +	/* Check length */
> > +10:	cmpl	$8, %esi
> > +	jg	30f
> > +	jl	20f
> > +
> > +	/* Exactly 8 bytes length */
> > +	addl	(%rdi), %eax
> > +	adcl	4(%rdi), %eax
> > +	RETURN
> > +
> > +	/* Less than 8 bytes length */
> > +20:	clc
> > +	jmpq *branch_tbl_len(, %rsi, 8)
> > +
> > +	/* Greater than 8 bytes length. Determine number of quads (n). Sum
> > +	 * over first n % 16 quads
> > +	 */
> > +30:	movl	%esi, %ecx
> > +	shrl	$3, %ecx
> > +	andl	$0xf, %ecx
> > +	negq	%rcx
> > +	lea	40f(, %rcx, 4), %r11
> > +	clc
> > +	jmp	*%r11
> 
> Are you absolutely sure that a jump table is the proper solution here? It 
> defeats branch prediction on most x86 uarchs. Why not label the loop stages and 
> jump in directly with a binary tree of branches?

So just to expand on this a bit, attached below is a quick & simple & stupid 
testcase that generates a 16 entries call table. (Indirect jumps and indirect 
calls are predicted similarly on most x86 uarchs.) Just built it with:

  gcc -Wall -O2 -o jump-table jump-table.c

Even on relatively modern x86 uarchs (I ran this on a post Nehalem IVB Intel CPU 
and also on AMD Opteron. The numbers are from the Intel box.) this gives a high 
branch miss rate with a 16 entries jump table:

 triton:~> taskset 1 perf stat --repeat 10 ./jump-table 16
 ... using 16 jump table entries.
 ... using 100000000 loop iterations.
 ... result: 10000000100000000
 [...]

 Performance counter stats for './jump-table 16' (10 runs):

       1386.131780      task-clock (msec)         #    1.001 CPUs utilized            ( +-  0.18% )
                33      context-switches          #    0.024 K/sec                    ( +-  1.71% )
                 0      cpu-migrations            #    0.000 K/sec                  
                52      page-faults               #    0.037 K/sec                    ( +-  0.71% )
     6,247,215,683      cycles                    #    4.507 GHz                      ( +-  0.18% )
     3,895,337,877      stalled-cycles-frontend   #   62.35% frontend cycles idle     ( +-  0.30% )
     1,404,014,996      instructions              #    0.22  insns per cycle        
                                                  #    2.77  stalled cycles per insn  ( +-  0.02% )
       300,820,988      branches                  #  217.022 M/sec                    ( +-  0.02% )
        87,518,741      branch-misses             #   29.09% of all branches          ( +-  0.01% )

       1.385240076 seconds time elapsed                                          ( +-  0.21% )

... as you can see the branch miss rate is very significant, causing a stalled 
decoder and very low instruction throughput.

I have to reduce the jump table to a single entry (!) to get good performance on 
this CPU:

 Performance counter stats for './jump-table 1' (10 runs):

        739.173505      task-clock (msec)         #    1.001 CPUs utilized            ( +-  0.26% )
                37      context-switches          #    0.051 K/sec                    ( +- 16.79% )
                 0      cpu-migrations            #    0.000 K/sec                  
                52      page-faults               #    0.070 K/sec                    ( +-  0.41% )
     3,331,328,405      cycles                    #    4.507 GHz                      ( +-  0.26% )
     2,012,973,596      stalled-cycles-frontend   #   60.43% frontend cycles idle     ( +-  0.47% )
     1,403,880,792      instructions              #    0.42  insns per cycle        
                                                  #    1.43  stalled cycles per insn  ( +-  0.05% )
       300,817,064      branches                  #  406.964 M/sec                    ( +-  0.05% )
            12,177      branch-misses             #    0.00% of all branches          ( +- 12.39% )

       0.738616356 seconds time elapsed                                          ( +-  0.26% )

Note how the runtime got halved: that is because stalls got halved and the 
instructions per cycle throughput doubled.

Even a two entries jump table performs poorly:

 Performance counter stats for './jump-table 2' (10 runs):

       1493.790686      task-clock (msec)         #    1.001 CPUs utilized            ( +-  0.06% )
                39      context-switches          #    0.026 K/sec                    ( +-  4.73% )
                 0      cpu-migrations            #    0.000 K/sec                  
                52      page-faults               #    0.035 K/sec                    ( +-  0.26% )
     6,732,372,612      cycles                    #    4.507 GHz                      ( +-  0.06% )
     4,229,130,302      stalled-cycles-frontend   #   62.82% frontend cycles idle     ( +-  0.09% )
     1,407,803,145      instructions              #    0.21  insns per cycle        
                                                  #    3.00  stalled cycles per insn  ( +-  0.08% )
       301,688,946      branches                  #  201.962 M/sec                    ( +-  0.09% )
       100,022,150      branch-misses             #   33.15% of all branches          ( +-  0.00% )

       1.492820524 seconds time elapsed                                          ( +-  0.08% )

In fact it's worse than the 16 entries runtime.

( Note that Intel SkyLake improved the indirect jump/call branch predictor.
  On another Intel CPU I have the boundary between good and bad prediction is
  at 4-6 entries. So this is highly uarch (and code layout) dependent. )

In contrast, a static hierarchy/tree of branches is predicted a lot better on most 
x86 uarchs, even with highly variable input. (This does not even count the extra 
calculations needed to calculate the jump table index, which, as you coded it in 
your patch, add 2-3 cycles of extra latency as well.)

Such branch miss characteristics matter and they can become more visible with 
smaller skb sizes.

So I'm generally sceptical of jump tables and I'd like to see careful and 
convincing perf stat runs on modern x86 uarchs, comparing the jump table solution 
to a branch hierarchy solution, before accepting a jump table solution into the 
x86 architecture.

x86 uarchs are generally good at predicting function pointer indirect jumps (which 
tend to be static) - multi-target jump tables are a lot harder nut to crack, 
especially if the jump index is calculated right before the jump is performed, 
like your patch does it.

The impact of branch misses is more pronounced on modern Intel CPUs, because 
speculation is deeper.

But as always I can be convinced with contrary numbers! :-)

Thanks,

	Ingo

-------------------------------------->
/*
 * Simple testcase to generate jump table usage.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned long (fn_t) (unsigned long param);

unsigned long global;

#define DEFINE_FUN(x)				\
						\
unsigned long fun_##x(unsigned long param)	\
{						\
	return param+global;			\
}

#define TABLE_SIZE_MAX 16L

DEFINE_FUN( 1);
DEFINE_FUN( 2);
DEFINE_FUN( 3);
DEFINE_FUN( 4);
DEFINE_FUN( 5);
DEFINE_FUN( 6);
DEFINE_FUN( 7);
DEFINE_FUN( 8);
DEFINE_FUN( 9);
DEFINE_FUN(10);
DEFINE_FUN(11);
DEFINE_FUN(12);
DEFINE_FUN(13);
DEFINE_FUN(14);
DEFINE_FUN(15);
DEFINE_FUN(16);

int main(int argc, char **argv)
{
	fn_t *fn_ptr [TABLE_SIZE_MAX] = {	 fun_1 , fun_2 , fun_3 , fun_4 ,
						 fun_5 , fun_6 , fun_7 , fun_8 ,
						 fun_9 , fun_10, fun_11, fun_12,
						 fun_13, fun_14, fun_15, fun_16,
											};
	unsigned long local = 0;
	unsigned long i;
	unsigned long table_size = TABLE_SIZE_MAX;
	unsigned long loops = 100000000;


	if ((argc >= 2 && !strcmp(argv[1], "-h")) || argc >= 4) {
		printf("usage: jump-table <table_size(1-%lu)(default: %lu)> <loops(default: %lu)>\n", TABLE_SIZE_MAX, TABLE_SIZE_MAX, loops);
		exit(0);
	}

	if (argc >= 2) {
		table_size = atol(argv[1]);
		if (table_size <= 1)
			table_size = 1;
		if (table_size > TABLE_SIZE_MAX)
			table_size = TABLE_SIZE_MAX;
	}
	printf("... using %lu jump table entries.\n", table_size);

	if (argc >= 3)
		loops = atol(argv[2]);
	printf("... using %lu loop iterations.\n", loops);

	/* Call a set of simple arithmetic functions from a jump table: */
	for (i = 0; i < loops; i++) {
		global++;
		local += fn_ptr[global % table_size](global);
	}

	printf("... result: %lu\n", local);
}
