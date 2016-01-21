From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Wed, 20 Jan 2016 16:07:05 -0800
Message-ID: <1453334825.1223.332.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5697D833.5010506@hpe.com>
	 <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
	 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
	 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
	 <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
	 <20160120013128.GA6326@pox.localdomain> <56A01BBF.1010301@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>
To: John <john.phillips5@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34722 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbcAUAHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 19:07:08 -0500
Received: by mail-pf0-f180.google.com with SMTP id q63so13266368pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 16:07:07 -0800 (PST)
In-Reply-To: <56A01BBF.1010301@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-20 at 16:43 -0700, John wrote:
> 
> On 01/19/2016 06:31 PM, Thomas Graf wrote:
> > On 01/19/16 at 04:51pm, Jesse Gross wrote:
> >> On Tue, Jan 19, 2016 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >>> So what is the purpose of having a dst if we need to drop it ?
> >>>
> >>> Adding code in GRO would be fine if someone explains me the purpose of
> >>> doing apparently useless work.
> >>>
> >>> (refcounting on dst is not exactly free)
> >> In the GRO case, the dst is only dropped on the packets which have
> >> been merged and therefore need to be freed (the GRO_MERGED_FREE case).
> >> It's not being thrown away for the overall frame, just metadata that
> >> has been duplicated on each individual frame, similar to the metadata
> >> in struct sk_buff itself. And while it is not used by the IP stack
> >> there are other consumers (eBPF/OVS/etc.). This entire process is
> >> controlled by the COLLECT_METADATA flag on tunnels, so there is no
> >> cost in situations where it is not actually used.
> > Right. There were thoughts around leveraging a per CPU scratch
> > buffer without a refcount and turn it into a full reference when
> > the packet gets enqueued somewhere but the need hasn't really come
> > up yet.
> >
> > Jesse, is this what you have in mind:
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index cc9e365..3a5e96d 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4548,9 +4548,10 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
> >                  break;
> >   
> >          case GRO_MERGED_FREE:
> > -               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
> > +               if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
> > +                       skb_release_head_state(skb);
> >                          kmem_cache_free(skbuff_head_cache, skb);
> > -               else
> > +               } else
> >                          __kfree_skb(skb);
> >                  break;
> So I've tested the below patch (same as one above with minor 
> modifications made to make it compile) and it worked - no memory leak. 
> Should I submit this or...?

Unfortunately fix is not complete.

As someone mentioned, GRO should not aggregate packets having different
dst.

This part is hard to achieve, as a pointer comparison wont be enough :
Each skb has its own meta dst allocation.

Quite frankly, I would rather disable GRO for packets with a dst,
instead of making GRO dog slow.

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index cf6c74550baa..124b8a5537e3 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -19,7 +19,10 @@ static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *s
 	struct gro_cell *cell;
 	struct net_device *dev = skb->dev;
 
-	if (!gcells->cells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
+	if (!gcells->cells ||
+	    skb->_skb_refdst ||
+	    skb_cloned(skb) ||
+	    !(dev->features & NETIF_F_GRO)) {
 		netif_rx(skb);
 		return;
 	}
