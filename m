From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Check num sacks in SACK fast path
Date: Wed, 31 Jan 2007 12:52:46 -0800 (PST)
Message-ID: <20070131.125246.85686582.davem@davemloft.net>
References: <20070129071339.24050.21052.sendpatchset@galon.ev-en.org>
	<20070129071349.24050.56022.sendpatchset@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030572AbXAaUwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 15:52:47 -0500
In-Reply-To: <20070129071349.24050.56022.sendpatchset@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Mon, 29 Jan 2007 09:13:49 +0200

> When we check for SACK fast path make sure that we also have the same number of
> SACK blocks in the cache and in the new SACK data. This prevents us from
> mistakenly taking the cache data if the old data in the SACK cache is the same
> as the data in the SACK block.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

We could implement this without extra state, for example by
clearing out the rest of the recv_sack_cache entries.

We should never see a SACK block from sequence zero to zero,
which would be an empty SACK block.

Something like the following?

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c26076f..84cd722 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -999,6 +1001,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 				return 0;
 		}
 	}
+	for (; i <= 4; i++) {
+		tp->recv_sack_cache[i].start_seq = 0;
+		tp->recv_sack_cache[i].end_seq = 0;
+	}
 
 	if (flag)
 		num_sacks = 1;
