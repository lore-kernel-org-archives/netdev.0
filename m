From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPVS] Don't leak sysctl tables if the scheduler registration
 fails
Date: Mon, 03 Dec 2007 13:04:53 +0300
Message-ID: <4753D4C5.4040301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51130 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbXLCKFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 05:05:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we load lblc or lblcr module we can leak some sysctl
tables if the call to register_ip_vs_scheduler() fails.

I've looked at the register_ip_vs_scheduler() code and saw, that
the only reason to fail is the name collision, so I think that
with some 3rd party schedulers this becomes a relevant issue. No?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index b843a11..ad89644 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -580,9 +580,14 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 
 static int __init ip_vs_lblc_init(void)
 {
+	int ret;
+
 	INIT_LIST_HEAD(&ip_vs_lblc_scheduler.n_list);
 	sysctl_header = register_sysctl_table(lblc_root_table);
-	return register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
+	ret = register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
+	if (ret)
+		unregister_sysctl_table(sysctl_header);
+	return ret;
 }
 
 
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index e5b323a..2a5ed85 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -769,9 +769,14 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 
 static int __init ip_vs_lblcr_init(void)
 {
+	int ret;
+
 	INIT_LIST_HEAD(&ip_vs_lblcr_scheduler.n_list);
 	sysctl_header = register_sysctl_table(lblcr_root_table);
-	return register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
+	ret = register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
+	if (ret)
+		unregister_sysctl_table(sysctl_header);
+	return ret;
 }
 
 
