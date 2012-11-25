From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: ipmr: limit MRT_TABLE identifiers
Date: Sun, 25 Nov 2012 11:44:29 -0800
Message-ID: <1353872669.30446.863.camel@edumazet-glaptop>
References: <50AC9CF6.2020501@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43549 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335Ab2KYToi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 14:44:38 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so5345892iea.19
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2012 11:44:38 -0800 (PST)
In-Reply-To: <50AC9CF6.2020501@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Name of pimreg devices are built from following format :

char name[IFNAMSIZ]; // IFNAMSIZ == 16

sprintf(name, "pimreg%u", mrt->id);

We must therefore limit mrt->id to 9 decimal digits
or risk a buffer overflow and a crash.

Restrict table identifiers in [0 ... 999999999] interval.

Reported-by: Chen Gang <gang.chen@asianux.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ipmr.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 6168c4d..3eab2b2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1318,6 +1318,10 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		if (get_user(v, (u32 __user *)optval))
 			return -EFAULT;
 
+		/* "pimreg%u" should not exceed 16 bytes (IFNAMSIZ) */
+		if (v != RT_TABLE_DEFAULT && v >= 1000000000)
+			return -EINVAL;
+
 		rtnl_lock();
 		ret = 0;
 		if (sk == rtnl_dereference(mrt->mroute_sk)) {
