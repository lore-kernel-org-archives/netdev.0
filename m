From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: fix dst race in sk_dst_get()
Date: Tue, 24 Jun 2014 10:05:11 -0700
Message-ID: <1403629511.3796.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	 <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406101726390.11647@dtop>
	 <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.10.1406102114520.28698@dinf>
	 <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406110011170.11647@dtop>
	 <alpine.DEB.2.02.1406110022550.11647@dtop>
	 <alpine.DEB.2.02.1406110036490.11647@dtop>
	 <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406111851140.18470@dtop>
	 <1402544609.3645.473.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406221202460.14871@dtop>
	 <1403512412.16682.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:43883 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007AbaFXRFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 13:05:21 -0400
Received: by mail-we0-f178.google.com with SMTP id x48so681645wes.9
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 10:05:14 -0700 (PDT)
In-Reply-To: <1403512412.16682.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When IP route cache had been removed in linux-3.6, we broke assumption
that dst entries were all freed after rcu grace period. DST_NOCACHE
dst were supposed to be freed from dst_release(). But it appears
we want to keep such dst around, either in UDP sockets or tunnels.

In sk_dst_get() we need to make sure dst refcount is not 0
before incrementing it, or else we might end up freeing a dst
twice.

DST_NOCACHE set on a dst does not mean this dst can not be attached
to a socket or a tunnel.

Then, before actual freeing, we need to observe a rcu grace period
to make sure all other cpus can catch the fact the dst is no longer
usable.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dormando <dormando@rydia.net>
---
 include/net/sock.h   |    4 ++--
 net/core/dst.c       |   16 +++++++++++-----
 net/ipv4/ip_tunnel.c |   14 +++++---------
 3 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 07b7fcd60d80..173cae485de1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1730,8 +1730,8 @@ sk_dst_get(struct sock *sk)
 
 	rcu_read_lock();
 	dst = rcu_dereference(sk->sk_dst_cache);
-	if (dst)
-		dst_hold(dst);
+	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
+		dst = NULL;
 	rcu_read_unlock();
 	return dst;
 }
diff --git a/net/core/dst.c b/net/core/dst.c
index 80d6286c8b62..a028409ee438 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -269,6 +269,15 @@ again:
 }
 EXPORT_SYMBOL(dst_destroy);
 
+static void dst_destroy_rcu(struct rcu_head *head)
+{
+	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
+
+	dst = dst_destroy(dst);
+	if (dst)
+		__dst_free(dst);
+}
+
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
@@ -276,11 +285,8 @@ void dst_release(struct dst_entry *dst)
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		WARN_ON(newrefcnt < 0);
-		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt) {
-			dst = dst_destroy(dst);
-			if (dst)
-				__dst_free(dst);
-		}
+		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
+			call_rcu(&dst->rcu_head, dst_destroy_rcu);
 	}
 }
 EXPORT_SYMBOL(dst_release);
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 097b3e7c1e8f..54b6731dab55 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -73,12 +73,7 @@ static void __tunnel_dst_set(struct ip_tunnel_dst *idst,
 {
 	struct dst_entry *old_dst;
 
-	if (dst) {
-		if (dst->flags & DST_NOCACHE)
-			dst = NULL;
-		else
-			dst_clone(dst);
-	}
+	dst_clone(dst);
 	old_dst = xchg((__force struct dst_entry **)&idst->dst, dst);
 	dst_release(old_dst);
 }
@@ -108,13 +103,14 @@ static struct rtable *tunnel_rtable_get(struct ip_tunnel *t, u32 cookie)
 
 	rcu_read_lock();
 	dst = rcu_dereference(this_cpu_ptr(t->dst_cache)->dst);
+	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
+		dst = NULL;
 	if (dst) {
 		if (dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
-			rcu_read_unlock();
 			tunnel_dst_reset(t);
-			return NULL;
+			dst_release(dst);
+			dst = NULL;
 		}
-		dst_hold(dst);
 	}
 	rcu_read_unlock();
 	return (struct rtable *)dst;
