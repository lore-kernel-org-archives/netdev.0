From: Jeff Garzik <jgarzik@pobox.com>
Subject: [Fwd: PATCH pktgen hang, memleak, fixes]
Date: Thu, 10 Jul 2003 13:40:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0DA525.2080808@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010608040006050807000806"
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010608040006050807000806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------010608040006050807000806
Content-Type: message/rfc822;
 name="PATCH pktgen hang, memleak, fixes"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="PATCH pktgen hang, memleak, fixes"

Return-Path: <linux-kernel-owner+jgarzik=40pobox.com@vger.kernel.org>
Delivered-To: garzik@gtf.org
Received: from puzzle.pobox.com (puzzle.pobox.com [207.106.49.20])
	by havoc.gtf.org (Postfix) with ESMTP id 7E495665C
	for <garzik@gtf.org>; Thu, 10 Jul 2003 11:27:15 -0400 (EDT)
Received: from puzzle.pobox.com (localhost [127.0.0.1])
	by puzzle.pobox.com (Postfix) with ESMTP id E4B9426C011
	for <garzik@gtf.org>; Thu, 10 Jul 2003 11:27:14 -0400 (EDT)
Delivered-To: jgarzik@pobox.com
Received: from vger.kernel.org (vger.kernel.org [209.116.70.75])
	by puzzle.pobox.com (Postfix) with ESMTP id C3B2526C124
	for <jgarzik@pobox.com>; Thu, 10 Jul 2003 11:27:14 -0400 (EDT)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S269321AbTGJPHs (ORCPT <rfc822;jgarzik@pobox.com>);
	Thu, 10 Jul 2003 11:07:48 -0400
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S269324AbTGJPHr
	(ORCPT <rfc822;linux-kernel-outgoing>);
	Thu, 10 Jul 2003 11:07:47 -0400
Received: from sea2-f47.sea2.hotmail.com ([207.68.165.47]:64013 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S269321AbTGJPHp
	(ORCPT <rfc822;linux-kernel@vger.kernel.org>);
	Thu, 10 Jul 2003 11:07:45 -0400
Received: from mail pickup service by hotmail.com with Microsoft SMTPSVC;
	 Thu, 10 Jul 2003 08:22:25 -0700
Received: from 63.173.114.243 by sea2fd.sea2.hotmail.msn.com with HTTP;
	Thu, 10 Jul 2003 15:22:24 GMT
X-Originating-IP: [63.173.114.243]
X-Originating-Email: [kambo77@hotmail.com]
From: "Kambo Lohan" <kambo77@hotmail.com>
To: linux-kernel@vger.kernel.org
Subject: PATCH pktgen hang, memleak, fixes 
Date: Thu, 10 Jul 2003 11:22:24 -0400
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Message-ID: <Sea2-F47vJo8jUbRX8z000320b1@hotmail.com>
X-OriginalArrivalTime: 10 Jul 2003 15:22:25.0186 (UTC) FILETIME=[10F4F020:01C346F7]
Sender: linux-kernel-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-kernel@vger.kernel.org
X-Spam-Status: No, hits=-4.7 required=7.0
	tests=AWL,BAYES_10,FROM_ENDS_IN_NUMS,PATCH_UNIFIED_DIFF,
	      X_MAILING_LIST
	version=2.55
X-Spam-Level: 
X-Spam-Checker-Version: SpamAssassin 2.55 (1.174.2.19-2003-05-19-exp)

This should fix about 3 things.  My first patch, be gentle...

2.5 has the same problem but I do not know if this will apply or not, we run 
2.4.


>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--- linux-2.4.21/net/core/pktgen.c	2002-11-28 18:53:15.000000000 -0500
+++ linux-2.4-kjp/net/core/pktgen.c	2003-07-10 11:08:31.000000000 -0400
@@ -34,6 +34,7 @@
  *   *  The new changes seem to have a performance impact of around 1%,
  *       as far as I can tell.
  *   --Ben Greear <greearb@candelatech.com>
+ * Fix refcount off by one if first packet fails, potential null deref, 
memleak 030710- KJP
  *
  * Renamed multiskb to clone_skb and cleaned up sending core for two 
distinct
  * skb modes. A clone_skb=0 mode for Ben "ranges" work and a clone_skb != 0
@@ -84,9 +85,9 @@
#define cycles()	((u32)get_cycles())


-#define VERSION "pktgen version 1.2"
+#define VERSION "pktgen version 1.2.1"
static char version[] __initdata =
-  "pktgen.c: v1.2: Packet Generator for packet performance testing.\n";
+  "pktgen.c: v1.2.1: Packet Generator for packet performance testing.\n";

/* Used to help with determining the pkts on receive */

@@ -613,12 +614,11 @@
                                 kfree_skb(skb);
                                 skb = fill_packet(odev, info);
                                 if (skb == NULL) {
-                                        break;
+					goto out_reldev;
                                 }
                                 fp++;
                                 fp_tmp = 0; /* reset counter */
                         }
-                        atomic_inc(&skb->users);
                 }

                 nr_frags = skb_shinfo(skb)->nr_frags;
@@ -634,9 +634,10 @@
				last_ok = 0;
			}
                         else {
-		           last_ok = 1;
-                           info->sofar++;
-                           info->seq_num++;
+				atomic_inc(&skb->users);
+				last_ok = 1;
+				info->sofar++;
+				info->seq_num++;
                         }
		}
		else {
@@ -707,6 +708,7 @@
		}
	}/* while we should be running */

+
	do_gettimeofday(&(info->stopped_at));

	total = (info->stopped_at.tv_sec - info->started_at.tv_sec) * 1000000 +
@@ -731,6 +733,8 @@
			     (unsigned long long) info->errors
			     );
	}
+
+	kfree_skb(skb);

out_reldev:
         if (odev) {

_________________________________________________________________
STOP MORE SPAM with the new MSN 8 and get 2 months FREE*  
http://join.msn.com/?page=features/junkmail

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/



--------------010608040006050807000806--
