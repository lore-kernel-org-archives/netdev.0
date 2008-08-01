From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: [PATCH] raw: restore daddr_cache in raw kernel socket.
Date: Fri, 01 Aug 2008 19:00:20 +0900
Message-ID: <4892DEB4.20203@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: usagi-users@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:34752 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbYHAKAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 06:00:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I created a patch of RAW socket.

This patch adds ip6_sk_dst_lookup()/ip6_dst_store() in rawv6_sendmsg().
so that RAW socket can use "daddr_cache".

When RAW socket sent the packets to same destination,
it must reduce over-head.

Could you please check the following patch?

Regards,
Naohiro Ooiwa


Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
---
 net/ipv6/raw.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 396f0ea..58c5e25 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -858,7 +858,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		fl.oif = np->mcast_oif;
 	security_sk_classify_flow(sk, &fl);

-	err = ip6_dst_lookup(sk, &dst, &fl);
+	err = ip6_sk_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto out;
 	if (final_p)
@@ -905,7 +905,17 @@ back_from_confirm:
 		release_sock(sk);
 	}
 done:
-	dst_release(dst);
+	if (dst)
+		ip6_dst_store(sk, dst,
+			      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
+			      &np->daddr : NULL,
+#ifdef CONFIG_IPV6_SUBTREES
+			      ipv6_addr_equal(&fl.fl6_src, &np->saddr) ?
+			      &np->saddr :
+#endif
+			      NULL);
+	else
+		dst_release(dst);
 out:
 	fl6_sock_release(flowlabel);
 	return err<0?err:len;
-- 


