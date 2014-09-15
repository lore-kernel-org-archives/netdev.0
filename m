From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: Correct TOS priority mapping for DSCP EF
Date: Mon, 15 Sep 2014 17:09:13 -0400 (EDT)
Message-ID: <20140915.170913.105209681419359224.davem@davemloft.net>
References: <=1410783785.7106.154.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140915145023.4834.93706.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759116AbaIOVJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:09:16 -0400
In-Reply-To: <20140915145023.4834.93706.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Sep 2014 16:50:47 +0200

> The DSCP value for Expedited Forwarding (EF) got mapped to
> internal priority TC_PRIO_INTERACTIVE_BULK, which ends up in
> medium/best-effort priority band(1) of pfifo_fast
> 
> This patch change TOS mapping, causing the DSCP EF to get mapped
> to TC_PRIO_INTERACTIVE, which end up in high priority band(0)
> of pfifo_fast.
> 
> While performing this policy change, document the TOS to priority
> lookup table ip_tos2prio[16].  Thus, making it easier to
> understand this table for reviewers.
> 
> The DSCP AFxx mappings are also suboptimal, but we choose not to
> change those mapping, only document the mapping in the code.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

I don't think you can make these mappings given that we don't
take the code-service bits of the TOS into account when we use
this table at all.

The DSCP values are composed in the top 6 bits, but we are only
considering the low 3 bits of that field (along with the high
bit of "CU", which is part of the ECN value and thus "don't care")

We should only match EF when the top two DSCP bits are "10".

This table and it's relationship to DSCP is confusing (but your
comments in this patch helped a lot, thanks).  Also it isn't
clear why we don't interpret the full DSCP field.

ECN_OR_COST() does nothing but serve as an annotation meaning
that this value has an ECN bit set.

So why don't we shift down by two bits, to get rid of the entire
"CU" field, and consider all 6 bits of the DSCP value in the
ip_tos2prio[] table?
