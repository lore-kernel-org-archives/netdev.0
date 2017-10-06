From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: fix race in ppp device destruction
Date: Fri, 6 Oct 2017 17:05:49 +0200
Message-ID: <f197b94ec7e16902a9601fdf840d5a8e94c8e91a.1507302309.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Beniamino Galvani <bgalvani@redhat.com>, linux-ppp@vger.kernel.org,
        Paul Mackerras <paulus@samba.org>,
        David Ahern <dsahern@gmail.com>,
        Gao Feng <gfree.wind@vip.163.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34141 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751487AbdJFPFx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 11:05:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ppp_release() tries to ensure that netdevices are unregistered before
decrementing the unit refcount and running ppp_destroy_interface().

This is all fine as long as the the device is unregistered by
ppp_release(): the unregister_netdevice() call, followed by
rtnl_unlock(), guarantee that the unregistration process completes
before rtnl_unlock() returns.

However, the device may be unregistered by other means (like
ppp_nl_dellink()). If this happens right before ppp_release() calling
rtnl_lock(), then ppp_release() has to wait for the concurrent
unregistration code to release the lock.
But rtnl_unlock() releases the lock before completing the device
unregistration process. This allows ppp_release() to proceed and
eventually call ppp_destroy_interface() before the unregistration
process completes. Calling free_netdev() on this partially unregistered
device will BUG():

 ------------[ cut here ]------------
 kernel BUG at net/core/dev.c:8141!
 invalid opcode: 0000 [#1] SMP

 CPU: 1 PID: 1557 Comm: pppd Not tainted 4.14.0-rc2+ #4
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014

 Call Trace:
  ppp_destroy_interface+0xd8/0xe0 [ppp_generic]
  ppp_disconnect_channel+0xda/0x110 [ppp_generic]
  ppp_unregister_channel+0x5e/0x110 [ppp_generic]
  pppox_unbind_sock+0x23/0x30 [pppox]
  pppoe_connect+0x130/0x440 [pppoe]
  SYSC_connect+0x98/0x110
  ? do_fcntl+0x2c0/0x5d0
  SyS_connect+0xe/0x10
  entry_SYSCALL_64_fastpath+0x1a/0xa5

 RIP: free_netdev+0x107/0x110 RSP: ffffc28a40573d88
 ---[ end trace ed294ff0cc40eeff ]---

We could set the ->needs_free_netdev flag on PPP devices and move the
ppp_destroy_interface() logic in the ->priv_destructor() callback. But
that'd be quite intrusive as we'd first need to unlink from the other
channels and units that depend on the device (the ones that used the
PPPIOCCONNECT and PPPIOCATTACH ioctls).

Instead, we can just let the netdevice hold a reference on its
ppp_file. This reference is dropped in ->priv_destructor(), at the very
end of the unregistration process, so that neither ppp_release() nor
ppp_disconnect_channel() can call ppp_destroy_interface() in the interim.

Reported-by: Beniamino Galvani <bgalvani@redhat.com>
Fixes: 8cb775bc0a34 ("ppp: fix device unregistration upon netns deletion")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index c3f77e3b7819..e365866600ba 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1339,7 +1339,17 @@ ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
 
 static int ppp_dev_init(struct net_device *dev)
 {
+	struct ppp *ppp;
+
 	netdev_lockdep_set_classes(dev);
+
+	ppp = netdev_priv(dev);
+	/* Let the netdevice take a reference on the ppp file. This ensures
+	 * that ppp_destroy_interface() won't run before the device gets
+	 * unregistered.
+	 */
+	atomic_inc(&ppp->file.refcnt);
+
 	return 0;
 }
 
@@ -1362,6 +1372,15 @@ static void ppp_dev_uninit(struct net_device *dev)
 	wake_up_interruptible(&ppp->file.rwait);
 }
 
+static void ppp_dev_priv_destructor(struct net_device *dev)
+{
+	struct ppp *ppp;
+
+	ppp = netdev_priv(dev);
+	if (atomic_dec_and_test(&ppp->file.refcnt))
+		ppp_destroy_interface(ppp);
+}
+
 static const struct net_device_ops ppp_netdev_ops = {
 	.ndo_init	 = ppp_dev_init,
 	.ndo_uninit      = ppp_dev_uninit,
@@ -1387,6 +1406,7 @@ static void ppp_setup(struct net_device *dev)
 	dev->tx_queue_len = 3;
 	dev->type = ARPHRD_PPP;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+	dev->priv_destructor = ppp_dev_priv_destructor;
 	netif_keep_dst(dev);
 }
 
-- 
2.14.2
