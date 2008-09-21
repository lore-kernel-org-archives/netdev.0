From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 01:06:49 +0400
Message-ID: <20080921210649.GB2135@2ka.mipt.ru>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org> <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru> <20080921200518.GK7736@localhost> <20080921202656.GC25052@2ka.mipt.ru> <20080921203503.GL7736@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080921203503.GL7736@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2008 at 12:35:03AM +0400, Cyrill Gorcunov (gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> yes Evgeniy - all could know that but this register info could help
> firmware engineers to distinguish problems (without additional efforts
> like ask users to pass debug argument - kerneloops will have it
> by default) if there not only one exist. I mean I don't think anyone
> would reject additional info about problem ever :)

Agreed.

diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 19a401c..36cdd57 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -206,6 +206,9 @@ MODULE_PARM_DESC(disable, "manually disable the radio (default 0 [radio on])");
 
 static u32 ipw2100_debug_level = IPW_DL_NONE;
 
+static int ipw2100_max_fatal_ints = 10;
+module_param(ipw2100_max_fatal_ints, int, 0644);
+
 #ifdef CONFIG_IPW2100_DEBUG
 #define IPW_DEBUG(level, message...) \
 do { \
@@ -3174,16 +3177,21 @@ static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
 	if (inta & IPW2100_INTA_FATAL_ERROR) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Fatal interrupt. Scheduling firmware restart.\n");
+
+		printk(KERN_WARNING DRV_NAME ": INTA: 0x%08lX\n",
+			(unsigned long)inta & IPW_INTERRUPT_MASK);
+
 		priv->inta_other++;
 		write_register(dev, IPW_REG_INTA, IPW2100_INTA_FATAL_ERROR);
 
 		read_nic_dword(dev, IPW_NIC_FATAL_ERROR, &priv->fatal_error);
-		IPW_DEBUG_INFO("%s: Fatal error value: 0x%08X\n",
+		printk(KERN_WARNING "%s: Fatal error value: 0x%08X\n",
 			       priv->net_dev->name, priv->fatal_error);
 
 		read_nic_dword(dev, IPW_ERROR_ADDR(priv->fatal_error), &tmp);
-		IPW_DEBUG_INFO("%s: Fatal error address value: 0x%08X\n",
+		printk(KERN_WARNING "%s: Fatal error address value: 0x%08X\n",
 			       priv->net_dev->name, tmp);
+		WARN_ON(ipw2100_max_fatal_ints-- >= 0);
 
 		/* Wake up any sleeping jobs */
 		schedule_reset(priv);


-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
