From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Mon, 22 Sep 2008 00:20:57 +0400
Message-ID: <20080921202057.GB25052@2ka.mipt.ru>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org> <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru> <20080921124332.67ddc13a@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ipw2100-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, yi.zhu@intel.com,
	reinette.chatre@intel.com, jgarzik@pobox.com,
	linville@tuxdriver.com, davem@davemloft.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:40999 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbYIUUYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2008 16:24:37 -0400
Content-Disposition: inline
In-Reply-To: <20080921124332.67ddc13a@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 12:43:32PM -0700, Arjan van de Ven (arjan@infradead.org) wrote:
> > @@ -3174,6 +3176,10 @@ static void ipw2100_irq_tasklet(struct
> > ipw2100_priv *priv) if (inta & IPW2100_INTA_FATAL_ERROR) {
> >  		printk(KERN_WARNING DRV_NAME
> >  		       ": Fatal interrupt. Scheduling firmware
> > restart.\n");
> > +		WARN_ON(1);
> > +
> > +		BUG_ON(ipw2100_max_fatal_ints-- <= 0);
> 
> BUG_ON in interrupt context is just extremely hostile, since it means
> the box is dead.
>
> also I would suggest using WARN_ON_ONCE() 

Well, I actually wanted to have a bug there because of it, but now I
think that annoying repeated warning is enough to bring attention to the
problem by putting bug information into some magic special place called
kerneloops collection.

Consider for inclusing for the upcoming kernel to get wider
notifications. Yes, it is not a bugfix, I know.

diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 19a401c..6599211 100644
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
@@ -3174,6 +3177,9 @@ static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
 	if (inta & IPW2100_INTA_FATAL_ERROR) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Fatal interrupt. Scheduling firmware restart.\n");
+
+		WARN_ON(ipw2100_max_fatal_ints-- >= 0);
+
 		priv->inta_other++;
 		write_register(dev, IPW_REG_INTA, IPW2100_INTA_FATAL_ERROR);
 


-- 
	Evgeniy Polyakov
