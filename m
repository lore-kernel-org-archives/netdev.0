From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: [PATCH] bridge: orphan frags on local receive
Date: Mon, 24 Feb 2014 21:12:20 +0800
Message-ID: <530B4534.3000106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

with vhost tx zero_copy, guest nic might get hang when host reserving
skb in socket queue delivered by guest, the case has been solved in
tun, it also been needed by bridge. This could easily happened when a
LAST_ACK state tcp occuring between guest and host.

Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
---
  net/bridge/br_input.c |    3 +++
  1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 28d5446..744e27a 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -117,6 +117,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
  		br->dev->stats.multicast++;
  	} else if ((dst = __br_fdb_get(br, dest, vid)) &&
  			dst->is_local) {
+		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+			goto drop;
  		skb2 = skb;
  		/* Do not forward the packet since it's local. */
  		skb = NULL;
@@ -136,6 +138,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
  out:
  	return 0;
  drop:
+	skb_tx_error(skb);
  	kfree_skb(skb);
  	goto out;
  }
-- 
1.7.3.1.msysgit.0

