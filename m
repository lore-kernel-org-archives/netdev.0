From: Lubomir Rintel <lkundrak@v3.sk>
Subject: [PATCH] ipv6: always add flag an address that failed DAD with DADFAILED
Date: Fri,  8 Jan 2016 13:47:23 +0100
Message-ID: <1452257243-19389-1-git-send-email-lkundrak@v3.sk>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Lubomir Rintel <lkundrak@v3.sk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The userspace needs to know why is the address being removed so that it can
perhaps obtain a new address.

Without the DADFAILED flag it's impossible to distinguish removal of a
temporary and tentative address due to DAD failure from other reasons (device
removed, manual address removal).

Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
---
 net/ipv6/addrconf.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1f21087..9342240 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1772,12 +1772,13 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 
 static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 {
+	if (dad_failed)
+		ifp->flags |= IFA_F_DADFAILED;
+
 	if (ifp->flags&IFA_F_PERMANENT) {
 		spin_lock_bh(&ifp->lock);
 		addrconf_del_dad_work(ifp);
 		ifp->flags |= IFA_F_TENTATIVE;
-		if (dad_failed)
-			ifp->flags |= IFA_F_DADFAILED;
 		spin_unlock_bh(&ifp->lock);
 		if (dad_failed)
 			ipv6_ifa_notify(0, ifp);
-- 
2.5.0
