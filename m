From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT] bridge: checksum not updated after pull
Date: Tue, 15 Nov 2011 10:09:14 -0800
Message-ID: <20111115100914.0c9540be@nehalam.linuxnetplumber.net>
References: <CAM1AHpSuruDx3CxzK=Med0iyxxwu7wxgRZib7yhBMiCVKXqzeA@mail.gmail.com>
 <4EC23EE7.2010606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Martin Volf <martin.volf.42@gmail.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"wcang@sfc.wide.ad.jp" <wcang@sfc.wide.ad.jp>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37368 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161Ab1KOSJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 13:09:24 -0500
In-Reply-To: <4EC23EE7.2010606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this is what is necessary, please test.

Subject: bridge: correct IPv6 checksum after pull

Bridge multicast snooping of ICMPv6 would incorrectly report a checksum problem
when used with Ethernet devices like sky2 that use CHECKSUM_COMPLETE.
When bytes are removed from skb, the computed checksum needs to be adjusted.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_multicast.c	2011-11-09 13:55:00.028012483 -0800
+++ b/net/bridge/br_multicast.c	2011-11-15 10:05:06.171314194 -0800
@@ -1501,7 +1501,9 @@ static int br_multicast_ipv6_rcv(struct
 
 	__skb_pull(skb2, offset);
 	skb_reset_transport_header(skb2);
-
+	skb_postpull_rcsum(skb2, skb_network_header(skb2),
+			   skb_network_header_len(skb2));
+
 	icmp6_type = icmp6_hdr(skb2)->icmp6_type;
 
 	switch (icmp6_type) {
