From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Mon, 2 Jun 2003 12:58:31 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16091.11735.721251.925522@robur.slu.se>
References: <20030522.015815.91322249.davem@redhat.com>
	<20030522.034058.71558626.davem@redhat.com>
	<20030522114438.GD2961@netnation.com>
	<20030522.153330.74735095.davem@redhat.com>
	<20030529205125.GA30058@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030529205125.GA30058@netnation.com>
List-Id: netdev.vger.kernel.org


Simon Kirby writes:
 > Full profile output available here:
 > 
 > 	http://blue.netnation.com/sim/ref/
 > 	readprofile.full_route_table_hash_fixed_napi.*
 > 
 > Note that if I increase the packet rate and NAPI kicks in, all of the
 > handle_IRQ and similar overhead basically disappears because it no longer
 > uses IRQs.  Pretty spiffy.  Here is a profile of that:
 > Full profile output available as:


  8896 rt_garbage_collect                         9.4237
  8959 ip_route_input_slow                        3.8885
 10516 dst_alloc                                 73.0278
 10666 kmem_cache_free                           66.6625
 15339 tg3_rx                                    16.2489
 16553 ipt_do_table                              14.9937
 20193 fn_hash_lookup                            70.1146
 26833 rt_intern_hash                            34.9388
 64803 ip_route_input                           150.0069

 From DoS perspective a more interesting experiment compared to where you limited input
 rate to have 30% idle CPU.

 New dst is coming all the time first seached in hash (ip_route_input) and not found
 so ip_route_input_slow/fn_hash_lookup/dst_alloc/rt_intern_hash path is taken to add
 a new dst entry...

 And later GC have to remove all enties with spin_lock_bh hold (no packet processing 
 runs). I see packet drops exactly when GC runs. Tuning GC might help but it's something 
 to observe.

 
 I had some idea to rate-limit new flows and try to isolate the device causing the DoS 
 Something like (ip_route_input):

 [We don't have an hash entry]

        /* 
           DoS check... Rate down but do not stop GC and creation of new 
           hash entries until GC frees resources. We limit per interface 
           so hogger dev(s) will be hit hardest. As a side effect we get 
           dst_overrun per device.

        */

        entries = atomic_read(&ipv4_dst_ops.entries);

        if (entries > ip_rt_max_size) {
                int drp = 4;

                if( dev->dst_hash_overrun++ % drp ) {

                        if (net_ratelimit())
                                printk(KERN_WARNING "dst creation throttled\n");

                        return -ECONNREFUSED;
                }

       /* Also make sure the slow path gets a chance to create the dst entry */

                if (ipv4_dst_ops.gc && ipv4_dst_ops.gc()) {
                        RT_CACHE_STAT_INC(gc_dst_overflow);
                        return -ENOBUFS;
                }
        }
  
 [ip_route_input_slow comes here] 


 But more thinking is needed...

 Cheers.
							--ro
  

