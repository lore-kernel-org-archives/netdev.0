From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCH net] netlink: mmap: fix lookup frame position
Date: Fri, 28 Aug 2015 16:05:20 +0900
Message-ID: <20150828070520.GB32596@gmail.com>
References: <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150820055447.GA2656@gmail.com>
 <20150825.201712.2151042716686513603.davem@davemloft.net>
 <20150828070058.GA32596@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33308 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbbH1HF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 03:05:26 -0400
Received: by padfo6 with SMTP id fo6so14455237pad.0
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 00:05:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150828070058.GA32596@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__netlink_lookup_frame() was always called with the same "pos"
value in netlink_forward_ring(). It will look at the same ring entry
header over and over again, every time through this loop. Then cycle
through the whole ring, advancing ring->head, not "pos" until it
equals the "ring->head != head" loop test fails.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a774985..39fa91f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -610,11 +610,11 @@ static void netlink_increment_head(struct netlink_ring *ring)
 
 static void netlink_forward_ring(struct netlink_ring *ring)
 {
-	unsigned int head = ring->head, pos = head;
+	unsigned int head = ring->head;
 	const struct nl_mmap_hdr *hdr;
 
 	do {
-		hdr = __netlink_lookup_frame(ring, pos);
+		hdr = __netlink_lookup_frame(ring, ring->head);
 		if (hdr->nm_status == NL_MMAP_STATUS_UNUSED)
 			break;
 		if (hdr->nm_status != NL_MMAP_STATUS_SKIP)
-- 
1.7.10.4
