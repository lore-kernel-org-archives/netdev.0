From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next 3/6] vxlan: fix byte order issues with NDA_PORT
Date: Mon, 29 Apr 2013 11:47:26 -0400
Message-ID: <OF8ABC3AAE.A5DC4C63-ON85257B5C.00551083-85257B5C.0056BE04@us.ibm.com>
References: <20130427213151.255971631@vyatta.com> <20130427213258.279619123@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:57701 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756984Ab3D2Prj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 11:47:39 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 29 Apr 2013 11:47:37 -0400
In-Reply-To: <20130427213258.279619123@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/27/2013 05:31:54 PM:

> From: Stephen Hemminger <stephen@networkplumber.org>

> The NDA_PORT attribute was added, but the author wasn't careful
> about width (port is 16 bits), or byte order.  The attribute was
> being dumped as 16 bits, but only 32 bit value would be accepted
> when setting up a device. Also, the remote port is in network
> byte order and was being compared with default port in host byte
> order.

        They were all in host order until your patch (though it looks like
I may have used __be16 instead of __u32 and it "worked" despite the
type error. I left it as 32 bits for netlink to be int-sized and not
have unintended promotions, not to mention because "vxlan_port" is 32bit,
and still is. I'm ok with switching them to network order and 16 bit,
but I think you should make "vxlan_port" the same byte
order and size as "remote_port" so the comparisons below don't require
byte-swapping at run-time, as the original code did not.

So my suggestion is you make vxlan_port be __be16 as part of this
patch, too.

> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> 
> --- a/drivers/net/vxlan.c   2013-04-27 13:38:57.232338603 -0700
> +++ b/drivers/net/vxlan.c   2013-04-27 13:56:54.050412049 -0700
> @@ -192,7 +192,7 @@ static int vxlan_fdb_info(struct sk_buff
>     if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
>        goto nla_put_failure;
> 
> -   if (rdst->remote_port && rdst->remote_port != vxlan_port &&
> +   if (rdst->remote_port && rdst->remote_port != htons(vxlan_port) &&
>         nla_put_be16(skb, NDA_PORT, rdst->remote_port))
>        goto nla_put_failure;
>     if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
> @@ -222,7 +222,7 @@ static inline size_t vxlan_nlmsg_size(vo
>     return NLMSG_ALIGN(sizeof(struct ndmsg))
>        + nla_total_size(ETH_ALEN) /* NDA_LLADDR */
>        + nla_total_size(sizeof(__be32)) /* NDA_DST */
> -      + nla_total_size(sizeof(__be32)) /* NDA_PORT */
> +      + nla_total_size(sizeof(__be16)) /* NDA_PORT */
>        + nla_total_size(sizeof(__be32)) /* NDA_VNI */
>        + nla_total_size(sizeof(__u32)) /* NDA_IFINDEX */
>        + nla_total_size(sizeof(struct nda_cacheinfo));
> @@ -317,7 +317,7 @@ static struct vxlan_fdb *vxlan_find_mac(
> 
>  /* Add/update destinations for multicast */
>  static int vxlan_fdb_append(struct vxlan_fdb *f,
> -             __be32 ip, __u32 port, __u32 vni, __u32 ifindex)
> +             __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
>  {
>     struct vxlan_rdst *rd_prev, *rd;
> 
> @@ -346,7 +346,7 @@ static int vxlan_fdb_append(struct vxlan
>  static int vxlan_fdb_create(struct vxlan_dev *vxlan,
>               const u8 *mac, __be32 ip,
>               __u16 state, __u16 flags,
> -             __u32 port, __u32 vni, __u32 ifindex,
> +             __be16 port, __u32 vni, __u32 ifindex,
>               __u8 ndm_flags)
>  {
>     struct vxlan_fdb *f;
> @@ -444,7 +444,8 @@ static int vxlan_fdb_add(struct ndmsg *n
>     struct vxlan_dev *vxlan = netdev_priv(dev);
>     struct net *net = dev_net(vxlan->dev);
>     __be32 ip;
> -   u32 port, vni, ifindex;
> +   __be16 port;
> +   u32 vni, ifindex;
>     int err;
> 
>     if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
> @@ -462,11 +463,11 @@ static int vxlan_fdb_add(struct ndmsg *n
>     ip = nla_get_be32(tb[NDA_DST]);
> 
>     if (tb[NDA_PORT]) {
> -      if (nla_len(tb[NDA_PORT]) != sizeof(u32))
> +      if (nla_len(tb[NDA_PORT]) != sizeof(__be16))
>           return -EINVAL;
> -      port = nla_get_u32(tb[NDA_PORT]);
> +      port = nla_get_be16(tb[NDA_PORT]);
>     } else
> -      port = vxlan_port;
> +      port = htons(vxlan_port);
> 
>     if (tb[NDA_VNI]) {
>        if (nla_len(tb[NDA_VNI]) != sizeof(u32))
> @@ -489,8 +490,8 @@ static int vxlan_fdb_add(struct ndmsg *n
>        ifindex = 0;
> 
>     spin_lock_bh(&vxlan->hash_lock);
> -   err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags, port,
> -      vni, ifindex, ndm->ndm_flags);
> +   err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags,
> +                port, vni, ifindex, ndm->ndm_flags);
>     spin_unlock_bh(&vxlan->hash_lock);
> 
>     return err;
> @@ -964,12 +965,13 @@ static netdev_tx_t vxlan_xmit_one(struct
>     struct udphdr *uh;
>     struct flowi4 fl4;
>     __be32 dst;
> -   __u16 src_port, dst_port;
> +   __u16 src_port;
> +   __be16 dst_port;
>          u32 vni;
>     __be16 df = 0;
>     __u8 tos, ttl;
> 
> -   dst_port = rdst->remote_port ? rdst->remote_port : vxlan_port;
> +   dst_port = rdst->remote_port ? rdst->remote_port : 
htons(vxlan_port);
>     vni = rdst->remote_vni;
>     dst = rdst->remote_ip;
> 
> @@ -1050,7 +1052,7 @@ static netdev_tx_t vxlan_xmit_one(struct
>     skb_reset_transport_header(skb);
>     uh = udp_hdr(skb);
> 
> -   uh->dest = htons(dst_port);
> +   uh->dest = dst_port;
>     uh->source = htons(src_port);
> 
>     uh->len = htons(skb->len);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
