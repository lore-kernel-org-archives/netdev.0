From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 20/24] IPVS: Add validity checks when adding/editing v6 services
Date: Wed, 20 Aug 2008 18:15:27 +0200
Message-ID: <1219248931-15064-21-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com,
	Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:51639 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786AbYHTQQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 12:16:12 -0400
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check to see if the specified scheduler is supported with IPv6 and whether
the supplied prefix length is valid.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 6127a97..39ab7dc 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1160,6 +1160,19 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
 		goto out_mod_dec;
 	}
 
+#ifdef CONFIG_IP_VS_IPV6
+	if (u->af == AF_INET6) {
+		if (!sched->supports_ipv6) {
+			ret = -EAFNOSUPPORT;
+			goto out_err;
+		}
+		if ((u->netmask < 1) || (u->netmask > 128)) {
+			ret = -EINVAL;
+			goto out_err;
+		}
+	}
+#endif
+
 	svc = kzalloc(sizeof(struct ip_vs_service), GFP_ATOMIC);
 	if (svc == NULL) {
 		IP_VS_DBG(1, "ip_vs_add_service: kmalloc failed.\n");
@@ -1247,6 +1260,19 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user *u)
 	}
 	old_sched = sched;
 
+#ifdef CONFIG_IP_VS_IPV6
+	if (u->af == AF_INET6) {
+		if (!sched->supports_ipv6) {
+			ret = EAFNOSUPPORT;
+			goto out;
+		}
+		if ((u->netmask < 1) || (u->netmask > 128)) {
+			ret = EINVAL;
+			goto out;
+		}
+	}
+#endif
+
 	write_lock_bh(&__ip_vs_svc_lock);
 
 	/*
-- 
1.5.4.5

