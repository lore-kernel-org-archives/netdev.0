From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hostap: Fix null pointer dereference in
	prism2_pccard_card_present()
Date: Sun, 28 Aug 2005 17:53:32 -0700
Message-ID: <20050829005331.GW7781@jm.kir.nu>
References: <871x4dx2ry.fsf@litku.valo.iki.fi> <43124814.8010704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <Kalle.Valo@iki.fi>, netdev@vger.kernel.org,
	hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <43124814.8010704@pobox.com>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 28, 2005 at 07:26:12PM -0400, Jeff Garzik wrote:
> applied, but let us know when the root cause is found...

local->hw_priv was initialized only after the interrupt handler was
registered. This could trigger a NULL pointer dereference in
prism2_pccard_card_present() that assumed that local->hw_priv is always
set (and it should have been). Fix this by setting local->hw_priv before
registering the interrupt handler.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c
===================================================================
--- netdev-2.6.orig/drivers/net/wireless/hostap/hostap_cs.c
+++ netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c
@@ -772,6 +772,13 @@ static int prism2_config(dev_link_t *lin
 		goto failed;
 	link->priv = dev;
 
+	iface = netdev_priv(dev);
+	local = iface->local;
+	local->hw_priv = hw_priv;
+	hw_priv->link = link;
+	strcpy(hw_priv->node.dev_name, dev->name);
+	link->dev = &hw_priv->node;
+
 	/*
 	 * Allocate an interrupt line.  Note that this does not assign a
 	 * handler to the interrupt, unless the 'Handler' member of the
@@ -817,13 +824,6 @@ static int prism2_config(dev_link_t *lin
 	link->state |= DEV_CONFIG;
 	link->state &= ~DEV_CONFIG_PENDING;
 
-	iface = netdev_priv(dev);
-	local = iface->local;
-	local->hw_priv = hw_priv;
-	hw_priv->link = link;
-	strcpy(hw_priv->node.dev_name, dev->name);
-	link->dev = &hw_priv->node;
-
 	local->shutdown = 0;
 
 	sandisk_enable_wireless(dev);


-- 
Jouni Malinen                                            PGP id EFC895FA
