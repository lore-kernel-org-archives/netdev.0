From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: atl2: don't mess up irq on suspend/resume (probably msi only)
Date: Wed, 19 Nov 2008 18:34:43 -0600
Message-ID: <20081119183443.7ca1cf23@osprey.hogchain.net>
References: <49201401.1060600@tuffmail.co.uk>
	<4921E574.3090602@tuffmail.co.uk>
	<20081117181336.1a270561@osprey.hogchain.net>
	<4922D195.9010505@tuffmail.co.uk>
	<4922FD09.2070007@tuffmail.co.uk>
	<49231CCB.8010900@tuffmail.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: atl1-devel@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Chris Snook <csnook@redhat.com>
To: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:54234 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbYKTAet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 19:34:49 -0500
Received: by rv-out-0506.google.com with SMTP id k40so196394rvb.1
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 16:34:48 -0800 (PST)
In-Reply-To: <49231CCB.8010900@tuffmail.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can someone tell before I submit this patch if the description is sane?

atl2: don't request irq on resume if netif running

If the device is suspended with the cable disconnected, then
resumed with the cable connected, dev->open is called before
resume. During resume, we request an IRQ, but the IRQ was
already assigned during dev->open, resulting in the warning
shown below.

Don't request an IRQ if the device is running.

Call Trace:
 [<c011b89a>] warn_on_slowpath+0x40/0x59
 [<c023df15>] raw_pci_read+0x4d/0x55
 [<c023dff3>] pci_read+0x1c/0x21
 [<c01bcd81>] __pci_find_next_cap_ttl+0x44/0x70
 [<c01bce86>] __pci_find_next_cap+0x1a/0x1f
 [<c01bcef9>] pci_find_capability+0x28/0x2c
 [<c01c4144>] pci_msi_check_device+0x53/0x62
 [<c01c49c2>] pci_enable_msi+0x3a/0x1cd
 [<e019f17b>] atl2_write_phy_reg+0x40/0x5f [atl2]
 [<c01061b1>] dma_generic_alloc_coherent+0x0/0xd7
 [<e019f107>] atl2_request_irq+0x15/0x49 [atl2]
 [<e01a1481>] atl2_open+0x20b/0x297 [atl2]
 [<c024a35c>] dev_open+0x62/0x91
 [<c0248b9a>] dev_change_flags+0x93/0x141
 [<c024f308>] do_setlink+0x238/0x2d5
 [<c02501b2>] rtnl_setlink+0xa9/0xbf
 [<c0297f0c>] mutex_lock+0xb/0x19
 [<c024ffa7>] rtnl_dump_ifinfo+0x0/0x69
 [<c0250109>] rtnl_setlink+0x0/0xbf
 [<c024fe42>] rtnetlink_rcv_msg+0x185/0x19f
 [<c0240fd1>] sock_rmalloc+0x23/0x57
 [<c024fcbd>] rtnetlink_rcv_msg+0x0/0x19f
 [<c0259457>] netlink_rcv_skb+0x2d/0x71
 [<c024fcb7>] rtnetlink_rcv+0x14/0x1a
 [<c025929e>] netlink_unicast+0x184/0x1e4
 [<c025992a>] netlink_sendmsg+0x233/0x240
 [<c023f405>] sock_sendmsg+0xb7/0xd0
 [<c0129131>] autoremove_wake_function+0x0/0x2b
 [<c0129131>] autoremove_wake_function+0x0/0x2b
 [<c0147796>] mempool_alloc+0x2d/0x9e
 [<c020c923>] scsi_pool_alloc_command+0x35/0x4f
 [<c0297f0c>] mutex_lock+0xb/0x19
 [<c028e867>] unix_stream_recvmsg+0x357/0x3e2
 [<c01b81c9>] copy_from_user+0x23/0x4f
 [<c02452ea>] verify_iovec+0x3e/0x6c
 [<c023f5ab>] sys_sendmsg+0x18d/0x1f0
 [<c023ffa8>] sys_recvmsg+0x146/0x1c8
 [<c0240016>] sys_recvmsg+0x1b4/0x1c8
 [<c0118f48>] __wake_up+0xf/0x15
 [<c02586cd>] netlink_table_ungrab+0x17/0x19
 [<c01b83ba>] copy_to_user+0x25/0x3b
 [<c023fe4a>] move_addr_to_user+0x50/0x68
 [<c0240266>] sys_getsockname+0x6f/0x9a
 [<c0240280>] sys_getsockname+0x89/0x9a
 [<c015046a>] do_wp_page+0x3ae/0x41a
 [<c0151525>] handle_mm_fault+0x4c5/0x540
 [<c02405d0>] sys_socketcall+0x176/0x1b0
 [<c010376d>] sysenter_do_call+0x12/0x21

Signed-off-by: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Signed-off-by: Jay Cliburn <jcliburn@gmail.com>
---
 drivers/net/atlx/atl2.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index f5bdc92..8571e8c 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1690,9 +1690,11 @@ static int atl2_resume(struct pci_dev *pdev)
 
 	ATL2_WRITE_REG(&adapter->hw, REG_WOL_CTRL, 0);
 
-	err = atl2_request_irq(adapter);
-	if (netif_running(netdev) && err)
-		return err;
+	if (netif_running(netdev)) {
+		err = atl2_request_irq(adapter);
+		if (err)
+			return err;
+	}
 
 	atl2_reset_hw(&adapter->hw);
 
-- 
1.5.6.5
