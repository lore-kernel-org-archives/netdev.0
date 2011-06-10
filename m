From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Fri, 10 Jun 2011 15:33:10 -0700
Message-ID: <1307745190.17300.85.camel@schen9-DESK>
References: <1307600810.3980.85.camel@edumazet-laptop>
	 <1307664235.17300.44.camel@schen9-DESK>
	 <20110609.204330.2090335955971650557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, andi@firstfloor.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58506 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758096Ab1FJWcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 18:32:18 -0400
In-Reply-To: <20110609.204330.2090335955971650557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-09 at 20:43 -0700, David Miller wrote:
> From: Tim Chen <tim.c.chen@linux.intel.com>
> Date: Thu, 09 Jun 2011 17:03:55 -0700
> 
> > When I retest with original 3.0-rc2 kernel, inet_putpeer no longer shows
> > up, wonder if dst->peer was not set for some reason. 
> 
> The overhead will only show up if an inetpeer entry exists for
> the destination IP address.
> 
> You can force one to be created, for example, by making a TCP
> connection to that destination.

You're right.  By adding the TCP connection, inet peer shows up now in
my profile of the patched kernel with Eric's two patches.

Eric's patches produced much better cpu utilization.
The addr_compare (used to consume 10% cpu) and atomic_dec_and_lock (used
to consume 20.5% cpu) in inet_putpeer is eliminated and inet_putpeer
uses only 10% cpu now.  Though inet_getpeer and inet_putpeer still
consumes significant cpu compared to the other test case when peer is
not present.

Tim

Profile with Eric's two patches and peer forced to be present with TCP
added looks like this:

-     19.38%     memcached  [kernel.kallsyms]             [k] inet_getpeer
   - inet_getpeer                                                
      + 99.97% inet_getpeer_v4                                                             
-     11.49%     memcached  [kernel.kallsyms]             [k] inet_putpeer
   - inet_putpeer                                                                          
      - 99.96% ipv4_dst_destroy                                  
           dst_destroy                                                                     
         + dst_release                                           
-      5.71%     memcached  [kernel.kallsyms]             [k] rt_set_nexthop.clone.30
   - rt_set_nexthop.clone.30                                     
      + 99.89% __ip_route_output_key                                                       
-      5.60%     memcached  [kernel.kallsyms]             [k] atomic_add_unless.clone.34
   - atomic_add_unless.clone.34                                                            
      + 99.94% neigh_lookup                                      
+      3.02%     memcached  [kernel.kallsyms]             [k] do_raw_spin_lock
+      2.87%     memcached  [kernel.kallsyms]             [k] atomic_dec_and_test
+      1.45%     memcached  [kernel.kallsyms]             [k] atomic_add
+      1.04%     memcached  [kernel.kallsyms]             [k] _raw_spin_lock_irqsave
+      1.03%     memcached  [kernel.kallsyms]             [k] bit_spin_lock.clone.41


