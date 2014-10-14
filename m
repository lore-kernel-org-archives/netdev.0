From: Houcheng Lin <houcheng@gmail.com>
Subject: [PATCH v2] netfilter: release skbuf when nlmsg put fail
Date: Tue, 14 Oct 2014 17:42:18 +0800
Message-ID: <CAL8JtxD=Vopo7fvKEnfKgOa3T=WyVH=mb_YqX9mES+n-6dJbrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: pablo@netfilter.org, Patrick McHardy <kaber@trash.net>,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When system is under heavy loading, the __nfulnl_send() may may failed
to put nlmsg into skbuf of nfulnl_instance. If not clear the skbuff on failed,
the __nfulnl_send() will still try to put next nlmsg onto this half-full skbuf
and cause the user program can never receive packet.

This patch fix this issue by releasing skbuf immediately after nlmst put
failed.

Signed-off-by: Houcheng Lin <houcheng@gmail.com>
---
 net/netfilter/nfnetlink_log.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index a11c5ff..0ad5d32 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -353,15 +353,17 @@ __nfulnl_send(struct nfulnl_instance *inst)
  NLMSG_DONE,
  sizeof(struct nfgenmsg),
  0);
- if (!nlh)
+ if (!nlh) {
+ WARN_ON(1);
+ kfree_skb(inst->skb);
  goto out;
+ }
  }
  status = nfnetlink_unicast(inst->skb, inst->net, inst->peer_portid,
    MSG_DONTWAIT);
-
+out:
  inst->qlen = 0;
  inst->skb = NULL;
-out:
  return status;
 }

-- 
1.7.9.5
