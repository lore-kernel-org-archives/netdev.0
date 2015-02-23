From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: pktgen: disable xmit_clone on virtual devices
Date: Sun, 22 Feb 2015 17:03:41 -0800
Message-ID: <1424653421.5565.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35086 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbbBWBDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 20:03:43 -0500
Received: by iecrl12 with SMTP id rl12so19943215iec.2
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 17:03:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Trying to use burst capability (aka xmit_more) on a virtual device
like bonding is not supported.

For example, skb might be queued multiple times on a qdisc, with
various list corruptions.

Fixes: 38b2cf2982dc ("net: pktgen: packet bursting via skb->xmit_more")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/pktgen.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b4899f5b7388..508155b283dd 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1134,6 +1134,9 @@ static ssize_t pktgen_if_write(struct file *file,
 			return len;
 
 		i += len;
+		if ((value > 1) &&
+		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
+			return -ENOTSUPP;
 		pkt_dev->burst = value < 1 ? 1 : value;
 		sprintf(pg_result, "OK: burst=%d", pkt_dev->burst);
 		return count;
