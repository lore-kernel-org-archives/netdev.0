From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 13:58:22 -0700
Message-ID: <20120924205822.GI26494@x200.localdomain>
References: <20120924184304.727711327@vyatta.com>
 <20120924185050.162920909@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709Ab2IXU6Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 16:58:24 -0400
Content-Disposition: inline
In-Reply-To: <20120924185050.162920909@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger (shemminger@vyatta.com) wrote:
> This is an implementation of Virtual eXtensible Local Area Network
> as described in draft RFC:
>   http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02
> 
> The driver integrates a Virtual Tunnel Endpoint (VTEP) functionality
> that learns MAC to IP address mapping. 
> 
> This implementation has not been tested for Interoperation with
> other equipment.

I'm working on doing some interop

> --- a/drivers/net/Kconfig	2012-09-24 10:56:57.080291529 -0700
> +++ b/drivers/net/Kconfig	2012-09-24 11:08:02.865416523 -0700
> @@ -149,6 +149,19 @@ config MACVTAP
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called macvtap.
>  
> +config VXLAN
> +       tristate "Virtual eXtensible Local Area Network (VXLAN)"
> +       depends on EXPERIMENTAL
> +       ---help---
> +	  This allows one to create vxlan virtual interfaces that provide
> +	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
> +	  to tunnel virtual network infrastructure in virtualized environments.
> +	  For more information see:
> +	    http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called macvlan.
                         ^^^^^^^
Cut 'n paste error, s/macvlan/vxlan/

> +/* Add static entry (via netlink) */
> +static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> +			 struct net_device *dev,
> +			 const unsigned char *addr, u16 flags)
> +{
> +	struct vxlan_dev *vxlan = netdev_priv(dev);
> +	__be32 ip;
> +	int err;
> +
> +	if (tb[NDA_DST] == NULL)
> +		return -EINVAL;
> +
> +	if (nla_len(tb[NDA_DST]) != sizeof(__be32))
> +		return -EAFNOSUPPORT;
> +
> +	ip = nla_get_be32(tb[NDA_DST]);
> +
> +	spin_lock_bh(&vxlan->hash_lock);
> +	err = vxlan_fdb_create(vxlan, addr, ip, VXLAN_FDB_PERM);

Any reason to force permanent when created from userspace?

> +static bool vxlan_group_used(struct vxlan_net *vn,
> +			     const struct vxlan_dev *this)
> +{
> +	const struct vxlan_dev *vxlan;
> +	struct hlist_node *node;
> +	unsigned h;
> +
> +	for (h = 0; h < VNI_HASH_SIZE; ++h)
> +		hlist_for_each_entry(vxlan, node, &vn->vni_list[h], hlist) {

is walking this chain only protected with rtnl?

> +/* Propogate ECN from outer IP header to tunneled packet */
> +static inline void vxlan_ecn_decap(const struct iphdr *iph, struct sk_buff *skb)
> +{
> +	if (INET_ECN_is_ce(iph->tos)) {
> +		if (skb->protocol == htons(ETH_P_IP))
> +			IP_ECN_set_ce(ip_hdr(skb));
> +		else if (skb->protocol == htons(ETH_P_IPV6))
> +			IP6_ECN_set_ce(ipv6_hdr(skb));
> +	}
> +}
<snip>
> +/* Propogate ECN bits out */
> +static inline u8 vxlan_ecn_encap(u8 tos,
> +				 const struct iphdr *iph,
> +				 const struct sk_buff *skb)
> +{
> +	u8 inner = vxlan_get_dsfield(iph, skb);
> +
> +	return INET_ECN_encapsulate(tos, inner);
> +}

Goal is to be RFC 6040 compliant, and it looks like some edge cases aren't
met, for example, should drop on decap when inner is not supporting ECN
and outer has set CE.

<snip>
> +/* Callback from net/ipv4/udp.c to receive packets */
> +	/* Mark socket as an encapsulation socket. */
> +	udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;

I don't think we need this particular encap_type value, just != 0

> +	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
> +	udp_encap_enable();
