From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next v3] net: split rt_genid for ipv4 and ipv6
Date: Fri, 26 Jul 2013 14:09:50 -0400
Message-ID: <1973541.1ksEzzDSut@sifl>
References: <1374745632-1624-1-git-send-email-fan.du@windriver.com> <20130725181314.GA24007@order.stressinduktion.org> <51F20DEF.2090108@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: nicolas.dichtel@6wind.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	steffen.klassert@secunet.com, netdev <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:64607 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab3GZSJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 14:09:54 -0400
Received: by mail-yh0-f54.google.com with SMTP id f73so1101677yha.41
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 11:09:53 -0700 (PDT)
In-Reply-To: <51F20DEF.2090108@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, July 26, 2013 01:49:35 PM Fan Du wrote:
> I take a look at SELINUX xfrm part, my limited understanding SELINUX XFRM
> rule should take global effect on all net name space in current
> implementation.

Yes, a SELinux policy load needs to bump the cache ID as the new SELinux 
policy could have an affect on the IPsec state (SELinux label associated with 
the SAs and SPD rules).
 
> diff --git a/security/selinux/include/xfrm.h
> b/security/selinux/include/xfrm.h index 65f67cb..4f72d2c 100644
> --- a/security/selinux/include/xfrm.h
> +++ b/security/selinux/include/xfrm.h
> @@ -50,8 +50,14 @@ int selinux_xfrm_decode_session(struct sk_buff *skb, u32
> *sid, int ckall);
> 
>   static inline void selinux_xfrm_notify_policyload(void)
>   {
> +       struct net *net;
> +
>          atomic_inc(&flow_cache_genid);
> -       rt_genid_bump(&init_net);
> +       rtnl_lock();
> +       for_each_net(net) {
> +               rt_genid_bump_all(net);
> +       }
> +       rtnl_unlock();
>   }
>   #else
>   static inline int selinux_xfrm_enabled(void)

-- 
paul moore
www.paul-moore.com
