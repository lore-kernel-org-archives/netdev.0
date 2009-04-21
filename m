From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Tue, 21 Apr 2009 21:58:51 +0200
Message-ID: <49EE257B.6090600@cosmosbay.com>
References: <20090421193937.GC9577@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52566 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbZDUT7A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 15:59:00 -0400
In-Reply-To: <20090421193937.GC9577@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcastO=
ctets and
> OutMcastOctets:
> http://tools.ietf.org/html/rfc4293
> But it seems we don't track those in any way that easy to separate fr=
om other
> protocols.  This patch adds those missing counters to the stats file.=
  Tested
> successfully by me
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
>=20
>  include/linux/snmp.h  |    4 ++++
>  net/ipv4/ip_input.c   |    4 ++++
>  net/ipv4/ip_output.c  |    3 +++
>  net/ipv4/proc.c       |    4 ++++
>  net/ipv6/ip6_input.c  |    4 ++++
>  net/ipv6/ip6_output.c |    8 ++++++++
>  net/ipv6/mcast.c      |    9 +++++++++
>  net/ipv6/ndisc.c      |    3 +++
>  net/ipv6/proc.c       |    4 ++++
>  net/ipv6/raw.c        |    6 ++++++
>  10 files changed, 49 insertions(+)
>=20
> diff --git a/include/linux/snmp.h b/include/linux/snmp.h
> index aee3f1e..95c17f6 100644
> --- a/include/linux/snmp.h
> +++ b/include/linux/snmp.h
> @@ -19,6 +19,8 @@ enum
>  {
>  	IPSTATS_MIB_NUM =3D 0,
>  	IPSTATS_MIB_INRECEIVES,			/* InReceives */
> +	IPSTATS_MIB_INOCTETS,			/* InOctets */
> +	IPSTATS_MIB_INMCASTOCTETS,		/* InMcastOctets */
>  	IPSTATS_MIB_INHDRERRORS,		/* InHdrErrors */
>  	IPSTATS_MIB_INTOOBIGERRORS,		/* InTooBigErrors */
>  	IPSTATS_MIB_INNOROUTES,			/* InNoRoutes */
> @@ -29,6 +31,8 @@ enum
>  	IPSTATS_MIB_INDELIVERS,			/* InDelivers */
>  	IPSTATS_MIB_OUTFORWDATAGRAMS,		/* OutForwDatagrams */
>  	IPSTATS_MIB_OUTREQUESTS,		/* OutRequests */
> +	IPSTATS_MIB_OUTOCTETS,			/* OutOctets */
> +	IPSTATS_MIB_OUTMCASTOCTETS,		/* OutMcastOctets */
>  	IPSTATS_MIB_OUTDISCARDS,		/* OutDiscards */
>  	IPSTATS_MIB_OUTNOROUTES,		/* OutNoRoutes */
>  	IPSTATS_MIB_REASMTIMEOUT,		/* ReasmTimeout */
> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index 1a58a6f..bc9169b 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -385,6 +385,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt,
>  		goto drop;
> =20
>  	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INRECEIVES);
> +	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_INOCTETS, skb->len);
> =20
>  	if ((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NULL) {
>  		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
> @@ -396,6 +397,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt,
> =20
>  	iph =3D ip_hdr(skb);
> =20
> +	if (ipv4_is_multicast(iph->daddr))
> +		IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_INMCASTOCTETS, skb->len)=
;
> +
>  	/*
>  	 *	RFC1122: 3.2.1.2 MUST silently discard any IP frame that fails t=
he checksum.
>  	 *
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 3e7e910..8a68dc2 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -245,6 +245,8 @@ int ip_mc_output(struct sk_buff *skb)
>  	 *	If the indicated interface is up and running, send the packet.
>  	 */

>  	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
> +	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_OUTOCTETS, skb->len);
> +	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_OUTMCASTOCTETS, skb->len)=
;

So you use the _BH variant right after IP_INC_STATS() ?
Which one is right (or which one is false ?)


> =20
>  	skb->dev =3D dev;
>  	skb->protocol =3D htons(ETH_P_IP);
> @@ -299,6 +301,7 @@ int ip_output(struct sk_buff *skb)
>  	struct net_device *dev =3D skb->dst->dev;
> =20
>  	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
> +	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_OUTOCTETS, skb->len);

same here

> =20
>  	skb->dev =3D dev;
>  	skb->protocol =3D htons(ETH_P_IP);
> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
> index cf0cdee..ff75e7d 100644
> --- a/net/ipv4/proc.c
> +++ b/net/ipv4/proc.c
> @@ -91,6 +91,8 @@ static const struct file_operations sockstat_seq_fo=
ps =3D {
>  /* snmp items */
>  static const struct snmp_mib snmp4_ipstats_list[] =3D {
>  	SNMP_MIB_ITEM("InReceives", IPSTATS_MIB_INRECEIVES),
> +	SNMP_MIB_ITEM("InOctets", IPSTATS_MIB_INOCTETS),
> +	SNMP_MIB_ITEM("InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
>  	SNMP_MIB_ITEM("InHdrErrors", IPSTATS_MIB_INHDRERRORS),
>  	SNMP_MIB_ITEM("InAddrErrors", IPSTATS_MIB_INADDRERRORS),
>  	SNMP_MIB_ITEM("ForwDatagrams", IPSTATS_MIB_OUTFORWDATAGRAMS),
> @@ -98,6 +100,8 @@ static const struct snmp_mib snmp4_ipstats_list[] =
=3D {
>  	SNMP_MIB_ITEM("InDiscards", IPSTATS_MIB_INDISCARDS),
>  	SNMP_MIB_ITEM("InDelivers", IPSTATS_MIB_INDELIVERS),
>  	SNMP_MIB_ITEM("OutRequests", IPSTATS_MIB_OUTREQUESTS),
> +	SNMP_MIB_ITEM("OutOctets", IPSTATS_MIB_OUTOCTETS),
> +	SNMP_MIB_ITEM("OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
>  	SNMP_MIB_ITEM("OutDiscards", IPSTATS_MIB_OUTDISCARDS),
>  	SNMP_MIB_ITEM("OutNoRoutes", IPSTATS_MIB_OUTNOROUTES),
>  	SNMP_MIB_ITEM("ReasmTimeout", IPSTATS_MIB_REASMTIMEOUT),
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 8f04bd9..04a7057 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -71,6 +71,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt
>  	idev =3D __in6_dev_get(skb->dev);
> =20
>  	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INRECEIVES);
> +	IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_INOCTETS, skb->len);
> =20
>  	if ((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NULL ||
>  	    !idev || unlikely(idev->cnf.disable_ipv6)) {
> @@ -98,6 +99,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt
> =20
>  	hdr =3D ipv6_hdr(skb);
> =20
> +	if (ipv6_addr_is_multicast(&hdr->daddr))
> +		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_INMCASTOCTETS, skb->len);
> +
>  	if (hdr->version !=3D 6)
>  		goto err;
> =20
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 9fb49c3..99f79a1 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -277,6 +277,11 @@ int ip6_xmit(struct sock *sk, struct sk_buff *sk=
b, struct flowi *fl,
>  	if ((skb->len <=3D mtu) || skb->local_df || skb_is_gso(skb)) {
>  		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
>  			      IPSTATS_MIB_OUTREQUESTS);
> +		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb->dst),
> +			      IPSTATS_MIB_OUTOCTETS, skb->len);
> +		if (ipv6_addr_is_multicast(&hdr->daddr))
> +			IP6_ADD_STATS_BH(net, ip6_dst_idev(skb->dst),
> +			      IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
>  		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
>  				dst_output);
>  	}
> @@ -1517,6 +1522,9 @@ int ip6_push_pending_frames(struct sock *sk)
> =20
>  	skb->dst =3D dst_clone(&rt->u.dst);
>  	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
> +	IP6_ADD_STATS_BH(net, rt->rt6i_idev, IPSTATS_MIB_OUTOCTETS, skb->le=
n);
> +	if (ipv6_addr_is_multicast(&hdr->daddr))
> +		IP6_ADD_STATS_BH(net, rt->rt6i_idev, IPSTATS_MIB_OUTMCASTOCTETS, s=
kb->len);
>  	if (proto =3D=3D IPPROTO_ICMPV6) {
>  		struct inet6_dev *idev =3D ip6_dst_idev(skb->dst);
> =20
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index a51fb33..8cc77e9 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1450,6 +1450,9 @@ static void mld_sendpack(struct sk_buff *skb)
>  	struct flowi fl;
> =20
>  	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
> +	IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_OUTOCTETS, skb->len);
> +	IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTOCTETS, skb->len);

same here

> +
>  	payload_len =3D (skb->tail - skb->network_header) - sizeof(*pip6);
>  	mldlen =3D skb->tail - skb->transport_header;
>  	pip6->payload_len =3D htons(payload_len);
> @@ -1776,6 +1779,7 @@ static void igmp6_send(struct in6_addr *addr, s=
truct net_device *dev, int type)
>  	rcu_read_lock();
>  	IP6_INC_STATS(net, __in6_dev_get(dev),
>  		      IPSTATS_MIB_OUTREQUESTS);
> +
>  	rcu_read_unlock();
>  	if (type =3D=3D ICMPV6_MGM_REDUCTION)
>  		snd_addr =3D &in6addr_linklocal_allrouters;
> @@ -1786,6 +1790,11 @@ static void igmp6_send(struct in6_addr *addr, =
struct net_device *dev, int type)
>  	payload_len =3D len + sizeof(ra);
>  	full_len =3D sizeof(struct ipv6hdr) + payload_len;
> =20
> +	IP6_ADD_STATS_BH(net, __in6_dev_get(dev),
> +		      IPSTATS_MIB_OUTOCTETS, full_len);
> +	IP6_ADD_STATS_BH(net, __in6_dev_get(dev),
> +		      IPSTATS_MIB_OUTMCASTOCTETS, full_len);
> +
>  	skb =3D sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + full_len,=
 1, &err);
> =20
>  	if (skb =3D=3D NULL) {
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 9f061d1..5a22e6b 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -534,6 +534,7 @@ void ndisc_send_skb(struct sk_buff *skb,
> =20
>  	idev =3D in6_dev_get(dst->dev);
>  	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
> +	IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_OUTOCTETS, skb->len);

same

> =20
>  	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
>  		      dst_output);
> @@ -1614,6 +1615,8 @@ void ndisc_send_redirect(struct sk_buff *skb, s=
truct neighbour *neigh,
>  	buff->dst =3D dst;
>  	idev =3D in6_dev_get(dst->dev);
>  	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
> +	IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_OUTOCTETS, buff->len);
> +

same

>  	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
>  		      dst_output);
>  	if (!err) {
> diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
> index 97c17fd..aefd40d 100644
> --- a/net/ipv6/proc.c
> +++ b/net/ipv6/proc.c
> @@ -62,6 +62,8 @@ static const struct file_operations sockstat6_seq_f=
ops =3D {
>  static struct snmp_mib snmp6_ipstats_list[] =3D {
>  /* ipv6 mib according to RFC 2465 */
>  	SNMP_MIB_ITEM("Ip6InReceives", IPSTATS_MIB_INRECEIVES),
> +	SNMP_MIB_ITEM("Ip6InOctets", IPSTATS_MIB_INOCTETS),
> +	SNMP_MIB_ITEM("Ip6InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
>  	SNMP_MIB_ITEM("Ip6InHdrErrors", IPSTATS_MIB_INHDRERRORS),
>  	SNMP_MIB_ITEM("Ip6InTooBigErrors", IPSTATS_MIB_INTOOBIGERRORS),
>  	SNMP_MIB_ITEM("Ip6InNoRoutes", IPSTATS_MIB_INNOROUTES),
> @@ -72,6 +74,8 @@ static struct snmp_mib snmp6_ipstats_list[] =3D {
>  	SNMP_MIB_ITEM("Ip6InDelivers", IPSTATS_MIB_INDELIVERS),
>  	SNMP_MIB_ITEM("Ip6OutForwDatagrams", IPSTATS_MIB_OUTFORWDATAGRAMS),
>  	SNMP_MIB_ITEM("Ip6OutRequests", IPSTATS_MIB_OUTREQUESTS),
> +	SNMP_MIB_ITEM("Ip6OutOctets", IPSTATS_MIB_OUTOCTETS),
> +	SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
>  	SNMP_MIB_ITEM("Ip6OutDiscards", IPSTATS_MIB_OUTDISCARDS),
>  	SNMP_MIB_ITEM("Ip6OutNoRoutes", IPSTATS_MIB_OUTNOROUTES),
>  	SNMP_MIB_ITEM("Ip6ReasmTimeout", IPSTATS_MIB_REASMTIMEOUT),
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index 61f6827..489be97 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -639,6 +639,12 @@ static int rawv6_send_hdrinc(struct sock *sk, vo=
id *from, int length,
>  		goto error_fault;
> =20
>  	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS)=
;

same problem here...

> +	IP6_ADD_STATS_BH(sock_net(sk), rt->rt6i_idev,
> +		      IPSTATS_MIB_OUTOCTETS, skb->len);
> +	if(ipv6_addr_is_multicast(&iph->daddr))
> +		IP6_ADD_STATS_BH(sock_net(sk), rt->rt6i_idev,
> +		      IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
> +
>  	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.d=
ev,
>  		      dst_output);
>  	if (err > 0)

