From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 01:40:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522084003.GA22613@netnation.com>
References: <20030519220409.V39658@shell.cyberus.ca> <20030519.234624.123976229.davem@redhat.com> <20030520074848.U40843@shell.cyberus.ca> <20030520.173607.88482742.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030520.173607.88482742.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 20, 2003 at 05:36:07PM -0700, David S. Miller wrote:

> None of this means that slowpath should not be improved if necessary.
> On the contrary, I would welcome good kernel profiling output from
> someone such as sim@netnation during such stress tests.

I decided to try some profiling while waiting for kernel compiles.
It seems that having a full BGP table is slowing thing down a lot.

I put 2.4.21-rc2 (with the new hash) on the test box.  I modified juno
to include a busy delay loop (to try to avoid timer aliasing throwing
off the remote profile and to be short enough to generate sufficient
traffic), and tuned it to leave about 30% idle CPU on the testing box.
I fired up juno, ran "readprofile -r", and let it sit for a while.
readprofile results:

   384 do_gettimeofday                            2.6667
   199 ipt_route_hook                             3.1094
  1092 fib_lookup                                 3.4125
  1286 ip_packet_match                            3.8274
   248 fib_rule_put                               3.8750
  3209 rt_intern_hash                             4.1784
   852 dst_destroy                                4.8409
  1923 fn_hash_lookup                             6.6771
  1325 kmem_cache_free                            8.2812
  1387 dst_alloc                                  9.6319
  3857 tg3_interrupt                             11.4792
  3848 do_softirq                                16.0333
  7354 ip_route_input                            17.0231
  8814 tg3_poll                                  28.9934
 17370 handle_IRQ_event                         108.5625
 26413 default_idle                             412.7031

I then faked a whole slew of routing table entries to look like normal
BGP routes.  "ip -o route | wc -l" shows 181012 entries, which is similar
to the actual routers.  readprofile results:

   289 do_gettimeofday                            2.0069
   669 fib_lookup                                 2.0906
   158 fib_rule_put                               2.4688
   367 tg3_recycle_rx                             2.5486
   889 ip_packet_match                            2.6458
  2375 rt_intern_hash                             3.0924
   636 dst_destroy                                3.6136
   868 dst_alloc                                  6.0278
  2029 tg3_interrupt                              6.0387
  1037 kmem_cache_free                            6.4813
  5364 ip_route_input                            12.4167
   993 default_idle                              15.5156
  7593 tg3_poll                                  24.9770
  9631 handle_IRQ_event                          60.1938
 26552 fn_hash_lookup                            92.1944

Hmm!  I guess the routing table size has a slight difference on
performance there.

Full readprofile output available here:

	http://blue.netnation.com/sim/ref/

I'm not sure if this is a "good" profile or not... I can try with
oprofile or something instead if that gives more useful results.

I think I wrote a loadable module to dump the hash distribution a while
back, but I can't remember where I put it.  I'll try writing something
like that again and see if there's anything interesting.

Simon-
