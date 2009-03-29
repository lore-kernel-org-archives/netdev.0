From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for March 27 (netfilter build error)
Date: Sun, 29 Mar 2009 13:59:30 +0200
Message-ID: <49CF62A2.6050803@netfilter.org>
References: <20090328102852.GA7697@localhost>	<49CEF882.5000005@oracle.com>	<20090329064704.GA7255@localhost> <20090328.234739.26481917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030407000400070201090800"
Cc: gorcunov@gmail.com, randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090328.234739.26481917.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030407000400070201090800
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Sun, 29 Mar 2009 10:47:04 +0400
> 
>> [Randy Dunlap - Sat, Mar 28, 2009 at 09:26:42PM -0700]
>> ... 
>> | works_for_me.  Thanks.
>> | but missing S-O-B.
>> | 
>> | Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
>> ...
>>
>> Thanks for testing Randy. So if nobody will complain
>> here is a solid version of the patch. Though I would like
>> if Pablo or Patrick confirm its correctness. Thanks!
> 
> I'll apply this once Patrick or Pablo have a look at it.

I think that the patch attached is better since it removes the overhead
of the IPv6 dependency, which is indeed too much for the use of one
function. Thanks.

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers

--------------030407000400070201090800
Content-Type: text/x-diff;
 name="x.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.patch"

netfilter: xtables: fix IPv6 dependency in the cluster match

This patch fixes a dependency with IPv6:

ERROR: "__ipv6_addr_type" [net/netfilter/xt_cluster.ko] undefined!

This patch adds a function that checks if the higher bits of the
address is 0xFF to identify a multicast address, instead of adding a
dependency due to __ipv6_addr_type(). I came up with this idea after
Patrick McHardy pointed possible problems with runtime module
dependencies.

Reported-by: Steven Noonan <steven@uplinklabs.net>
Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 net/netfilter/xt_cluster.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)


diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index ad5bd89..f2d2482 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -58,6 +58,13 @@ xt_cluster_hash(const struct nf_conn *ct,
 }
 
 static inline bool
+xt_cluster_ipv6_is_multicast(const struct in6_addr *addr)
+{
+	__be32 st = addr->s6_addr32[0];
+	return ((st & htonl(0xFF000000)) == htonl(0xFF000000)); 
+}
+
+static inline bool
 xt_cluster_is_multicast_addr(const struct sk_buff *skb, u_int8_t family)
 {
 	bool is_multicast = false;
@@ -67,8 +74,8 @@ xt_cluster_is_multicast_addr(const struct sk_buff *skb, u_int8_t family)
 		is_multicast = ipv4_is_multicast(ip_hdr(skb)->daddr);
 		break;
 	case NFPROTO_IPV6:
-		is_multicast = ipv6_addr_type(&ipv6_hdr(skb)->daddr) &
-						IPV6_ADDR_MULTICAST;
+		is_multicast =
+			xt_cluster_ipv6_is_multicast(&ipv6_hdr(skb)->daddr);
 		break;
 	default:
 		WARN_ON(1);

--------------030407000400070201090800--
