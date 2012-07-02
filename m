From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3] ieee802154: verify packet size
	before trying to allocate it
Date: Mon,  2 Jul 2012 13:29:55 +0200
Message-ID: <1341228595-9883-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently when sending data over datagram, the send function will attempt to
allocate any size passed on from the userspace.

We should make sure that this size is checked and limited. We'll limit it
to the MTU of the device, which is checked later anyway.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/dgram.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 6fbb2ad..1670561 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -230,6 +230,12 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	mtu = dev->mtu;
 	pr_debug("name = %s, mtu = %u\n", dev->name, mtu);
 
+	if (size > mtu) {
+		pr_debug("size = %Zu, mtu = %u\n", size, mtu);
+		err = -EINVAL;
+		goto out_dev;
+	}
+
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
 	skb = sock_alloc_send_skb(sk, hlen + tlen + size,
@@ -258,12 +264,6 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (err < 0)
 		goto out_skb;
 
-	if (size > mtu) {
-		pr_debug("size = %Zu, mtu = %u\n", size, mtu);
-		err = -EINVAL;
-		goto out_skb;
-	}
-
 	skb->dev = dev;
 	skb->sk  = sk;
 	skb->protocol = htons(ETH_P_IEEE802154);
-- 
1.7.8.6


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
