From: Chema Gonzalez <chema@berkeley.edu>
Subject: [PATCH] net: Small bug on rxhash calculation
Date: Wed, 5 Sep 2012 23:35:40 -0700
Message-ID: <CAEb0MffEfboq_VmPFCtzGHe-SQ4Dd1O6Hptrc_jHVnp7itKyQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: edumazet@google.com, Chema Gonzalez <chema@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:55599 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325Ab2IFGfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 02:35:41 -0400
Received: by vcbfk26 with SMTP id fk26so1940183vcb.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 23:35:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 5c02179069826bfba9360383b88601b31ff05517 Mon Sep 17 00:00:00 2001
From: Chema Gonzalez <chema@google.com>
Date: Wed, 5 Sep 2012 17:05:48 -0700
Subject: [PATCH] net: Small bug on rxhash calculation

While the (current) sorting of the ports/addresses is coherent
(you get the same rxhash for packets sharing the same (unsorted)
4-tuple), ports and addresses should not be sorted independently,
which currently are: For traffic between A=S:l and B=L:s, packets
in both directions would get their rxhash from hashing
{L, S, {s, l}}. The same rxhash is obtained from packets between
C=S:s and D=L:l.

This patch ensures traffic between A and B gets their rxhash
from {S, L, {s, l}}, and traffic between C and D from {S, L,
{l, s}}

The patch is co-written with Eric Dumazet <edumazet@google.com>

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 net/core/dev.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b1e6d63..dcc673d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2655,15 +2655,16 @@ void __skb_get_rxhash(struct sk_buff *skb)
        if (!skb_flow_dissect(skb, &keys))
                return;

-       if (keys.ports) {
-               if ((__force u16)keys.port16[1] < (__force u16)keys.port16[0])
-                       swap(keys.port16[0], keys.port16[1]);
+       if (keys.ports)
                skb->l4_rxhash = 1;
-       }

        /* get a consistent hash (same value on both flow directions) */
-       if ((__force u32)keys.dst < (__force u32)keys.src)
+       if (((__force u32)keys.dst < (__force u32)keys.src) ||
+           (((__force u32)keys.dst == (__force u32)keys.src) &&
+            ((__force u16)keys.port16[1] < (__force u16)keys.port16[0]))) {
                swap(keys.dst, keys.src);
+               swap(keys.port16[0], keys.port16[1]);
+       }

        hash = jhash_3words((__force u32)keys.dst,
                            (__force u32)keys.src,
--
1.7.7.3
