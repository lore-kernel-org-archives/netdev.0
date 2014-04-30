From: Liu Yu <allanliuyu@gmail.com>
Subject: [PATCH]  tcp_cubic: fix the range of delayed_ack
Date: Wed, 30 Apr 2014 17:34:09 +0800
Message-ID: <5360C391.2040202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com, ncardwell@google.com,
	shemminger@vyatta.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33857 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932922AbaD3JcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 05:32:25 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so1626857igq.4
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 02:32:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Liu Yu <allanyuliu@tencent.com>

commit b9f47a3aaeab (tcp_cubic: limit delayed_ack ratio to prevent
divide error) try to prevent divide error, but there is still a little
chance that delayed_ack can reach zero. In case the param cnt get
negative value, then ratio+cnt would overflow and may happen to be zero.
As a result, min(ratio, ACK_RATIO_LIMIT) will calculate to be zero.

In some old kernels, such as 2.6.32, there is a bug that would
pass negative param, which then ultimately leads to this divide error.

commit 5b35e1e6e9c (tcp: fix tcp_trim_head() to adjust segment count
with skb MSS) fixed the negative param issue. However, 
it's safe that we fix the range of delayed_ack as well,
to make sure we do not hit a divide by zero.

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Liu Yu <allanyuliu@tencent.com>
---
 net/ipv4/tcp_cubic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 8bf2245..b4f1b29 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -409,7 +409,7 @@ static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 		ratio -= ca->delayed_ack >> ACK_RATIO_SHIFT;
 		ratio += cnt;
 
-		ca->delayed_ack = min(ratio, ACK_RATIO_LIMIT);
+		ca->delayed_ack = clamp(ratio, 1U, ACK_RATIO_LIMIT);
 	}
 
 	/* Some calls are for duplicates without timetamps */
-- 
1.7.1
