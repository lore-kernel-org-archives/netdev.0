From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 07/10] af_ieee802154: minor cleanup in
	dgram_bind
Date: Fri,  7 Aug 2009 16:58:42 +0400
Message-ID: <1249649925-11996-8-git-send-email-dbaryshkov@gmail.com>
References: <1249649925-11996-1-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-2-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-3-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-4-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-5-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-6-git-send-email-dbaryshkov@gmail.com>
	<1249649925-11996-7-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1249649925-11996-7-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

1) fix ro->bound protection by socket lock
2) make ro->bound bit instead of int

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/dgram.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index d1da6c6..25018a9 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -40,9 +40,10 @@ static DEFINE_RWLOCK(dgram_lock);
 struct dgram_sock {
 	struct sock sk;
 
-	int bound;
 	struct ieee802154_addr src_addr;
 	struct ieee802154_addr dst_addr;
+
+	unsigned bound:1;
 };
 
 static inline struct dgram_sock *dgram_sk(const struct sock *sk)
@@ -86,18 +87,18 @@ static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
 {
 	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
 	struct dgram_sock *ro = dgram_sk(sk);
-	int err = 0;
+	int err = -EINVAL;
 	struct net_device *dev;
 
+	lock_sock(sk);
+
 	ro->bound = 0;
 
 	if (len < sizeof(*addr))
-		return -EINVAL;
+		goto out;
 
 	if (addr->family != AF_IEEE802154)
-		return -EINVAL;
-
-	lock_sock(sk);
+		goto out;
 
 	dev = ieee802154_get_dev(sock_net(sk), &addr->addr);
 	if (!dev) {
@@ -113,6 +114,7 @@ static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
 	memcpy(&ro->src_addr, &addr->addr, sizeof(struct ieee802154_addr));
 
 	ro->bound = 1;
+	err = 0;
 out_put:
 	dev_put(dev);
 out:
-- 
1.6.3.3


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
