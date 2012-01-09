From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Mon, 09 Jan 2012 22:47:57 +0100
Message-ID: <4F0B608D.6090309@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: David Laight <David.Laight@ACULAB.COM>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello guys,

>>>>> -    outb(reg, base);
>>>>> -    outb(val, base + 1);
>>>>> +    outw( reg + ( val<<   8), base);
>>>>
>>>> That modification does fix your problem, right? The others above
> don't
>>>> help nor harm but we don't know if it's really realted to the same
>>>> problem. I wll dig a bit deeper.
>>>
>>> Exactly. The others above I removed because facing the opposite,
> even
>>> missing interrupts but then just to avoid other possible side
> effects
>>> and then assuming that they might be related.
>>
>> OK. My concern: Can we be sure that 16bit accesses are always
> supported
>> by the hardware? Does a spinlock_irqsave/spinlock_irqrestore around
> the
>> 8bit accesses already help?
>
> Hmmm... are there any register reads that need the
> same 'double cycle' sequence ??
> If so you need to stop reads being interleaved (with
> themselves and writes) so requesting a 16bit access
> doesn't help.
>
> Which means you need a spinlock...
>
> 	David
>
>

@David: Thank You very much for that hint. You are right and to
implement correct we need a spinlock.

@Wolfgang: I was thinking about Your question regarding 8/16 bit and
in fact it wouldn't work at all on a clean 8 bit cards.

Further it wouldn't work on 16 bit cards where the MSB is not equal
to base port +1 and anyway, it's depending always on how the chip is
interfaced to the ISA bus and in which mode the chip is configured.


And therefore I was giving David's hint a try in using a spinlock in
function cc770_isa_port_write_reg_indirect() and patched as follows:

---------------------------------------------------------------------
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
index 4be5fe2..fe39eed 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -110,6 +110,9 @@ MODULE_PARM_DESC(bcr, "Bus configuration register (default=0x40 [CBY])");
  #define CC770_IOSIZE          0x20
  #define CC770_IOSIZE_INDIRECT 0x02

+/* Spinlock for cc770_isa_port_write_reg_indirect */
+static DEFINE_SPINLOCK( outb_lock);
+
  static struct platform_device *cc770_isa_devs[MAXDEV];

  static u8 cc770_isa_mem_read_reg(const struct cc770_priv *priv, int reg)
@@ -147,9 +150,12 @@ static void cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
  						int reg, u8 val)
  {
  	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags;

+	spin_lock_irqsave( &outb_lock, flags);
  	outb(reg, base);
  	outb(val, base + 1);
+	spin_unlock_irqrestore( &outb_lock, flags);	
  }

  static int __devinit cc770_isa_probe(struct platform_device *pdev)
----------------------------------------------------------------------


The result is absolutely perfect. I was sending 2,000,000 telegrams
without any problem like the foregoing patch but now 8 bit compatible.




Further I have also investigated a bit the issue regarding the "HM"
patches.

I checked out the can4linux and I could find this patch in file
can_i82527funcs.c as mentioned by Oliver.
@Oliver: BTW thanks for Your investigation.

After studying the Makefile and some tests I discovered that
this file is just used for the target SBS_PC7 but funny enough not
for GENERIC_I82527.

I was seeking the declaration of CANout used in can_i82527funcs.c
to see if it's based on the same code we had and as well as in Lincan
but unfortunately the target SBS_PC7 doesn't compile with kernel
2.6.39-4 and moreover I got the message:
...can4linux/trunk/can4linux/i82527funcs.c:72:
                       error: implicit declaration of function 'CANout'

And additional not knowing if the board of SBS_PC7 is ISA or PCI based
I tried to find out and found after some research the following
thread:
http://old.nabble.com/-PATCH-v2--cc770-isa%3A-legacy-driver-for-CC770-i82725-on-the-ISA-bus-td24216347.html

According to that I assumed it's ISA based and is working with cc770_isa.

But not finding the declaration of CANout used in can_i82527funcs.c I
assumed further that it was done without spinlock which might cause
the effect of repeated or even lost interrupts as well depending on
the hardware configuration.

If this is the case then the HM patches would be obsolete and maybe
someone owning a SBS PC7 can test without these patches.

@Henrik: I would like to ask You if You can confirm this when You are
back.
Thanks a lot.


Wolfgang

