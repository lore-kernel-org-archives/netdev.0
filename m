From: David Miller <davem@davemloft.net>
Subject: Re: Excess use of packed attribute
Date: Wed, 09 Aug 2006 21:11:36 -0700 (PDT)
Message-ID: <20060809.211136.57445905.davem@davemloft.net>
References: <1154995328.11916.24.camel@w-sridhar2.beaverton.ibm.com>
	<20060807.173920.102575221.davem@davemloft.net>
	<ada3bc5sql0.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26547
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030625AbWHJEL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 00:11:29 -0400
To: rdreier@cisco.com
In-Reply-To: <ada3bc5sql0.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 09 Aug 2006 11:37:31 -0700

> Agreed (although not really RISC -- sparc64 and ia64 have this
> problem, while ppc is fine with unaligned access).  However
> __attribute__((packed,aligned)) has just been brought to my attention.
> For example, on sparc64,
> 
> 	struct foo { char x; int a; } __attribute__((packed,aligned));
> 	struct bar { char x; int b; } __attribute__((packed));
> 	
> 	int c(struct foo *x) { return x->a; }
> 	int d(struct bar *x) { return x->b; }
> 
> compiles to:
 ...
> which suggests that adding "aligned" is a good idea for many of the
> uses of "packed".  However I don't know how all gcc version do with
> this.  Anyone have any comments on "__attribute__((packed,aligned))"?

Good find.

It might usable in some of the questionable cases, however it changes
the size of the struct which eliminates most of the gains.

For example:

davem@sunset:~/src/GIT/net-2.6$ cat foo.c
#include <stdio.h>

struct foo_packed {
	char x; int a;
} __attribute__((packed));

struct foo_packed_aligned {
	char x; int a;
} __attribute__((packed,aligned));

int main(void)
{
	printf("foo_packed: sizeof(%Zd)\n",
	       sizeof(struct foo_packed));
	printf("foo_packed_aligned: sizeof(%Zd)\n",
	       sizeof(struct foo_packed_aligned));

	return 0;
}
davem@sunset:~/src/GIT/net-2.6$ gcc -O -o foo foo.c
davem@sunset:~/src/GIT/net-2.6$ ./foo
foo_packed: sizeof(5)
foo_packed_aligned: sizeof(8)
davem@sunset:~/src/GIT/net-2.6$ 

This doesn't work for things like packet headers, for example.

Oh well.
