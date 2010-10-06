From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: [PATCH] net: Fix sk_dst_check() to reset the obsolete dst_entry of a socket.
Date: Wed, 6 Oct 2010 00:27:35 -0700
Message-ID: <AANLkTikkv4htP1f=KFwSaa8=K6LicDN0eusXctow-Efb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    The issue is caused by the CL d11a4dc18bf41719c9f0d7ed494d295dd2973b92
    which will never reset the dst_entry of a socket if its current entry
    is freed(obsolete) for ipv4. This will block the socket's traffic
    instead of looking up a new dst_entry.

    Signed-off-by: Chung-yih Wang <cywang@google.com>
---
diff --git a/net/core/sock.c b/net/core/sock.c
index ef30e9d..b508819 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -382,7 +382,8 @@ struct dst_entry *__sk_dst_check(struct sock *sk,
u32 cookie)
 {
        struct dst_entry *dst = __sk_dst_get(sk);

-       if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+       if (dst && dst->obsolete && ((dst->obsolete > 0) ||
+           (dst->ops->check(dst, cookie) == NULL))) {
                sk_tx_queue_clear(sk);
                rcu_assign_pointer(sk->sk_dst_cache, NULL);
                dst_release(dst);
@@ -397,7 +398,8 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
 {
        struct dst_entry *dst = sk_dst_get(sk);

-       if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+       if (dst && dst->obsolete && ((dst->obsolete > 0) ||
+           (dst->ops->check(dst, cookie) == NULL))) {
                sk_dst_reset(sk);
                dst_release(dst);
                return NULL;
