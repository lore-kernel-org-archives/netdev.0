From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect
 negative mem references
Date: Wed, 28 Mar 2012 22:39:32 +0200
Message-ID: <1332967172.2325.22.camel@edumazet-glaptop>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>
	 <1332965129.2325.12.camel@edumazet-glaptop>
	 <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matt Evans <matt@ozlabs.org>
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-03-28 at 22:26 +0200, Jan Seiffert wrote:
> 2012/3/28 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Wed, 2012-03-28 at 21:15 +0200, Jan Seiffert wrote:
> >> Consider the following test program:
> >>
> >> #include <stdio.h>
> >> #include <sys/types.h>
> >> #include <sys/socket.h>
> >> #include <netinet/in.h>
> >> #include <pcap-bpf.h>
> >>
> >> #define die(x) do {perror(x); return 1;} while (0)
> >> struct bpf_insn udp_filter[] = {
> >>       /*   0 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(0)), /* leax        net[0] */
> >>       /*   1 */ BPF_STMT(BPF_LD|BPF_B|BPF_IND, 0),             /* ldb [x+0] */
> >>       /*   2 */ BPF_STMT(BPF_RET|BPF_A, 0),                    /* ret a */
> >> };
> >
> > When this point was raised some weeks ago, we wanted to see a _real_ use
> > of negative mem reference.
> >
> > You provide a test program but what this filter is supposed to do
> > exactly ?
> >
> 
> Say you have a UDP socket, and you want to filter for bogus source
> addresses (drop already in kernel to save the context switch).
> To have only one bpf program for ipv4 and ipv6 (you have to checked
> the same bogus v4 addresses in mapped space), there is a point where
> it elegant to have a negative offset saved in the X register.

Cool, thats a valid use, thanks.


Problem is you slow down the jit in its normal use, for a very specific
use. 

Please rework your patch so that absolute loads of positive offsets
(known at compile time) dont have to test negative offsets at run time.

You add two instructions per load, and thats not good.

Something like :

sk_load_word:
        .globl  sk_load_word
 
       test    %esi,%esi
       js      bpf_slow_path_word_neg

sk_load_word_positive_offset:
	.globl sk_load_word_positive_offset

        mov     %r9d,%eax               # hlen
        sub     %esi,%eax               # hlen - offset
        cmp     $3,%eax

...
