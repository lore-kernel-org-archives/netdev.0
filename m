From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH] include/net/genetlink.h: Allow genlmsg_cancel to accept
 a NULL argument
Date: Wed, 2 Feb 2011 07:17:29 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1102020659520.9302@ask.diku.dk>
References: <Pine.LNX.4.64.1101281642080.8546@pc-004.diku.dk>
 <20110201.145410.115936566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paul.moore@hp.com, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110201.145410.115936566.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Feb 2011, David Miller wrote:

> From: Julia Lawall <julia@diku.dk>
> Date: Fri, 28 Jan 2011 16:43:40 +0100 (CET)
> 
> > nlmsg_cancel can accept NULL as its second argument, so for similarity,
> > this patch extends genlmsg_cancel to be able to accept a NULL second
> > argument as well.
> > 
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> I did a scan of all of the cases where this interface is used, and
> I cannot find a situation where this capability would even be useful.
> 
> The use pattern is always:
> 
> 	hdr = genlmsg_put(skb, ...);
> 	if (!hdr)
> 		goto out;
> 
> 	NLA_PUT_*();
> 	NLA_PUT_*();
> 	....
> 
> 	return genlmsg_end(skb, hdr);
> 
> nla_put_failure:
> 	genlmsg_cancel(skb, hdr);
> out:
> 	return -EWHATEVER;

This pattern occurred in eg:

net/netlabel/netlabel_unlabeled.c

in the function netlbl_unlabel_staticlist_gen and in other netlabel code, 
as well as in net/wireless/nl80211.c, but with the function nl80211hdr_put 
instead of genlmsg_put.  I submitted patches for all of these cases, so 
that is perhaps why you don't see them.  But someone suggested to change 
genlmsg_cancel as well, to be as permissive as nlmsg_cancel.

For nlmsg_cancel, there are two occurrences in 
net/netfilter/nf_conntrack_netlink.c where nlmsg_cancel is reachable with 
the second argument NULL.

For nlmsg_cancel the ability to accept NULL as a second argument comes 
from the fact that it only calls nlmsg_trim, which does nothing if NULL is 
the second argument.  nlmsg_trim is also called by nla_nest_cancel.  There 
are many calls to nla_nest_cancel with NULL as the second argument in the 
directory net/sched, for example in the function gred_dump in 
net/sched/sch_gred.c.  net/sched also contains a call to nlmsg_trim with 
NULL as the second argument, in the function flow_dump, in 
net/sched/cls_flow.c.

The whole thing seems somewhat sloppy.  I'm sure that all of the 
above-cited occurrences could be rewritten as outlined above to skip over 
the cancel/trim function.

julia
