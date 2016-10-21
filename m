From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] ipv6: do not increment mac header when it's unset
Date: Fri, 21 Oct 2016 18:28:25 +0900
Message-ID: <20161021092825.28085-1-Jason@zx2c4.com>
References: <CAHmME9q5yDae6qXecKK-Cdw-91geRnvzYocg=ypFucH+9LVt_g@mail.gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Pipacs <pageexec@gmail.com>,
        Emese Revfy <re.emese@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9q5yDae6qXecKK-Cdw-91geRnvzYocg=ypFucH+9LVt_g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Otherwise we'll overflow the integer. This occurs when layer 3 tunneled
packets are handed off to the IPv6 layer.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/ipv6/reassembly.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e2ea311..a943203 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -456,7 +456,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	skb_network_header(head)[nhoff] = skb_transport_header(head)[0];
 	memmove(head->head + sizeof(struct frag_hdr), head->head,
 		(head->data - head->head) - sizeof(struct frag_hdr));
-	head->mac_header += sizeof(struct frag_hdr);
+	if (skb_mac_header_was_set(head))
+		head->mac_header += sizeof(struct frag_hdr);
 	head->network_header += sizeof(struct frag_hdr);
 
 	skb_reset_transport_header(head);
-- 
2.10.1
