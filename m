From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] eql: dont rely on HZ=100
Date: Tue, 27 Mar 2012 01:52:00 -0700
Message-ID: <1332838320.3248.6.camel@edumazet-laptop>
References: <1332669700.32446.142.camel@shinybook.infradead.org>
	 <1332746975.2379.5.camel@shinybook.infradead.org>
	 <1332835965.3248.2.camel@edumazet-laptop>
	 <1332836241.2058.35.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56541 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757269Ab2C0IwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 04:52:06 -0400
Received: by wgbdr13 with SMTP id dr13so4647460wgb.1
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 01:52:04 -0700 (PDT)
In-Reply-To: <1332836241.2058.35.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 mars 2012 =C3=A0 09:17 +0100, David Woodhouse a =C3=A9crit =
:

> Thanks. I blame the baby for that one too. Once she's been taken
> swimming and dropped off at nursery and I've had at least two more cu=
ps
> of tea, I'll have another go :)
>=20

Looking at this driver, it seems it depends on HZ=3D100 ?

[PATCH] eql: dont rely on HZ=3D100

HZ is more likely to be 1000 these days.

timer handlers are run from softirq, no need to disable bh

skb priority 1 is TC_PRIO_FILLER

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/eql.c      |    7 ++++---
 include/linux/if_eql.h |    2 +-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index a59cf96..f219d38 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -125,6 +125,7 @@
 #include <linux/if.h>
 #include <linux/if_arp.h>
 #include <linux/if_eql.h>
+#include <linux/pkt_sched.h>
=20
 #include <asm/uaccess.h>
=20
@@ -143,7 +144,7 @@ static void eql_timer(unsigned long param)
 	equalizer_t *eql =3D (equalizer_t *) param;
 	struct list_head *this, *tmp, *head;
=20
-	spin_lock_bh(&eql->queue.lock);
+	spin_lock(&eql->queue.lock);
 	head =3D &eql->queue.all_slaves;
 	list_for_each_safe(this, tmp, head) {
 		slave_t *slave =3D list_entry(this, slave_t, list);
@@ -157,7 +158,7 @@ static void eql_timer(unsigned long param)
 		}
=20
 	}
-	spin_unlock_bh(&eql->queue.lock);
+	spin_unlock(&eql->queue.lock);
=20
 	eql->timer.expires =3D jiffies + EQL_DEFAULT_RESCHED_IVAL;
 	add_timer(&eql->timer);
@@ -341,7 +342,7 @@ static netdev_tx_t eql_slave_xmit(struct sk_buff *s=
kb, struct net_device *dev)
 		struct net_device *slave_dev =3D slave->dev;
=20
 		skb->dev =3D slave_dev;
-		skb->priority =3D 1;
+		skb->priority =3D TC_PRIO_FILLER;
 		slave->bytes_queued +=3D skb->len;
 		dev_queue_xmit(skb);
 		dev->stats.tx_packets++;
diff --git a/include/linux/if_eql.h b/include/linux/if_eql.h
index 79c4f26..18a5d02 100644
--- a/include/linux/if_eql.h
+++ b/include/linux/if_eql.h
@@ -22,7 +22,7 @@
 #define EQL_DEFAULT_SLAVE_PRIORITY 28800
 #define EQL_DEFAULT_MAX_SLAVES     4
 #define EQL_DEFAULT_MTU            576
-#define EQL_DEFAULT_RESCHED_IVAL   100
+#define EQL_DEFAULT_RESCHED_IVAL   HZ
=20
 #define EQL_ENSLAVE     (SIOCDEVPRIVATE)
 #define EQL_EMANCIPATE  (SIOCDEVPRIVATE + 1)
