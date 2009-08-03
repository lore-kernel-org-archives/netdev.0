From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Mon, 3 Aug 2009 07:15:39 +0000
Message-ID: <20090803071539.GA5506@ff.dom.local>
References: <20090728155055.2266.41649.sendpatchset@localhost.localdomain> <OF4A7A6701.1BD183E8-ON65257604.0024A9E1-65257606.0030A90D@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, kaber@trash.net,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58462 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbZHCHPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 03:15:46 -0400
Received: by bwz19 with SMTP id 19so2266505bwz.37
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 00:15:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OF4A7A6701.1BD183E8-ON65257604.0024A9E1-65257606.0030A90D@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 02, 2009 at 02:21:30PM +0530, Krishna Kumar2 wrote:
> Krishna Kumar2/India/IBM@IBMIN wrote on 07/28/2009 09:20:55 PM:
> 
> > Subject [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
> >
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> >
> > dev_queue_xmit enqueue's a skb and calls qdisc_run which
> > dequeue's the skb and xmits it. In most cases (after
> > instrumenting the code), the skb that is enqueue'd is the
> > same one that is dequeue'd (unless the queue gets stopped
> > or multiple cpu's write to the same queue and ends in a
> > race with qdisc_run). For default qdiscs, we can remove
> > this path and simply xmit the skb since this is a work
> > conserving queue.
> 
> Any comments on this patch?

Maybe I missed something, but I didn't get this patch, and can't see
it e.g. in the patchwork.

Jarek P.

> Thanks,
> 
> - KK
> 
> > The patch uses a new flag - TCQ_F_CAN_BYPASS to identify
> > the default fast queue. I plan to use this flag for the
> > previous patch also (rename if required).  The controversial
> > part of the patch is incrementing qlen when a skb is
> > requeued, this is to avoid checks like the second line below:
> >
> > +    } else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
> > >> THIS LINE:   !q->gso_skb &&
> > +               !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
> >
> > Results of a 4 hour testing for multiple netperf sessions
> > (1, 2, 4, 8, 12 sessions on a 4 cpu system-X and 1, 2, 4,
> > 8, 16, 32 sessions on a 16 cpu P6). Aggregate Mb/s across
> > the iterations:
> >
> > -----------------------------------------------------------------
> >      |         System-X          |               P6
> > -----------------------------------------------------------------
> > Size |  ORG BW          NEW BW   |      ORG BW          NEW BW
> > -----|---------------------------|-------------------------------
> > 16K  |  154264          156234   |      155350          157569
> > 64K  |  154364          154825   |      155790          158845
> > 128K |  154644          154803   |      153418          155572
> > 256K |  153882          152007   |      154784          154596
> > -----------------------------------------------------------------
> >
> > Netperf reported Service demand reduced by 15% on the P6 but
> > no noticeable difference on the system-X box.
> >
> > Please review.
> >
> > Thanks,
> >
> > - KK
> 
