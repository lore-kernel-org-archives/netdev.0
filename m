From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 11:45:33 +0100
Message-ID: <490AE1CD.9040207@cosmosbay.com>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>	<20081031.005219.141937694.davem@davemloft.net>	<Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi> <20081031.025159.51432990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030404020908030700070809"
Cc: ilpo.jarvinen@helsinki.fi, shemminger@vyatta.com, zbr@ioremap.net,
	rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, efault@gmx.de, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751960AbYJaKqm@vger.kernel.org>
In-Reply-To: <20081031.025159.51432990.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030404020908030700070809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Fri, 31 Oct 2008 11:40:16 +0200 (EET)
>=20
>> Let me remind that it is just a single process, so no ping-pong & othe=
r=20
>> lock related cache effects should play any significant role here, no? =
(I'm=20
>> no expert though :-)).
>=20
> Not locks or ping-pongs perhaps, I guess.  So it just sends and
> receives over a socket, implementing both ends of the communication
> in the same process?
>=20
> If hash chain conflicts do happen for those 2 sockets, just traversing
> the chain 2 entries deep could show up.

tbench is very sensible to cache line ping-pongs (on SMP machines of cour=
se)

Just to prove my point, I coded the following patch and tried it
on a HP BL460c G1. This machine has 2 quad cores cpu=20
(Intel(R) Xeon(R) CPU E5450  @3.00GHz)

tbench 8 went from 2240 MB/s to 2310 MB/s after this patch applied

[PATCH] net: Introduce netif_set_last_rx() helper

On SMP machine, loopback device (and possibly others net device)
should try to avoid dirty the memory cache line containing "last_rx"
field. Got 3% increase on tbench on a 8 cpus machine.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/loopback.c    |    2 +-
 include/linux/netdevice.h |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 1 deletion(-)


--------------030404020908030700070809
Content-Type: text/plain;
 name="netif_set_last_rx.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netif_set_last_rx.patch"

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 3b43bfd..cf17238 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -85,7 +85,7 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 #endif
-	dev->last_rx = jiffies;
+	netif_set_last_rx(dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
 	pcpu_lstats = dev->ml_priv;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c8bcb59..6729865 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -849,6 +849,22 @@ static inline void *netdev_priv(const struct net_device *dev)
 #define SET_NETDEV_DEV(net, pdev)	((net)->dev.parent = (pdev))
 
 /**
+ *	netif_set_last_rx - Set last_rx field of a device
+ *	@dev:  network device
+ *
+ * Instead of setting net->last_rx to jiffies, drivers should call this helper
+ * to avoid dirtying a cache line if last_rx already has the current jiffies
+ */
+static inline void netif_set_last_rx(struct net_device *dev)
+{
+#ifdef CONFIG_SMP
+	if (dev->last_rx == jiffies)
+		return;
+#endif
+	dev->last_rx = jiffies;
+}
+
+/**
  *	netif_napi_add - initialize a napi context
  *	@dev:  network device
  *	@napi: napi context

--------------030404020908030700070809--
