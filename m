From: Mateusz Jurczyk <mjurczyk@google.com>
Subject: [PATCH v2] netfilter: nfnetlink: Improve input length sanitization in nfnetlink_rcv
Date: Wed,  7 Jun 2017 15:50:38 +0200
Message-ID: <20170607135038.1592-1-mjurczyk@google.com>
References: <1496841821.736.35.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496841821.736.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Verify that the length of the socket buffer is sufficient to cover the
nlmsghdr structure before accessing the nlh->nlmsg_len field for further
input sanitization. If the client only supplies 1-3 bytes of data in
sk_buff, then nlh->nlmsg_len remains partially uninitialized and
contains leftover memory from the corresponding kernel allocation.
Operating on such data may result in indeterminate evaluation of the
nlmsg_len < NLMSG_HDRLEN expression.

The bug was discovered by a runtime instrumentation designed to detect
use of uninitialized memory in the kernel. The patch prevents this and
other similar tools (e.g. KMSAN) from flagging this behavior in the future.

Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
---
Changes in v2:
  - Compare skb->len against NLMSG_HDRLEN to avoid assuming the layout of
    the nlmsghdr structure.

 net/netfilter/nfnetlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 80f5ecf2c3d7..1f9667f52be5 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -491,7 +491,8 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
 
-	if (nlh->nlmsg_len < NLMSG_HDRLEN ||
+	if (skb->len < NLMSG_HDRLEN ||
+	    nlh->nlmsg_len < NLMSG_HDRLEN ||
 	    skb->len < nlh->nlmsg_len)
 		return;
 
-- 
2.13.1.508.gb3defc5cc-goog
