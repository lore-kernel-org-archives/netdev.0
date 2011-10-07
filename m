From: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Subject: [RFC PATCH net 1/2] [BUGFIX] bonding: use local function pointer of
 bond->recv_probe in bond_handle_frame
Date: Fri, 07 Oct 2011 21:49:54 +0900
Message-ID: <20111007124954.7089.9776.stgit@ltc219.sdl.hitachi.co.jp>
References: <20111007124925.7089.27260.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yrl.pp-manager.tt@hitachi.com,
	Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111007124925.7089.27260.stgit@ltc219.sdl.hitachi.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bond->recv_probe is called in bond_handle_frame() when
a packet is received, but bond_close() sets it to NULL. So,
a panic occurs when both functions work in parallel.

Why this happen:
After null pointer check of bond->recv_probe, an sk_buff is
duplicated and bond->recv_probe is called in bond_handle_frame.
So, a panic occurs when bond_close() is called between the
check and call of bond->recv_probe.

Patch:
This patch uses a local function pointer of bond->recv_probe
in bond_handle_frame(). So, it can avoid the null pointer
dereference.


Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---

 drivers/net/bonding/bond_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6d79b78..f1baec5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1435,6 +1435,8 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 	struct sk_buff *skb = *pskb;
 	struct slave *slave;
 	struct bonding *bond;
+	void (*recv_probe)(struct sk_buff *, struct bonding *,
+				struct slave *);
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
@@ -1448,11 +1450,12 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 	if (bond->params.arp_interval)
 		slave->dev->last_rx = jiffies;
 
-	if (bond->recv_probe) {
+	recv_probe = bond->recv_probe;
+	if (recv_probe) {
 		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
 
 		if (likely(nskb)) {
-			bond->recv_probe(nskb, bond, slave);
+			recv_probe(nskb, bond, slave);
 			dev_kfree_skb(nskb);
 		}
 	}
