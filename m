From: Benjamin LaHaise <bcrl@kvack.org>
Subject: fib route create slow
Date: Sat, 28 Aug 2004 23:31:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829033115.GA6467@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello folks,

As some of you may be aware, I've been working on an L2TP implementation 
again recently.  To give folks a bit of background, L2TP is used by a number 
of DSL providers to tunnel PPP sessions to ISPs.  At least with one local 
provider, all of the tunnels will occasionally get dropped as they "service" 
the system.  The end result is that the time it takes for all of the incoming 
sessions to come up is very important.  The codebase I'm working on is able 
to do this in close to O(1) time for each new session in the userland and 
kernel l2tp components.  Unfortunately, after patching dev_get_by_name and 
dev_get_by_index (I'll post that after cleaning it up), the route cache 
comes up on top as doubling and quadrupling the amount of time for each 
1000 new interfaces:

Interfaces	Time		Create only
1000		0m2.349s	1.507049s
2000		0m9.745s	6.401269s
3000		0m25.932s	16.905815s
4000		0m48.450s	31.442625s
5000		1m19.064s	51.704020s

The interfaces are particularly boring: each has the same local address 
with a different remote address.  This configuration is substantially 
worse than setting each interface to use a different local address.

In any event, what I'm wondering is if there is any ongoing work (or planned 
work) to replace the present fib data structures with something that scales 
better for large numbers of interfaces and routes?  This work has been done 
on 2.4.21-rhel, but 2.6 exhibits the same behaviour.  Are there any other 
cases that an overhaul should consider?  Any input is appreciated.  Cheers,

		-ben

...lots of boring entries...
     6 rmqueue                                    0.0078
     7 __kmem_cache_alloc                         0.0292
     8 kfree                                      0.1000
    42 SHATransform                               0.1382
   113 proc_match                                 1.1771
   269 rt_run_flush                               1.5284
   301 neigh_parms_release                        1.8813
  1330 fn_hash_flush                              6.3942
  1820 fib_create_info                            1.6978
  2976 fib_sync_down                             18.6000
  7026 total                                      0.0041


-- 
"Time is what keeps everything from happening all at once." -- John Wheeler
