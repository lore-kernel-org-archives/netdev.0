From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 4/5] sunvnet: count multicast packets
Date: Thu, 16 Mar 2017 12:12:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB283F@AcuExch.aculab.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
 <1489512283-422140-5-git-send-email-shannon.nelson@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB12CF@AcuExch.aculab.com>
 <4ee0ac85-62a3-2cb2-0d5d-d17e4334bde8@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Shannon Nelson' <shannon.nelson@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ee0ac85-62a3-2cb2-0d5d-d17e4334bde8@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson
> Sent: 16 March 2017 00:18
> To: David Laight; netdev@vger.kernel.org; davem@davemloft.net
> On 3/15/2017 1:50 AM, David Laight wrote:
> > From: Shannon Nelson
> >> Sent: 14 March 2017 17:25
> > ...
> >> +	if (unlikely(is_multicast_ether_addr(eth_hdr(skb)->h_dest)))
> >> +		dev->stats.multicast++;
> >
> > I'd guess that:
> > 	dev->stats.multicast += is_multicast_ether_addr(eth_hdr(skb)->h_dest);
> > generates faster code.
> > Especially if is_multicast_ether_addr(x) is (*x >> 7).

I'd clearly got brain-fade there, mcast bit is the first transmitted bit
(on ethernet) but the bytes are sent LSB first (like async).
> > 	David
> 
> Hi David, thanks for the comment.  My local instruction level
> performance guru is on vacation this week so I can't do a quick check
> with him today on this.  However, I"m not too worried here since the
> inline code for is_multicast_ether_addr() is simply
> 
> 	return 0x01 & addr[0];
> 
> and objdump tells me that on sparc it compiles down to a simple single
> byte load and compare:
> 
>      325c:	c2 08 80 03 	ldub  [ %g2 + %g3 ], %g1
>      3260:	80 88 60 01 	btst  1, %g1
>      3264:	32 60 00 b3 	bne,a,pn   %xcc, 3530 <vnet_rx_one+0x430>
>      3268:	c2 5c 61 68 	ldx  [ %l1 + 0x168 ], %g1
> 		dev->stats.multicast++;

Followed by a branch that might be marked 'assume taken' so the
normal path takes the branch.
I guess that is followed by 'add 1 to %g1', 'stx %g1, [ %l1 + 0x168 ]'
and a branch to 3530.
GCC must be using that condition to generate get the bottom of a loop
to 'fallthrough' to its top!

My version should generate something like:
		ldub  [ %g2 + %g3 ], %g1
		ldx   [ %l1 + 0x168 ], %g2
		and   1, %g1
		add   %g1, %g2, %g2
		stx   %g2, [ %l1 + 0x168 ]
While this looks like 5 instructions (rather than 2) it has fewer pipeline
stalls and can be 'spread out' into the surrounding lines of code to
reduce the stalls further.

> I don't think this driver will ever be used on anything bug sparc, so
> I'm not worried about how x86 might compile this.

On x86 gcc is likely to ignore the 'unlikely' and generate a forwards
(predicted not taken) branch around the increment.
I've had to but asm comments in the else part of conditionals like
that to force gcc to generate a forwards jump to the 'unlikely' statements.

	David
