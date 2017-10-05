From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: BUG in free_netdev() on ppp link deletion
Date: Thu, 5 Oct 2017 16:55:03 +0200
Message-ID: <20171005145503.ehv34hkzm5gtrjcp@alphalink.fr>
References: <20171003074413.GA26158@tp>
 <20171003164003.f5yay2oe6dhxnump@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
        Paul Mackerras <paulus@samba.org>,
        David Ahern <dsahern@gmail.com>,
        Gao Feng <gfree.wind@vip.163.com>
To: Beniamino Galvani <bgalvani@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:57336 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdJEOzI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 10:55:08 -0400
Content-Disposition: inline
In-Reply-To: <20171003164003.f5yay2oe6dhxnump@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 06:40:03PM +0200, Guillaume Nault wrote:
> On Tue, Oct 03, 2017 at 09:44:14AM +0200, Beniamino Galvani wrote:
> >  Call Trace:
> >   ppp_destroy_interface+0xd8/0xe0 [ppp_generic]
> >   ppp_disconnect_channel+0xda/0x110 [ppp_generic]
> >   ppp_unregister_channel+0x5e/0x110 [ppp_generic]
> >   pppox_unbind_sock+0x23/0x30 [pppox]
> >   pppoe_connect+0x130/0x440 [pppoe]
> >   SYSC_connect+0x98/0x110
> >   ? do_fcntl+0x2c0/0x5d0
> >   SyS_connect+0xe/0x10
> >   entry_SYSCALL_64_fastpath+0x1a/0xa5
> >  RIP: 0033:0x7fa71f4af840
> >  RSP: 002b:00007ffe4ea40bf8 EFLAGS: 00000246 ORIG_RAX: 000000000000002a
> >  RAX: ffffffffffffffda RBX: 0000556d37ae0538 RCX: 00007fa71f4af840
> >  RDX: 000000000000001e RSI: 00007ffe4ea40c00 RDI: 0000000000000008
> >  RBP: 0000556d37b2a1b0 R08: 0000556d396e95b0 R09: 0000000000000008
> >  R10: 00000000aaaaaaab R11: 0000000000000246 R12: 0000556d37adc008
> >  R13: 0000556d37adc004 R14: 0000556d37b2a1a4 R15: 0000000000000000
> >  Code: 04 00 00 04 e8 cb 52 e3 ff 5b 41 5c 41 5d 5d c3 41 0f b7 84 24 32 02 00 00 4c 89 e7 48 29 c7 e8 80 8b aa ff 5b 41 5c 41 5d 5d c3 <0f> 0b 0f 1f 80 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 41 57 41 
> >  RIP: free_netdev+0x107/0x110 RSP: ffffc28a40573d88
> >  ---[ end trace ed294ff0cc40eeff ]---
> > 
> > To reproduce this, establish a PPP connection through pppd, then bring
> > down and delete the ppp interface:
> > 
> >  # pppd nodetach lock user client plugin rp-pppoe.so ens11 noauth nodeflate password password &
> >  Plugin rp-pppoe.so loaded.
> >  RP-PPPoE plugin version 3.8p compiled against pppd 2.4.7
> >  PPP session is 16
> >  Connected to fe:54:00:5f:04:13 via interface ens11
> >  Using interface ppp0
> >  Connect: ppp0 <--> ens11
> >  CHAP authentication succeeded: Access granted
> >  CHAP authentication succeeded
> >  peer from calling number FE:54:00:5F:04:13 authorized
> >  local  IP address 3.1.1.10
> >  remote IP address 3.1.1.1
> > 
> >  # ip l set ppp0 down
> >  # ip l del ppp0
> > 
> > It does not happen every time but only when ppp_destroy_interface() is
> > called with dev->reg_state = UNREGISTERING, set by the concurrent
> > rtnl_delete_link().
> > 
> Indeed, we have a race here: ppp_destroy_interface() can be called before
> netdev_run_todo() completes. I'm working on it.
> 
Sorry for the delay, I've followed a few complicated dead ends before
getting to this simple and rather obvious fix.

Can you try this patch?


-------- 8< --------

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
 
