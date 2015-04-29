From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp_westwood: fix tcp_westwood_info()
Date: Wed, 29 Apr 2015 16:20:58 -0700
Message-ID: <1430349658.3711.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	 <1430263429-4069-2-git-send-email-edumazet@google.com>
	 <20150429.181252.2106091176943411796.davem@davemloft.net>
	 <1430347239.3711.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ycheng@google.com,
	ncardwell@google.com, kbuild test robot <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:35192 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbbD2XVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:21:00 -0400
Received: by iejt8 with SMTP id t8so54970186iej.2
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 16:20:59 -0700 (PDT)
In-Reply-To: <1430347239.3711.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I forgot to update tcp_westwood when changing get_info() behavior,
this patch should fix this.

Fixes: 64f40ff5bbdb ("tcp: prepare CC get_info() access from getsockopt()")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_westwood.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index b3c57cceb9907fe9d79f33f33369a96b647b5f26..c10732e39837872c724b801700f627a7fb1c9390 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -256,18 +256,19 @@ static void tcp_westwood_event(struct sock *sk, enum tcp_ca_event event)
 }
 
 /* Extract info for Tcp socket info provided via netlink. */
-static int tcp_westwood_info(struct sock *sk, u32 ext, struct sk_buff *skb)
+static size_t tcp_westwood_info(struct sock *sk, u32 ext, int *attr,
+				union tcp_cc_info *info)
 {
 	const struct westwood *ca = inet_csk_ca(sk);
 
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
-		struct tcpvegas_info info = {
-			.tcpv_enabled = 1,
-			.tcpv_rtt = jiffies_to_usecs(ca->rtt),
-			.tcpv_minrtt = jiffies_to_usecs(ca->rtt_min),
-		};
+		info->vegas.tcpv_enabled = 1;
+		info->vegas.tcpv_rttcnt	= 0;
+		info->vegas.tcpv_rtt	= jiffies_to_usecs(ca->rtt),
+		info->vegas.tcpv_minrtt	= jiffies_to_usecs(ca->rtt_min),
 
-		return nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
+		*attr = INET_DIAG_VEGASINFO;
+		return sizeof(struct tcpvegas_info);
 	}
 	return 0;
 }
