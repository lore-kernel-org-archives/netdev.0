From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Mon, 30 Aug 2004 14:07:29 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040830140729.7309ecc0.davem@davemloft.net>
References: <20040830201957.GY5824@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rusty@rustcorp.com.au,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040830201957.GY5824@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2004 22:19:57 +0200
Harald Welte <laforge@netfilter.org> wrote:

> In those cases, the error path from net/ipv4/netfilter/ipt_MASQUERADE.c:
 ...
> is taken.
> 
> A couple of questions:
> 
> 1) Why do we have this check in the first place?  What would be wrong
>    with re-routing if the user requests us by configuration?
> 
> 2) Why don't we include 'oif' in the routing key?  If we wanted to make
>    sure that oif doesn't change, then we should tell the routing lookup
>    rather than complaining afterwards, shouldn't we ?

The original idea was that if the input route relookup sends us
to a different device, something is very strange.

Input routing looks up using daddr/saddr/tos as the key.  The change
here is that we're now using the fwmark, so you're right that only
policy routing can cause this thing to trigger.

Where did this check some from?  From this change below, and the
changelog explains why we do things this way.

I know you don't use BK Harald, but things like this are why you should
at least use the web based interface to look at file change history.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2003/08/11 22:47:11-07:00 rusty@rustcorp.com.au 
#   [NETFILTER]: Fix masquerade routing check.
#   
#   Alexey says:
#    Unrelated: giving out->ifindex is a bug, by the way. It can screw up
#    the things a lot. In this context, if you want to be sure that packet
#    will go out expected interface you do plain lookup and drop packet
#    if it gave you some strange route.
# 
# net/ipv4/netfilter/ipt_MASQUERADE.c
#   2003/08/11 22:46:31-07:00 rusty@rustcorp.com.au +11 -4
#   [NETFILTER]: Fix masquerade routing check.
# 
diff -Nru a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-08-30 13:51:03 -07:00
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-08-30 13:51:03 -07:00
@@ -91,11 +91,18 @@
 #ifdef CONFIG_IP_ROUTE_FWMARK
 						.fwmark = (*pskb)->nfmark
 #endif
-					      } },
-				    .oif = out->ifindex };
+					      } } };
 		if (ip_route_output_key(&rt, &fl) != 0) {
-			/* Shouldn't happen */
-			printk("MASQUERADE: No route: Rusty's brain broke!\n");
+			/* Funky routing can do this. */
+			if (net_ratelimit())
+				printk("MASQUERADE:"
+				       " No route: Rusty's brain broke!\n");
+			return NF_DROP;
+		}
+		if (rt->u.dst.dev != out) {
+			if (net_ratelimit())
+				printk("MASQUERADE:"
+				       " Route sent us somewhere else.\n");
 			return NF_DROP;
 		}
 	}
