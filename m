From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 39372] New: Problems with HFSC Scheduler
Date: Sat, 30 Jul 2011 07:22:42 +0200
Message-ID: <1312003362.2873.54.camel@edumazet-laptop>
References: <bug-39372-10286@https.bugzilla.kernel.org/>
	 <20110714151425.844b7738.akpm@linux-foundation.org>
	 <4E32A796.8060104@ziu.info>
	 <1311946060.2843.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311948052.2843.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32BF87.6010909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Soltys <soltys@ziu.info>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>, lucas.bocchi@gmail.com,
	631945@bugs.debian.org, 00bormoj@gmail.com,
	fdelawarde@wirelessmundi.com
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62233 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab1G3FWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2011 01:22:47 -0400
Received: by wwe5 with SMTP id 5so4131995wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 22:22:46 -0700 (PDT)
In-Reply-To: <4E32BF87.6010909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 16:11 +0200, Patrick McHardy a =C3=A9=
crit :

> Yeah, that seems to be the correct fix, thanks for looking into this.

Thanks Patrick, here is the official patch submission then ;)

[PATCH] sch_sfq: fix sfq_enqueue()

commit 8efa88540635 (sch_sfq: avoid giving spurious NET_XMIT_CN signals=
)
forgot to call qdisc_tree_decrease_qlen() to signal upper levels that a
packet (from another flow) was dropped, leading to various problems.=20

With help from Michal Soltys and Michal Pokrywka, who did a bisection.

Bugzilla ref: https://bugzilla.kernel.org/show_bug.cgi?id=3D39372
Debian ref: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D631945

Reported-by: Lucas Bocchi <lucas.bocchi@gmail.com>
Reported-and-bisected-by: Michal Pokrywka <wolfmoon@o2.pl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Michal Soltys <soltys@ziu.info>
Acked-by: Patrick McHardy <kaber@trash.net>
---
 net/sched/sch_sfq.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 4536ee6..2a2d287 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -410,7 +410,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch=
)
 	/* Return Congestion Notification only if we dropped a packet
 	 * from this flow.
 	 */
-	return (qlen !=3D slot->qlen) ? NET_XMIT_CN : NET_XMIT_SUCCESS;
+	if (qlen !=3D slot->qlen)
+		return NET_XMIT_CN;
+
+	/* As we dropped a packet, better let upper stack know this */
+	qdisc_tree_decrease_qlen(sch, 1);
+	return NET_XMIT_SUCCESS;
 }
=20
 static struct sk_buff *


