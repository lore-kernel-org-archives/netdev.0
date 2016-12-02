From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Fri, 2 Dec 2016 12:54:43 +0100
Message-ID: <163220cc-a91b-5627-ea93-cd43dc0079c6@stressinduktion.org>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain>
 <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <CALx6S34+Brx-JERLhexxv9CGE9moH_Pi-H_OK=hQ-iJ2g2yYgg@mail.gmail.com>
 <20161202112450.1720d33d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36217 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753159AbcLBLyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 06:54:46 -0500
In-Reply-To: <20161202112450.1720d33d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.12.2016 11:24, Jesper Dangaard Brouer wrote:
> On Thu, 1 Dec 2016 13:51:32 -0800
> Tom Herbert <tom@herbertland.com> wrote:
> 
>>>> The technical plenary at last IETF on Seoul a couple of weeks ago was
>>>> exclusively focussed on DDOS in light of the recent attack against
>>>> Dyn. There were speakers form Cloudflare and Dyn. The Cloudflare
>>>> presentation by Nick Sullivan
>>>> (https://www.ietf.org/proceedings/97/slides/slides-97-ietf-sessb-how-to-stay-online-harsh-realities-of-operating-in-a-hostile-network-nick-sullivan-01.pdf)
>>>> alluded to some implementation of DDOS mitigation. In particular, on
>>>> slide 6 Nick gave some numbers for drop rates in DDOS. The "kernel"
> 
> slide 14
> 
>>>> numbers he gave we're based in iptables+BPF and that was a whole
>>>> 1.2Mpps-- somehow that seems ridiculously to me (I said so at the mic
>>>> and that's also when I introduced XDP to whole IETF :-) ). If that's
>>>> the best we can do the Internet is in a world hurt. DDOS mitigation
>>>> alone is probably a sufficient motivation to look at XDP. We need
>>>> something that drops bad packets as quickly as possible when under
>>>> attack, we need this to be integrated into the stack, we need it to be
>>>> programmable to deal with the increasing savvy of attackers, and we
>>>> don't want to be forced to be dependent on HW solutions. This is why
>>>> we created XDP!  
> 
> The 1.2Mpps number is a bit low, but we are unfortunately in that
> ballpark.
> 
>>> I totally understand that. But in my reply to David in this thread I
>>> mentioned DNS apex processing as being problematic which is actually
>>> being referred in your linked slide deck on page 9 ("What do floods look
>>> like") and the problematic of parsing DNS packets in XDP due to string
>>> processing and looping inside eBPF.
> 
> That is a weak argument. You do realize CloudFlare actually use eBPF to
> do this exact filtering, and (so-far) eBPF for parsing DNS have been
> sufficient for them.

You are talking about this code on the following slides (I actually
transcribed it for you here and disassembled):

l0:	ld #0x14
l1:	ldxb 4*([0]&0xf)
l2:	add x
l3:	tax
l4:	ld [x+0]
l5:	jeq #0x7657861, l6, l13
l6:	ld [x+4]
l7:	jeq #0x6d706c65, l8, l13
l8:	ld [x+8]
l9:	jeq #0x3636f6d, l10, l13
l10:	ldb [x+12]
l11:	jeq #0, l12, l13
l12:	ret #0x1
l13:	ret #0

You can offload this to u32 in hardware if that is what you want.

The reason this works is because of netfilter, which allows them to
dynamically generate BPF programs and insert and delete them from
chains, do intersection or unions of them.

If you have a freestanding program like in XDP the complexity space is a
different one and not comparable to this at all.

Bye,
Hannes
