From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/3] SELinux: return -ECONNREFUSED from ip_postroute to
 signal fatal error
Date: Fri, 19 Nov 2010 10:11:55 -0500
Message-ID: <1290179515.8839.41.camel@sifl>
References: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com>
	 <20101116215257.6727.12163.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	selinux@tycho.nsa.gov, netfilter-devel@vger.kernel.org,
	equinox@diac24.net, eric.dumazet@gmail.com, davem@davemloft.net,
	hzhong@gmail.com, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, sds@tycho.nsa.gov,
	yoshfuji@linux-ipv6.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:34756 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab0KSPME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 10:12:04 -0500
In-Reply-To: <20101116215257.6727.12163.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-16 at 16:52 -0500, Eric Paris wrote:
> The SELinux netfilter hooks just return NF_DROP if they drop a packet.  We
> want to signal that a drop in this hook is a permanant fatal error and is not
> transient.  If we do this the error will be passed back up the stack in some
> places and applications will get a faster interaction that something went
> wrong.

Sorry for the delay, but I wasn't able to respond until today ...

> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 8ba5001..b1104f9 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4594,11 +4594,11 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
>  				secmark_perm = PACKET__SEND;
>  			break;
>  		default:
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);
>  		}
>  		if (secmark_perm == PACKET__FORWARD_OUT) {
>  			if (selinux_skb_peerlbl_sid(skb, family, &peer_sid))
> -				return NF_DROP;
> +				return NF_DROP_ERR(-ECONNREFUSED);

The error condition here isn't due to a policy decision, but some
runtime error that happened when trying to determine the peer label of
an individual packet.  I think leaving this as just NF_DROP is the right
thing to do as an error here can be temporary.

>  		} else
>  			peer_sid = SECINITSID_KERNEL;
>  	} else {
> @@ -4611,28 +4611,28 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
>  	ad.u.net.netif = ifindex;
>  	ad.u.net.family = family;
>  	if (selinux_parse_skb(skb, &ad, &addrp, 0, NULL))
> -		return NF_DROP;
> +		return NF_DROP_ERR(-ECONNREFUSED);

Same thing, this is a transient error and not due to a policy decision.
We should keep this as NF_DROP.

>  	if (secmark_active)
>  		if (avc_has_perm(peer_sid, skb->secmark,
>  				 SECCLASS_PACKET, secmark_perm, &ad))
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);

Yep, this is a good place as the error is the result of a policy
decision, i.e. an avc_has_perm() call.

>  	if (peerlbl_active) {
>  		u32 if_sid;
>  		u32 node_sid;
>  
>  		if (sel_netif_sid(ifindex, &if_sid))
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);

Another transient error case, should be NF_DROP.

>  		if (avc_has_perm(peer_sid, if_sid,
>  				 SECCLASS_NETIF, NETIF__EGRESS, &ad))
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);

Good.
 
>  		if (sel_netnode_sid(addrp, family, &node_sid))
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);

Bad.

>  		if (avc_has_perm(peer_sid, node_sid,
>  				 SECCLASS_NODE, NODE__SENDTO, &ad))
> -			return NF_DROP;
> +			return NF_DROP_ERR(-ECONNREFUSED);

Good.  I think you get the idea now.

Also, while I think we can ignore the forwarding and output hooks, we do
need to change the NF_DROPs in selinux_ip_postroute_compat() ... I'd
suggest the following (the last change catches more than just policy
decisions but considering the "compat" nature I think a little wiggle
room is okay here):

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 65fa8bf..de1b79e 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4520,11 +4520,11 @@ static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
        if (selinux_secmark_enabled())
                if (avc_has_perm(sksec->sid, skb->secmark,
                                 SECCLASS_PACKET, PACKET__SEND, &ad))
-                       return NF_DROP;
+                       return NF_DROP_ERR(-ECONNREFUSED);
 
        if (selinux_policycap_netpeer)
                if (selinux_xfrm_postroute_last(sksec->sid, skb, &ad, proto))
-                       return NF_DROP;
+                       return NF_DROP_ERR(-ECONNREFUSED);
 
        return NF_ACCEPT;
 }

-- 
paul moore
linux @ hp


