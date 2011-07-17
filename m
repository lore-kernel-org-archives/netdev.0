From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH][RFC] netfilter: Fix small leak in
 ipq_build_packet_message()
Date: Sun, 17 Jul 2011 19:46:16 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1107171942400.32359@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, coreteam@netfilter.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipq_build_packet_message() in net/ipv4/netfilter/ip_queue.c and
net/ipv6/netfilter/ip6_queue.c contain a small potential mem leak as
far as I can tell.

We allocate memory for 'skb' with alloc_skb() annd then call
 nlh = NLMSG_PUT(skb, 0, 0, IPQM_PACKET, size - sizeof(*nlh));

NLMSG_PUT is a macro
 NLMSG_PUT(skb, pid, seq, type, len) \
  		NLMSG_NEW(skb, pid, seq, type, len, 0)

that expands to NLMSG_NEW, which is also a macro which expands to:
 NLMSG_NEW(skb, pid, seq, type, len, flags) \
  	({	if (unlikely(skb_tailroom(skb) < (int)NLMSG_SPACE(len))) \
  			goto nlmsg_failure; \
  		__nlmsg_put(skb, pid, seq, type, len, flags); })

If we take the true branch of the 'if' statement and 'goto
nlmsg_failure', then we'll, at that point, return from
ipq_build_packet_message() without having assigned 'skb' to anything
and we'll leak the memory we allocated for it when it goes out of
scope.

Fix this by placing a 'kfree(skb)' at 'nlmsg_failure'.

I admit that I do not know how likely this to actually happen or even
if there's something that guarantees that it will never happen - I'm
not that familiar with this code, but if that is so, I've not been
able to spot it.

Please review and commit if you believe this is correct. Thanks.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/ipv4/netfilter/ip_queue.c  |    1 +
 net/ipv6/netfilter/ip6_queue.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

  Disclaimer: Patch is compile tested only.

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 5c9b9d9..48f7d5b 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -218,6 +218,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 	return skb;
 
 nlmsg_failure:
+	kfree_skb(skb);
 	*errp = -EINVAL;
 	printk(KERN_ERR "ip_queue: error creating packet message\n");
 	return NULL;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 2493948..87b243a 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -218,6 +218,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 	return skb;
 
 nlmsg_failure:
+	kfree_skb(skb);
 	*errp = -EINVAL;
 	printk(KERN_ERR "ip6_queue: error creating packet message\n");
 	return NULL;
-- 
1.7.6


PS. Please CC me on replies since I'm not subscribed to all the lists 
copied on this mail.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

