From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bridge: fix initial packet flood if !STP
Date: Fri, 15 May 2009 09:11:58 -0700
Message-ID: <20090515091158.55090cd0@nehalam>
References: <20090515091013.44b624d7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56791 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755395AbZEOQMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 12:12:08 -0400
In-Reply-To: <20090515091013.44b624d7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bridge is configured with no STP and forwarding delay of 0 (which
is typical for virtualization) then when link starts it will flood all
packets for the first 20 seconds. 

This bug was introduced by a combination of earlier changes:
  * forwarding database uses hold time of zero to indicate 
    user wants to always flood packets
  * optimzation of the case of forwarding delay of 0 avoids the initial
    timer tick

The fix is to just skip all the topology change detection code if
kernel STP is not being used.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_stp.c	2009-05-14 13:34:49.965908836 -0700
+++ b/net/bridge/br_stp.c	2009-05-14 14:15:11.370903917 -0700
@@ -297,6 +297,9 @@ void br_topology_change_detection(struct
 {
 	int isroot = br_is_root_bridge(br);
 
+	if (br->stp_enabled != BR_KERNEL_STP)
+		return;
+
 	pr_info("%s: topology change detected, %s\n", br->dev->name,
 		isroot ? "propagating" : "sending tcn bpdu");
 
