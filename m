From: Glenn Wurster <gwurster@scs.carleton.ca>
Subject: [PATCH 2.6.36-rc3 1/1] IPv6 BUG: Temp addresses are immediately
	deleted after being created.
Date: Wed, 22 Sep 2010 12:04:27 -0400
Message-ID: <20100922160427.GB11185__5729.53253654322$1285174298$gmane$org@external.electric.ath.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <netdev-owner@vger.kernel.org>
Received: from 69-55-236-88.in-addr.arpa.johncompanies.com ([69.55.236.88]:47151
	"EHLO external.dropship.ath.cx" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751749Ab0IVQu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 12:50:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a bug in the interaction between ipv6_create_tempaddr and 
addrconf_verify.  Because ipv6_create_tempaddr uses the cstamp and tstamp 
from the public address in creating a private address, if we have not 
received a router advertisement in a while, tstamp + temp_valid_lft might be 
< now.  If this happens, the new address is created inside 
ipv6_create_tempaddr, then the loop within addrconf_verify starts again and 
the address is immediately deleted.  We are left with no temporary addresses 
on the interface, and no more will be created until the public IP address is 
updated.  To avoid this, set the expiry time to be the minimum of the time 
left on the public address or the config option PLUS the current age of the 
public interface.

Sending again because of a previous e-mail header issue.

Signed-off-by: Glenn Wurster <gwurster@scs.carleton.ca>
---
 net/ipv6/addrconf.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cfee6ae..9c74454 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -836,7 +836,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, 
struct inet6_ifaddr *i
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
-	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
+	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp, age;
 	unsigned long regen_advance;
 	int tmp_plen;
 	int ret = 0;
@@ -886,12 +886,13 @@ retry:
 		goto out;
 	}
 	memcpy(&addr.s6_addr[8], idev->rndid, 8);
+	age = (jiffies - ifp->tstamp) / HZ;
 	tmp_valid_lft = min_t(__u32,
 			      ifp->valid_lft,
-			      idev->cnf.temp_valid_lft);
+			      idev->cnf.temp_valid_lft + age);
 	tmp_prefered_lft = min_t(__u32,
 				 ifp->prefered_lft,
-				 idev->cnf.temp_prefered_lft -
+				 idev->cnf.temp_prefered_lft + age -
 				 idev->cnf.max_desync_factor);
 	tmp_plen = ifp->prefix_len;
 	max_addresses = idev->cnf.max_addresses;

