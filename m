From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction
	in	RCU.
Date: Sun, 20 Jul 2008 11:35:19 -0400
Message-ID: <1216568119.4847.101.camel@localhost>
References: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1KKZmE-0000ty-00-XQvu0L+U/CjiRBuR/1fSEKKkPtS2pBon@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-20-07 at 22:20 +0800, Herbert Xu wrote:

> Not all actions :) That nat action for example wasn't intended to
> be shared at all.  In fact I still need to submit a patch to make
> it skip the shared hash as otherwise it simply won't scale as the
> number of nat actions increases (e.g., to 256K).

True, sharing in the case of nat will cause scaling challenges because
there is a per-action locking. So you dont want to share in that case.
Let me clarify the global "sharedness" of actions, because i dont think
there is an issue:

All actions (on a per-type hash table basis) have an index.
You create filter rule X and specify action nat.
You may specify the index of the action when you create the filter X. 
If you then create another filter rule Y, also using the same action
index, then that nat action is shared between rule X and rule Y[1].

If you dont specify the index a new nat action is created.
So in essence, if you create 256K rules each with an action and
as long as you dont specify the action index, you should be fine
because none will be shared.
The only scaling thing i can think of is to try and make the nat action
hash table large to reduce the init lookup. Other than that, once the
action is bound to a filter lookup cost is zero.

cheers,
jamal

[1]This is useful for tow reasons:
a) memory saving purposes: If you dont care that much about performance
or on a uniprocessor machine, one action would just be sufficient for
many rules.
b) accounting purposes; as you know qdiscs/filters/actions are
per-device. Over the years, a need has arosen from some users to have a
"per system" accounting (refer to the IMQ/IFB approach). Eg, if i wanted
the policer action to account for ingress eth0 and egress eth1 for a
user, i couldnt do it without some acrobatics.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
