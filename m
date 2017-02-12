From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/21] netfilter: nf_ct_sip: Use mod_timer_pending()
Date: Sun, 12 Feb 2017 20:42:45 +0100
Message-ID: <1486928573-24773-14-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

timer_del() followed by timer_add() can be replaced by
mod_timer_pending().

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_sip.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index c3fc14e021ec..24174c520239 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -809,13 +809,11 @@ static int refresh_signalling_expectation(struct nf_conn *ct,
 		    exp->tuple.dst.protonum != proto ||
 		    exp->tuple.dst.u.udp.port != port)
 			continue;
-		if (!del_timer(&exp->timeout))
-			continue;
-		exp->flags &= ~NF_CT_EXPECT_INACTIVE;
-		exp->timeout.expires = jiffies + expires * HZ;
-		add_timer(&exp->timeout);
-		found = 1;
-		break;
+		if (mod_timer_pending(&exp->timeout, jiffies + expires * HZ)) {
+			exp->flags &= ~NF_CT_EXPECT_INACTIVE;
+			found = 1;
+			break;
+		}
 	}
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 	return found;
-- 
2.1.4

