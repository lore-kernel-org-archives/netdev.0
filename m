From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 1/3] ehea: fix might sleep problem
Date: Thu, 3 Jul 2008 15:18:45 +0100
Message-ID: <200807031618.46087.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, hering2@de.ibm.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kamalesh@linux.vnet.ibm.com, linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>, Marcus Eder <meder@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

A mutex has to be replaced by spinlocks as it can be called from
a context which does not allow sleeping.
The kzalloc flag GFP_KERNEL has to be replaced by GFP_ATOMIC
for the same reason.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---

diff -Nurp -X dontdiff linux-2.6.26-rc8/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.26-rc8/drivers/net/ehea/ehea.h	2008-06-25 03:58:20.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-07-02 12:38:05.000000000 +0200
@@ -452,7 +452,7 @@ struct ehea_bcmc_reg_entry {
 struct ehea_bcmc_reg_array {
 	struct ehea_bcmc_reg_entry *arr;
 	int num_entries;
-	struct mutex lock;
+	spinlock_t lock;
 };
 
 #define EHEA_PORT_UP 1
diff -Nurp -X dontdiff linux-2.6.26-rc8/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.26-rc8/drivers/net/ehea/ehea_main.c	2008-06-25 03:58:20.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-07-02 12:38:05.000000000 +0200
@@ -241,7 +241,7 @@ static void ehea_update_bcmc_registratio
 		}
 
 	if (num_registrations) {
-		arr = kzalloc(num_registrations * sizeof(*arr), GFP_KERNEL);
+		arr = kzalloc(num_registrations * sizeof(*arr), GFP_ATOMIC);
 		if (!arr)
 			return;  /* Keep the existing array */
 	} else
@@ -301,7 +301,7 @@ static struct net_device_stats *ehea_get
 
 	memset(stats, 0, sizeof(*stats));
 
-	cb2 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb2 = kzalloc(PAGE_SIZE, GFP_ATOMIC);
 	if (!cb2) {
 		ehea_error("no mem for cb2");
 		goto out;
@@ -1763,7 +1763,7 @@ static int ehea_set_mac_addr(struct net_
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 
 	/* Deregister old MAC in pHYP */
 	if (port->state == EHEA_PORT_UP) {
@@ -1785,7 +1785,7 @@ static int ehea_set_mac_addr(struct net_
 
 out_upregs:
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1947,7 +1947,7 @@ static void ehea_set_multicast_list(stru
 	}
 	ehea_promiscuous(dev, 0);
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
@@ -1978,7 +1978,7 @@ static void ehea_set_multicast_list(stru
 	}
 out:
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2497,7 +2497,7 @@ static int ehea_up(struct net_device *de
 		}
 	}
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret) {
@@ -2520,7 +2520,7 @@ out:
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 
 	ehea_update_firmware_handles();
 	mutex_unlock(&ehea_fw_handles.lock);
@@ -2575,7 +2575,7 @@ static int ehea_down(struct net_device *
 
 	mutex_lock(&ehea_fw_handles.lock);
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
@@ -2584,7 +2584,7 @@ static int ehea_down(struct net_device *
 	port->state = EHEA_PORT_DOWN;
 
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_clean_all_portres(port);
 	if (ret)
@@ -3590,7 +3590,7 @@ int __init ehea_module_init(void)
 	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
 
 	mutex_init(&ehea_fw_handles.lock);
-	mutex_init(&ehea_bcmc_regs.lock);
+	spin_lock_init(&ehea_bcmc_regs.lock);
 
 	ret = check_module_parm();
 	if (ret)
