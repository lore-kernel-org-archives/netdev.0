From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 2/7] Make __devinet_sysctl_register return an error
Date: Tue, 11 Dec 2007 20:48:44 +0300
Message-ID: <475ECD7C.8050905@openvz.org>
References: <475ECC69.1040809@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38703 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753104AbXLKRs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 12:48:56 -0500
In-Reply-To: <475ECC69.1040809@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, this function is void, so failures in creating
sysctls for new/renamed devices are not reported to anywhere.

Fixing this is another complex (needed?) task, but this
return value is needed during the namespaces creation to
handle the case, when we failed to create "all" and "default"
entries.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 872883e..bfb0fb0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1455,8 +1460,8 @@ static struct devinet_sysctl_table {
 	},
 };
 
-static void __devinet_sysctl_register(char *dev_name, int ctl_name,
-		struct ipv4_devconf *p)
+static int __devinet_sysctl_register(struct net *net, char *dev_name,
+		int ctl_name, struct ipv4_devconf *p)
 {
 	int i;
 	struct devinet_sysctl_table *t;
@@ -1498,14 +1504,14 @@ static void __devinet_sysctl_register(char *dev_name, int ctl_name,
 		goto free_procname;
 
 	p->sysctl = t;
-	return;
+	return 0;
 
 free_procname:
 	kfree(t->dev_name);
 free:
 	kfree(t);
 out:
-	return;
+	return -ENOBUFS;
 }
 
 static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
-- 
1.5.3.4

