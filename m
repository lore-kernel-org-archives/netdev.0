From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] bridge: fix race with topology change timer
Date: Thu, 2 May 2013 17:23:28 -0700
Message-ID: <20130502172328.2ff0273f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:55276 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab3ECAXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 20:23:44 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so614222pbc.2
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 17:23:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bridge should only send topology change notice if it is not
the root bridge. It is possible for message age timer to elect itself
as a new root bridge, and still have a topology change timer running
but waiting for bridge lock on other CPU.

Solve the race by checking if we are root bridge before continuing.
This was the root cause of the cases where br_send_tcn_bpdu would OOPS.

Reported-by: JerryKang <jerry.kang@samsung.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Patch against current net (for 3.10 merge window)
Should go to stable

--- a/net/bridge/br_stp_timer.c	2013-05-02 14:30:53.442556944 -0700
+++ b/net/bridge/br_stp_timer.c	2013-05-02 14:31:54.481765082 -0700
@@ -107,7 +107,7 @@ static void br_tcn_timer_expired(unsigne
 
 	br_debug(br, "tcn timer expired\n");
 	spin_lock(&br->lock);
-	if (br->dev->flags & IFF_UP) {
+	if (!br_is_root_bridge(br) && (br->dev->flags & IFF_UP)) {
 		br_transmit_tcn(br);
 
 		mod_timer(&br->tcn_timer,jiffies + br->bridge_hello_time);
