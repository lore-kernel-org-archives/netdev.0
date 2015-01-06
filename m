From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC rocker-net-next 2/6] net: flow: Handle error when
 putting a field while putting a flow
Date: Tue, 6 Jan 2015 10:04:39 +0900
Message-ID: <20150106010437.GB14077@vergenet.net>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
 <1420440610-20621-3-git-send-email-simon.horman@netronome.com>
 <54AAC9AE.4010104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40890 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754331AbbAFBEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 20:04:50 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so29900095pab.28
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 17:04:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54AAC9AE.4010104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2015 at 09:28:14AM -0800, John Fastabend wrote:
> On 01/04/2015 10:50 PM, Simon Horman wrote:
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >---
> >  net/core/flow_table.c | 9 +++++++--
> >  1 file changed, 7 insertions(+), 2 deletions(-)
> >
> >diff --git a/net/core/flow_table.c b/net/core/flow_table.c
> >index 2af831e..753ebe0 100644
> >--- a/net/core/flow_table.c
> >+++ b/net/core/flow_table.c
> >@@ -981,8 +981,9 @@ done:
> >
> >  int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
> >  {
> >-	struct nlattr *flows, *matches;
> >+	struct nlattr *flows;
> >  	struct nlattr *actions = NULL; /* must be null to unwind */
> >+	struct nlattr *matches = NULL; /* must be null to unwind */
> 
> Actually we don't need to initialize to NULL now. That was some crazy
> unwind scheme I had in place initially.
> 
> Now we only ever do a nla_nest_cancel on nested attributes that have
> been initialized with nla_nest_start(). So I can simplify this to
> 
> 	struct nlattr *flows, *matches, *actions;

Thanks, that does seem much nicer :)

> 
> >  	int err, j, i = 0;
> >
> >  	flows = nla_nest_start(skb, NET_FLOW_FLOW);
> >@@ -1005,7 +1006,11 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
> >  			if (!f->header)
> >  				continue;
> >
> >-			nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
> >+			err = nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
> 
> Great thanks. I missed this one.
> 
> >+			if (err) {
> >+				nla_nest_cancel(skb, matches);
> >+				goto flows_put_failure;
> >+			}
> >  		}
> >  		nla_nest_end(skb, matches);
> >  	}
> >
> 
> I'll fold this into the series and resubmit thanks.
> 
> .John
> 
> -- 
> John Fastabend         Intel Corporation
