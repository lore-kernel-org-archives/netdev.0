From: Sudeep Holla <sudeep.holla@arm.com>
Subject: Unhandled fault during system suspend in sky2_shutdown
Date: Mon, 11 Apr 2016 17:24:37 +0100
Message-ID: <570BCFC5.4070208@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sudeep Holla <sudeep.holla@arm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Mirko Lindner <mlindner@marvell.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am seeing unhandled fault during system suspend in sky2_shutdown.
I am not sure if it's something missing in the firmware, but just wanted
to check. I see that networkmanager is invoking calling to 
netlink_sendmsg which calls sky2_get_stats after the device is shutdown.

Unhandled fault: synchronous external abort (0x96000210) at 
0xffff0000091c2918
Internal error: : 96000210 [#1] PREEMPT SMP
Modules linked in:
CPU: 3 PID: 2029 Comm: NetworkManager Not tainted 4.6.0-rc3 #126
Hardware name: ARM Juno development board (r2) (DT)
task: ffff80007a673000 ti: ffff800940b5c000 task.ti: ffff800940b5c000
PC is at sky2_get_stats+0x44/0x3b8
LR is at dev_get_stats+0x58/0xc8
  sky2_get_stats+0x44/0x3b8
  rtnl_fill_stats+0x20/0x138
  rtnl_fill_ifinfo+0x440/0xb38
  rtnl_getlink+0xe8/0x198
  rtnetlink_rcv_msg+0xe4/0x220
  netlink_rcv_skb+0xc4/0xf8
  rtnetlink_rcv+0x2c/0x40
  netlink_unicast+0x160/0x238
  netlink_sendmsg+0x2f0/0x358
  sock_sendmsg+0x18/0x30
  ___sys_sendmsg+0x204/0x218
  __sys_sendmsg+0x44/0x88
  SyS_sendmsg+0xc/0x18
  el0_svc_naked+0x24/0x28

The below patch is the hack I came up to check if the netdev is detached 
and unregistered, I no longer see the issue.

Regards,
Sudeep

-->8

diff --git i/drivers/net/ethernet/marvell/sky2.c 
w/drivers/net/ethernet/marvell/sky2.c
index ec0a22119e09..0ff0434e32fc 100644
--- i/drivers/net/ethernet/marvell/sky2.c
+++ w/drivers/net/ethernet/marvell/sky2.c
@@ -5220,6 +5220,13 @@ static SIMPLE_DEV_PM_OPS(sky2_pm_ops, 
sky2_suspend, sky2_resume);

  static void sky2_shutdown(struct pci_dev *pdev)
  {
+       struct sky2_hw *hw = pci_get_drvdata(pdev);
+       int i;
+
+       for (i = hw->ports - 1; i >= 0; --i) {
+               sky2_detach(hw->dev[i]);
+               unregister_netdev(hw->dev[i]);
+       }
         sky2_suspend(&pdev->dev);
         pci_wake_from_d3(pdev, device_may_wakeup(&pdev->dev));
         pci_set_power_state(pdev, PCI_D3hot);
