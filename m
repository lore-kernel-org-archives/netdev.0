From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] udp: use atomic_inc_not_zero_hint
Date: Tue, 16 Nov 2010 06:58:26 +0100
Message-ID: <1289887106.3364.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62071 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472Ab0KPF6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 00:58:35 -0500
Received: by wwa36 with SMTP id 36so363168wwa.1
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 21:58:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP sockets refcount is usually 2, unless an incoming frame is going to
be queued in receive or backlog queue.

Using atomic_inc_not_zero_hint() permits to reduce latency, because
processor issues less memory transactions.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |    2 +-
 net/ipv4/udp.c     |    4 ++--
 net/ipv6/udp.c     |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a6338d0..eb0c1f5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -57,7 +57,7 @@
 #include <linux/rculist_nulls.h>
 #include <linux/poll.h>
 
-#include <asm/atomic.h>
+#include <linux/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5e0a3a5..491ecd3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -430,7 +430,7 @@ begin:
 
 	if (result) {
 exact_match:
-		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score2(result, net, saddr, sport,
 				  daddr, hnum, dif) < badness)) {
@@ -500,7 +500,7 @@ begin:
 		goto begin;
 
 	if (result) {
-		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
 				  daddr, dport, dif) < badness)) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 91def93..b541a4e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -227,7 +227,7 @@ begin:
 
 	if (result) {
 exact_match:
-		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score2(result, net, saddr, sport,
 				  daddr, hnum, dif) < badness)) {
@@ -294,7 +294,7 @@ begin:
 		goto begin;
 
 	if (result) {
-		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
+		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score(result, net, hnum, saddr, sport,
 					daddr, dport, dif) < badness)) {


