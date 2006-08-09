From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Excess use of packed attribute
Date: Wed, 09 Aug 2006 11:37:31 -0700
Message-ID: <ada3bc5sql0.fsf@cisco.com>
References: <20060807133423.11bfbff3@localhost.localdomain>
	<1154995328.11916.24.camel@w-sridhar2.beaverton.ibm.com>
	<20060807.173920.102575221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sri@us.ibm.com, shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:59177 "EHLO
	sj-iport-1.cisco.com") by vger.kernel.org with ESMTP
	id S1751304AbWHIShg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 14:37:36 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.173920.102575221.davem@davemloft.net> (David Miller's message of "Mon, 07 Aug 2006 17:39:20 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> For the cases where it is no actually necessary, the code
    David> generation cost on RISC cpus is very high.  Byte loads and
    David> stores will be used to access _every_ member of such
    David> structures on RISC machines because the compiler cannot
    David> guarentee the alignment of any data object when packed is
    David> specified.

Agreed (although not really RISC -- sparc64 and ia64 have this
problem, while ppc is fine with unaligned access).  However
__attribute__((packed,aligned)) has just been brought to my attention.
For example, on sparc64,

	struct foo { char x; int a; } __attribute__((packed,aligned));
	struct bar { char x; int b; } __attribute__((packed));
	
	int c(struct foo *x) { return x->a; }
	int d(struct bar *x) { return x->b; }

compiles to:

	0000000000000000 <c>:
	   0:   d0 5a 00 00     ldx  [ %o0 ], %o0
	   4:   91 2a 30 08     sllx  %o0, 8, %o0
	   8:   81 c3 e0 08     retl
	   c:   91 3a 30 20     srax  %o0, 0x20, %o0
	  10:   30 68 00 04     b,a   %xcc, 20 <d>
	  14:   01 00 00 00     nop
	  18:   01 00 00 00     nop
	  1c:   01 00 00 00     nop
	
	0000000000000020 <d>:
	  20:   c6 0a 20 01     ldub  [ %o0 + 1 ], %g3
	  24:   c2 0a 20 02     ldub  [ %o0 + 2 ], %g1
	  28:   c4 0a 20 03     ldub  [ %o0 + 3 ], %g2
	  2c:   87 28 f0 18     sllx  %g3, 0x18, %g3
	  30:   d0 0a 20 04     ldub  [ %o0 + 4 ], %o0
	  34:   83 28 70 10     sllx  %g1, 0x10, %g1
	  38:   82 10 40 03     or  %g1, %g3, %g1
	  3c:   85 28 b0 08     sllx  %g2, 8, %g2
	  40:   84 10 80 01     or  %g2, %g1, %g2
	  44:   90 12 00 02     or  %o0, %g2, %o0
	  48:   81 c3 e0 08     retl
	  4c:   91 3a 20 00     sra  %o0, 0, %o0
	  50:   30 68 00 04     b,a   %xcc, 60 <d+0x40>
	  54:   01 00 00 00     nop
	  58:   01 00 00 00     nop
	  5c:   01 00 00 00     nop

which suggests that adding "aligned" is a good idea for many of the
uses of "packed".  However I don't know how all gcc version do with
this.  Anyone have any comments on "__attribute__((packed,aligned))"?

Thanks,
  Roland
