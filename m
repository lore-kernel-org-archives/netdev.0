From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Sat, 6 Mar 2004 18:02:06 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403061740010.1158@u.domain.uli>
References: <200403042202.BAA10586@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, niv@us.ibm.com, ak@suse.de, ruddk@us.ibm.com,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200403042202.BAA10586@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 5 Mar 2004 kuznet@ms2.inr.ac.ru wrote:

> > - do we need to walk all tos values for ip_rt_redirect in the same
> > way as for ip_rt_frag_needed,
>
> Well, it is just the same thing (except for one thing, that ignored
> redirects are harmless)

	A related 3-hunk change (on top of tos-8.diff), more eyes are
needed. The 2nd hunk tries harder to propagate the new_gw. It seems
this 2nd hunk is needed because the first list of checks does not compare
all possible keys and we can not simply exit the hash chain in the
middle. This problem exists also in current kernels, for example, when
fwmark is used. As for hunks 1 and the 3, they are needed if we want
to propagate the new_gw value to all entries in the hash chain
with the cost of some cycles. If we do not apply 1 and 3 then
we will update the next entries in the chain on another redirect
message.

	do_next is still used to avoid deadloops in a chain, do_repeat is 
used only on successful update.

Comments?

Regards

--
Julian Anastasov <ja@ssi.bg>

--- linux-tos-8/net/ipv4/route.c	2004-03-06 13:24:03.000000000 +0200
+++ linux/net/ipv4/route.c	2004-03-06 17:28:34.572673040 +0200
@@ -1018,6 +1018,8 @@
 	for (i = 0; i < 2; i++) {
 			unsigned hash = rt_hash_code(daddr, skeys[i], tos_values[j]);

+		do_repeat:
+
 			rthp=&rt_hash_table[hash].chain;

 			rcu_read_lock();
@@ -1039,8 +1041,10 @@
 				    rth->rt_src != saddr ||
 				    rth->u.dst.error ||
 				    rth->rt_gateway != old_gw ||
-				    rth->u.dst.dev != dev)
-					break;
+				    rth->u.dst.dev != dev) {
+					rthp = &rth->u.rt_next;
+					continue;
+				}

 				dst_hold(&rth->u.dst);
 				rcu_read_unlock();
@@ -1089,8 +1093,10 @@
 				}

 				rt_del(hash, rth);
-				if (!rt_intern_hash(hash, rt, &rt))
+				if (!rt_intern_hash(hash, rt, &rt)) {
 					ip_rt_put(rt);
+					goto do_repeat;
+				}
 				goto do_next;
 			}
 			rcu_read_unlock();
