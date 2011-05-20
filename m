From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the tip tree (net tree
 interaction)
Date: Fri, 20 May 2011 14:14:17 +1000
Message-ID: <20110520141417.f49bf364.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jacek Luczak <difrost.kernel@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the tip tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

net/sctp/bind_addr.c: In function 'sctp_bind_addr_clean':
net/sctp/bind_addr.c:148: error: 'sctp_local_addr_free' undeclared (first use in this function)

Caused by commit 1231f0baa547 ("net,rcu: convert call_rcu
(sctp_local_addr_free) to kfree_rcu()") interacting with commit
c182f90bc1f2 ("SCTP: fix race between sctp_bind_addr_free() and
sctp_bind_addr_conflict()") from the net tree.

I applied the following patch as a merge fix:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 20 May 2011 14:11:11 +1000
Subject: [PATCH] net,rcu: convert another call to call_rcu(sctp_local_addr_free)

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/sctp/bind_addr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 6338413..83e3011 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -145,7 +145,7 @@ static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
 	/* Empty the bind address list. */
 	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
 		list_del_rcu(&addr->list);
-		call_rcu(&addr->rcu, sctp_local_addr_free);
+		kfree_rcu(addr, rcu);
 		SCTP_DBG_OBJCNT_DEC(addr);
 	}
 }
-- 
1.7.5.1


-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
