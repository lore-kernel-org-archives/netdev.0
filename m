From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6] ip_frag: Remove some atomic ops
Date: Mon, 14 Jun 2010 22:01:06 +0800
Message-ID: <4C163622.7080003@cn.fujitsu.com>
References: <1276506144.2478.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276506144.2478.40.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote, at 06/14/2010 05:02 PM:
> Instead of doing one atomic operation per frag, we can factorize them.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

IPv6 netfilter has implemented owns queue to manage/reassemble defragments.
So, you miss this one.

[PATCH 1/2] netfilter: defrag: remove one redundant atomic ops

Instead of doing one atomic operation per frag, we can factorize them.
Reported from Eric Dumazet.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6fb8901..bc5b86d 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -442,7 +442,6 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	skb_shinfo(head)->frag_list = head->next;
 	skb_reset_transport_header(head);
 	skb_push(head, head->data - skb_network_header(head));
-	atomic_sub(head->truesize, &nf_init_frags.mem);
 
 	for (fp=head->next; fp; fp = fp->next) {
 		head->data_len += fp->len;
@@ -452,8 +451,8 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		else if (head->ip_summed == CHECKSUM_COMPLETE)
 			head->csum = csum_add(head->csum, fp->csum);
 		head->truesize += fp->truesize;
-		atomic_sub(fp->truesize, &nf_init_frags.mem);
 	}
+	atomic_sub(head->truesize, &nf_init_frags.mem);
 
 	head->next = NULL;
 	head->dev = dev;
