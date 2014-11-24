From: Angelo Rizzi <angelo.rizzi@3dautomazione.it>
Subject: net_tx_action race condition?
Date: Mon, 24 Nov 2014 14:29:59 +0100
Message-ID: <547332D7.7050104@3dautomazione.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000500070503040007020101"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relaygw4-5.mclink.it ([213.21.178.160]:43105 "EHLO
	relaygw4-5.mclink.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbaKXNa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 08:30:26 -0500
Received: from [195.110.128.82] (HELO smtpoutgw1.mclink.it)
  by relaygw4-5.mclink.it (CommuniGate Pro SMTP 6.0.6)
  with ESMTP id 36407582 for netdev@vger.kernel.org; Mon, 24 Nov 2014 14:30:25 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000500070503040007020101
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi Daniel,
Here attached the patch file you required.
The problem i've found is on the declaration of 'struct softnet_data 
*sd' in function 'net_tx_action'
What happens to me (i have an embedded system based on FPGA and a NIOS2 
cpu) is that, due to compiler optimization, the content of 
'sd->completion_queue' is saved in a CPU register before interrupt 
disabling (when the instruction 'if (sd->completion_queue) {' is 
executed) and then the register contents is used for interrupt-disabled 
assignment ('clist = sd->completion_queue') instead of re-read the 
variable contents.
This seems to lead to a race condition when an interrupt modifies the 
content of 'sd->completion_queue' between these two instructions.
What i have done to avoid this situation is to change the declaration of 
'struct softnet_data *sd' to 'volatile struct softnet_data *sd' and now 
everything seems to be ok.
I hope this will help.

Regards,
Angelo


--------------000500070503040007020101
Content-Type: text/plain; charset=windows-1252;
 name="net_tx_action_patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="net_tx_action_patch"

--- linux-2.6.32.64/net/core/dev.c.orig	2014-11-24 12:52:36.103335551 +0100
+++ linux-2.6.32.64/net/core/dev.c	2014-11-24 12:52:58.863949715 +0100
@@ -2069,7 +2069,7 @@ EXPORT_SYMBOL(netif_rx_ni);
 
 static void net_tx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	volatile struct softnet_data *sd = &__get_cpu_var(softnet_data);
 
 	if (sd->completion_queue) {
 		struct sk_buff *clist;

--------------000500070503040007020101--
