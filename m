From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next 4/6] ipv4: rate limit updating of next hop exceptions with same pmtu
Date: Mon, 27 May 2013 14:16:14 +0300
Message-ID: <1369653376-4731-5-git-send-email-timo.teras@iki.fi>
References: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:37673 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757851Ab3E0LOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 07:14:46 -0400
Received: by mail-ee0-f41.google.com with SMTP id d4so3793364eek.14
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 04:14:45 -0700 (PDT)
In-Reply-To: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tunnel devices call update_pmtu for each packet sent, this causes
contention on the fnhe_lock. Ignore the pmtu update if pmtu is not
actually changed, and there is still plenty of time before the entry
expires.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/ipv4/route.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 561a378..a4082be 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -947,6 +947,10 @@ static void __ip_rt_update_pmtu(struct rtable *rt,=
 struct flowi4 *fl4, u32 mtu)
 	if (mtu < ip_rt_min_pmtu)
 		mtu =3D ip_rt_min_pmtu;
=20
+	if (rt->rt_pmtu =3D=3D mtu &&
+	    time_before(jiffies, dst->expires - ip_rt_mtu_expires / 2))
+		return;
+
 	rcu_read_lock();
 	if (fib_lookup(dev_net(dst->dev), fl4, &res) =3D=3D 0) {
 		struct fib_nh *nh =3D &FIB_RES_NH(res);
--=20
1.8.2.3
