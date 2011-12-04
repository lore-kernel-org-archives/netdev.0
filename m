From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_sendmsg() page recycling
Date: Sun, 04 Dec 2011 18:05:17 +0100
Message-ID: <1323018317.2762.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61852 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235Ab1LDRFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 12:05:23 -0500
Received: by eeaq14 with SMTP id q14so1535634eea.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 09:05:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If our TCP_PAGE(sk) is not shared (page_count() == 1), we can set page
offset to 0.

This permits better filling of the pages on small to medium tcp writes.

"tbench 16" results on my dev server (2x4x2 machine) :

Before : 3072 MB/s
After  : 3146 MB/s  (2.4 % gain)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 45156be..a09fe25 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1009,7 +1009,12 @@ new_segment:
 				int merge = 0;
 				int i = skb_shinfo(skb)->nr_frags;
 				struct page *page = TCP_PAGE(sk);
-				int off = TCP_OFF(sk);
+				int off;
+
+				if (page && page_count(page) == 1)
+					TCP_OFF(sk) = 0;
+
+				off = TCP_OFF(sk);
 
 				if (skb_can_coalesce(skb, i, page, off) &&
 				    off != PAGE_SIZE) {
