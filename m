From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v3 4/6] vxlan: check valid combinations of address scopes
Date: Mon, 19 Jun 2017 10:03:58 +0200
Message-ID: <d805d1b379ccd409281ec357a3c131dfdb8a7f16.1497825555.git.mschiffer@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497825555.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1497825555.git.mschiffer@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Multicast addresses are never valid as local address
* Link-local IPv6 unicast addresses may only be used as remote when the
  local address is link-local as well
* Don't allow link-local IPv6 local/remote addresses without interface

We also store in the flags field if link-local addresses are used for the
follow-up patches that actually make VXLAN over link-local IPv6 work.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

Notes:
    v2: was "vxlan: don't allow link-local IPv6 local/remote addresses without
    interface" before. v2 does a lot more checks and adds the
    VXLAN_F_IPV6_LINKLOCAL flag.
    v3: remove kernel log messages

 drivers/net/vxlan.c | 29 +++++++++++++++++++++++++++++
 include/net/vxlan.h |  2 ++
 2 files changed, 31 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 00680cc597ac..d6d57317cbd5 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2907,11 +2907,35 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 	if (conf->saddr.sa.sa_family != conf->remote_ip.sa.sa_family)
 		return -EINVAL;
 
+	if (vxlan_addr_multicast(&conf->saddr))
+		return -EINVAL;
+
 	if (conf->saddr.sa.sa_family == AF_INET6) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 		use_ipv6 = true;
 		conf->flags |= VXLAN_F_IPV6;
+
+		if (!(conf->flags & VXLAN_F_COLLECT_METADATA)) {
+			int local_type =
+				ipv6_addr_type(&conf->saddr.sin6.sin6_addr);
+			int remote_type =
+				ipv6_addr_type(&conf->remote_ip.sin6.sin6_addr);
+
+			if (local_type & IPV6_ADDR_LINKLOCAL) {
+				if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
+				    (remote_type != IPV6_ADDR_ANY))
+					return -EINVAL;
+
+				conf->flags |= VXLAN_F_IPV6_LINKLOCAL;
+			} else {
+				if (remote_type ==
+				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL))
+					return -EINVAL;
+
+				conf->flags &= ~VXLAN_F_IPV6_LINKLOCAL;
+			}
+		}
 	}
 
 	if (conf->label && !use_ipv6)
@@ -2937,6 +2961,11 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		if (vxlan_addr_multicast(&conf->remote_ip))
 			return -EINVAL;
 
+#if IS_ENABLED(CONFIG_IPV6)
+		if (conf->flags & VXLAN_F_IPV6_LINKLOCAL)
+			return -EINVAL;
+#endif
+
 		*lower = NULL;
 	}
 
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 479bb75789ea..b816a0a6686e 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -258,6 +258,7 @@ struct vxlan_dev {
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 #define VXLAN_F_COLLECT_METADATA	0x2000
 #define VXLAN_F_GPE			0x4000
+#define VXLAN_F_IPV6_LINKLOCAL		0x8000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
@@ -272,6 +273,7 @@ struct vxlan_dev {
 /* Flags that can be set together with VXLAN_F_GPE. */
 #define VXLAN_F_ALLOWED_GPE		(VXLAN_F_GPE |			\
 					 VXLAN_F_IPV6 |			\
+					 VXLAN_F_IPV6_LINKLOCAL |	\
 					 VXLAN_F_UDP_ZERO_CSUM_TX |	\
 					 VXLAN_F_UDP_ZERO_CSUM6_TX |	\
 					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
-- 
2.13.1
