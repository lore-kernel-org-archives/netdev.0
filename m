From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 4/7] secid reconciliation-v02: Invoke LSM hook for outbound
 traffic
Date: Mon, 18 Sep 2006 15:12:18 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609181456060.5976@d.namei>
References: <45019F66.20603@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:56530 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932301AbWIRTMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 15:12:22 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45019F66.20603@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Sep 2006, Venkat Yekkirala wrote:

> -static void secmark_restore(struct sk_buff *skb)
> +static unsigned int secmark_restore(struct sk_buff *skb, unsigned int
> hooknum,
> +			   const struct xt_target *target)
> {
> -	if (!skb->secmark) {
> -		u32 *connsecmark;
> -		enum ip_conntrack_info ctinfo;
> +	u32 *psecmark;
> +	u32 secmark = 0;
> +	enum ip_conntrack_info ctinfo;
> 
> -		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
> -		if (connsecmark && *connsecmark)
> -			if (skb->secmark != *connsecmark)
> -				skb->secmark = *connsecmark;
> -	}
> +	psecmark = nf_ct_get_secmark(skb, &ctinfo);
> +	if (psecmark)
> +		secmark = *psecmark;
> +
> +	if (!secmark)
> +		return XT_CONTINUE;
> +
> +	/* Set secmark on inbound and filter it on outbound */
> +	if (hooknum == NF_IP_POST_ROUTING || hooknum == NF_IP6_POST_ROUTING) {
> +		if (!security_skb_netfilter_check(skb, secmark))
> +			return NF_DROP;
> +	} else
> +		if (skb->secmark != secmark)
> +			skb->secmark = secmark;
> +
> +	return XT_CONTINUE;
> }

Quite a lot of logic has changed here.

With the original code, we only restored a secmark once for the lifetime 
of a packet or connetcion (to make behavior deterministic and security 
marks immutable in the face of arbitrarily complex iptables rules).

With your patch, secmarks are always writable.

What about packets on the OUTPUT hook?

Also, we did not restore a 'null' (zero) secmark to the skb (while this 
should never happen with the current SECMARK target, there may be 
non-SELinux extensions later which set a null marking).

Why not just do something like:


	psecmark = nf_ct_get_secmark(skb, &ctinfo);
	if (psecmark && *psecmark) {

		... core of function ...

	}

	return XT_CONTINUE;

I don't think you need the new secmark variable.

You've also changed the logic for the dummy case of 
security_skb_netfilter_check()


+static inline int security_skb_netfilter_check(struct sk_buff *skb,
+                                       u32 nf_secid)
+{
+       return 1;
+}
+

This code does not now behave as it did originally.  Keep in mind that 
SELinux is not the only user of SECMARK.

(The documentation of the hook in security.h doesn't match the behavior, 
either -- it's (re-)labeling, not just filtering).

I really don't know if connection tracking is the right place to be doing 
policy enforcment, either.  Perhaps you should just do the relabeling here 
and enforcement later.

The xt_SECMARK.c case has similar issues to all of the above.



- James
-- 
James Morris
<jmorris@namei.org>
