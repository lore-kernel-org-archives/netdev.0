From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Wed, 11 Jan 2012 10:05:46 +0100
Message-ID: <4F0D50EA.6080900@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com> <4F0C31F1.20908@essax.com> <4F0C4EA8.7060002@grandegger.com> <4F0C63C6.5080305@essax.com> <4F0C661F.6030508@grandegger.com> <4F0C8B4B.8070104@essax.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F0C8B4B.8070104@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Wolfgang,

> Hello Wolfgang,
>
> -------- Original Message --------
> Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver for the CC770 and AN82527
> From: Wolfgang Grandegger <wg@grandegger.com>
> To: info@essax.com
> Cc: David Laight <David.Laight@ACULAB.COM>, Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com, netdev@vger.kernel.org, linux-can@vger.kernel.org,
> socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>, Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de, henrik@focus-sw.com
> Date: Tue Jan 10 2012 17:23:59 GMT+0100 (CET)
>
>> Hi Wolfgang,
>>
>> On 01/10/2012 05:13 PM, Wolfgang Zarre wrote:
>>> Hello Wolfgang,
>>>
>>>> On 01/10/2012 01:41 PM, Wolfgang Zarre wrote:
>>>>> Hello David,
>>>>>>
>>>>>>> cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
>>>>>>> int reg, u8 val)
>>>>>>> {
>>>>>>> unsigned long base = (unsigned long)priv->reg_base;
>>>>>>> + unsigned long flags;
>>>>>>>
>>>>>>> + spin_lock_irqsave(&outb_lock, flags);
>>>>>>> outb(reg, base);
>>>>>>> outb(val, base + 1);
>>>>>>> + spin_unlock_irqrestore(&outb_lock, flags);
>>>>>>
>>>>>> Is there a 'read_reg_indirect' function??
>>>>>
>>>>> Yes, there is.
>>>>>
>>>>>> If so it also needs to use the same mutex.
>>>>>
>>>>> Actually, I don't think that we have a problem with mutex
>>>>> beside that it's using just one inb() statement but having
>>>>> for sure with an interrupt between both outb() statements which
>>>>> seems to be critical for the cc770.
>>>>
>>>> But the indirect read function also sets the address register before
>>>> reading the data using inb(). This sequence should also not be
>>>> interrupted and therefore we need to synchronize. For the indirect
>>>> access of the SJA1000 we also need to add spinlocks. Wonder why nobody
>>>> complained so far.
>>>
>>> So, if I understand correct that means that inb() can be interrupted
>>> between
>>> setting the address and reading. If this is the case then yes, we need
>>> spinlock if this is not the case then IMHO we wouldn't need or am I wrong?
>>
>> I think we speak about different things. inb() cannot be interrupted but
>> outb() followed by inb(). For indirect accesses we need something like:
>>
>> /* Spinlock for cc770_isa_port_write_reg_indirect */
>> static DEFINE_SPINLOCK(cc770_isa_port_lock);
>>
>> static u8 cc770_isa_port_read_reg_indirect(const struct cc770_priv *priv,
>> int reg)
>> {
>> unsigned long base = (unsigned long)priv->reg_base;
>> unsigned long flags;
>> u8 val;
>>
>> spin_lock_irqsave(&cc770_isa_port_lock, flags);
>> outb(reg, base);
>> val = inb(base + 1);
>> spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
>>
>> return val;
>> }
>>
>> static void cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
>> int reg, u8 val)
>> {
>> unsigned long base = (unsigned long)priv->reg_base;
>> unsigned long flags;
>>
>> spin_lock_irqsave(&cc770_isa_port_lock, flags);
>> outb(reg, base);
>> outb(val, base + 1);
>> spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
>> }
>>
>> Hope we are in synch now.
>>
>
> Thanks a lot. Yes, now phase locked and in synch and sorry, by mistake
> I looked at the wrong function (cc770_isa_port_read_reg) in the heat of
> the moment.
>
> Absolutely clear, there we need a spinlock definitely. I'll start another test run
> just to confirm.
>
>


Test was successful, 2.000.000 telegrams again without problems.
Here so far the patch as You suggested:

-------------------------------------------------------------------
  diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index 4be5fe2..adf3e45 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -110,6 +110,10 @@ MODULE_PARM_DESC(bcr, "Bus configuration register (default=0x40 [CBY])");
  #define CC770_IOSIZE          0x20
  #define CC770_IOSIZE_INDIRECT 0x02

+/* Spinlock for cc770_isa_port_write_reg_indirect */
+static DEFINE_SPINLOCK(cc770_isa_port_lock);
+
+
  static struct platform_device *cc770_isa_devs[MAXDEV];

  static u8 cc770_isa_mem_read_reg(const struct cc770_priv *priv, int reg)
@@ -138,18 +142,26 @@ static u8 cc770_isa_port_read_reg_indirect(const struct cc770_priv *priv,
  					     int reg)
  {
  	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags;
+	u8 val;

+	spin_lock_irqsave(&cc770_isa_port_lock, flags);
  	outb(reg, base);
-	return inb(base + 1);
+	val = inb(base + 1);
+	spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
+	return val;
  }

  static void cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
  						int reg, u8 val)
  {
  	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags;

+	spin_lock_irqsave(&cc770_isa_port_lock, flags);
  	outb(reg, base);
  	outb(val, base + 1);
+	spin_unlock_irqrestore(&cc770_isa_port_lock, flags); 	
  }

  static int __devinit cc770_isa_probe(struct platform_device *pdev)
-------------------------------------------------------


>> Wolfgang.
>>
>
> Wolfgang

Wolfgang
