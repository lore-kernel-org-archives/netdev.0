From: roy.qing.li@gmail.com
Subject: [RFC PATCH] fix IP_ECN_set_ce
Date: Wed, 19 Dec 2012 14:21:35 +0800
Message-ID: <1355898095-7444-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:59541 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab2LSGVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 01:21:40 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so738746dak.19
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 22:21:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Li RongQing <roy.qing.li@gmail.com>

1. ECN uses the two least significant (right-most) bits of the DiffServ
field in the IPv4, so it should be in iph->tos, not in (iph->tos+1)

2. When setting CE, we should check if ECN Capable Transport supports,
both 10 and 01 mean ECN Capable Transport, so only check 10 is not enou=
gh
    00: Non ECN-Capable Transport =E2=80=94 Non-ECT
    10: ECN Capable Transport =E2=80=94 ECT(0)
    01: ECN Capable Transport =E2=80=94 ECT(1)
    11: Congestion Encountered =E2=80=94 CE

3. Remove the misunderstand comment

4. fix the checksum computation

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/inet_ecn.h |   22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index aab7375..545a683 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -73,27 +73,13 @@ static inline void INET_ECN_dontxmit(struct sock *s=
k)
=20
 static inline int IP_ECN_set_ce(struct iphdr *iph)
 {
-	u32 check =3D (__force u32)iph->check;
-	u32 ecn =3D (iph->tos + 1) & INET_ECN_MASK;
-
-	/*
-	 * After the last operation we have (in binary):
-	 * INET_ECN_NOT_ECT =3D> 01
-	 * INET_ECN_ECT_1   =3D> 10
-	 * INET_ECN_ECT_0   =3D> 11
-	 * INET_ECN_CE      =3D> 00
-	 */
-	if (!(ecn & 2))
+	u32 ecn =3D iph->tos & INET_ECN_MASK;
+
+	if (INET_ECN_is_ce(ecn) || INET_ECN_is_not_ect(ecn))
 		return !ecn;
=20
-	/*
-	 * The following gives us:
-	 * INET_ECN_ECT_1 =3D> check +=3D htons(0xFFFD)
-	 * INET_ECN_ECT_0 =3D> check +=3D htons(0xFFFE)
-	 */
-	check +=3D (__force u16)htons(0xFFFB) + (__force u16)htons(ecn);
+	csum_replace2(&iph->check, iph->tos, iph->tos|INET_ECN_CE);
=20
-	iph->check =3D (__force __sum16)(check + (check>=3D0xFFFF));
 	iph->tos |=3D INET_ECN_CE;
 	return 1;
 }
--=20
1.7.10.4
