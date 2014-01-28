From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Tue, 28 Jan 2014 09:57:06 +0100
Message-ID: <20140128085706.GB30123@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39104 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754662AbaA1I5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 03:57:08 -0500
Content-Disposition: inline
In-Reply-To: <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > +	do {
> > +		struct sk_buff *nskb = segs->next;
> > +		int err;
> > +
> > +		segs->next = NULL;
> > +		err = dst_output(segs);
> > +
> > +		if (err && ret == 0)
> > +			ret = err;
> > +		segs = nskb;
> > +	} while (segs);
> > +
> > +	return ret;
> > +}
> > +
> 
> Its still unclear if this is the best strategy.
> 
> TCP stream not using DF flag are very unlikely to care if we adjust
> their MTU (lowering gso_size) at this point ?

Thanks for this suggestion.  It would indeed be nice to avoid sw
segmentation.  I tried:

static void ip_gso_adjust_seglen(struct sk_buff *skb)
{
        unsigned int mtu;

        if (!skb_is_gso(skb))
                return;

        mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
        skb_shinfo(skb)->gso_size = mtu - sizeof(struct iphdr);
}

But this yields

[   28.644776] kernel BUG at net/net/core/skbuff.c:2984!
[   28.644776] invalid opcode: 0000 [#1] SMP 
[   28.644776] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0+ #35
[   28.644776] task: ffffffff818104c0 ti: ffffffff81800000 task.ti: ffffffff81800000
[   28.644776] RIP: 0010:[<ffffffff813b10d8>]  [<ffffffff813b10d8>] skb_segment+0x808/0x830
[   28.644776] RSP: 0018:ffff88002fc03688  EFLAGS: 00010212
[   28.644776] RAX: 000000000000047c RBX: ffff88002d614b00 RCX: ffff88002d72ab00
[   28.644776] RDX: 000000000000047c RSI: 00000000000050fa RDI: ffff88002cf9f800
[   28.644776] RBP: ffff88002fc03778 R08: 0000000000000000 R09: ffff88002cdaf300
[   28.644776] R10: 0000000000000011 R11: 0000000000004ff2 R12: ffff88002cf9ff80
[   28.644776] R13: 0000000000000011 R14: 00000000000050fa R15: 00000000000054a2
[   28.644776] FS:  00007f27db007700(0000) GS:ffff88002fc00000(0000) knlGS:0000000000000000
[   28.644776] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   28.644776] CR2: 00007f8176cedcfc CR3: 000000002cd14000 CR4: 00000000000006b0
[   28.644776] Stack:
[   28.644776]  0000000000000046 ffffffff00000014 0000000000000001 ffffffff00000022
[   28.644776]  ffff88002cdaf300 ffff88002d72aaf0 0000000000000000 0000000000004ff2
[   28.644776]  0000000000000014 ffffffff818104c0 ffffffff81810bc8 ffffffffffffffbe
[   28.644776] Call Trace:
[   28.644776]  <IRQ> 
[   28.644776]  [<ffffffff8125e742>] ? number.isra.1+0x302/0x330
[   28.644776]  [<ffffffff8142f35e>] tcp_gso_segment+0x11e/0x3f0
[   28.644776]  [<ffffffff8143f2c9>] inet_gso_segment+0x129/0x350
[   28.644776]  [<ffffffff810832cf>] ?  __lock_acquire+0x2ef/0x1ca0
[   28.644776]  [<ffffffff813bcd9d>] skb_mac_gso_segment+0xdd/0x1e0
[   28.644776]  [<ffffffff813bcd07>] ?  skb_mac_gso_segment+0x47/0x1e0
[   28.644776]  [<ffffffff813bcf00>] __skb_gso_segment+0x60/0xc0
[   28.644776]  [<ffffffff813bd203>] dev_hard_start_xmit+0x183/0x5b0
[   28.644776]  [<ffffffff813e064e>] sch_direct_xmit+0xfe/0x280
[   28.644776]  [<ffffffff813bd843>] __dev_queue_xmit+0x213/0x6b0
[   28.644776]  [<ffffffff813bd635>] ?  __dev_queue_xmit+0x5/0x6b0
[   28.644776]  [<ffffffff813bdcf0>] dev_queue_xmit+0x10/0x20
[   28.644776]  [<ffffffff8140c2a9>] ip_finish_output+0x419/0x600
[   28.644776]  [<ffffffff8140c4de>] ? ip_output+0x4e/0xc0
[   28.644776]  [<ffffffff810803e4>] ? __lock_is_held+0x54/0x80
[   28.644776]  [<ffffffff8140c4de>] ip_output+0x4e/0xc0
[   28.644776]  [<ffffffff81407ffb>] ip_forward+0x21b/0x650

Eric, any chance you know wheter mucking with gso_size in this way
is supposed to work?

I will go through skb_segment and see if I can find out what exactly causes this
BUG_ON to trigger.
