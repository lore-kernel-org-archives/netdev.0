From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Sat, 13 Dec 2003 02:10:52 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312130205460.7978-100000@u.domain.uli>
References: <20031212003143.062598e9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: niv@us.ibm.com, <ak@suse.de>, <ruddk@us.ibm.com>, <kuznet@ms2.inr.ac.ru>,
        <netdev@oss.sgi.com>, <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031212003143.062598e9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 12 Dec 2003, David S. Miller wrote:

> I think #2 should be very safe because fib node fn_tos values are only
> ever set when that config variable is enabled, and fib rule r_tos values
> are only compared on lookup when it is enabled as well.  However, there
> could be a few more ifdefs added to the fib rule code to cover all the
> assignment cases too but let's not worry about that right now.

	It seems the FIB changes are small, only for the lookups.
I didn't changed the other places, better to allow deletion by
tos because the flag can be changed at run time.

diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	Sat Dec 13 02:04:59 2003
+++ b/net/ipv4/fib_hash.c	Sat Dec 13 02:04:59 2003
@@ -48,6 +48,8 @@
    printk(KERN_DEBUG a)
  */
 
+extern int ip_rt_ignore_tos;
+
 static kmem_cache_t * fn_hash_kmem;
 
 /*
@@ -309,7 +311,7 @@
 					continue;
 			}
 #ifdef CONFIG_IP_ROUTE_TOS
-			if (f->fn_tos && f->fn_tos != flp->fl4_tos)
+			if (f->fn_tos && f->fn_tos != flp->fl4_tos && !ip_rt_ignore_tos)
 				continue;
 #endif
 			f->fn_state |= FN_S_ACCESSED;
diff -Nru a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
--- a/net/ipv4/fib_rules.c	Sat Dec 13 02:04:59 2003
+++ b/net/ipv4/fib_rules.c	Sat Dec 13 02:04:59 2003
@@ -49,6 +49,8 @@
 
 #define FRprintk(a...)
 
+extern int ip_rt_ignore_tos;
+
 struct fib_rule
 {
 	struct fib_rule *r_next;
@@ -323,7 +325,7 @@
 		if (((saddr^r->r_src) & r->r_srcmask) ||
 		    ((daddr^r->r_dst) & r->r_dstmask) ||
 #ifdef CONFIG_IP_ROUTE_TOS
-		    (r->r_tos && r->r_tos != flp->fl4_tos) ||
+		    (r->r_tos && r->r_tos != flp->fl4_tos && !ip_rt_ignore_tos) ||
 #endif
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		    (r->r_fwmark && r->r_fwmark != flp->fl4_fwmark) ||

Regards

--
Julian Anastasov <ja@ssi.bg>
