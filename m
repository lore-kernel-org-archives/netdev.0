From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next 2/3] ipv4: rate limit updating of next hop exceptions with same pmtu
Date: Tue, 28 May 2013 09:46:32 +0300
Message-ID: <1369723593-5307-2-git-send-email-timo.teras@iki.fi>
References: <20130527.233844.2081972819091665848.davem@davemloft.net>
 <1369723593-5307-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:45947 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932977Ab3E1Go5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:44:57 -0400
Received: by mail-ea0-f169.google.com with SMTP id m14so4204849eaj.14
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 23:44:56 -0700 (PDT)
In-Reply-To: <1369723593-5307-1-git-send-email-timo.teras@iki.fi>
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
