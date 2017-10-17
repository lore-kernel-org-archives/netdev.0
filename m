From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tun: relax check on eth_get_headlen() return value
Date: Tue, 17 Oct 2017 10:07:44 -0700
Message-ID: <1508260064.31614.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Petar Penkov <peterpenkov96@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:54635 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754567AbdJQRHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:07:49 -0400
Received: by mail-pf0-f194.google.com with SMTP id n89so1786679pfk.11
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 10:07:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller hit the WARN() in tun_get_user(), providing skb
with payload in fragments only, and nothing in skb->head

GRO layer is fine with this, so relax the check.

Fixes: 90e33d459407 ("tun: enable napi_gro_frags() for TUN/TAP driver")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 57e4c31fa84adc4d9af6ab69a87feac23a8b034e..c64ec19af9b73744270f5cdb922d0f0c1c8f4443 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1737,7 +1737,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		/* Exercise flow dissector code path. */
 		u32 headlen = eth_get_headlen(skb->data, skb_headlen(skb));
 
-		if (headlen > skb_headlen(skb) || headlen < ETH_HLEN) {
+		if (unlikely(headlen > skb_headlen(skb))) {
 			this_cpu_inc(tun->pcpu_stats->rx_dropped);
 			napi_free_frags(&tfile->napi);
 			mutex_unlock(&tfile->napi_mutex);
