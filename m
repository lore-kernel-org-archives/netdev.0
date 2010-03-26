From: David Miller <davem@davemloft.net>
Subject: Re: mmotm 2010-03-23 - IPv6 warnings...
Date: Thu, 25 Mar 2010 21:40:50 -0700 (PDT)
Message-ID: <20100325.214050.101816448.davem@davemloft.net>
References: <12096.1269481001@localhost>
	<20100324184226.3bf42d8f.akpm@linux-foundation.org>
	<4788.1269535530@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4788.1269535530@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis.Kletnieks@vt.edu
Date: Thu, 25 Mar 2010 12:45:30 -0400

> On Wed, 24 Mar 2010 18:42:26 EDT, Andrew Morton said:
>> On Wed, 24 Mar 2010 21:36:41 -0400 Valdis.Kletnieks@vt.edu wrote:
>> 
>> > On Tue, 23 Mar 2010 15:34:59 PDT, akpm@linux-foundation.org said:
>> > > The mm-of-the-moment snapshot 2010-03-23-15-34 has been uploaded to
>> > > 
>> > >    http://userweb.kernel.org/~akpm/mmotm/
>> > 
>> > Seen in my dmesg.  It may be relevant that I'm at home, and my IPv6
>> > prefix arrives via a PPP VPN connection. This happened about 20-25 seconds
>> > after I launched pppd.
>> 
>> Yes, thanks, I get the same - it doesn't seem to break anything.  It
>> also happens some time after boot has completed.
> 
> Just doing an 'ifup eth0' on a network with IPv6 on it is sufficient.

I just checked the following into net-next-2.6 which should at least
kill that dmesg log.

If you still are missing your ipv6 addresses, let me know how
they normally get added, maybe that's enough to let me figure
it out.

Thanks.

ipv6: Fix result generation in ipv6_get_ifaddr().

Finishing naturally from hlist_for_each_entry(x, ...) does not result
in 'x' being NULL.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/addrconf.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9995683..21b4c9e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1341,9 +1341,9 @@ EXPORT_SYMBOL(ipv6_chk_prefix);
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *addr,
 				     struct net_device *dev, int strict)
 {
-	struct inet6_ifaddr *ifp = NULL;
-	struct hlist_node *node;
+	struct inet6_ifaddr *ifp, *result = NULL;
 	unsigned int hash = ipv6_addr_hash(addr);
+	struct hlist_node *node;
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
@@ -1352,6 +1352,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
 			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict)) {
+				result = ifp;
 				in6_ifa_hold(ifp);
 				break;
 			}
@@ -1359,7 +1360,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 	}
 	rcu_read_unlock_bh();
 
-	return ifp;
+	return result;
 }
 
 /* Gets referenced address, destroys ifaddr */
-- 
1.7.0.3
