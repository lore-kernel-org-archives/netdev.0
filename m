From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next] net: core: set qdisc pkt len before tc_classify
Date: Tue, 12 May 2015 10:03:23 -0700
Message-ID: <20150512170322.GA3524@Alexeis-MBP.westell.com>
References: <1431437838-5478-1-git-send-email-fw@strlen.de>
 <1431440547.566.84.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150512151646.GB22387@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	daniel@iogearbox.net, jhs@mojatatu.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35089 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbbELRD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:03:27 -0400
Received: by igbyr2 with SMTP id yr2so114359020igb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 10:03:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150512151646.GB22387@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 05:16:46PM +0200, Florian Westphal wrote:
> > 
> > A qdisc might have a stab (cf qdisc_calculate_pkt_len() )
> 
> Thanks for pointing this out Eric.

Indeed. Thanks Eric!

> I was under impression that stab was only useful for egress but in
> fact tc did support ingress stab too.

That was my impression as well. Though it was allowed to add
qdisc_size_table to ingress, it's useless. Nothing takes advantage
of recomputed qdisc_pkt_len. It can only mess with stats, which
seems to be already broken:
- egress qdiscs do qdisc_bstats_update() only at dequeue, whereas
  ingress double counts dropped packets
- qdisc_bstats_update() does:
  bstats->bytes += qdisc_pkt_len(skb);
  bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
  but nothing on ingress does qdisc_pkt_len_init().
  So when we see gso packet on ingress the stats are very wrong.

I think we should fix ingress stats as a whole.
Option 1:
 do qdisc_pkt_len_init() + optional call into size_table
 to update stats only after classifers returned TC_ACT_OK.
 Cons: extra overhead per packet only to update ingress qdisc stats.
Option 2:
 use byte and packet counts from underlying netdev, when
 reporting stats via ingress qdisc.
 Pros: No arithmetic in the fast path.

I think option 2 is much preferred, since it's faster and
equally accurate.

Jamal, what's your take?

Thanks!
