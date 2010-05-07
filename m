From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: avoid one atomic in enqueue_to_backlog
Date: Fri, 07 May 2010 11:51:21 +0200
Message-ID: <1273225881.2261.39.camel@edumazet-laptop>
References: <1273136322.2357.15.camel@edumazet-laptop>
	 <20100506.220759.25136752.davem@davemloft.net>
	 <1273209375.2222.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:42585 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755571Ab0EGJvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 05:51:25 -0400
Received: by bwz19 with SMTP id 19so465031bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 02:51:23 -0700 (PDT)
In-Reply-To: <1273209375.2222.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 07:16 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 06 mai 2010 =C3=A0 22:07 -0700, David Miller a =C3=A9crit :
>=20
> > Looks great, applied, thanks Eric.
>=20
> Thanks, I have a followup to avoid one atomic in enqueue phase too ;)
>=20

[PATCH net-next-2.6] rps: avoid one atomic in enqueue_to_backlog

If CONFIG_SMP=3Dy, then we own a queue spinlock, we can avoid the atomi=
c
test_and_set_bit() from napi_schedule_prep().

We now have same number of atomic ops per netif_rx() calls than with
pre-RPS kernel.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 32611c8..49fa5a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2426,8 +2426,10 @@ enqueue:
 			return NET_RX_SUCCESS;
 		}
=20
-		/* Schedule NAPI for backlog device */
-		if (napi_schedule_prep(&sd->backlog)) {
+		/* Schedule NAPI for backlog device
+		 * We can use non atomic operation since we own the queue lock
+		 */
+		if (!__test_and_set_bit(NAPI_STATE_SCHED, &sd->backlog.state)) {
 			if (!rps_ipi_queued(sd))
 				____napi_schedule(sd, &sd->backlog);
 		}


