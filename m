From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 05/10] Remove local address check on IP output
Date: Wed, 03 Jan 2007 17:36:28 +0100
Message-ID: <20070103163627.14635.88250.stgit@nienna.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

ip_route_output() contains a check to make sure that no flows with
non-local source IP addresses are routed. Unfortunately this check
makes it completely impossible to use non-local bound sockets as no
outbound packets will make through the stack.

This patch moves the interface lookup to the multicast-specific code
path as that is the only real user of the interface data looked up.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 net/ipv4/route.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 537b976..bb1158a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2498,11 +2498,6 @@ #endif
 		    ZERONET(oldflp->fl4_src))
 			goto out;
 
-		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
-			goto out;
-
 		/* I removed check for oif == dev_out->oif here.
 		   It was wrong for two reasons:
 		   1. ip_dev_find(saddr) can return wrong iface, if saddr is
@@ -2528,12 +2523,14 @@ #endif
 			   Luckily, this hack is good workaround.
 			 */
 
+			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
+			dev_out = ip_dev_find(oldflp->fl4_src);
+			if (dev_out == NULL)
+				goto out;
+
 			fl.oif = dev_out->ifindex;
 			goto make_route;
 		}
-		if (dev_out)
-			dev_put(dev_out);
-		dev_out = NULL;
 	}
 
 
