From: Brian Pomerantz <bapper@piratehaven.org>
Subject: [PATCH] [IPV4] Fix secondary IP addresses after promotion
Date: Fri, 4 Nov 2005 10:46:33 -0800
Message-ID: <20051104184633.GA16256@skull.piratehaven.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750828AbVKDSqf@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When 3 or more IP addresses in the same subnet exist on a device and the
first one is removed, only the promoted IP address can be reached.  Just
after promotion of the next IP address, this fix spins through any more
IP addresses on the interface and sends a NETDEV_UP notification for
that address.  This repopulates the FIB with the proper route
information.

Signed-off-by: Brian Pomerantz <bapper@piratehaven.org>

---

 net/ipv4/devinet.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

applies-to: 9bbb209cab841f700162a96e158dfa3ecd361f46
489d4e25469c8329451aca3e91c8e1929e6ecf63
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 4ec4b2c..72d6c93 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -235,6 +235,7 @@ static void inet_del_ifa(struct in_devic
 {
 	struct in_ifaddr *promote = NULL;
 	struct in_ifaddr *ifa1 = *ifap;
+	struct in_ifaddr *ifa;
 
 	ASSERT_RTNL();
 
@@ -243,7 +244,6 @@ static void inet_del_ifa(struct in_devic
 	 **/
 
 	if (!(ifa1->ifa_flags & IFA_F_SECONDARY)) {
-		struct in_ifaddr *ifa;
 		struct in_ifaddr **ifap1 = &ifa1->ifa_next;
 
 		while ((ifa = *ifap1) != NULL) {
@@ -294,7 +294,13 @@ static void inet_del_ifa(struct in_devic
 		/* not sure if we should send a delete notify first? */
 		promote->ifa_flags &= ~IFA_F_SECONDARY;
 		rtmsg_ifa(RTM_NEWADDR, promote);
-		notifier_call_chain(&inetaddr_chain, NETDEV_UP, promote);
+
+		/* update fib in the rest of this address list */
+		ifa = promote;
+		while (ifa != NULL) {
+			notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
+			ifa = ifa->ifa_next;
+		}
 	}
 }
 
---
0.99.9.GIT
