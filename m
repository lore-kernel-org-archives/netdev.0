From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: fq: increase max delay from 125 ms to
 one second
Date: Tue, 25 Nov 2014 08:57:29 -0800
Message-ID: <1416934649.29427.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
	 <1416933094.29427.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Yang Yingliang <yangyingliang@huawei.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:37435 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbaKYQ5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:57:31 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so906850ieb.40
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:57:31 -0800 (PST)
In-Reply-To: <1416933094.29427.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

FQ/pacing has a clamp of delay of 125 ms, to avoid some possible harm.

It turns out this delay is too small to allow pacing low rates :
Some ISP setup very aggressive policers as low as 16kbit.
    
Now TCP stack has spurious rtx prevention, it seems safe to increase
this fixed parameter, without adding a qdisc attribute.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yang Yingliang <yangyingliang@huawei.com>
---
This is something we run since July 2014 with good results, I forgot to
upstream this change. Thanks !

Notes for Googlers :

 Google-Bug-Id: 9297267
 Google-Bug-Id: 11789651
 Change-Id: I081d7d842bfb860a4cd620bf1c71a8eb239150c8

 net/sched/sch_fq.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index cbd7e1fd23b41bb7ba0bb348c3a1a287652cca93..9b05924cc386ecc2cdb9816be27e439637fb37b3 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -481,12 +481,11 @@ begin:
 		if (likely(rate))
 			do_div(len, rate);
 		/* Since socket rate can change later,
-		 * clamp the delay to 125 ms.
-		 * TODO: maybe segment the too big skb, as in commit
-		 * e43ac79a4bc ("sch_tbf: segment too big GSO packets")
+		 * clamp the delay to 1 second.
+		 * Really, providers of too big packets should be fixed !
 		 */
-		if (unlikely(len > 125 * NSEC_PER_MSEC)) {
-			len = 125 * NSEC_PER_MSEC;
+		if (unlikely(len > NSEC_PER_SEC)) {
+			len = NSEC_PER_SEC;
 			q->stat_pkts_too_long++;
 		}
 
