From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 1/6] net: fib6: fib6_commit_metrics: fix potential NULL pointer dereference
Date: Mon,  5 Jan 2015 23:57:43 +0100
Message-ID: <1420498668-4660-2-git-send-email-dborkman@redhat.com>
References: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.cz>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715AbbAEW6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 17:58:06 -0500
In-Reply-To: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IPv6 host routes with metrics attached are being added, we fetch
the metrics store from the dst via COW through dst_metrics_write_ptr(),
added through commit e5fd387ad5b3.

One remaining problem here is that we actually call into inet_getpeer()
and may end up allocating/creating a new peer from the kmemcache, which
may fail.

Example trace from perf probe (inet_getpeer:41) where create is 1:

ip 6877 [002] 4221.391591: probe:inet_getpeer: (ffffffff8165e293)
  85e294 inet_getpeer.part.7 (<- kmem_cache_alloc())
  85e578 inet_getpeer
  8eb333 ipv6_cow_metrics
  8f10ff fib6_commit_metrics

Therefore, a check for NULL on the return of dst_metrics_write_ptr()
is necessary here.

Joint work with Florian Westphal.

=46ixes: e5fd387ad5b3 ("ipv6: do not overwrite inetpeer metrics prematu=
rely")
Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/ip6_fib.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index b2d1838..db4984e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -633,18 +633,17 @@ static bool rt6_qualify_for_ecmp(struct rt6_info =
*rt)
 static int fib6_commit_metrics(struct dst_entry *dst,
 			       struct nlattr *mx, int mx_len)
 {
+	bool dst_host =3D dst->flags & DST_HOST;
 	struct nlattr *nla;
 	int remaining;
 	u32 *mp;
=20
-	if (dst->flags & DST_HOST) {
-		mp =3D dst_metrics_write_ptr(dst);
-	} else {
-		mp =3D kzalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
-		if (!mp)
-			return -ENOMEM;
+	mp =3D dst_host ? dst_metrics_write_ptr(dst) :
+			kzalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
+	if (unlikely(!mp))
+		return -ENOMEM;
+	if (!dst_host)
 		dst_init_metrics(dst, mp, 0);
-	}
=20
 	nla_for_each_attr(nla, mx, mx_len, remaining) {
 		int type =3D nla_type(nla);
--=20
1.7.11.7
