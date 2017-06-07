From: Mateusz Jurczyk <mjurczyk@google.com>
Subject: [PATCH] decnet: dn_rtmsg: Improve input length sanitization in dnrmg_receive_user_skb
Date: Wed,  7 Jun 2017 15:14:29 +0200
Message-ID: <20170607131429.30441-1-mjurczyk@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Verify that the length of the socket buffer is sufficient to cover the
entire nlh->nlmsg_len field before accessing that field for further
input sanitization. If the client only supplies 1-3 bytes of data in
sk_buff, then nlh->nlmsg_len remains partially uninitialized and
contains leftover memory from the corresponding kernel allocation.
Operating on such data may result in indeterminate evaluation of the
nlmsg_len < sizeof(*nlh) expression.

The bug was discovered by a runtime instrumentation designed to detect
use of uninitialized memory in the kernel. The patch prevents this and
other similar tools (e.g. KMSAN) from flagging this behavior in the future.

Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
---
 net/decnet/netfilter/dn_rtmsg.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 1ed81ac6dd1a..26e020e9d415 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -102,7 +102,9 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
 
-	if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
+	if (skb->len < sizeof(nlh->nlmsg_len) ||
+	    nlh->nlmsg_len < sizeof(*nlh) ||
+	    skb->len < nlh->nlmsg_len)
 		return;
 
 	if (!netlink_capable(skb, CAP_NET_ADMIN))
-- 
2.13.1.508.gb3defc5cc-goog
