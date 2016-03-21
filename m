From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] change nfqueue failopen to apply also to
 receive message buffer in addition to queue size
Date: Mon, 21 Mar 2016 13:22:36 +0100
Message-ID: <20160321122236.GB29493@breakpoint.cc>
References: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"Florian Westphal (fw@strlen.de)" <fw@strlen.de>,
	stephen@networkplumber.org
To: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yigal Reiss (yreiss) <yreiss@cisco.com> wrote:

[ CC shemminger ]

This is the place where the commit message should go.

The Subject: line alone isn't enough for a large patch like this.

> Signed-off-by: Yigal Reiss <yreiss@cisco.com>
> ---
> 
> NOTE: this is a re-send after being bounced by the test robot for a compiler warning. I hope I'm doing the right thing in resubmitting rather than replying to the original message. Recompiled w/o warnings and re-tested. 

Resubmit is ok.

> This is follow-up on http://marc.info/?l=netfilter-devel&m=145765526817347&w=2 

Perhaps you could summarize the discussion in the commit message.

> Existing fail-open mechanism for nfqueue only applies for message that cannot be sent due to queue size (queue_maxlen). It does not apply when the failure is due to socket receive buffer size. This seems to be quite arbitrary since different packet sizes for the same queue and buffer sizes yield failure for different reasons.
> 
> This patch makes both behave the same. 

This should go into the commit log, not here.

> There is also a change in the proc file (/proc/net/netfilter/nfnetlink_queue) to account for the fail-opened packets.
 
> One change to existing behavior which I would like to stress is in the function netlink_unicast (now in netlink_unicast_nofree). In case where a call to sk_filter() returned non-zero value, netlink_unicast would set its returned error value to skb->len. I don't see how this ever made sense and I couldn't find anyone looking at this value. I changed this in order to have a consistent (err<0) return value on errors which was required for my changes. If anyone sees a problem with this change I'd like to know.

Should be done in a separate change.

It looks like a bug -- AFAICS if a sk filter is active on the nfnetlink
sk we will believe sk got queued and will put the (free'd) skb ptr on
the reinject list.

Added here:
   commit b1153f29ee07dc1a788964409255a4b4fae50b98
   Author: Stephen Hemminger <shemminger@vyatta.com>
   netlink: make socket filters work on netlink

It looks like the intent is to hide the error from writes happening
on netlink sk, but doing so also hides it from nfnetlink_queue which
relies on skb having been attached to the sk when we don't see an error.

Maybe Stephen remembers details?
Is the error masking intentional/needed?

If so it seems we will need to refactor this a bit to
differentiate between kernel-internal caller and "called
on behalf of userspace"....

> -
> +        unsigned int queue_failopened;
> +        unsigned int nobuf_failopened;

Is this useful...?

Userspace already should get -ENOBUFS errors on netlink overrun.

> -	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %2d\n",
> +	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %5u %5u %2d\n",

Problematic since it changes layout of a file we unfortunately have to
view as uapi.

I would prefer if we could leave the proc file alone and not
add any new stats counters for this, unless there is a good argument
for doing so.

> +			     long *timeo, struct sock *ssk)
> +{
> +    int ret = netlink_attachskb_nofree(sk, skb, timeo, ssk);
> +    if (ret < 0)
> +	kfree_skb(skb);
> +    return ret;
> +}

Seems this patch is whitespace damaged.
Please send a patch to yourself and make sure it applies cleanly via git-am.

> @@ -1752,7 +1760,6 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
>  		sock_put(sk);
>  
>  		if (signal_pending(current)) {
> -			kfree_skb(skb);
>  			return sock_intr_errno(*timeo);
>  		}

This would make the {} unneded so these should be zapped too.
