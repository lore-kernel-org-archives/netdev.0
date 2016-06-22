From: Chanho Min <chanho.min@lge.com>
Subject: [PATCH RESEND] ipconfig : Fix null reference to the freed dev_addr
Date: Wed, 22 Jun 2016 19:08:13 +0900
Message-ID: <1466590093-1515-1-git-send-email-chanho.min@lge.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Gunho Lee <gunho.lee@lge.com>, <linux-kernel@vger.kernel.org>,
	Jongsung Kim <neidhard.kim@lge.com>,
	Chanho Min <chanho.min@lge.com>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from LGEAMRELO13.lge.com ([156.147.23.53]:47021 "EHLO
	lgeamrelo13.lge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbcFVKXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 06:23:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The USB to ethernet can be detached and free netdev after
rtnl mutex is released. It can cause null reference during
the dynamic IP configuration.

sequence is:

	ic_open_devs
	rtnl_lock();
	wait for a carrier
				hub_event()
				usb_disconnect()
				unregister_netdev
				rtnl_lock();
	rtnl_unlock();
				unregister_netdevice
				rtnl_unlock();
				free_netdev()
	ic_dynamic()

another sequence is:

	ip_auto_config
	ic_dynamic
				hub_event
				usb_disconnect
				free_netdev
	ic_bootp_send_if

log:
==========
Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = 80004000[  318.748428] [00000000] *pgd=00000000
Internal error: Oops: 5 [#1] PREEMPT SMP ARM
Modules linked in:[  318.760356] CPU: 1 PID: 1 Comm: swapper/0
task: b44c8000 ti: b44b2000 task.ti: b44b2000
PC is at mmiocpy+0x8c/0x330
LR is at ip_auto_config+0x70c/0x10a4
==========

To fix this, I suggested patch that checks if device is available
before the DHCP packet is sended.

Signed-off-by: Chanho Min <chanho.min@lge.com>
---
 net/ipv4/ipconfig.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 0bc7412..5b29a32 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1233,6 +1233,10 @@ static int __init ic_dynamic(void)
 	get_random_bytes(&timeout, sizeof(timeout));
 	timeout = CONF_BASE_TIMEOUT + (timeout % (unsigned int) CONF_TIMEOUT_RANDOM);
 	for (;;) {
+		if (d->dev->reg_state != NETREG_REGISTERED) {
+			pr_cont(" lost device!\n");
+			break;
+		}
 #ifdef IPCONFIG_BOOTP
 		/* Track the device we are configuring */
 		ic_dev_xid = d->xid;
-- 
1.7.9.5
