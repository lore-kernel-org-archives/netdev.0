From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] net: ipv4: fix schedule while atomic bug in check_lifetime()
Date: Fri,  5 Apr 2013 11:39:39 +0200
Message-ID: <1365154779-4204-3-git-send-email-jiri@resnulli.us>
References: <1365154779-4204-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:48990 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab3DEJjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 05:39:49 -0400
Received: by mail-we0-f175.google.com with SMTP id t11so2719851wey.6
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 02:39:48 -0700 (PDT)
In-Reply-To: <1365154779-4204-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

move might_sleep operations out of the rcu_read_lock() section.
Also fix iterating over ifa_dev->ifa_list

Introduced by: commit 5c766d642bcaf "ipv4: introduce address lifetime"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/devinet.c | 58 +++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 42 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 00386e0..c6287cd 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -587,13 +587,16 @@ static void check_lifetime(struct work_struct *work)
 {
 	unsigned long now, next, next_sec, next_sched;
 	struct in_ifaddr *ifa;
+	struct hlist_node *n;
 	int i;
 
 	now = jiffies;
 	next = round_jiffies_up(now + ADDR_CHECK_FREQUENCY);
 
-	rcu_read_lock();
 	for (i = 0; i < IN4_ADDR_HSIZE; i++) {
+		bool change_needed = false;
+
+		rcu_read_lock();
 		hlist_for_each_entry_rcu(ifa, &inet_addr_lst[i], hash) {
 			unsigned long age;
 
@@ -606,16 +609,7 @@ static void check_lifetime(struct work_struct *work)
 
 			if (ifa->ifa_valid_lft != INFINITY_LIFE_TIME &&
 			    age >= ifa->ifa_valid_lft) {
-				struct in_ifaddr **ifap ;
-
-				rtnl_lock();
-				for (ifap = &ifa->ifa_dev->ifa_list;
-				     *ifap != NULL; ifap = &ifa->ifa_next) {
-					if (*ifap == ifa)
-						inet_del_ifa(ifa->ifa_dev,
-							     ifap, 1);
-				}
-				rtnl_unlock();
+				change_needed = true;
 			} else if (ifa->ifa_preferred_lft ==
 				   INFINITY_LIFE_TIME) {
 				continue;
@@ -625,10 +619,8 @@ static void check_lifetime(struct work_struct *work)
 					next = ifa->ifa_tstamp +
 					       ifa->ifa_valid_lft * HZ;
 
-				if (!(ifa->ifa_flags & IFA_F_DEPRECATED)) {
-					ifa->ifa_flags |= IFA_F_DEPRECATED;
-					rtmsg_ifa(RTM_NEWADDR, ifa, NULL, 0);
-				}
+				if (!(ifa->ifa_flags & IFA_F_DEPRECATED))
+					change_needed = true;
 			} else if (time_before(ifa->ifa_tstamp +
 					       ifa->ifa_preferred_lft * HZ,
 					       next)) {
@@ -636,8 +628,42 @@ static void check_lifetime(struct work_struct *work)
 				       ifa->ifa_preferred_lft * HZ;
 			}
 		}
+		rcu_read_unlock();
+		if (!change_needed)
+			continue;
+		rtnl_lock();
+		hlist_for_each_entry_safe(ifa, n, &inet_addr_lst[i], hash) {
+			unsigned long age;
+
+			if (ifa->ifa_flags & IFA_F_PERMANENT)
+				continue;
+
+			/* We try to batch several events at once. */
+			age = (now - ifa->ifa_tstamp +
+			       ADDRCONF_TIMER_FUZZ_MINUS) / HZ;
+
+			if (ifa->ifa_valid_lft != INFINITY_LIFE_TIME &&
+			    age >= ifa->ifa_valid_lft) {
+				struct in_ifaddr **ifap;
+
+				for (ifap = &ifa->ifa_dev->ifa_list;
+				     *ifap != NULL; ifap = &(*ifap)->ifa_next) {
+					if (*ifap == ifa) {
+						inet_del_ifa(ifa->ifa_dev,
+							     ifap, 1);
+						break;
+					}
+				}
+			} else if (ifa->ifa_preferred_lft !=
+				   INFINITY_LIFE_TIME &&
+				   age >= ifa->ifa_preferred_lft &&
+				   !(ifa->ifa_flags & IFA_F_DEPRECATED)) {
+				ifa->ifa_flags |= IFA_F_DEPRECATED;
+				rtmsg_ifa(RTM_NEWADDR, ifa, NULL, 0);
+			}
+		}
+		rtnl_unlock();
 	}
-	rcu_read_unlock();
 
 	next_sec = round_jiffies_up(next);
 	next_sched = next;
-- 
1.8.1.2
