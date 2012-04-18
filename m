From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix retransmit of partially acked frames
Date: Wed, 18 Apr 2012 22:14:23 +0200
Message-ID: <1334780063.2472.352.camel@edumazet-glaptop>
References: <CAA1sL1QTRKnfvCnHWjbSJ-hq6dgZK+KGDPVTrOhsfZcFTs01Mw@mail.gmail.com>
	 <1334502964.28012.1.camel@edumazet-glaptop>
	 <CAA1sL1SJyY7fYJn7OKqo5Pa=b4-r9DW90-5WVGBf==tFjVEBpg@mail.gmail.com>
	 <1334695506.2472.46.camel@edumazet-glaptop>
	 <CAA1sL1TN+acPd4NAnFC0soeHzzcJe0ja3_zS5ZkFog11HSDAyA@mail.gmail.com>
	 <1334734196.2472.91.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Marc MERLIN <marc@merlins.org>
To: Alexander Beregalov <a.beregalov@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334734196.2472.91.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Alexander Beregalov reported skb_over_panic errors and provided stack
trace.

I occurs commit a21d45726aca (tcp: avoid order-1 allocations on wifi and
tx path) added a regression, when a retransmit is done after a partial
ACK.

tcp_retransmit_skb() tries to aggregate several frames if the first one
has enough available room to hold the following ones payload. This is
controlled by /proc/sys/net/ipv4/tcp_retrans_collapse tunable (default :
enabled)

Problem is we must make sure _pskb_trim_head() doesnt fool
skb_availroom() when pulling some bytes from skb (this pull is done when
receiver ACK part of the frame).

Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
Cc: Marc MERLIN <marc@merlins.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 376b2cf..7ac6423 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1096,6 +1096,7 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
 	eat = min_t(int, len, skb_headlen(skb));
 	if (eat) {
 		__skb_pull(skb, eat);
+		skb->avail_size -= eat;
 		len -= eat;
 		if (!len)
 			return;
