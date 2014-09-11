From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 6/7] ipip: TX path for IPIP/UDP foo-over-udp encapsulation
Date: Thu, 11 Sep 2014 13:07:35 -0700
Message-ID: <1410466056-30239-7-git-send-email-therbert@google.com>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41697 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503AbaIKUIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 16:08:24 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so9248047pab.29
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 13:08:23 -0700 (PDT)
In-Reply-To: <1410466056-30239-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ipip.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 64 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 62eaa00..3474106 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -240,6 +240,11 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip_tunnel_parm p;
 
+	/* Try generic tunnel ioctls first */
+	err = ip_tunnel_gen_ioctl(dev, ifr, cmd);
+	if (err != -ENOIOCTLCMD)
+		return err;
+
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
 
@@ -301,7 +306,8 @@ static int ipip_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	tunnel->hlen = 0;
+	tunnel->tun_hlen = 0;
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
 	tunnel->parms.iph.protocol = IPPROTO_IPIP;
 	return ip_tunnel_init(dev);
 }
@@ -340,19 +346,67 @@ static void ipip_netlink_parms(struct nlattr *data[],
 		parms->iph.frag_off = htons(IP_DF);
 }
 
+/* This function returns true when ENCAP attributes are present in the nl msg */
+static bool ipip_netlink_encap_parms(struct nlattr *data[],
+				     struct ip_tunnel_encap *ipencap)
+{
+	bool ret = false;
+
+	memset(ipencap, 0, sizeof(*ipencap));
+
+	if (!data)
+		return ret;
+
+	if (data[IFLA_IPTUN_ENCAP_TYPE]) {
+		ret = true;
+		ipencap->type = nla_get_u16(data[IFLA_IPTUN_ENCAP_TYPE]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_FLAGS]) {
+		ret = true;
+		ipencap->flags = nla_get_u16(data[IFLA_IPTUN_ENCAP_FLAGS]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_SPORT]) {
+		ret = true;
+		ipencap->sport = nla_get_u16(data[IFLA_IPTUN_ENCAP_SPORT]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_DPORT]) {
+		ret = true;
+		ipencap->dport = nla_get_u16(data[IFLA_IPTUN_ENCAP_DPORT]);
+	}
+
+	return ret;
+}
+
 static int ipip_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip_tunnel_parm p;
+	struct ip_tunnel *t = netdev_priv(dev);
+	struct ip_tunnel_encap ipencap;
+	int err;
+
+	if (ipip_netlink_encap_parms(data, &ipencap)) {
+		err = ip_tunnel_encap_setup(t, &ipencap);
+		if (err < 0)
+			return err;
+	}
 
 	ipip_netlink_parms(data, &p);
-	return ip_tunnel_newlink(dev, tb, &p);
+	err = ip_tunnel_newlink(dev, tb, &p);
+
+	return err;
 }
 
 static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 			   struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_encap ipencap;
+	int err;
 
 	ipip_netlink_parms(data, &p);
 
@@ -360,7 +414,14 @@ static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 	    (!(dev->flags & IFF_POINTOPOINT) && p.iph.daddr))
 		return -EINVAL;
 
-	return ip_tunnel_changelink(dev, tb, &p);
+	err = ip_tunnel_changelink(dev, tb, &p);
+	if (err < 0)
+		return err;
+
+	if (ipip_netlink_encap_parms(data, &ipencap))
+		err = ip_tunnel_encap_setup(t, &ipencap);
+
+	return err;
 }
 
 static size_t ipip_get_size(const struct net_device *dev)
-- 
2.1.0.rc2.206.gedb03e5
