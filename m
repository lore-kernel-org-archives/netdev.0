From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 net-next] ip neigh: allow flush FAILED neighbour entry
Date: Fri, 16 Jun 2017 11:31:52 +0800
Message-ID: <1497583912-27981-1-git-send-email-liuhangbin@gmail.com>
References: <1496651489-28110-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33478 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdFPDcJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 23:32:09 -0400
Received: by mail-pf0-f193.google.com with SMTP id w12so3763183pfk.0
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 20:32:08 -0700 (PDT)
In-Reply-To: <1496651489-28110-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After upstream commit 5071034e4af7 ('neigh: Really delete an arp/neigh entry
on "ip neigh delete" or "arp -d"'), we could delete a single FAILED neighbour
entry now. But `ip neigh flush` still skip the FAILED entry.

Move the filter after first round flush so we can flush FAILED entry on fixed
kernel and also do not keep retrying on old kernel.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/ipneigh.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 4d8fc85..9c38a60 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -445,7 +445,6 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 		filter.flushb = flushb;
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
-		filter.state &= ~NUD_FAILED;
 
 		while (round < MAX_ROUNDS) {
 			if (rtnl_dump_request_n(&rth, &req.n) < 0) {
@@ -474,6 +473,7 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 				printf("\n*** Round %d, deleting %d entries ***\n", round, filter.flushed);
 				fflush(stdout);
 			}
+			filter.state &= ~NUD_FAILED;
 		}
 		printf("*** Flush not complete bailing out after %d rounds\n",
 			MAX_ROUNDS);
-- 
2.5.5
