From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/8) convert sdla to new initialization
Date: Wed, 3 Sep 2003 16:49:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903164925.5c44ce73.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, mike.mclagan@linux.org,
   Jeff Garzik
 <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Based on Al viro's NE10-sdla
	* switched sdla to dynamic allocation
	* sdla: embedded ->priv
	* sdla: fixed resource leaks on failure exits
Additionally fixes.
	* get rid of cli/sti
	* get rid of MOD/INC 

Builds and probes, but don't have the hardware.
Driver has never built on 2.6 before this.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Sep  3 15:30:12 2003
+++ b/drivers/net/Space.c	Wed Sep  3 15:30:12 2003
@@ -100,6 +100,9 @@
 extern int mac8390_probe(struct net_device *dev);
 extern int mac89x0_probe(struct net_device *dev);
 extern int mc32_probe(struct net_device *dev);
+#ifdef CONFIG_SDLA
+extern struct net_device *sdla_init(void);
+#endif
   
 /* Detachable devices ("pocket adaptors") */
 extern int de620_probe(struct net_device *);
@@ -401,19 +404,11 @@
 /*  Statically configured drivers -- order matters here. */
 void probe_old_netdevs(void)
 {
-
-}
-
 #ifdef CONFIG_SDLA
-extern int sdla_init(struct net_device *);
-static struct net_device sdla0_dev = {
-	.name		=  "sdla0",
-	.next		=  NEXT_DEV,
-	.init		=  sdla_init,
-};
-#undef NEXT_DEV
-#define NEXT_DEV	(&sdla0_dev)
+	sdla_init();
 #endif
+
+}
 
 #if defined(CONFIG_LTPC)
 extern int ltpc_probe(struct net_device *);
diff -Nru a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
--- a/drivers/net/wan/sdla.c	Wed Sep  3 15:30:12 2003
+++ b/drivers/net/wan/sdla.c	Wed Sep  3 15:30:12 2003
@@ -71,6 +71,8 @@
                                     0xD0000, 0xD2000, 0xD4000, 0xD6000, 0xD8000, 0xDA000, 0xDC000, 0xDE000,
                                     0xE0000, 0xE2000, 0xE4000, 0xE6000, 0xE8000, 0xEA000, 0xEC000, 0xEE000}; 
 
+static spinlock_t sdla_lock = SPIN_LOCK_UNLOCKED;
+
 /*********************************************************
  *
  * these are the core routines that access the card itself 
@@ -79,10 +81,10 @@
 
 #define SDLA_WINDOW(dev,addr) outb((((addr) >> 13) & 0x1F), (dev)->base_addr + SDLA_REG_Z80_WINDOW)
 
-static void sdla_read(struct net_device *dev, int addr, void *buf, short len)
+static void __sdla_read(struct net_device *dev, int addr, void *buf, short len)
 {
-	unsigned long flags;
-	char          *temp, *base;
+	char          *temp;
+	const void    *base;
 	int           offset, bytes;
 
 	temp = buf;
@@ -90,13 +92,10 @@
 	{	
 		offset = addr & SDLA_ADDR_MASK;
 		bytes = offset + len > SDLA_WINDOW_SIZE ? SDLA_WINDOW_SIZE - offset : len;
-		base = (void *) (dev->mem_start + offset);
+		base = (const void *) (dev->mem_start + offset);
 
-		save_flags(flags);
-		cli();
 		SDLA_WINDOW(dev, addr);
 		memcpy(temp, base, bytes);
-		restore_flags(flags);
 
 		addr += bytes;
 		temp += bytes;
@@ -104,10 +103,19 @@
 	}  
 }
 
-static void sdla_write(struct net_device *dev, int addr, void *buf, short len)
+static void sdla_read(struct net_device *dev, int addr, void *buf, short len)
 {
 	unsigned long flags;
-	char          *temp, *base;
+	spin_lock_irqsave(&sdla_lock, flags);
+	__sdla_read(dev, addr, buf, len);
+	spin_unlock_irqrestore(&sdla_lock, flags);
+}
+
+static void __sdla_write(struct net_device *dev, int addr, 
+			 const void *buf, short len)
+{
+	const char    *temp;
+	void 	      *base;
 	int           offset, bytes;
 
 	temp = buf;
@@ -116,17 +124,27 @@
 		offset = addr & SDLA_ADDR_MASK;
 		bytes = offset + len > SDLA_WINDOW_SIZE ? SDLA_WINDOW_SIZE - offset : len;
 		base = (void *) (dev->mem_start + offset);
-		save_flags(flags);
-		cli();
+
 		SDLA_WINDOW(dev, addr);
 		memcpy(base, temp, bytes);
-		restore_flags(flags);
+
 		addr += bytes;
 		temp += bytes;
 		len  -= bytes;
 	}
 }
 
+static void sdla_write(struct net_device *dev, int addr, 
+		       const void *buf, short len)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&sdla_lock, flags);
+	__sdla_write(dev, addr, buf, len);
+	spin_unlock_irqrestore(&sdla_lock, flags);
+}
+
+
 static void sdla_clear(struct net_device *dev)
 {
 	unsigned long flags;
@@ -138,8 +156,7 @@
 	bytes = SDLA_WINDOW_SIZE;
 	base = (void *) dev->mem_start;
 
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&sdla_lock, flags);
 	while(len)
 	{
 		SDLA_WINDOW(dev, addr);
@@ -148,7 +165,8 @@
 		addr += bytes;
 		len  -= bytes;
 	}
-	restore_flags(flags);
+	spin_unlock_irqrestore(&sdla_lock, flags);
+
 }
 
 static char sdla_byte(struct net_device *dev, int addr)
@@ -158,11 +176,10 @@
 
 	temp = (void *) (dev->mem_start + (addr & SDLA_ADDR_MASK));
 
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&sdla_lock, flags);
 	SDLA_WINDOW(dev, addr);
 	byte = *temp;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&sdla_lock, flags);
 
 	return(byte);
 }
@@ -414,7 +431,8 @@
 	struct frad_local        *flp;
 	struct sdla_cmd          *cmd_buf;
 	unsigned long            pflags;
-	int                      jiffs, ret, waiting, len;
+	unsigned long		 jiffs;
+	int                      ret, waiting, len;
 	long                     window;
 
 	flp = dev->priv;
@@ -423,8 +441,8 @@
 	ret = 0;
 	len = 0;
 	jiffs = jiffies + HZ;  /* 1 second is plenty */
-	save_flags(pflags);
-	cli();
+
+	spin_lock_irqsave(&sdla_lock, pflags);
 	SDLA_WINDOW(dev, window);
 	cmd_buf->cmd = cmd;
 	cmd_buf->dlci = dlci;
@@ -436,7 +454,7 @@
 	cmd_buf->length = inlen;
 
 	cmd_buf->opp_flag = 1;
-	restore_flags(pflags);
+	spin_unlock_irqrestore(&sdla_lock, pflags);
 
 	waiting = 1;
 	len = 0;
@@ -444,18 +462,17 @@
 	{
 		if (waiting++ % 3) 
 		{
-			save_flags(pflags);
-			cli();
+			spin_lock_irqsave(&sdla_lock, pflags);
 			SDLA_WINDOW(dev, window);
 			waiting = ((volatile int)(cmd_buf->opp_flag));
-			restore_flags(pflags);
+			spin_unlock_irqrestore(&sdla_lock, pflags);
 		}
 	}
 	
 	if (!waiting)
 	{
-		save_flags(pflags);
-		cli();
+
+		spin_lock_irqsave(&sdla_lock, pflags);
 		SDLA_WINDOW(dev, window);
 		ret = cmd_buf->retval;
 		len = cmd_buf->length;
@@ -471,7 +488,7 @@
 		if (ret)
 			memcpy(&status, cmd_buf->data, len > sizeof(status) ? sizeof(status) : len);
 
-		restore_flags(pflags);
+		spin_unlock_irqrestore(&sdla_lock, pflags);
 	}
 	else
 		ret = SDLA_RET_TIMEOUT;
@@ -555,7 +572,6 @@
 	if (i == CONFIG_DLCI_MAX)
 		return(-EMLINK);  /* #### Alan: Comments on this ?? */
 
-	MOD_INC_USE_COUNT;
 
 	flp->master[i] = master;
 	flp->dlci[i] = -*(short *)(master->dev_addr);
@@ -588,7 +604,6 @@
 	flp->master[i] = NULL;
 	flp->dlci[i] = 0;
 
-	MOD_DEC_USE_COUNT;
 
 	if (netif_running(slave)) {
 		if (flp->config.station == FRAD_STATION_CPE)
@@ -688,14 +703,14 @@
 				ret = sdla_cmd(dev, SDLA_INFORMATION_WRITE, *(short *)(skb->dev->dev_addr), 0, NULL, skb->len, &addr, &size);
 				if (ret == SDLA_RET_OK)
 				{
-					save_flags(flags); 
-					cli();
+
+					spin_lock_irqsave(&sdla_lock, flags);
 					SDLA_WINDOW(dev, addr);
 					pbuf = (void *)(((int) dev->mem_start) + (addr & SDLA_ADDR_MASK));
-						sdla_write(dev, pbuf->buf_addr, skb->data, skb->len);
-						SDLA_WINDOW(dev, addr);
+					__sdla_write(dev, pbuf->buf_addr, skb->data, skb->len);
+					SDLA_WINDOW(dev, addr);
 					pbuf->opp_flag = 1;
-					restore_flags(flags);
+					spin_unlock_irqrestore(&sdla_lock, flags);
 				}
 				break;
 		}
@@ -753,8 +768,7 @@
 	pbufi = NULL;
 	pbuf = NULL;
 
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&sdla_lock, flags);
 
 	switch (flp->type)
 	{
@@ -821,7 +835,7 @@
 		case SDLA_S502A:
 		case SDLA_S502E:
 			if (success)
-				sdla_read(dev, SDLA_502_RCV_BUF + SDLA_502_DATA_OFS, skb_put(skb,len), len);
+				__sdla_read(dev, SDLA_502_RCV_BUF + SDLA_502_DATA_OFS, skb_put(skb,len), len);
 
 			SDLA_WINDOW(dev, SDLA_502_RCV_BUF);
 			cmd->opp_flag = 0;
@@ -834,9 +848,9 @@
 				split = addr + len > buf_top + 1 ? len - (buf_top - addr + 1) : 0;
 				len2 = len - split;
 
-				sdla_read(dev, addr, skb_put(skb, len2), len2);
+				__sdla_read(dev, addr, skb_put(skb, len2), len2);
 				if (split)
-					sdla_read(dev, buf_base, skb_put(skb, split), split);
+					__sdla_read(dev, buf_base, skb_put(skb, split), split);
 			}
 
 			/* increment the buffer we're looking at */
@@ -853,7 +867,7 @@
 		(*dlp->receive)(skb, master);
 	}
 
-	restore_flags(flags);
+	spin_unlock_irqrestore(&sdla_lock, flags);
 }
 
 static irqreturn_t sdla_isr(int irq, void *dev_id, struct pt_regs * regs)
@@ -979,8 +993,6 @@
 
 	netif_stop_queue(dev);
 	
-	MOD_DEC_USE_COUNT;
-
 	return(0);
 }
 
@@ -1082,8 +1094,6 @@
 
 	netif_start_queue(dev);
 	
-	MOD_INC_USE_COUNT;
-
 	return(0);
 }
 
@@ -1614,19 +1624,30 @@
 	return(&flp->stats);
 }
 
-int __init sdla_init(struct net_device *dev)
+static void setup_sdla(struct net_device *dev)
 {
+	dev->flags		= 0;
+	dev->type		= 0xFFFF;
+	dev->hard_header_len	= 0;
+	dev->addr_len		= 0;
+	dev->mtu		= SDLA_MAX_MTU;
+}
+
+struct net_device * __init sdla_init(void)
+{
+	struct net_device *dev;
 	struct frad_local *flp;
+	int err = -ENOMEM;
 
-	/* allocate the private data structure */
-	flp = kmalloc(sizeof(struct frad_local), GFP_KERNEL);
-	if (!flp)
-		return(-ENOMEM);
+	dev = alloc_netdev(sizeof(struct frad_local), "sdla0", setup_sdla);
+	if (!dev)
+		goto out;
 
-	memset(flp, 0, sizeof(struct frad_local));
-	dev->priv = flp;
+	SET_MODULE_OWNER(dev);
+	netdev_boot_setup_check(dev);
+
+	flp = dev->priv;
 
-	dev->flags		= 0;
 	dev->open		= sdla_open;
 	dev->stop		= sdla_close;
 	dev->do_ioctl		= sdla_ioctl;
@@ -1635,12 +1656,6 @@
 	dev->hard_start_xmit	= sdla_transmit;
 	dev->change_mtu		= sdla_change_mtu;
 
-	dev->type		= 0xFFFF;
-	dev->hard_header_len	= 0;
-	dev->addr_len		= 0;
-	dev->mtu		= SDLA_MAX_MTU;
-	SET_MODULE_OWNER(dev);
-
 	flp->activate		= sdla_activate;
 	flp->deactivate		= sdla_deactivate;
 	flp->assoc		= sdla_assoc;
@@ -1652,7 +1667,14 @@
 	flp->timer.data		= (unsigned long) dev;
 	flp->timer.function	= sdla_poll;
 
-	return(0);
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	kfree(dev);
+out:
+	return ERR_PTR(err);
 }
 
 int __init sdla_c_setup(void)
@@ -1663,10 +1685,7 @@
 }
 
 #ifdef MODULE
-static struct net_device sdla0 = {
-	.name = "sdla0",
-	.init = sdla_init
-};
+static struct net_device *sdla0;
 #endif /* MODULE */
 
 static int __init init_sdla(void)
@@ -1675,7 +1694,9 @@
 
 	sdla_c_setup();
 #ifdef MODULE
-	result = register_netdev(&sdla0);
+	sdla0 = sdla_init();
+	if (IS_ERR(sdla0))
+		result = PTR_ERR(sdla0);
 #endif
 	return result;
 }
@@ -1683,11 +1704,10 @@
 static void __exit exit_sdla(void)
 {
 #ifdef MODULE
-	unregister_netdev(&sdla0);
-	if (sdla0.priv)
-		kfree(sdla0.priv);
-	if (sdla0.irq)
-		free_irq(sdla0.irq, &sdla0);
+	unregister_netdev(sdla0);
+	if (sdla0->irq)
+		free_irq(sdla0->irq, sdla0);
+	free_netdev(sdla0);
 #endif
 }
 
