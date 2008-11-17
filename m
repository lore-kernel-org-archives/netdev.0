From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] isdn: remove extra byteswap in
 isdn_net_ciscohdlck_slarp_send_reply
Date: Sun, 16 Nov 2008 20:18:36 -0800
Message-ID: <1226895516.6150.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>, Karsten Keil <kkeil@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:61519 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755724AbYKQESk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 23:18:40 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2429688wfd.4
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2008 20:18:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a144ea4b7a13087081ab5402fa9ad0bcfd249e67 [IPV4]: annotate struct in_ifaddr

Missed this extra byteswap as the isdn inlines hide the htonl inside put_u32
which causes an extra byteswap on little-endian arches.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, this is the minimal patch suitable to fix mainline without any net-next
material mixed in.  I'd suggest sending this one to Linus and then applying
my previous patch to net-next (if you need a resend, just ask)

Then whenever you do your net-next merge with Linus, the resolution should be trivial.

Harvey

 drivers/isdn/i4l/isdn_net.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index bb904a0..1bfc55d 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1641,8 +1641,10 @@ isdn_net_ciscohdlck_slarp_send_reply(isdn_net_local *lp)
 	/* slarp reply, send own ip/netmask; if values are nonsense remote
 	 * should think we are unable to provide it with an address via SLARP */
 	p += put_u32(p, CISCO_SLARP_REPLY);
-	p += put_u32(p, addr);	// address
-	p += put_u32(p, mask);	// netmask
+	*(__be32 *)p = addr;	// address
+	p += 4;
+	*(__be32 *)p = mask;	// netmask
+	p += 4;
 	p += put_u16(p, 0);	// unused
 
 	isdn_net_write_super(lp, skb);
-- 
1.6.0.4.994.g16bd3e



