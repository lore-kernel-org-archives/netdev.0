From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] neigh: reorder struct neighbour
Date: Thu, 11 Nov 2010 17:57:19 +0100
Message-ID: <1289494639.17691.1499.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37323 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab0KKQ5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 11:57:23 -0500
Received: by wwb34 with SMTP id 34so69583wwb.1
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 08:57:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is important to move nud_state outside of the often modified cache
line (because of refcnt), to reduce false sharing in neigh_event_send()

This is a followup of commit 0ed8ddf4045f (neigh: Protect neigh->ha[]
with a seqlock)

This gives a 7% speedup on routing test with IP route cache disabled.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
David, it appears I forgot to push this patch, I have it in my tree
since one month. Thanks !

 include/net/neighbour.h |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 55590ab..815b2ce 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -96,16 +96,16 @@ struct neighbour {
 	struct neigh_parms	*parms;
 	unsigned long		confirmed;
 	unsigned long		updated;
-	__u8			flags;
-	__u8			nud_state;
-	__u8			type;
-	__u8			dead;
+	rwlock_t		lock;
 	atomic_t		refcnt;
 	struct sk_buff_head	arp_queue;
 	struct timer_list	timer;
 	unsigned long		used;
 	atomic_t		probes;
-	rwlock_t		lock;
+	__u8			flags;
+	__u8			nud_state;
+	__u8			type;
+	__u8			dead;
 	seqlock_t		ha_lock;
 	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
 	struct hh_cache		*hh;


