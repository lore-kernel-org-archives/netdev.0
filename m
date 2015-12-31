From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] connector: bump skb->users before callback invocation
Date: Thu, 31 Dec 2015 14:26:33 +0100
Message-ID: <20151231132633.GA30790@breakpoint.cc>
References: <CACT4Y+bKYO2XfY74tgUiOC7WotQ8DRBcMT=2yy3S=Ubz8bnj_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>, zbr@ioremap.net
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60090 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751471AbbLaN0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 08:26:45 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+bKYO2XfY74tgUiOC7WotQ8DRBcMT=2yy3S=Ubz8bnj_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry reports memleak with syskaller program.
Problem is that connector bumps skb usecount but might not invoke callback.

So move skb_get to where we invoke the callback.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 I wonder wth userspace can cram skb->len < NLMSG_HDRLEN
 down the kernel, it seems to beg for trouble...

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index d7373ca..25693b0 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -179,26 +179,21 @@ static int cn_call_callback(struct sk_buff *skb)
  *
  * It checks skb, netlink header and msg sizes, and calls callback helper.
  */
-static void cn_rx_skb(struct sk_buff *__skb)
+static void cn_rx_skb(struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh;
-	struct sk_buff *skb;
 	int len, err;
 
-	skb = skb_get(__skb);
-
 	if (skb->len >= NLMSG_HDRLEN) {
 		nlh = nlmsg_hdr(skb);
 		len = nlmsg_len(nlh);
 
 		if (len < (int)sizeof(struct cn_msg) ||
 		    skb->len < nlh->nlmsg_len ||
-		    len > CONNECTOR_MAX_MSG_SIZE) {
-			kfree_skb(skb);
+		    len > CONNECTOR_MAX_MSG_SIZE)
 			return;
-		}
 
-		err = cn_call_callback(skb);
+		err = cn_call_callback(skb_get(skb));
 		if (err < 0)
 			kfree_skb(skb);
 	}
