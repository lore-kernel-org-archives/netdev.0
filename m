From: "Laurent Chavey" <chavey@google.com>
Subject: [PATCH] bonding: Added fix for device xmit call with irq disabled <resubmit>
Date: Fri, 13 Jun 2008 18:14:55 -0700
Message-ID: <97949e3e0806131814j1f22fd72oce1541511d728120@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:58841 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787AbYFNBPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:15:02 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m5E1Evvo008154
	for <netdev@vger.kernel.org>; Sat, 14 Jun 2008 02:14:57 +0100
Received: from wf-out-1314.google.com (wff29.prod.google.com [10.142.6.29])
	by zps36.corp.google.com with ESMTP id m5E1Ej05028690
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 18:14:56 -0700
Received: by wf-out-1314.google.com with SMTP id 29so5222341wff.29
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 18:14:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmitting. Previous patch sent with html tags.

In some rare cases (i.e. netconsole), hard_start_xmit() may be
called with interrupts disabled as such it cannot call the slave's
dev_queue_xmit() with interrupts disabled. So instead, it calls the
slave's hard_start_xmit().

Signed-off-by: Laurent Chavey <chavey@google.com>

--- linux-2.6.25.org/drivers/net/bonding/bond_main.c    2008-04-16
19:49:44.000000000 -0700
+++ linux-2.6.25/drivers/net/bonding/bond_main.c        2008-06-13
17:37:10.000000000 -0700
@@ -401,8 +401,21 @@
                skb->dev = slave_dev;
        }

-       skb->priority = 1;
-       dev_queue_xmit(skb);
+       /* priority field is used by tc qdiscs for classifying
+        * packets. See usage of TC_H_MAJ and TC_H_MIN in
+        * /net/sched/sch_*.c files.
+        */
+       skb->priority |= 1;
+
+       /* In some rare cases (i.e. netconsole), hard_start_xmit() may be
+        * called with interrupts disabled as such it cannot call the slave's
+        * dev_queue_xmit() with interrupts disabled. So instead, it calls the
+        * slave's hard_start_xmit().
+        */
+       if (unlikely(irqs_disabled()))
+               slave_dev->hard_start_xmit(skb, slave_dev);
+       else
+               dev_queue_xmit(skb);

        return 0;
 }

--
