From: David Woodhouse <dwmw2@infradead.org>
Subject: RX/close vcc race with solos/atmtcp/usbatm/he
Date: Wed, 26 May 2010 12:16:24 +0100
Message-ID: <1274872584.20576.13579.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nathan Williams <nathan@traverse.com.au>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45064 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759179Ab0EZLQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 07:16:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've had this crash reported to me...

[18842.727906] EIP: [<e082f490>] br2684_push+0x19/0x234 [br2684] SS:ESP 0068:dfb89d14 

[18845.090712] [<c13ecff3>] ? do_page_fault+0x0/0x2e1 
[18845.120042] [<e082f490>] ? br2684_push+0x19/0x234 [br2684] 
[18845.153530] [<e084fa13>] solos_bh+0x28b/0x7c8 [solos_pci] 
[18845.186488] [<e084f711>] ? solos_irq+0x2d/0x51 [solos_pci] 
[18845.219960] [<c100387b>] ? handle_irq+0x3b/0x48 
[18845.247732] [<c10265cb>] ? irq_exit+0x34/0x57 
[18845.274437] [<c1025720>] tasklet_action+0x42/0x69 
[18845.303247] [<c102643f>] __do_softirq+0x8e/0x129 
[18845.331540] [<c10264ff>] do_softirq+0x25/0x2a 
[18845.358274] [<c102664c>] _local_bh_enable_ip+0x5e/0x6a 
[18845.389677] [<c102666d>] local_bh_enable+0xb/0xe 
[18845.417944] [<e08490a8>] ppp_unregister_channel+0x32/0xbb [ppp_generic] 
[18845.458193] [<e08731ad>] pppox_unbind_sock+0x18/0x1f [pppox] 
[18845.492712] [<e087f5f7>] pppoe_device_event+0xa7/0x159 [pppoe] 
[18845.528269] [<c13ed2ff>] notifier_call_chain+0x2b/0x4a 
[18845.559674] [<c1038a62>] raw_notifier_call_chain+0xc/0xe 
[18845.592110] [<c1300867>] dev_close+0x51/0x8b 
[18845.618266] [<c1300927>] rollback_registered_many+0x86/0x15e 
[18845.652813] [<c1300ab3>] unregister_netdevice_queue+0x67/0x91 
[18845.687849] [<c1300b79>] unregister_netdev+0x14/0x1c 
[18845.718221] [<e082f4d1>] br2684_push+0x5a/0x234 [br2684] 
[18845.750676] [<e083dc21>] vcc_release+0x64/0x100 [atm] 

The problem is that the 'find_vcc' functions in these drivers are
returning a vcc with the ATM_VF_READY bit cleared, because it's already
in the process of being destroyed. If we fix that simple oversight,
there's still a race condition because the socket can still be closed
(and completely freed, afaict) between our call to find_vcc() and our
call to vcc->push() in the RX tasklet.

Here's a patch for solos-pci which should fix it. We prevent the race by
making the dev->ops->close() function wait for the RX tasklet to
complete, so it can't still be using the vcc in question.

I think this same approach should work OK for usbatm and he. Less sure
about atmtcp -- we may need some extra locking there to protect
atmtcp_c_send(). And I'm ignoring eni_proc_read() for now.

Can anyone see a better approach -- short of rewriting the whole ATM
layer to make the locking saner?

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index c5f5186..a73f102 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -774,7 +774,8 @@ static struct atm_vcc *find_vcc(struct atm_dev *dev, short vpi, int vci)
 	sk_for_each(s, node, head) {
 		vcc = atm_sk(s);
 		if (vcc->dev == dev && vcc->vci == vci &&
-		    vcc->vpi == vpi && vcc->qos.rxtp.traffic_class != ATM_NONE)
+		    vcc->vpi == vpi && vcc->qos.rxtp.traffic_class != ATM_NONE &&
+		    test_bit(ATM_VF_READY, &vcc->flags))
 			goto out;
 	}
 	vcc = NULL;
@@ -900,6 +901,10 @@ static void pclose(struct atm_vcc *vcc)
 	clear_bit(ATM_VF_ADDR, &vcc->flags);
 	clear_bit(ATM_VF_READY, &vcc->flags);
 
+	/* Hold up vcc_destroy_socket() (our caller) until solos_bh() in the
+	   tasklet has finished processing any incoming packets (and, more to
+	   the point, using the vcc pointer). */
+	tasklet_unlock_wait(&card->tlet);
 	return;
 }
 

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

