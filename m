From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 21:43:55 +0200
Message-ID: <1270237435.2545.4.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	 <1270197304.1936.179.camel@edumazet-laptop>
	 <1270211871.11099.2.camel@edumazet-laptop>
	 <1270225735.11099.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:59148 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab0DBToA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 15:44:00 -0400
Received: by bwz9 with SMTP id 9so1831176bwz.29
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 12:43:59 -0700 (PDT)
In-Reply-To: <1270225735.11099.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 avril 2010 =C3=A0 18:28 +0200, Eric Dumazet a =C3=A9crit=
 :
> Some more thoughts ...
>=20
> Do we really want to call inet_rps_record_flow(sk) from inet_sendmsg(=
) &
> inet_sendpage() ?
>=20
> This seems not necessary to me...
>=20

I think I get it, you want to catch unidirectional flows (apps that onl=
y
send data), and let ACK packets be processed by the sender cpu :=3D)


I did following patch to remove one conditional branch :

 net/core/dev.c |   20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)


diff --git a/net/core/dev.c b/net/core/dev.c
index 0a9ced8..cfe46d8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2225,8 +2225,6 @@ static int get_rps_cpu(struct net_device *dev, st=
ruct sk_buff *skb,
 	u16 tcpu;
 	u32 addr1, addr2, ports, ihl;
=20
-	*rflowp =3D NULL;
-
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index =3D skb_get_rx_queue(skb);
 		if (unlikely(index >=3D dev->num_rx_queues)) {
@@ -2443,7 +2441,7 @@ int netif_rx(struct sk_buff *skb)
 {
 	unsigned int qtail;
 #ifdef CONFIG_RPS
-	struct rps_dev_flow *rflow;
+	struct rps_dev_flow voidflow, *rflow =3D &voidflow;
 	int cpu, err;
 #endif
=20
@@ -2461,10 +2459,7 @@ int netif_rx(struct sk_buff *skb)
 	if (cpu < 0)
 		cpu =3D smp_processor_id();
=20
-	err =3D enqueue_to_backlog(skb, cpu, &qtail);
-
-	if (rflow)
-		rflow->last_qtail =3D qtail;
+	err =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
=20
 	rcu_read_unlock();
=20
@@ -2839,7 +2834,7 @@ out:
 int netif_receive_skb(struct sk_buff *skb)
 {
 #ifdef CONFIG_RPS
-	struct rps_dev_flow *rflow;
+	struct rps_dev_flow voidflow, *rflow =3D &voidflow;
 	int cpu, err;
=20
 	rcu_read_lock();
@@ -2848,13 +2843,8 @@ int netif_receive_skb(struct sk_buff *skb)
=20
 	if (cpu < 0)
 		err =3D __netif_receive_skb(skb);
-	else {
-		unsigned int qtail;
-
-		err =3D enqueue_to_backlog(skb, cpu, &qtail);
-		if (rflow)
-			rflow->last_qtail =3D qtail;
-	}
+	else
+		err =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
=20
 	rcu_read_unlock();
=20


