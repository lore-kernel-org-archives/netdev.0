From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Don't limit the number of tunnels with generic name explicitly.
Date: Thu, 21 Feb 2008 15:38:16 +0300
Message-ID: <47BD70B8.3030507@openvz.org>
References: <47BD6907.7050303@openvz.org> <47BD6A28.1030007@trash.net> <47BD6BD7.1060200@openvz.org> <47BD6CE9.7000908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47963 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754384AbYBUMiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 07:38:20 -0500
In-Reply-To: <47BD6CE9.7000908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Pavel Emelyanov wrote:
>> Patrick McHardy wrote:
>>
>>> It would be nicer to replace the entire hand-made name
>>> allocation to remove the 100 device limit.
>>>
>> Actually, I thought the same, but fixing % in names looks like a 
>> BUG-fix for 2.6.25, while removing the hand-made name allocation 
>> looks like an enhancement for 2.6.26. No?
> 
> 
> Well, its so closely related that I guess it would still look
> like a bugfix :) But changing this in 2.6.26 is also fine of
> course, your patch just reminded me since I wanted to change
> this for a long time and repeatedly forgot about it again.

Ok, point taken ;) Here's the 2nd patch that does so. If David 
decides it can go to 2.6.25, that would be good, otherwise this 
patch will fit the 2.6.26 as well.

Changelog:

Use the added dev_alloc_name() call to create tunnel device name,
rather than iterate in a hand-made loop with an artificial limit.

Thanks Patrick for noticing this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index c17fa1f..6512d85 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -14,8 +14,6 @@
 /* capable of receiving packets */
 #define IP6_TNL_F_CAP_RCV 0x20000
 
-#define IP6_TNL_MAX 128
-
 /* IPv6 tunnel */
 
 struct ip6_tnl {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6b9744f..e7821ba 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -259,16 +259,8 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int
 
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
-	else {
-		int i;
-		for (i=1; i<100; i++) {
-			sprintf(name, "gre%d", i);
-			if (__dev_get_by_name(&init_net, name) == NULL)
-				break;
-		}
-		if (i==100)
-			goto failed;
-	}
+	else
+		sprintf(name, "gre%%d");
 
 	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
 	if (!dev)
@@ -292,7 +284,6 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int
 
 failed_free:
 	free_netdev(dev);
-failed:
 	return NULL;
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 118e7d9..dbaed69 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -221,16 +221,8 @@ static struct ip_tunnel * ipip_tunnel_locate(struct ip_tunnel_parm *parms, int c
 
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
-	else {
-		int i;
-		for (i=1; i<100; i++) {
-			sprintf(name, "tunl%d", i);
-			if (__dev_get_by_name(&init_net, name) == NULL)
-				break;
-		}
-		if (i==100)
-			goto failed;
-	}
+	else
+		sprintf(name, "tunl%%d");
 
 	dev = alloc_netdev(sizeof(*t), name, ipip_tunnel_setup);
 	if (dev == NULL)
@@ -254,7 +246,6 @@ static struct ip_tunnel * ipip_tunnel_locate(struct ip_tunnel_parm *parms, int c
 
 failed_free:
 	free_netdev(dev);
-failed:
 	return NULL;
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index fa83d70..78f4388 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -229,18 +229,11 @@ static struct ip6_tnl *ip6_tnl_create(struct ip6_tnl_parm *p)
 	char name[IFNAMSIZ];
 	int err;
 
-	if (p->name[0]) {
+	if (p->name[0])
 		strlcpy(name, p->name, IFNAMSIZ);
-	} else {
-		int i;
-		for (i = 1; i < IP6_TNL_MAX; i++) {
-			sprintf(name, "ip6tnl%d", i);
-			if (__dev_get_by_name(&init_net, name) == NULL)
-				break;
-		}
-		if (i == IP6_TNL_MAX)
-			goto failed;
-	}
+	else
+		sprintf(name, "ip6tnl%%d");
+
 	dev = alloc_netdev(sizeof (*t), name, ip6_tnl_dev_setup);
 	if (dev == NULL)
 		goto failed;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a09a6b0..1656c00 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -164,16 +164,8 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct ip_tunnel_parm *parms, int
 
 	if (parms->name[0])
 		strlcpy(name, parms->name, IFNAMSIZ);
-	else {
-		int i;
-		for (i=1; i<100; i++) {
-			sprintf(name, "sit%d", i);
-			if (__dev_get_by_name(&init_net, name) == NULL)
-				break;
-		}
-		if (i==100)
-			goto failed;
-	}
+	else
+		sprintf(name, "sit%%d");
 
 	dev = alloc_netdev(sizeof(*t), name, ipip6_tunnel_setup);
 	if (dev == NULL)
