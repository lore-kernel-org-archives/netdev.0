From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 1/6] skbuff: Do not allow skb recycling with disabled IRQs
Date: Wed, 11 Nov 2009 03:11:01 +0300
Message-ID: <20091111001101.GA8817@oksana.dev.rtsoft.ru>
References: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>, Jon Loeliger <jdl@jdl.com>,
	Kumar Gopalpet-B05799 <B05799@freescale.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:1554 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751775AbZKKAK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 19:10:56 -0500
Content-Disposition: inline
In-Reply-To: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAPI drivers try to recycle SKBs in their polling routine, but we
generally don't know the context in which the polling will be called,
and the skb recycling itself may require IRQs to be enabled.

This patch adds irqs_disabled() test to the skb_recycle_check()
routine, so that we'll not let the drivers hit the skb recycling
path with IRQs disabled.

As a side effect, this patch actually disables skb recycling for some
[broken] drivers. E.g. gianfar driver grabs an irqsave spinlock during
TX ring processing, and then tries to recycle an skb, and that caused
the following badness:

nf_conntrack version 0.5.0 (1008 buckets, 4032 max)
------------[ cut here ]------------
Badness at kernel/softirq.c:143
NIP: c003e3c4 LR: c423a528 CTR: c003e344
...
NIP [c003e3c4] local_bh_enable+0x80/0xc4
LR [c423a528] destroy_conntrack+0xd4/0x13c [nf_conntrack]
Call Trace:
[c15d1b60] [c003e32c] local_bh_disable+0x1c/0x34 (unreliable)
[c15d1b70] [c423a528] destroy_conntrack+0xd4/0x13c [nf_conntrack]
[c15d1b80] [c02c6370] nf_conntrack_destroy+0x3c/0x70
--- Exception: c428168c at 0xc15d1c50
LR = 0xc15d1c40
[c15d1ba0] [c0286f3c] skb_release_head_state+0x100/0x104 (unreliable)
[c15d1bb0] [c0288340] skb_recycle_check+0x8c/0x10c
[c15d1bc0] [c01e1688] gfar_poll+0x190/0x384
[c15d1c10] [c02935ac] net_rx_action+0xec/0x22c
[c15d1c50] [c003dd8c] __do_softirq+0xe8/0x224
...

Reported-by: Jon Loeliger <jdl@jdl.com>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 net/core/skbuff.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 80a9616..941bac9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -493,6 +493,9 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 {
 	struct skb_shared_info *shinfo;
 
+	if (irqs_disabled())
+		return 0;
+
 	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
 		return 0;
 
-- 
1.6.3.3

