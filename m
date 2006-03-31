From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 20/33] pcmcia: remove export of pcmcia_release_configuration
Date: Fri, 31 Mar 2006 22:20:27 +0200
Message-ID: <20060331202027.GI28037@dominikbrodowski.de>
References: <20060331195852.GB27888@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mtd@lists.infradead.org
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
To: linux-pcmcia@lists.infradead.org
Content-Disposition: inline
In-Reply-To: <20060331195852.GB27888@dominikbrodowski.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
	<mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
	<mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: linux-mtd-bounces@lists.infradead.org
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Handle the _modifying_ operation sm91c92_cs requires in
pcmcia_modify_configuration, so that the only remaining users
of pcmcia_release_configuration() are within the pcmcia core
module.

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

---

 drivers/mtd/maps/pcmciamtd.c     |    3 +--
 drivers/net/pcmcia/smc91c92_cs.c |   29 +++++++++++------------------
 drivers/pcmcia/ds_internal.h     |    2 ++
 drivers/pcmcia/pcmcia_resource.c |   23 ++++++++++++++++++++++-
 include/pcmcia/cs.h              |   10 +++++-----
 5 files changed, 41 insertions(+), 26 deletions(-)

4bbed5231468014b500b048d7370a1c6c349231a
diff --git a/drivers/mtd/maps/pcmciamtd.c b/drivers/mtd/maps/pcmciamtd.c
index f988c81..f45ff25 100644
--- a/drivers/mtd/maps/pcmciamtd.c
+++ b/drivers/mtd/maps/pcmciamtd.c
@@ -353,8 +353,7 @@ static void pcmciamtd_release(dev_link_t
 		}
 		pcmcia_release_window(link->win);
 	}
-	pcmcia_release_configuration(link->handle);
-	link->state &= ~DEV_CONFIG;
+	pcmcia_disable_device(link->handle);
 }
 
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 84e18bb..86942c0 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -874,11 +874,8 @@ static int smc91c92_suspend(struct pcmci
 	dev_link_t *link = dev_to_instance(p_dev);
 	struct net_device *dev = link->priv;
 
-	if (link->state & DEV_CONFIG) {
-		if (link->open)
-			netif_device_detach(dev);
-		pcmcia_release_configuration(link->handle);
-	}
+	if ((link->state & DEV_CONFIG) && (link->open))
+		netif_device_detach(dev);
 
 	return 0;
 }
@@ -894,7 +891,6 @@ static int smc91c92_resume(struct pcmcia
 		if ((smc->manfid == MANFID_MEGAHERTZ) &&
 		    (smc->cardid == PRODID_MEGAHERTZ_EM3288))
 			mhz_3288_power(link);
-		pcmcia_request_configuration(link->handle, &link->conf);
 		if (smc->manfid == MANFID_MOTOROLA)
 			mot_config(link);
 		if ((smc->manfid == MANFID_OSITECH) &&
@@ -963,18 +959,15 @@ static int check_sig(dev_link_t *link)
     }
 
     if (width) {
-	printk(KERN_INFO "smc91c92_cs: using 8-bit IO window.\n");
-	/* call pcmcia_release_configuration() in _suspend */
-	smc91c92_suspend(link->handle);
-
-	link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
-	link->handle->socket->io[0].res->flags &= ~IO_DATA_PATH_WIDTH;
-	link->handle->socket->io[0].res->flags |= IO_DATA_PATH_WIDTH_8;
-
-	/* call pcmcia_request_configuration() in _resume, it handles the
-	 * flag update */
-	smc91c92_resume(link->handle);
-	return check_sig(link);
+	    modconf_t mod = {
+		    .Attributes = CONF_IO_CHANGE_WIDTH,
+	    };
+	    printk(KERN_INFO "smc91c92_cs: using 8-bit IO window.\n");
+
+	    smc91c92_suspend(link->handle);
+	    pcmcia_modify_configuration(link->handle, &mod);
+	    smc91c92_resume(link->handle);
+	    return check_sig(link);
     }
     return -ENODEV;
 }
diff --git a/drivers/pcmcia/ds_internal.h b/drivers/pcmcia/ds_internal.h
index 783d861..3a2b25e 100644
--- a/drivers/pcmcia/ds_internal.h
+++ b/drivers/pcmcia/ds_internal.h
@@ -8,6 +8,8 @@ extern void pcmcia_put_dev(struct pcmcia
 
 struct pcmcia_device * pcmcia_device_add(struct pcmcia_socket *s, unsigned int function);
 
+extern int pcmcia_release_configuration(struct pcmcia_device *p_dev);
+
 #ifdef CONFIG_PCMCIA_IOCTL
 extern void __init pcmcia_setup_ioctl(void);
 extern void __exit pcmcia_cleanup_ioctl(void);
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index f4dcea6..16504f8 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -442,6 +442,28 @@ int pcmcia_modify_configuration(struct p
 		   (mod->Attributes & CONF_VPP2_CHANGE_VALID))
 		return CS_BAD_VPP;
 
+	if (mod->Attributes & CONF_IO_CHANGE_WIDTH) {
+		pccard_io_map io_off = { 0, 0, 0, 0, 1 };
+		pccard_io_map io_on;
+		int i;
+
+		io_on.speed = io_speed;
+		for (i = 0; i < MAX_IO_WIN; i++) {
+			if (!s->io[i].res)
+				continue;
+			io_off.map = i;
+			io_on.map = i;
+
+			io_on.flags = MAP_ACTIVE | IO_DATA_PATH_WIDTH_8;
+			io_on.start = s->io[i].res->start;
+			io_on.stop = s->io[i].res->end;
+
+			s->ops->set_io_map(s, &io_off);
+			mdelay(40);
+			s->ops->set_io_map(s, &io_on);
+		}
+	}
+
 	return CS_SUCCESS;
 } /* modify_configuration */
 EXPORT_SYMBOL(pcmcia_modify_configuration);
@@ -479,7 +501,6 @@ int pcmcia_release_configuration(struct 
 
 	return CS_SUCCESS;
 } /* pcmcia_release_configuration */
-EXPORT_SYMBOL(pcmcia_release_configuration);
 
 
 /** pcmcia_release_io
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index 7b91520..087b3bc 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -116,10 +116,11 @@ typedef struct modconf_t {
 } modconf_t;
 
 /* Attributes for ModifyConfiguration */
-#define CONF_IRQ_CHANGE_VALID	0x100
-#define CONF_VCC_CHANGE_VALID	0x200
-#define CONF_VPP1_CHANGE_VALID	0x400
-#define CONF_VPP2_CHANGE_VALID	0x800
+#define CONF_IRQ_CHANGE_VALID	0x0100
+#define CONF_VCC_CHANGE_VALID	0x0200
+#define CONF_VPP1_CHANGE_VALID	0x0400
+#define CONF_VPP2_CHANGE_VALID	0x0800
+#define CONF_IO_CHANGE_WIDTH	0x1000
 
 /* For RequestConfiguration */
 typedef struct config_req_t {
@@ -378,7 +379,6 @@ int pcmcia_get_status(struct pcmcia_devi
 int pcmcia_get_mem_page(window_handle_t win, memreq_t *req);
 int pcmcia_map_mem_page(window_handle_t win, memreq_t *req);
 int pcmcia_modify_configuration(struct pcmcia_device *p_dev, modconf_t *mod);
-int pcmcia_release_configuration(struct pcmcia_device *p_dev);
 int pcmcia_release_window(window_handle_t win);
 int pcmcia_request_configuration(struct pcmcia_device *p_dev, config_req_t *req);
 int pcmcia_request_io(struct pcmcia_device *p_dev, io_req_t *req);
-- 
1.2.4


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
