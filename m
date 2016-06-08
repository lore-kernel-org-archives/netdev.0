From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Wed, 8 Jun 2016 14:16:25 +0200
Message-ID: <20160608121625.GA4097@salvia>
References: <20160602002354.GG1644@akamai.com>
 <20160606223106.GA1621@salvia>
 <57575367.4010604@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53316 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161396AbcFHMQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 08:16:33 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 22D5346B454
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 14:16:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0ABDF15D62D
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 14:16:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E8B0515D630
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 14:16:26 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <57575367.4010604@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 07:06:15PM -0400, Vishwanath Pai wrote:
> On 06/06/2016 06:31 PM, Pablo Neira Ayuso wrote:
> > On Wed, Jun 01, 2016 at 08:23:54PM -0400, Vishwanath Pai wrote:
> >> netfilter/nflog: nflog-range does not truncate packets
> >>
> >> The --nflog-range parameter from userspace is ignored in the kernel and
> >> the entire packet is sent to the userspace. The per-instance parameter
> >> copy_range still works, with this change --nflog-range will have
> >> preference over copy_range.
> > 
> > I think it's reasonable to assume that --nflog-range from the rule
> > applies globally to any instance.
> > 
> > However, per-instance copy_range has prevailed over --nflog-range
> > since the beginning, so I would follow a more conservative approach,
> > ie. remain copy_range in preference over --nflog-range.
> > 
> > So I'd suggest you invert this logic.
> > 
> > Let me know, thanks.
> > 
> 
> Thanks for reviewing this. I think my comment on the patch was
> misleading, we do give preference to copy_range and that is what we
> default to.

Looking again at your code:

        case NFULNL_COPY_PACKET:
-               if (inst->copy_range > skb->len)
+               data_len = inst->copy_range;
+               if (li->u.ulog.copy_len < data_len)
+                       data_len = li->u.ulog.copy_len;

data_len is set to instance's copy_range.

But then, if the NFLOG rule indicates smaller copy_len, you use this
value. So to my understanding, NFLOG rule prevails over instance's
copy_range in what matters, which is to shrink the copy range.

> --nflog-range will not override the per-instance default,
> the only time it would get preference is when its value is lesser than
> the per-instance value. If copy_range is lesser than --nflog-range then
> we retain copy_range.
>
> So basically what we are doing is min(copy_range, nflog-range).
> Just wanted to clarify this, if this is not how it's meant to be
> please let me know.
>
> Also, there is a bug in my patch, li->u.ulog.copy_len can be set to "0"
> from userspace (if --nflog-range is not specified), so we have to check
> for this condition before using the value. I will send a V2 of the patch
> based on your reply.

Currently, li->u.ulog.copy_len is set to "0" by default when not
specified.

But copy_len = 0 is a valid possibility, so this looks a bit more
tricky to me to fix since we may need to get flags here to know when
this is set.

Probably something like:

        if (li->flags & NF_LOG_F_COPY_RANGE)
                data_len = li->u.ulog.copy_len;
        /* Per-instance copy range prevails over global per-rule option. */
        if (data_len < inst->copy_range)
                data_len = inst->copy_range;
        if (data_len > skb->len)
                data_len = skb->len;

Although this would require a bit more code to introduce these flags.

You will also need a new flag for xt_NFLOG:

#define XT_NFLOG_COPY_LEN       0x2

it seems other XT_NFLOG_* flags were already in place.

Interesting that nobody noticed this for so long BTW.
