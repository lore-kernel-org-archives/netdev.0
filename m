From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v02: Enforcement for SELinux
Date: Wed, 20 Sep 2006 17:08:54 -0400
Message-ID: <36282A1733C57546BE392885C061859201573267@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:25766 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932104AbWITVJO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 17:09:14 -0400
To: Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static int selinux_skb_policy_check(struct sk_buff *skb, 
> unsigned short
> > family) +{
> > +	u32 xfrm_sid, trans_sid;
> > +	int err;
> > +
> > +	if (selinux_compat_net)
> > +		return 1;
> > +
> > +	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
> > +	BUG_ON(err);
> 
> First, any reason against including the "struct sock *" in 
> the LSM hook?  At a 
> quick glance it looks like it is available at each place 
> security_skb_policy_check() is invoked?  If there are no 
> objections I would 
> like to see it included in the hook.

There's no sock available (NULL) for forward, no-sock, time-wait cases, etc.

What you are trying to accomplish with the sock here anyway?

> 
> Second, I wonder if it would be better to do a NetLabel/CIPSO 
> query here using 
> the xfrm_sid as the NetLabel "base_sid" instead of at the end 
> of the function 
> (see your comment)?  This way we wouldn't have to duplicate the 
> avc_has_perm() and security_transition_sid() calls for both xfrm and 
> NetLabel.

There's a need for an additional avc_has_perm check anyway between
the cipso label and the ipsec/transition label, to check to make sure
the cipso level falls within the range on the IPSec/transition SA.

No need for a new transition between ipsec/transition label and the cipso
label since the cipso label would be sharing the TE portion with the
ipsec/transition label (this could change in the future, when you get round
to doing entire SELinux contexts over the wire). For now, you would just
set the secmark to the cipso label if the label could come thru
(i.e. if the avc_has_perm succeeds).
