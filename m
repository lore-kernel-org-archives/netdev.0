From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] ieee802154: verify packet size before
	trying to allocate it
Date: Wed,  6 Jun 2012 23:32:02 +0200
Message-ID: <1339018322-19360-1-git-send-email-levinsasha928@gmail.com>
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

We should make sure that this size is checked and limited. The maximum size
of an IP packet seemed like the safest limit here.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/dgram.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 6fbb2ad..cf5070b 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -232,6 +232,10 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
+	if (hlen + tlen + size > USHRT_MAX) {
+		err = -EMSGSIZE;
+		goto out;
+	}
 	skb = sock_alloc_send_skb(sk, hlen + tlen + size,
 			msg->msg_flags & MSG_DONTWAIT,
 			&err);
-- 
1.7.8.6


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
