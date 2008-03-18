From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] [IPV6]: Fix refcounting for anycast dst entries.
Date: Tue, 18 Mar 2008 17:35:25 +0300
Message-ID: <1205850925-11736-3-git-send-email-den@openvz.org>
References: <1205850761.9163.21.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
        "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1205850761.9163.21.camel-aPCOdVxUTlgvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Anycast DST entries allocated inside ipv6_dev_ac_inc are leaked when
network device is stopped without removing IPv6 addresses from it. The
bug has been observed in the reality on 2.6.18-rhel5 kernel.

In the above case addrconf_ifdown marks all entries as obsolete and
ip6_del_rt called from __ipv6_dev_ac_dec returns ENOENT. The referrence is
not dropped.

The fix is simple. DST entry should not keep referrence when stored in the
FIB6 tree.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv6/anycast.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 96868b9..7bc0469 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -334,9 +334,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, struct in6_addr *addr)
 	idev->ac_list = aca;
 	write_unlock_bh(&idev->lock);
 
-	dst_hold(&rt->u.dst);
-	if (ip6_ins_rt(rt))
-		dst_release(&rt->u.dst);
+	ip6_ins_rt(rt);
 
 	addrconf_join_solict(dev, &aca->aca_addr);
 
@@ -378,10 +376,7 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr)
 	addrconf_leave_solict(idev, &aca->aca_addr);
 
 	dst_hold(&aca->aca_rt->u.dst);
-	if (ip6_del_rt(aca->aca_rt))
-		dst_free(&aca->aca_rt->u.dst);
-	else
-		dst_release(&aca->aca_rt->u.dst);
+	ip6_del_rt(aca->aca_rt);
 
 	aca_put(aca);
 	return 0;
-- 
1.5.3.rc5
