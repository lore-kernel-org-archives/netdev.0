From: Vernon Sauder <vernoninhand@gmail.com>
Subject: Re: [PATCH] smc91x: enable ethtool EEPROM interface
Date: Fri, 16 Jan 2009 12:28:20 -0500
Message-ID: <4970C3B4.1040006@gmail.com>
References: <1232081619-25580-1-git-send-email-VernonInHand@gmail.com>	<alpine.LFD.2.00.0901160004110.9524@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:39904 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935749AbZAPR2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 12:28:25 -0500
Received: by qyk4 with SMTP id 4so2107273qyk.13
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2009 09:28:23 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.0901160004110.9524@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Pitre wrote:

>On Thu, 15 Jan 2009, Vernon Sauder wrote:
>
>> From: Vernon Sauder <vsauder@inhand.com>
>> 
>> 
>> Signed-off-by: Vernon Sauder <vsauder@inhand.com>
>> ---
>>  drivers/net/smc91x.c |  112 +++++++++++++++++++++++++++++++++++++++++++++++++-
>>  1 files changed, 110 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
>> index b215a8d..f692439 100644
>> --- a/drivers/net/smc91x.c
>> +++ b/drivers/net/smc91x.c
>> @@ -1643,6 +1643,113 @@ static void smc_ethtool_setmsglevel(struct net_device *dev, u32 level)
>>  	lp->msg_enable = level;
>>  }
>>  
>> +/* GP is same as RPC, just bank 1 */
>> +#define SMC_GET_GP		SMC_GET_RPC
>> +#define SMC_SET_GP		SMC_SET_RPC
>
>NAK.  This will blow up the moment you have SMC_DEBUG > 0.
>Please add proper definitions in smc91x.h instead.
>
>
>Nicolas

Sorry about that. This was an old patch before bank checking. Here is an update.

From: Vernon Sauder <vsauder@inhand.com>
Date: Fri, 16 Jan 2009 12:05:42 -0500
Subject: [PATCH] smc91x: enable ethtool EEPROM interface


Signed-off-by: Vernon Sauder <vsauder@inhand.com>
---
 drivers/net/smc91x.c |  108 +++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/smc91x.h |   10 +++++
 2 files changed, 116 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index b215a8d..ba802f5 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1643,6 +1643,109 @@ static void smc_ethtool_setmsglevel(struct net_device *dev, u32 level)
 	lp->msg_enable = level;
 }

+static int smc_write_eeprom_word(struct net_device *dev, u16 addr, u16 word)
+{
+	struct smc_local *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+	spin_lock_irq(&lp->lock);
+	/* load word into GP register */
+	SMC_SELECT_BANK(lp, 1);
+	SMC_SET_GP(lp, word);
+	/* set the address to put the data in EEPROM */
+	SMC_SELECT_BANK(lp, 2);
+	SMC_SET_PTR(lp, addr);
+	/* tell it to write */
+	SMC_SELECT_BANK(lp, 1);
+	u16 ctl = SMC_GET_CTL(lp);
+	SMC_SET_CTL(lp, ctl | (CTL_EEPROM_SELECT | CTL_STORE));
+	/* wait for it to finish */
+	do {
+		udelay(1);
+	} while (SMC_GET_CTL(lp) & CTL_STORE);
+	/* clean up */
+	SMC_SET_CTL(lp, ctl);
+	SMC_SELECT_BANK(lp, 2);
+	spin_unlock_irq(&lp->lock);
+	return 0;
+}
+
+static int smc_read_eeprom_word(struct net_device *dev, u16 addr, u16 *word)
+{
+	struct smc_local *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+
+	spin_lock_irq(&lp->lock);
+	/* set the EEPROM address to get the data from */
+	SMC_SELECT_BANK(lp, 2);
+	SMC_SET_PTR(lp, addr | PTR_READ);
+	/* tell it to load */
+	SMC_SELECT_BANK(lp, 1);
+	SMC_SET_GP(lp, 0xffff);	/* init to known */
+	u16 ctl = SMC_GET_CTL(lp);
+	SMC_SET_CTL(lp, ctl | (CTL_EEPROM_SELECT | CTL_RELOAD));
+	/* wait for it to finish */
+	do {
+		udelay(1);
+	} while (SMC_GET_CTL(lp) & CTL_RELOAD);
+	/* read word from GP register */
+	*word = SMC_GET_GP(lp);
+	/* clean up */
+	SMC_SET_CTL(lp, ctl);
+	SMC_SELECT_BANK(lp, 2);
+	spin_unlock_irq(&lp->lock);
+	return 0;
+}
+
+static int smc_ethtool_geteeprom_len(struct net_device *dev)
+{
+	return 0x23 * 2;
+}
+
+static int smc_ethtool_geteeprom(struct net_device *dev,
+		struct ethtool_eeprom *eeprom, u8 *data)
+{
+	int i, ret;
+
+	DBG(1, "Reading %d bytes at %d(0x%x)\n",
+		eeprom->len, eeprom->offset, eeprom->offset);
+	int imax = smc_ethtool_geteeprom_len(dev);
+	for (i = 0; i < eeprom->len; i += 2) {
+		int offset = i + eeprom->offset;
+		if (offset > imax)
+			break;
+		u16 wbuf;
+		ret = smc_read_eeprom_word(dev, offset >> 1, &wbuf);
+		if (ret != 0)
+			return ret;
+		DBG(2, "Read 0x%x from 0x%x\n", wbuf, offset >> 1);
+		data[i] = (wbuf >> 8) & 0xff;
+		data[i+1] = wbuf & 0xff;
+	}
+	return 0;
+}
+
+static int smc_ethtool_seteeprom(struct net_device *dev,
+		struct ethtool_eeprom *eeprom, u8 *data)
+{
+	int i, ret;
+
+	DBG(1, "Writing %d bytes to %d(0x%x)\n",
+			eeprom->len, eeprom->offset, eeprom->offset);
+	int imax = smc_ethtool_geteeprom_len(dev);
+	for (i = 0; i < eeprom->len; i += 2) {
+		int offset = i + eeprom->offset;
+		if (offset > imax)
+			break;
+		u16 wbuf = (data[i] << 8) | data[i + 1];
+		DBG(2, "Writing 0x%x to 0x%x\n", wbuf, offset >> 1);
+		ret = smc_write_eeprom_word(dev, offset >> 1, wbuf);
+		if (ret != 0)
+			return ret;
+	}
+	return 0;
+}
+
+
 static const struct ethtool_ops smc_ethtool_ops = {
 	.get_settings	= smc_ethtool_getsettings,
 	.set_settings	= smc_ethtool_setsettings,
@@ -1652,8 +1755,9 @@ static const struct ethtool_ops smc_ethtool_ops = {
 	.set_msglevel	= smc_ethtool_setmsglevel,
 	.nway_reset	= smc_ethtool_nwayreset,
 	.get_link	= ethtool_op_get_link,
-//	.get_eeprom	= smc_ethtool_geteeprom,
-//	.set_eeprom	= smc_ethtool_seteeprom,
+	.get_eeprom_len = smc_ethtool_geteeprom_len,
+	.get_eeprom	= smc_ethtool_geteeprom,
+	.set_eeprom	= smc_ethtool_seteeprom,
 };

 /*
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index c4ccd12..ed9ae43 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -1141,6 +1141,16 @@ static const char * chip_ids[ 16 ] =  {

 #define SMC_GET_MII(lp)		SMC_inw(ioaddr, MII_REG(lp))

+#define SMC_GET_GP(lp)		SMC_inw(ioaddr, GP_REG(lp))
+
+#define SMC_SET_GP(lp, x)						\
+	do {								\
+		if (SMC_MUST_ALIGN_WRITE(lp))				\
+			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 8, 1));	\
+		else							\
+			SMC_outw(x, ioaddr, GP_REG(lp));		\
+	} while (0)
+
 #define SMC_SET_MII(lp, x)		SMC_outw(x, ioaddr, MII_REG(lp))

 #define SMC_GET_MIR(lp)		SMC_inw(ioaddr, MIR_REG(lp))
-- 
1.6.1

