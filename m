From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] solos-pci: Fix race condition in tasklet RX handling
Date: Fri, 06 Aug 2010 17:17:36 +0100
Message-ID: <1281111456.2715.29.camel@localhost>
References: <1274872584.20576.13579.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nathan Williams <nathan@traverse.com.au>,
	linux-atm-general@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47528 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190Ab0HFQRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 12:17:42 -0400
In-Reply-To: <1274872584.20576.13579.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were seeing faults in the solos-pci receive tasklet when packets
arrived for a VCC which was currently being closed:

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

This patch uses an RCU-inspired approach to fix it. In the RX tasklet's
find_vcc() function we first refuse to use a VCC which already has the
ATM_VF_READY bit cleared. And in the VCC close function, we synchronise
with the tasklet to ensure that it can't still be using the VCC before
we continue and allow the VCC to be destroyed.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Tested-by: Nathan Williams <nathan@traverse.com.au>
Cc: stable@kernel.org
---
Nathan, you probably still ought to work out why your customer's setup
keeps disconnecting and closing the connection -- under normal operation
on a stable DSL line, this race should almost never have been triggered.

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


