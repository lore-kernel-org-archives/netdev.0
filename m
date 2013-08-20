From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH next] netlink: prevent deadlock in ctrl_dumpfamily()
Date: Tue, 20 Aug 2013 16:50:33 +0300
Message-ID: <20130820135033.GA2315@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commmit 58ad436fcf49810aa006016107f494c9ac9013db
Author: Johannes Berg <johannes.berg at intel.com>

    genetlink: fix family dump race

added genl_lock() call to ctrl_dumpfamily(), which potentially
can deadlock. Suppose the following case:

genl_rcv_msg(): !family->parallel_ops -> genl_lock()
	genl_family_rcv_msg()
		netlink_dump_start()
			netlink_dump()
				ctrl_dumpfamily() --> genl_lock()

Take in account possibility of genl_lock() in genl_rcv_msg() and do
not acquire genl_mutex in ctrl_dumpfamily() for a family that supports
parallel_ops.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 net/netlink/genetlink.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f85f8a2..fca3659 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -791,6 +791,12 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 	int fams_to_skip = cb->args[1];
 	bool need_locking = chains_to_skip || fams_to_skip;
 
+	if (need_locking) {
+		/* genl_mutex could be already locked in genl_rcv_msg() */
+		rt = genl_family_find_byid(cb->nlh->nlmsg_type);
+		need_locking = need_locking && rt->parallel_ops;
+	}
+
 	if (need_locking)
 		genl_lock();
 
