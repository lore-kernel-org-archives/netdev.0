From: Christian Benvenuti <christian.benvenuti@libero.it>
Subject: Default route selection and dead GW detection
Date: Tue, 11 Jan 2005 14:03:50 -0800
Message-ID: <1105481030.2809.4160.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
  I am looking at how Linux selects a default route (when
multipath is not configured), and in particular I am looking at:

        fn_hash_select_default / fib_detect_death (kernel 2.6.9)

It seems to me this is the logic used:

  a) If there is only one default route defined (which would be the one
     previously selected by <fn_hash_lookup> and saved in "res->fi"),
     that one would be used.

  b) If there is more than one route available, then:

     b1) the first default route whose next-hop is NUD_REACHABLE
         is selected.

     b2) if there is no NUD_REACHABLE GW, then

         b3) all eligible default routes are checked and the
             last one with a NUD_VALID GW is selected
             (if != fn_hash_last_dflt)

             b4) if there is no NUD_VALID GW, all default routes
                 will be tried by <fn_hash_select_default>, one by
                 one, from first one to last one.

Did I get the logic right? Supposing I did, I have a couple of
questions about b3):

1) why does b3) check for (!=fn_hash_last_dflt) ?
   In other words, if you do not use the "fn_hash_last_dflt"
   GW for sometime, and therefore its NUD states goes to
   NUD_STALE, why would you select another NUD_VALID (but
   not NUD_REACHABLE) GW?

2) please see my second question below

static int fib_detect_death(struct fib_info *fi, int order,
			    struct fib_info **last_resort,
                            int *last_idx)
{
	struct neighbour *n;
	int state = NUD_NONE;

	n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
	if (n) {
		state = n->nud_state;
		neigh_release(n);
	}
	if (state==NUD_REACHABLE)
		return 0;
	if ((state&NUD_VALID) && order != fn_hash_last_dflt)
		return 0;

/* Why does the block below keep updating <last_resort> and 
 * <last_idx> even when they are already initialized?
 * (e.g. from a previous invocation by <fn_hash_select_default>)
 * Is it just to make code simpler?
 */
	if ((state&NUD_VALID) ||
	    (*last_idx<0 && order > fn_hash_last_dflt)) {
		*last_resort = fi;
		*last_idx = order;
	}
	return 1;
}

I also have a doubt about how the "classic" configuration
of multiple default routes coexists with a multipath default
route.

Since multiple default GW are configurable both with multiple

  "route add default ..."

commands, or with a single default multipath route like 

  "ip route add default ..."

am I correct if I say that those two forms are exclusive?

You can configure default routes with both commands, the
kernel does not complain, but it seems the routing routines 
<ip_route_{input, output}_slow> do not take this possibility
into account. 

For example:

- <ip_route_output_slow> selects the default route either
  with <fib_select_multipath> or <fib_select_default>:

  ...
  #ifdef CONFIG_IP_ROUTE_MULTIPATH
	if (res.fi->fib_nhs > 1 && fl.oif == 0)
		fib_select_multipath(&fl, &res);
	else
  #endif
	if (!res.prefixlen && res.type == RTN_UNICAST && !fl.oif)
		fib_select_default(&fl, &res);
  ...

- <ip_route_input_slow> does not call <fib_select_default>
  at all:

  ...
  #ifdef CONFIG_IP_ROUTE_MULTIPATH
	if (res.fi->fib_nhs > 1 && fl.oif == 0)
		fib_select_multipath(&fl, &res);
  #endif
  ... 


Thanks in advance
-Christian
