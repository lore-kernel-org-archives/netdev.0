From: "David S. Miller" <davem@redhat.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Fri, 12 Dec 2003 00:31:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031212003143.062598e9.davem@redhat.com>
References: <20031210160946.4110c611.davem@redhat.com>
	<Pine.LNX.4.44.0312110219210.1519-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, ak@suse.de, ruddk@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312110219210.1519-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Dec 2003 02:34:51 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> On Wed, 10 Dec 2003, David S. Miller wrote:
> 
> > But regardless, let us say that your system has complexity O(16)
> > lookups as you mention, your proposal changes this to O(16+8).
> 
> 	It is ~16 :)
> 
> 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
> 
> 	This is what happens on full table, of course. OK,
> some simple numbers for an ideal table:

But look at default gc_thresh setting, which is when we trim
rt cache entries:

        ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);

The ip_rt_max_size value is meant to be a sort of buffer to absorb
the situation where many rt cache entries are unreclaimable.

But this is a seperate issue, and we can discuss your further points
regardless.

> 2 cases depending on whether TOS is a hash key (path=saddr->daddr):
> 
> 1. TOS is a hash key:
> 
> 	- in each chain we have 16 paths, 1 TOS value per path
> 	- all 8 TOS values for a path are in 8 different chains
> 
> 2. TOS is not a hash key:
> 
> 	2 paths per chain (2 paths x 8 TOS values => 16 entries)
> 
> if all saddr->daddr->tos streams have same packet rate I think
> the CPU time to lookup them will be same.
> This is because 8 (number of TOS values) < 16 (chain length).
> 
> 	And I hope the users always can tune the proposed TOS
> settings if they see DoS and if they do not need TOS as a rt key.

Ok.  I agree with your analysis.  Let's propose something concrete.

1) PMTU processing applies PMTU change to all TOS'd instances of
   a route.  This behavior change is sysctl controllable, and
   on by default.

   The implementation is to just lookup all 8 possible TOS values.

2) Whether TOS is a routing cache hash key is controlled by another
   sysctl.

   When CONFIG_IP_ROUTE_TOS is set this sysctl defaults to on, other-
   wise it defaults to off.

I think #2 should be very safe because fib node fn_tos values are only
ever set when that config variable is enabled, and fib rule r_tos values
are only compared on lookup when it is enabled as well.  However, there
could be a few more ifdefs added to the fib rule code to cover all the
assignment cases too but let's not worry about that right now.

Comments?
