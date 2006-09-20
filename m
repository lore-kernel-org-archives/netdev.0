From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 4/7] secid reconciliation-v02: Invoke LSM hook for out
	bound traffic
Date: Wed, 20 Sep 2006 15:49:36 -0400
Message-ID: <36282A1733C57546BE392885C061859201573239@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:14384 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932344AbWITTuB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 15:50:01 -0400
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

See below.

> -----Original Message-----
> From: James Morris [mailto:jmorris@namei.org]
> Sent: Monday, September 18, 2006 2:12 PM
> To: Venkat Yekkirala
> Cc: netdev@vger.kernel.org; selinux@tycho.nsa.gov; sds@tycho.nsa.gov;
> chanson@trustedcs.com
> Subject: Re: [PATCH 4/7] secid reconciliation-v02: Invoke LSM hook for
> outbound traffic
> 
> 
> On Fri, 8 Sep 2006, Venkat Yekkirala wrote:
> 
> > -static void secmark_restore(struct sk_buff *skb)
> > +static unsigned int secmark_restore(struct sk_buff *skb, 
> unsigned int
> > hooknum,
> > +			   const struct xt_target *target)
> > {
> > -	if (!skb->secmark) {
> > -		u32 *connsecmark;
> > -		enum ip_conntrack_info ctinfo;
> > +	u32 *psecmark;
> > +	u32 secmark = 0;
> > +	enum ip_conntrack_info ctinfo;
> > 
> > -		connsecmark = nf_ct_get_secmark(skb, &ctinfo);
> > -		if (connsecmark && *connsecmark)
> > -			if (skb->secmark != *connsecmark)
> > -				skb->secmark = *connsecmark;
> > -	}
> > +	psecmark = nf_ct_get_secmark(skb, &ctinfo);
> > +	if (psecmark)
> > +		secmark = *psecmark;
> > +
> > +	if (!secmark)
> > +		return XT_CONTINUE;
> > +
> > +	/* Set secmark on inbound and filter it on outbound */
> > +	if (hooknum == NF_IP_POST_ROUTING || hooknum == 
> NF_IP6_POST_ROUTING) {
> > +		if (!security_skb_netfilter_check(skb, secmark))
> > +			return NF_DROP;
> > +	} else
> > +		if (skb->secmark != secmark)
> > +			skb->secmark = secmark;
> > +
> > +	return XT_CONTINUE;
> > }
> 
> Quite a lot of logic has changed here.
> 
> With the original code, we only restored a secmark once for 
> the lifetime 
> of a packet or connetcion (to make behavior deterministic and 
> security 
> marks immutable in the face of arbitrarily complex iptables rules).
> 
> With your patch, secmarks are always writable.

Hopefully the following thread addressed these concerns.
http://marc.theaimsgroup.com/?l=selinux&m=115870100405571&w=2

> 
> What about packets on the OUTPUT hook?

I will check for OUTPUT as well as POSTROUTING to kickoff skb_flow_out().

> 
> Also, we did not restore a 'null' (zero) secmark to the skb 
> (while this 
> should never happen with the current SECMARK target, there may be 
> non-SELinux extensions later which set a null marking).

How do you envision this (i.e. resoring a null secmark) being useful?
secmark is anyway zero by default (when no labeling rules exist for the
connection) right?

> 
> Why not just do something like:
> 
> 
> 	psecmark = nf_ct_get_secmark(skb, &ctinfo);
> 	if (psecmark && *psecmark) {
> 
> 		... core of function ...
> 
> 	}
> 
> 	return XT_CONTINUE;
> 
> I don't think you need the new secmark variable.

Will do.

> 
> You've also changed the logic for the dummy case of 
> security_skb_netfilter_check()

I am not getting this. This is a new function. Did you mean
to point to a different function?

> 
> 
> +static inline int security_skb_netfilter_check(struct sk_buff *skb,
> +                                       u32 nf_secid)
> +{
> +       return 1;
> +}
> +
> 
> This code does not now behave as it did originally.  Keep in 
> mind that 
> SELinux is not the only user of SECMARK.

Missed this as well (this is a new function in this patch). Please
elaborate.
> 
> (The documentation of the hook in security.h doesn't match 
> the behavior, 
> either -- it's (re-)labeling, not just filtering).

Will fix this.

> 
> I really don't know if connection tracking is the right place 
> to be doing 
> policy enforcment, either.  Perhaps you should just do the 
> relabeling here 
> and enforcement later.

We could have done enforcement, in the SELinux postroute_last
hook for example, if only there were a place to hold onto the
"exit point context", separate from the label already associated
with the skb in the secmark field. postroute_last would need BOTH
the label of the skb (available in the secmark field) and the
"exit point context" to do enforcement.
