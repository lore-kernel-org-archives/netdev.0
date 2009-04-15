From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] packet: avoid warnings when high-order page allocation fails
Date: Wed, 15 Apr 2009 12:35:16 +0200
Message-ID: <49E5B864.203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48935 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbZDOKfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:35:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Latest tcpdump/libpcap triggers annoying messages because of high order page
allocation failures (when lowmem exhausted or fragmented)

These allocation errors are correctly handled so could be silent.

[22660.208901] tcpdump: page allocation failure. order:5, mode:0xc0d0
[22660.208921] Pid: 13866, comm: tcpdump Not tainted 2.6.30-rc2 #170
[22660.208936] Call Trace:
[22660.208950]  [<c04e2b46>] ? printk+0x18/0x1a
[22660.208965]  [<c02760f7>] __alloc_pages_internal+0x357/0x460
[22660.208980]  [<c0276251>] __get_free_pages+0x21/0x40
[22660.208995]  [<c04cc835>] packet_set_ring+0x105/0x3d0
[22660.209009]  [<c04ccd1d>] packet_setsockopt+0x21d/0x4d0
[22660.209025]  [<c0270400>] ? filemap_fault+0x0/0x450
[22660.209040]  [<c0449e34>] sys_setsockopt+0x54/0xa0
[22660.209053]  [<c044b97f>] sys_socketcall+0xef/0x270
[22660.209067]  [<c0202e34>] sysenter_do_call+0x12/0x26

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 74776de..13c3ef0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1758,8 +1758,9 @@ static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
 
 static inline char *alloc_one_pg_vec_page(unsigned long order)
 {
-	return (char *) __get_free_pages(GFP_KERNEL | __GFP_COMP | __GFP_ZERO,
-					 order);
+	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP | __GFP_ZERO | __GFP_NOWARN;
+
+	return (char *) __get_free_pages(gfp_flags, order);
 }
 
 static char **alloc_pg_vec(struct tpacket_req *req, int order)
