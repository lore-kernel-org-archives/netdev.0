From: Ben Greear <greearb@candelatech.com>
Subject: Re: ARP table question
Date: Wed, 12 Nov 2008 14:10:26 -0800
Message-ID: <491B5452.6020709@candelatech.com>
References: <491B1600.4080505@candelatech.com> <491B1841.9050404@candelatech.com> <491B31EB.4050304@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070103070709000309040004"
Cc: Patrick McHardy <kaber@trash.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46761 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbYKLWKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 17:10:31 -0500
In-Reply-To: <491B31EB.4050304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070103070709000309040004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Ben Greear wrote:
> I have 500 mac-vlans on a system talking to 500 other
> mac-vlans.  My problem is that the arp-table gets extremely
> huge because every time an arp-request comes in on all mac-vlans,
> a stale arp entry is added for each mac-vlan.  I have filtering
> turned on, but that doesn't help because the neigh_event_ns call
> below will cause a stale neighbor entry to be created regardless
> of whether a replay will be sent or not.
> 
> Maybe the neigh_event code should be below the checks for dont_send,
> and only create check neigh_event_ns if we are !dont_send?

The attached patch makes it work much better for me.  The patch
will cause the code to NOT create a stale neighbor entry if we
are not going to respond to the ARP request.  The old code
*would* create a stale entry even if we are not going to respond.

This is against 2.6.25.15.

Signed-off-by:  Ben Greear<greearb@candelatech.com>

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------070103070709000309040004
Content-Type: text/x-patch;
 name="patch0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch0.patch"

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 8c16b42..dd454b7 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -872,18 +872,18 @@ static int arp_process(struct sk_buff *skb)
 		addr_type = rt->rt_type;
 
 		if (addr_type == RTN_LOCAL) {
-			n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
-			if (n) {
-				int dont_send = 0;
-
-				if (!dont_send)
-					dont_send |= arp_ignore(in_dev,sip,tip);
-				if (!dont_send && IN_DEV_ARPFILTER(in_dev))
-					dont_send |= arp_filter(sip,tip,dev);
-				if (!dont_send)
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+			int dont_send = 0;
 
-				neigh_release(n);
+			if (!dont_send)
+				dont_send |= arp_ignore(in_dev,sip,tip);
+			if (!dont_send && IN_DEV_ARPFILTER(in_dev))
+				dont_send |= arp_filter(sip,tip,dev);
+			if (!dont_send) {
+				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
+				if (n) {
+					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+					neigh_release(n);
+				}
 			}
 			goto out;
 		} else if (IN_DEV_FORWARD(in_dev)) {

--------------070103070709000309040004--
