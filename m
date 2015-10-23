From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v3] openvswitch: Fix egress tunnel info.
Date: Fri, 23 Oct 2015 20:22:07 +0200
Message-ID: <20151023202207.1533982b@griffin>
References: <1445563036-9623-1-git-send-email-pshelar@nicira.com>
	<20151023141738.4db54324@griffin>
	<CALnjE+oOrvGmXuW0aexHt_CO2W7DEMLJyHzW3psCFuK+aG+5Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbbJWSWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 14:22:11 -0400
In-Reply-To: <CALnjE+oOrvGmXuW0aexHt_CO2W7DEMLJyHzW3psCFuK+aG+5Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Oct 2015 10:30:24 -0700, Pravin Shelar wrote:
> I see lot of refactoring scope for vxlan code even without this patch.
> I am planing to address it in net-next.

Great, thanks a lot!

> > What about IPv6? There's IPv6 support for metadata based vxlan in
> > net.git, thus this should have IPv6 support, too. But then, this is
> > currently used only by ovs which got the IPv6 support only in
> > net-next.git, thus it may be enough to fix it there.
> >
> I did choose to implement only for ipv4 since it is pretty late for
> fix so wanted to keep simple as possible. IPv6 support is not there
> yet anyways.

Okay.

> > This doesn't do what the name suggests and is, actually, ovs specific.
> > The ip_tunnel_info can be provided as a part of lwtstate and this
> > function should handle that case, too. This is not a problem for
> > net.git, as the function just returns EINVAL in such case, but should
> > be addressed for net-next.git. As ovs is currently the only user, I'd
> > be also fine with just a comment stating that, so it's clear for future
> > users of this function that it needs to be extended before it can be
> > used out of ovs.
> >
> 
> I considered lwstate, but I am reluctant to add this complexity
> without a usecase.

I don't think it's complex. See the quick and dirty patch below (that
has even a negative diffstat):

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index ce009710120c..3a1d3966a79e 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -60,36 +60,25 @@ static inline struct metadata_dst *tun_rx_dst(int md_size)
 	return tun_dst;
 }
 
-static inline struct metadata_dst *tun_dst_unclone(struct sk_buff *skb)
+static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb)
 {
-	struct metadata_dst *md_dst = skb_metadata_dst(skb);
-	int md_size = md_dst->u.tun_info.options_len;
+	struct metadata_dst *dst;
+	struct ip_tunnel_info *info = skb_tunnel_info(skb);
 	struct metadata_dst *new_md;
 
-	if (!md_dst)
+	if (!info)
 		return ERR_PTR(-EINVAL);
-
-	new_md = metadata_dst_alloc(md_size, GFP_ATOMIC);
+	new_md = metadata_dst_alloc(info->options_len, GFP_ATOMIC);
 	if (!new_md)
 		return ERR_PTR(-ENOMEM);
 
-	memcpy(&new_md->u.tun_info, &md_dst->u.tun_info,
-	       sizeof(struct ip_tunnel_info) + md_size);
+	memcpy(&new_md->u.tun_info, info,
+	       sizeof(struct ip_tunnel_info) + info->options_len);
 	skb_dst_drop(skb);
 	dst_hold(&new_md->dst);
 	skb_dst_set(skb, &new_md->dst);
-	return new_md;
-}
-
-static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb)
-{
-	struct metadata_dst *dst;
-
-	dst = tun_dst_unclone(skb);
-	if (IS_ERR(dst))
-		return NULL;
 
-	return &dst->u.tun_info;
+	return info;
 }
 
 static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,

> I agree in general it is true, but this is only called in OVS case. In
> that context ENOMEM is common error case than any other case. But I
> see your point, I will send patch to fix the return code.

Thanks. It's better to make this right from the start to avoid
surprises later when we build on the code.

> 
> >> +     if (unlikely(!(info->mode & IP_TUNNEL_INFO_TX)))
> >> +             return -EINVAL;
> >
> > It would be much better to check the mode before copying the metadata.
> >
> This is pretty rare case, Thats why I would rather keep the code
> simple and not to call skb_tunnel_info() and then
> skb_tunnel_info_unclone() to optimize this case.

The extra skb_tunnel_info call is not a big deal but you're right that
this should be rare. And the code is correct even the way you wrote it,
it just has an extra allocation in the rare case. No problem.

> > This should at least check whether the tun_info is indeed IPv4. Actual
> > IPv6 support for this function can be added to net-next.git.
> >
> net tree only supports IPv4 tunnels. I am not sure value of this
> check, specially since we need differ changes on net-next.

You're right.

Thanks,

 Jiri

-- 
Jiri Benc
