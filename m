From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Thu, 02 Jul 2009 12:51:17 +0200
Message-ID: <4A4C9125.8020705@gmail.com>
References: <20090630.213927.180401151.davem@davemloft.net> <20090702075724.GA10608@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50577 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbZGBKvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 06:51:32 -0400
In-Reply-To: <20090702075724.GA10608@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
>> The following changes since commit 52989765629e7d182b4f146050ebba0ab=
f2cb0b7:
>>   Linus Torvalds (1):
>>         Merge git://git.kernel.org/.../davem/net-2.6
>>
>> are available in the git repository at:
>>
>>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git mast=
er
>=20
> Hm, something in this lot quickly wrecked networking here - see the=20
> tx timeout dump below. It starts with:
>=20
> [  351.004596] WARNING: at net/sched/sch_generic.c:246 dev_watchdog+0=
x10b/0x19c()
> [  351.011815] Hardware name: System Product Name
> [  351.016220] NETDEV WATCHDOG: eth0 (forcedeth): transmit queue 0 ti=
med out
>=20
> Config attached. Unfortunately i've got no time to do bisection=20
> today.



forcedeth might have a problem, in its netif_wake_queue() logic, but
I could not see why a recent patch could make this problem visible now.

CPU0/1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
is not a new cpu either :)

forcedeth uses an internal tx_stop without appropriate barrier.

Could you try following patch ?

(random guess as I dont have much time right now)

Thank you


diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1094d29..dc6bbde 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2165,7 +2165,7 @@ static int nv_start_xmit(struct sk_buff *skb, str=
uct net_device *dev)
 	empty_slots =3D nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <=3D entries)) {
 		netif_stop_queue(dev);
-		np->tx_stop =3D 1;
+		set_mb(np->tx_stop, 1);
 		spin_unlock_irqrestore(&np->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
@@ -2286,7 +2286,7 @@ static int nv_start_xmit_optimized(struct sk_buff=
 *skb, struct net_device *dev)
 	empty_slots =3D nv_get_empty_tx_slots(np);
 	if (unlikely(empty_slots <=3D entries)) {
 		netif_stop_queue(dev);
-		np->tx_stop =3D 1;
+		set_mb(np->tx_stop, 1);
 		spin_unlock_irqrestore(&np->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
@@ -2564,7 +2564,7 @@ static void nv_tx_timeout(struct net_device *dev)
 	else
 		status =3D readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
=20
-	printk(KERN_INFO "%s: Got tx_timeout. irq: %08x\n", dev->name, status=
);
+	printk(KERN_INFO "%s: Got tx_timeout. irq: %08x tx_stop=3D%d\n", dev-=
>name, status, np->tx_stop);
=20
 	{
 		int i;
