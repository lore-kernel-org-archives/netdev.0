From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 7/7] gre: TX path for GRE/UDP foo-over-udp encapsulation
Date: Thu, 11 Sep 2014 13:07:36 -0700
Message-ID: <1410466056-30239-8-git-send-email-therbert@google.com>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34076 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503AbaIKUI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 16:08:27 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so9953229pab.32
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 13:08:26 -0700 (PDT)
In-Reply-To: <1410466056-30239-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/uapi/linux/if_tunnel.h |  4 +++
 net/ipv4/ip_gre.c              | 77 +++++++++++++++++++++++++++++++++++++++---
 2 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 4369b62..8aa2431 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -117,6 +117,10 @@ enum {
 	IFLA_GRE_ENCAP_LIMIT,
 	IFLA_GRE_FLOWINFO,
 	IFLA_GRE_FLAGS,
+	IFLA_GRE_ENCAP_TYPE,
+	IFLA_GRE_ENCAP_FLAGS,
+	IFLA_GRE_ENCAP_SPORT,
+	IFLA_GRE_ENCAP_DPORT,
 	__IFLA_GRE_MAX,
 };
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 9b84254..f820481 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -239,7 +239,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	tpi.seq = htonl(tunnel->o_seqno);
 
 	/* Push GRE header. */
-	gre_build_header(skb, &tpi, tunnel->hlen);
+	gre_build_header(skb, &tpi, tunnel->tun_hlen);
 
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
@@ -310,9 +310,14 @@ out:
 static int ipgre_tunnel_ioctl(struct net_device *dev,
 			      struct ifreq *ifr, int cmd)
 {
-	int err = 0;
+	int err;
 	struct ip_tunnel_parm p;
 
+	/* Try generic tunnel ioctls first */
+	err = ip_tunnel_gen_ioctl(dev, ifr, cmd);
+	if (err != -ENOIOCTLCMD)
+		return err;
+
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
 	if (cmd == SIOCADDTUNNEL || cmd == SIOCCHGTUNNEL) {
@@ -472,9 +477,11 @@ static void __gre_tunnel_init(struct net_device *dev)
 	struct ip_tunnel *tunnel;
 
 	tunnel = netdev_priv(dev);
-	tunnel->hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
+	tunnel->tun_hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
 	tunnel->parms.iph.protocol = IPPROTO_GRE;
 
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
+
 	dev->needed_headroom	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
 
@@ -628,6 +635,40 @@ static void ipgre_netlink_parms(struct nlattr *data[], struct nlattr *tb[],
 		parms->iph.frag_off = htons(IP_DF);
 }
 
+/* This function returns true when ENCAP attributes are present in the nl msg */
+static bool ipgre_netlink_encap_parms(struct nlattr *data[],
+				      struct ip_tunnel_encap *ipencap)
+{
+	bool ret = false;
+
+	memset(ipencap, 0, sizeof(*ipencap));
+
+	if (!data)
+		return ret;
+
+	if (data[IFLA_GRE_ENCAP_TYPE]) {
+		ret = true;
+		ipencap->type = nla_get_u16(data[IFLA_GRE_ENCAP_TYPE]);
+	}
+
+	if (data[IFLA_GRE_ENCAP_FLAGS]) {
+		ret = true;
+		ipencap->flags = nla_get_u16(data[IFLA_GRE_ENCAP_FLAGS]);
+	}
+
+	if (data[IFLA_GRE_ENCAP_SPORT]) {
+		ret = true;
+		ipencap->sport = nla_get_u16(data[IFLA_GRE_ENCAP_SPORT]);
+	}
+
+	if (data[IFLA_GRE_ENCAP_DPORT]) {
+		ret = true;
+		ipencap->dport = nla_get_u16(data[IFLA_GRE_ENCAP_DPORT]);
+	}
+
+	return ret;
+}
+
 static int gre_tap_init(struct net_device *dev)
 {
 	__gre_tunnel_init(dev);
@@ -653,22 +694,48 @@ static void ipgre_tap_setup(struct net_device *dev)
 	ip_tunnel_setup(dev, gre_tap_net_id);
 }
 
+static int ipgre_tunnel_update_encap(struct ip_tunnel *t,
+				     struct ip_tunnel_encap *ipencap)
+{
+	return 0;
+}
+
 static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip_tunnel_parm p;
+	struct ip_tunnel *nt;
+	struct ip_tunnel_encap ipencap;
+	int err;
 
 	ipgre_netlink_parms(data, tb, &p);
-	return ip_tunnel_newlink(dev, tb, &p);
+	err = ip_tunnel_newlink(dev, tb, &p);
+	if (err < 0)
+		return err;
+
+	if (ipgre_netlink_encap_parms(data, &ipencap))
+		err = ipgre_tunnel_update_encap(nt, &ipencap);
+
+	return err;
 }
 
 static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			    struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_encap ipencap;
+	int err;
 
 	ipgre_netlink_parms(data, tb, &p);
-	return ip_tunnel_changelink(dev, tb, &p);
+	err = ip_tunnel_changelink(dev, tb, &p);
+	if (err < 0)
+		return err;
+
+	if (ipgre_netlink_encap_parms(data, &ipencap))
+		err = ipgre_tunnel_update_encap(t, &ipencap);
+
+	return err;
 }
 
 static size_t ipgre_get_size(const struct net_device *dev)
-- 
2.1.0.rc2.206.gedb03e5
