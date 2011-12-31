From: Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Sat, 31 Dec 2011 10:39:35 +0100
Message-ID: <4EFED857.3000701@essax.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
	<4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com>
	<4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com>
	<4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com>
	<4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com>
	<4EE1E26B.6090308@grandegger.com> <4EE4F76E.3000506@essax.com>
	<4EE5C824.2050704@grandegger.com> <4EE5E321.8050104@essax.com>
	<4EE5EBBF.6080007@grandegger.com> <4EF22625.5000109@essax.com>
	<4EF2FA3F.3010308@grandegger.com> <4EF32E84.1080006@essax.com>
Reply-To: info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4EF32E84.1080006-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Wolfgang,

> Hello Wolfgang,
>> Hi Wolfgang,
>>
>> On 12/21/2011 07:32 PM, Wolfgang Zarre wrote:
>>> Hello Wolfgang,
>> ...
>>
>>
>> Again, please check if you have netif_start_queue() at the end of the
>> open function.
>>
>
> As said I'm using eec921ac28fde243456078a557768808d93d94a3
>
> However, I'll try further to investigate that issue due the fact having it
> running with my lincan without problems and therefore it should be possible
> to find the problem.
>

I found the problem which was then at the end quite simple to understand why it
get stuck due the fact not receiving an interrupt for TX and due that no
reactivation of the queue.

I think that maybe also the hacks in the TX functions are obsolete with the
fix assuming that the repeated interrupts just happen by indirect access.

Here my fix which worked for me:
--------------------------------------------------------------------------------------------------------
diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
index 2d12f89..dad6707 100644
--- a/drivers/net/can/cc770/cc770.c
+++ b/drivers/net/can/cc770/cc770.c
@@ -460,15 +460,6 @@ static netdev_tx_t cc770_start_xmit(struct sk_buff *skb, struct net_device *dev)

  	stats->tx_bytes += dlc;

-
-	/*
-	 * HM: We had some cases of repeated IRQs so make sure the
-	 * INT is acknowledged I know it's already further up, but
-	 * doing again fixed the issue
-	 */
-	cc770_write_reg(priv, msgobj[mo].ctrl0,
-			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
-
  	return NETDEV_TX_OK;
  }

@@ -689,12 +680,6 @@ static void cc770_tx_interrupt(struct net_device *dev, unsigned int o)
  	/* Nothing more to send, switch off interrupts */
  	cc770_write_reg(priv, msgobj[mo].ctrl0,
  			MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
-	/*
-	 * We had some cases of repeated IRQ so make sure the
-	 * INT is acknowledged
-	 */
-	cc770_write_reg(priv, msgobj[mo].ctrl0,
-			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);

  	stats->tx_packets++;
  	can_get_echo_skb(dev, 0);
diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index 4be5fe2..48fc128 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -148,8 +148,7 @@ static void cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
  {
  	unsigned long base = (unsigned long)priv->reg_base;

-	outb(reg, base);
-	outb(val, base + 1);
+	outw( reg + ( val << 8), base);
  }

  static int __devinit cc770_isa_probe(struct platform_device *pdev)

---------------------------------------------------------------------------------------------


Please let me know if this is OK for You, maybe You can do some tests as well.

Would continue then with further tests regarding error conditions, however
I realised another small issue with dropped packages at reception.

As soon as You read the first time from the socket and then You stop reading
the packages are not counted as 'dropped' any more which is IMHO not correct
because as soon as You stop reading they should be counted as dropped again.


>> Wolfgang.
>
> Wolfgang

Wolfgang
