From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 5/7] ipv6 addrconf: implement RFC7559 router solicitation backoff
Date: Sat, 24 Sep 2016 09:05:07 -0700
Message-ID: <1474733109-18355-5-git-send-email-zenczykowski@gmail.com>
References: <CAHo-Oozocj2rzY8hTTr1f3roMy9iz50j6X=dBG5qmz4B_LFAFQ@mail.gmail.com>
 <1474733109-18355-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34954 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758018AbcIXQGE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 12:06:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id 6so6713691pfl.2
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 09:06:04 -0700 (PDT)
In-Reply-To: <1474733109-18355-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This implements:
  https://tools.ietf.org/html/rfc7559

Backoff is performed according to RFC3315 section 14:
  https://tools.ietf.org/html/rfc3315#section-14

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 include/net/if_inet6.h |  1 +
 net/ipv6/addrconf.c    | 31 +++++++++++++++++++++++++++----
 2 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 1c8b6820b694..515352c6280a 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -201,6 +201,7 @@ struct inet6_dev {
 	struct ipv6_devstat	stats;
 
 	struct timer_list	rs_timer;
+	__s32			rs_interval;	/* in jiffies */
 	__u8			rs_probes;
 
 	__u8			addr_gen_mode;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 255be34cdbce..f2147b3352b9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -112,6 +112,24 @@ static inline u32 cstamp_delta(unsigned long cstamp)
 	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
 }
 
+static inline s32 rfc3315_s14_backoff_init(s32 initial)
+{
+	s64 r = 900000 + (prandom_u32() % 200001); /* 0.9 .. 1.1 */
+	s32 v = initial * r / 1000000;
+	return v;
+}
+
+static inline s32 rfc3315_s14_backoff_update(s32 cur, s32 ceiling)
+{
+	s64 r = 1900000 + (prandom_u32() % 200001); /* 1.9 .. 2.1 */
+	s32 v = cur * r / 1000000;
+	if (v > ceiling) {
+		r -= 1000000; /* 0.9 .. 1.1 */
+		v = ceiling * r / 1000000;
+	}
+	return v;
+}
+
 #ifdef CONFIG_SYSCTL
 static int addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
@@ -3698,11 +3716,13 @@ static void addrconf_rs_timer(unsigned long data)
 			goto put;
 
 		write_lock(&idev->lock);
+		idev->rs_interval = rfc3315_s14_backoff_update(
+			idev->rs_interval, idev->cnf.rtr_solicit_max_interval);
 		/* The wait after the last probe can be shorter */
 		addrconf_mod_rs_timer(idev, (idev->rs_probes ==
 					     idev->cnf.rtr_solicits) ?
 				      idev->cnf.rtr_solicit_delay :
-				      idev->cnf.rtr_solicit_interval);
+				      idev->rs_interval);
 	} else {
 		/*
 		 * Note: we do not support deprecated "all on-link"
@@ -3973,10 +3993,11 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 
 		write_lock_bh(&ifp->idev->lock);
 		spin_lock(&ifp->lock);
+		ifp->idev->rs_interval = rfc3315_s14_backoff_init(
+			ifp->idev->cnf.rtr_solicit_interval);
 		ifp->idev->rs_probes = 1;
 		ifp->idev->if_flags |= IF_RS_SENT;
-		addrconf_mod_rs_timer(ifp->idev,
-				      ifp->idev->cnf.rtr_solicit_interval);
+		addrconf_mod_rs_timer(ifp->idev, ifp->idev->rs_interval);
 		spin_unlock(&ifp->lock);
 		write_unlock_bh(&ifp->idev->lock);
 	}
@@ -5132,8 +5153,10 @@ update_lft:
 
 	if (update_rs) {
 		idev->if_flags |= IF_RS_SENT;
+		idev->rs_interval = rfc3315_s14_backoff_init(
+			idev->cnf.rtr_solicit_interval);
 		idev->rs_probes = 1;
-		addrconf_mod_rs_timer(idev, idev->cnf.rtr_solicit_interval);
+		addrconf_mod_rs_timer(idev, idev->rs_interval);
 	}
 
 	/* Well, that's kinda nasty ... */
-- 
2.8.0.rc3.226.g39d4020
