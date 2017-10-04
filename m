From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [PATCH v6 1/1] ip_tunnel: add mpls over gre support
Date: Wed,  4 Oct 2017 19:35:57 +0200
Message-ID: <e2d0ce36a2e811df680cad29d1ae283b6ba0f13d.1507129836.git.amine.kherbouche@6wind.com>
References: <cover.1507129836.git.amine.kherbouche@6wind.com>
Cc: netdev@vger.kernel.org, amine.kherbouche@6wind.com,
        equinox@diac24.net
To: tom@herbertland.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:51303 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdJDRiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:38:20 -0400
Received: by mail-wm0-f44.google.com with SMTP id f4so16592464wme.0
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 10:38:20 -0700 (PDT)
In-Reply-To: <cover.1507129836.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit introduces the MPLSoGRE support (RFC 4023), using ip tunnel
API by simply adding ipgre_tunnel_encap_(add|del)_mpls_ops() and the new
tunnel type TUNNEL_ENCAP_MPLS.

Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
---
 include/uapi/linux/if_tunnel.h |  1 +
 net/mpls/af_mpls.c             | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 2e52088..a2f48c0 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -84,6 +84,7 @@ enum tunnel_encap_types {
 	TUNNEL_ENCAP_NONE,
 	TUNNEL_ENCAP_FOU,
 	TUNNEL_ENCAP_GUE,
+	TUNNEL_ENCAP_MPLS,
 };
 
 #define TUNNEL_ENCAP_FLAG_CSUM		(1<<0)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c5b9ce4..9745e8f 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -16,6 +16,7 @@
 #include <net/arp.h>
 #include <net/ip_fib.h>
 #include <net/netevent.h>
+#include <net/ip_tunnels.h>
 #include <net/netns/generic.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -39,6 +40,36 @@ static int one = 1;
 static int label_limit = (1 << 20) - 1;
 static int ttl_max = 255;
 
+#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
+size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
+{
+	return sizeof(struct mpls_shim_hdr);
+}
+
+static const struct ip_tunnel_encap_ops mpls_iptun_ops = {
+	.encap_hlen	= ipgre_mpls_encap_hlen,
+};
+
+static int ipgre_tunnel_encap_add_mpls_ops(void)
+{
+	return ip_tunnel_encap_add_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
+}
+
+static void ipgre_tunnel_encap_del_mpls_ops(void)
+{
+	ip_tunnel_encap_del_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
+}
+#else
+static int ipgre_tunnel_encap_add_mpls_ops(void)
+{
+	return 0;
+}
+
+static void ipgre_tunnel_encap_del_mpls_ops(void)
+{
+}
+#endif
+
 static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
 		       unsigned int nlm_flags);
@@ -2485,6 +2516,10 @@ static int __init mpls_init(void)
 		      0);
 	rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
 		      mpls_netconf_dump_devconf, 0);
+	err = ipgre_tunnel_encap_add_mpls_ops();
+	if (err)
+		pr_err("Can't add mpls over gre tunnel ops\n");
+
 	err = 0;
 out:
 	return err;
@@ -2502,6 +2537,7 @@ static void __exit mpls_exit(void)
 	dev_remove_pack(&mpls_packet_type);
 	unregister_netdevice_notifier(&mpls_dev_notifier);
 	unregister_pernet_subsys(&mpls_net_ops);
+	ipgre_tunnel_encap_del_mpls_ops();
 }
 module_exit(mpls_exit);
 
-- 
2.1.4
