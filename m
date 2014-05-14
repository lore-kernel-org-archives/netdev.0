From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Wed, 14 May 2014 09:32:15 +0100
Message-ID: <1400056335.21829.2.camel@kazak.uk.xensource.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>
	 <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	<xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48134 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbaENIcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:32:18 -0400
In-Reply-To: <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 09:13 -0700, Eric Dumazet wrote:
> On Tue, 2014-05-13 at 15:31 +0100, Zoltan Kiss wrote:
> > The original series for reintroducing grant mapping for netback had a patch [1]
> > to handle receiving of packets from an another VIF. Grant copy on the receiving
> > side needs the grant ref of the page to set up the op.
> > The original patch assumed (wrongly) that the frags array haven't changed. In
> > the case reported by Sander, the sending guest sent a packet where the linear
> > buffer and the first frag were under PKT_PROT_LEN (=128) bytes.
> > xenvif_tx_submit() then pulled up the linear area to 128 bytes, and ditched the
> > first frag. The receiving side had an off-by-one problem when gathered the grant
> > refs.
> > This patch fixes that by checking whether the actual frag's page pointer is the
> > same as the page in the original frag list. It can handle any kind of changes on
> > the original frags array, like:
> > - removing granted frags from the beginning or the end
> > - adding local pages to the frags list
> > To keep it optimized to the most common cases, it doesn't handle when the order
> > of the original frags changed. That would require ubuf to be reseted to the
> > beginning of the chain (skb_shinfo(skb)->destructor_arg), and reiterating
> > through the list every time.
> > 
> > OPEN QUESTIONS:
> > - Is it a safe assumption that nothing changes the order of the original frags?
> >   Removing them from the array or injecting new pages anywhere is not a problem.
> > - I used UINT_MAX as a kind of INVALID_GRANT_REF, however there is no such thing
> >   in the grant mapping API. Should we codify this or is it better if we just
> >   find another way to distinguish whether a frag is local or not?
> > - Should this fix go to David's net tree or directly to the mainline tree? Or
> >   both?
> > 
> > [1]: 3e2234: xen-netback: Handle foreign mapped pages on the guest RX path
> > 
> > Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> > Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> > ---
> 
> 
> The 'cleanup' of stale ubufs should be right after __pskb_pull_tail().
> 
> This is the function that can 'consume frags' after all.

That would be OK for the call to __pskb_pull_tail in netback itself --
but what about any other calls from other bits of the network stack
which don't know about this driver-specific data structure?

> Its not clear that you catch all cases, like skbs being purged in case
> of device dismantle.

Doesn't that go through the normal skb destroy path, as opposed to
manipulating an existing skb?

> I am not saying your patch is wrong, only that it adds yet an obscure
> thing with no comments. In two years, nobody will understand this.

Agreed.

Ian.
