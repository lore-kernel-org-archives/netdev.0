From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net] netconsole: Check for carrier before calling netpoll_send_udp()
Date: Tue, 11 Aug 2015 11:32:26 +1000
Message-ID: <1439256746-7953-1-git-send-email-jmaxwell37@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	jmaxwell@redhat.com, Jon Maxwell <jmaxwell37@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have seen a few crashes recently where a NIC is getting
reset for some reason and then the driver or another module calls
printk() which invokes netconsole. Netconsole then calls the
adapter specific poll routine via netpoll which crashes because 
the adapter is resetting and its structures are being reinitialized.

So far we have seen this happen with ixgbe and vmxnet3 drivers.
The back trace from the ixgbe crash example looks like this:

#8 [] page_fault at
#9 [] ixgbe_clean_rx_irq at  [ixgbe] <--- crash here
#10 [] ixgbe_poll at  [ixgbe]
#11 [] netpoll_poll_dev at 
#12 [] netpoll_send_skb_on_dev at 
#13 [] netpoll_send_udp at 
#14 [] write_msg at  [netconsole]
#15 [] __call_console_drivers at 
#16 [] _call_console_drivers at 
#17 [] release_console_sem at 
#18 [] vprintk at 
#19 [] printk at 
#20 [] __dev_printk at 
#21 [] _dev_info at 
#22 [] ixgbe_init_interrupt_scheme at  [ixgbe]
#23 [] ixgbe_dcbnl_devreset at  [ixgbe]
#24 [] ixgbe_dcbnl_set_all at  [ixgbe]
#25 [] ixgbe_dcbnl_setdcbx at  [ixgbe]
#26 [] dcb_doit at 
#27 [] rtnetlink_rcv_msg at 
#28 [] netlink_rcv_skb at 
#29 [] rtnetlink_rcv at 
#30 [] netlink_unicast at 
#31 [] netlink_sendmsg at 
#32 [] sock_sendmsg at 
#33 [] sys_sendto at 
#34 [] system_call_fastpath at 

I could reproduce this using an ixgbe NIC. 

I verified that the proposed fix works. It checks that carrier is 
asserted before calling netpoll_send_udp(). Therefore if the adapter
is resetting netconsole does not call the netpoll routines and the 
crash is avoided. When the adapter is back online and carrier is 
reasserted netconsole will succeed again.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 drivers/net/netconsole.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ba2f5e7..f760463 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -744,7 +744,8 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
 		netconsole_target_get(nt);
-		if (nt->enabled && netif_running(nt->np.dev)) {
+		if (nt->enabled && netif_running(nt->np.dev) &&
+		    netif_carrier_ok(nt->np.dev)) {
 			/*
 			 * We nest this inside the for-each-target loop above
 			 * so that we're able to get as much logging out to
-- 
1.8.3.1
