From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH v4 1/2] NetLabel: secid reconciliation support
Date: Wed, 4 Oct 2006 12:59:41 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF8A5@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: eparis@redhat.com, jmorris@namei.org, sds@tycho.nsa.gov,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:13121 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161671AbWJDRAI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 13:00:08 -0400
To: paul.moore@hp.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -3714,19 +3714,34 @@ static int selinux_skb_flow_in(struct sk
>  	if (skb->dev == &loopback_dev)
>  		return 1;
>  
> +	if (skb->secmark)
> +		loc_sid = skb->secmark;
> +	else
> +		loc_sid = SECINITSID_NETMSG;
> +
>  	err = selinux_xfrm_decode_session(skb, &xfrm_sid, 0);
>  	BUG_ON(err);
> -
> -	err = avc_has_perm(xfrm_sid, skb->secmark? : SECINITSID_NETMSG,
> -					SECCLASS_PACKET,
> -					PACKET__FLOW_IN, NULL);
> +	err = selinux_netlbl_skb_sid(skb,
> +				     xfrm_sid ? xfrm_sid : loc_sid,
> +				     &nlbl_sid);
>  	if (err)
>  		goto out;
>  
> -	if (xfrm_sid)
> -		skb->secmark = xfrm_sid;
> +	if (nlbl_sid)
> +		ext_sid = nlbl_sid;
> +	else
> +		ext_sid = xfrm_sid;

There's a problem here in that it would require 2 different policies
depending on whether one is using netlabel or xfrm. Specifically, in
the absence of matching iptables contexts (secmark), the skb here
will get:

- 0 (xfrm case)
- network_t (netlabel)

This has implications for getpeercon() where it would

- fail with ENOPROTOOPT (xfrm case)
- returns network_t (netlabel)

I would still argue that the nature of the domain being carried by
the packet is still unlabeled_t as implied by the null secmark. While
I view secmark/point as specifying BOTH a flow control point and a
default domain (incidentally using the same label more because of
implementation constrainst), I view network_t as purely a flow control
point.

But I also realize there can be equally forceful arguments for what this
patch does.

What does the community think? We need to resolve it one way or the
other unless the above differences in behavior are desired or somehow
accounted for in policy and apps.

> +
> +	err = avc_has_perm(ext_sid,
> +			   loc_sid,
> +			   SECCLASS_PACKET,
> +			   PACKET__FLOW_IN,
> +			   NULL);
> +	if (err)
> +		goto out;
>  
> -	/* See if NetLabel can flow in thru the current secmark here */
> +	if (ext_sid)
> +		skb->secmark = ext_sid;
>  
>  out:
>  	return err ? 0 : 1;
> 
