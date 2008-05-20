From: Toyo Abe <tabe@miraclelinux.com>
Subject: [IPV6] ADDRCONF: Defer dad for global address until dad for linklocal
 is completed.
Date: Tue, 20 May 2008 12:37:54 +0900
Message-ID: <48324792.5070309@miraclelinux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070301070403070304040708"
Cc: netdev@vger.kernel.org, Toyo Abe <tabe@miraclelinux.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:51782 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbYETEEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 00:04:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070301070403070304040708
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

When RA packet with prefix option is received during processing DAD for linklocal
address, Linux initiates DAD for global address derived from the received prefix.
It can be succeeded even if a duplicated linklocal address is detected.

RFC4862 5.4.5, which describes the behaviour on DAD failure, says;

   If the address is a link-local address formed from an interface
   identifier based on the hardware address, which is supposed to be
   uniquely assigned (e.g., EUI-64 for an Ethernet interface), IP
   operation on the interface SHOULD be disabled.  By disabling IP
   operation, the node will then:

   -  not send any IP packets from the interface,

   -  silently drop any IP packets received on the interface, and

   -  not forward any IP packets to the interface (when acting as a
      router or processing a packet with a Routing header).

This problem was observed by testing with beta version of TAHI test suite (v4.0.0b2)
- Stateless Address Autoconfiguration test #3, #5, #14, and #15 force dad for linklocal
to be failed and send RA to the host, then check if the host doesn't respond to
DAD NS with respect to its global address. However, 2.6.26-rc2 send DAD NA in response
to the DAD NS so the test scenarios were failed.

This patch fixes the problem by deferring DAD initiation for global address until
DAD for linklocal address is completed. Now the failed test scenarios noted above
are all passed.

Thank you,
-toyo

--------------070301070403070304040708
Content-Type: text/x-patch;
 name="IPV6-ADDRCONF-Defer-dad-for-global-address-until-dad-for-linklocal-is-completed.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="IPV6-ADDRCONF-Defer-dad-for-global-address-until-dad-for-lin";
 filename*1="klocal-is-completed.patch"

[IPV6] ADDRCONF: Defer dad for global address until dad for linklocal is completed.

When RA packet with prefix option is received during processing DAD for linklocal
address, Linux initiates DAD for global address derived from the received prefix.
It can be succeeded even if a duplicated linklocal address is detected.

RFC4862 5.4.5, which describes the behaviour on DAD failure, says;

   If the address is a link-local address formed from an interface
   identifier based on the hardware address, which is supposed to be
   uniquely assigned (e.g., EUI-64 for an Ethernet interface), IP
   operation on the interface SHOULD be disabled.  By disabling IP
   operation, the node will then:

   -  not send any IP packets from the interface,

   -  silently drop any IP packets received on the interface, and

   -  not forward any IP packets to the interface (when acting as a
      router or processing a packet with a Routing header).

This problem was observed by testing with beta version of TAHI test suite (v4.0.0b2)
- Stateless Address Autoconfiguration test #3, #5, #14, and #15 force dad for linklocal
to be failed and send RA to the host, then check if the host doesn't respond to
DAD NS with respect to its global address. However, 2.6.26-rc2 send DAD NA in response
to the DAD NS so the test scenarios were failed.

This patch fixes the problem by deferring DAD initiation for global address until
DAD for linklocal address is completed. Now the failed test scenarios noted above
are all passed.

Signed-off-by: Toyo Abe <tabe@miraclelinux.com>

---
 include/linux/if_addr.h |    1 +
 net/ipv6/addrconf.c     |   62 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 54 insertions(+), 9 deletions(-)

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index 43f3bed..75ff0b8 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -40,6 +40,7 @@ enum
 
 #define	IFA_F_NODAD		0x02
 #define IFA_F_OPTIMISTIC	0x04
+#define IFA_F_PENDDAD		0x08
 #define	IFA_F_HOMEADDRESS	0x10
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e591e09..3080ded 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1532,21 +1532,20 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	return -1;
 }
 
-static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
+static struct inet6_ifaddr *ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
 {
-	int err = -1;
 	struct inet6_ifaddr *ifp;
 
 	read_lock_bh(&idev->lock);
 	for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
-		if (ifp->scope == IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
+		if (ifp->scope == IFA_LINK) {
+			in6_ifa_hold(ifp);
 			memcpy(eui, ifp->addr.s6_addr+8, 8);
-			err = 0;
 			break;
 		}
 	}
 	read_unlock_bh(&idev->lock);
-	return err;
+	return ifp;
 }
 
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1808,13 +1807,13 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 
 	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
 		struct inet6_ifaddr * ifp;
+		struct inet6_ifaddr * ifl;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
-			if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
-			    ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
+			if ((ifl = ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) == NULL) {
 				in6_dev_put(in6_dev);
 				return;
 			}
@@ -1832,7 +1831,9 @@ ok:
 
 		if (ifp == NULL && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
-			u32 addr_flags = 0;
+			u32 addr_flags = IFA_F_PENDDAD;
+			struct inet6_dev *idev;
+			int dad_now = 0;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 			if (in6_dev->cnf.optimistic_dad &&
@@ -1856,7 +1857,28 @@ ok:
 
 			update_lft = create = 1;
 			ifp->cstamp = jiffies;
-			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
+
+			/*
+			 * Defer dad for global address on the idev until
+			 * dad for linklocal is completed.
+			 */
+			idev = ifp->idev;
+			read_lock_bh(&idev->lock);
+			if (!(ifl->flags & IFA_F_TENTATIVE)) {
+				spin_lock(&ifp->lock);
+			    	if (ifp->flags & IFA_F_PENDDAD) {
+					ifp->flags &= ~IFA_F_PENDDAD;
+					dad_now = 1;
+				}
+				spin_unlock(&ifp->lock);
+			}
+			read_unlock_bh(&idev->lock);
+			/* Since we got a ifl->refcnt in ipv6_inherit_eui64(), release it. */
+			in6_ifa_put(ifl);
+
+			/* If dad for linklocal is already completed, start dad right away. */
+			if (dad_now)
+				addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}
 
 		if (ifp) {
@@ -2780,6 +2802,23 @@ out:
 	in6_ifa_put(ifp);
 }
 
+static void addrconf_dad_kick_pending(struct inet6_dev *idev) {
+	struct inet6_ifaddr *ifp;
+
+	read_lock_bh(&idev->lock);
+	for (ifp = idev->addr_list; ifp; ifp = ifp->if_next) {
+		spin_lock_bh(&ifp->lock);
+		if (!(ifp->flags & (IFA_F_TENTATIVE|IFA_F_PENDDAD))) {
+			spin_unlock_bh(&ifp->lock);
+			continue;
+		}
+		ifp->flags &= ~IFA_F_PENDDAD;
+		spin_unlock_bh(&ifp->lock);
+		addrconf_dad_kick(ifp);
+	}
+	read_unlock_bh(&idev->lock);
+}
+
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
 	struct net_device *	dev = ifp->idev->dev;
@@ -2790,6 +2829,11 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 
 	ipv6_ifa_notify(RTM_NEWADDR, ifp);
 
+	if ((dev->flags&IFF_LOOPBACK) == 0 &&
+	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
+		addrconf_dad_kick_pending(ifp->idev);
+	}
+
 	/* If added prefix is link local and forwarding is off,
 	   start sending router solicitations.
 	 */

--------------070301070403070304040708--
