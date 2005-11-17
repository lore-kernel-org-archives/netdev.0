From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH]IPv6: Acquire addrconf_hash_lock for reading instead of writing
 in addrconf_verify(...)
Date: Thu, 17 Nov 2005 10:14:11 +0800
Message-ID: <437BE773.6010007@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161102AbVKQCLs@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

addrconf_verify(...) only traverse address hash table when addrconf_hash_lock is held
for writing, and it may hold addrconf_hash_lock for a long time. So I think it's better
to acquire addrconf_hash_lock for reading instead of  writing

Signed-off-by: Yan Zheng <yanzheng@21cn.com>

============================================================
--- a/net/ipv6/addrconf.c	2005-11-17 09:27:54.000000000 +0800
+++ b/net/ipv6/addrconf.c	2005-11-17 09:25:42.000000000 +0800
@@ -2627,7 +2627,7 @@ static void addrconf_verify(unsigned lon
 	for (i=0; i < IN6_ADDR_HSIZE; i++) {
 
 restart:
-		write_lock(&addrconf_hash_lock);
+		read_lock(&addrconf_hash_lock);
 		for (ifp=inet6_addr_lst[i]; ifp; ifp=ifp->lst_next) {
 			unsigned long age;
 #ifdef CONFIG_IPV6_PRIVACY
@@ -2649,7 +2649,7 @@ restart:
 			if (age >= ifp->valid_lft) {
 				spin_unlock(&ifp->lock);
 				in6_ifa_hold(ifp);
-				write_unlock(&addrconf_hash_lock);
+				read_unlock(&addrconf_hash_lock);
 				ipv6_del_addr(ifp);
 				goto restart;
 			} else if (age >= ifp->prefered_lft) {
@@ -2668,7 +2668,7 @@ restart:
 
 				if (deprecate) {
 					in6_ifa_hold(ifp);
-					write_unlock(&addrconf_hash_lock);
+					read_unlock(&addrconf_hash_lock);
 
 					ipv6_ifa_notify(0, ifp);
 					in6_ifa_put(ifp);
@@ -2686,7 +2686,7 @@ restart:
 						in6_ifa_hold(ifp);
 						in6_ifa_hold(ifpub);
 						spin_unlock(&ifp->lock);
-						write_unlock(&addrconf_hash_lock);
+						read_unlock(&addrconf_hash_lock);
 						ipv6_create_tempaddr(ifpub, ifp);
 						in6_ifa_put(ifpub);
 						in6_ifa_put(ifp);
@@ -2703,7 +2703,7 @@ restart:
 				spin_unlock(&ifp->lock);
 			}
 		}
-		write_unlock(&addrconf_hash_lock);
+		read_unlock(&addrconf_hash_lock);
 	}
 
 	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
