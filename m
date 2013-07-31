From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v5 2/7] vxlan: Restructure vxlan receive for
 multiple protocols.
Date: Wed, 31 Jul 2013 16:47:49 -0700
Message-ID: <20130731164749.58b6ee1b@nehalam.linuxnetplumber.net>
References: <1375312469-18623-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:48294 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab3GaXry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:47:54 -0400
Received: by mail-pd0-f172.google.com with SMTP id z11so586671pdj.31
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 16:47:53 -0700 (PDT)
In-Reply-To: <1375312469-18623-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Jul 2013 16:14:29 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> -- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -57,6 +57,7 @@
>  #define VXLAN_VID_MASK	(VXLAN_N_VID - 1)
>  /* IP header + UDP + VXLAN + Ethernet header */
>  #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
> +#define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
>  
>  #define VXLAN_FLAGS 0x08000000	/* struct vxlanhdr.vx_flags required value. */
>  
> @@ -82,8 +83,12 @@ static int vxlan_net_id;
>  
>  static const u8 all_zeros_mac[ETH_ALEN];
>  
> +struct vxlan_sock;
> +typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
> +
>  /* per UDP socket information */
>  struct vxlan_sock {
> +	vxlan_rcv_t	 *rcv;
>  	struct hlist_node hlist;
>  	struct rcu_head	  rcu;
>  	struct work_struct del_work;
> @@ -211,6 +216,18 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
>  	return NULL;
>  }
>  
> +static struct vxlan_dev *vxlan_find_vni_port(struct vxlan_sock *vs, u32 id)
> +{
> +	struct vxlan_dev *vxlan;
> +
> +	hlist_for_each_entry_rcu(vxlan, vni_head(vs, id), hlist) {
> +		if (vxlan->default_dst.remote_vni == id)
> +			return vxlan;
> +	}
> +
> +	return NULL;
> +}
> +
>  /* Fill in neighbour message in skbuff. */
>  static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
>  			  const struct vxlan_fdb *fdb,
> @@ -836,23 +853,16 @@ static void vxlan_igmp_work(struct work_struct *work)
>  /* Callback from net/ipv4/udp.c to receive packets */
>  static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
>  {
> -	struct iphdr *oip;
> +	struct vxlan_sock *vs;
>  	struct vxlanhdr *vxh;
> -	struct vxlan_dev *vxlan;
> -	struct pcpu_tstats *stats;
>  	__be16 port;
> -	__u32 vni;
> -	int err;
> -
> -	/* pop off outer UDP header */
> -	__skb_pull(skb, sizeof(struct udphdr));
>  
>  	/* Need Vxlan and inner Ethernet header to be present */
> -	if (!pskb_may_pull(skb, sizeof(struct vxlanhdr)))
> +	if (!pskb_may_pull(skb, VXLAN_HLEN))
>  		goto error;

This patch would be clearer if split into two parts.
One for the parsing changes (like VXLAN_HLEN) and other for the receive
callback.
