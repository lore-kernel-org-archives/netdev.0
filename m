From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [BUG] problem with BPF in PF_PACKET sockets, introduced in linux-2.6.19
Date: Thu, 25 Jan 2007 16:22:20 +0300
Message-ID: <20070125132220.GA15410@ms2.inr.ac.ru>
References: <200701041747.46358.raivis@mt.lv> <20070124.152133.61337361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raivis@mt.lv, netdev@vger.kernel.org, waltje@uWalt.NL.Mugnet.ORG,
	gw4pts@gw4pts.ampr.org, dim@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:47290 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S965280AbXAYOOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 09:14:03 -0500
Content-Disposition: inline
In-Reply-To: <20070124.152133.61337361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> So this whole idea to make run_filter() return signed integers
> and fail on negative is entirely flawed, it simply cannot work
> and retain the expected semantics which have been there forever.

Actually, it can. Return value was used only as sign of error,
so that the mistake was to return original unsigned result casted to int.

Alternative fix is enclosed. To be honest, it is not better than
yours: duplication of couple lines of code against passing return
value by pointer.

Alexey


diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index da73e8a..51e5537 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -437,11 +437,13 @@ static inline int run_filter(struct sk_b
 	rcu_read_lock_bh();
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter != NULL) {
-		err = sk_run_filter(skb, filter->insns, filter->len);
-		if (!err)
+		unsigned int res;
+
+		res = sk_run_filter(skb, filter->insns, filter->len);
+		if (!res)
 			err = -EPERM;
-		else if (*snaplen > err)
-			*snaplen = err;
+		else if (*snaplen > res)
+			*snaplen = res;
 	}
 	rcu_read_unlock_bh();
 
