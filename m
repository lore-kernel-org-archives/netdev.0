From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Thu, 09 Jun 2011 17:03:55 -0700
Message-ID: <1307664235.17300.44.camel@schen9-DESK>
References: <1307600810.3980.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48489 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756046Ab1FJADK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 20:03:10 -0400
In-Reply-To: <1307600810.3980.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-09 at 08:26 +0200, Eric Dumazet wrote:
> Profiles show false sharing in addr_compare() because refcnt/dtime
> changes dirty the first inet_peer cache line, where are lying the keys
> used at lookup time. If many cpus are calling inet_getpeer() and
> inet_putpeer(), or need frag ids, addr_compare() is in 2nd position in
> "perf top".
> 

I've applied both inetpeer patches.  I also no longer have inet_getpeer
and inet_putpeer and addr_compare in my profile.  Instead, neighbor
lookup is now dominant.  See profile below.

When I retest with original 3.0-rc2 kernel, inet_putpeer no longer shows
up, wonder if dst->peer was not set for some reason. 

Tim

-     27.06%     memcached  [kernel.kallsyms]             [k] atomic_add_unless.clone.34
   - atomic_add_unless.clone.34
      - 99.97% neigh_lookup
           __neigh_lookup_errno.clone.17
           arp_bind_neighbour
           rt_intern_hash
           __ip_route_output_key
           ip_route_output_flow
           udp_sendmsg
           inet_sendmsg
           __sock_sendmsg
           sock_sendmsg
           __sys_sendmsg
           sys_sendmsg
           system_call_fastpath
           __sendmsg
-     13.33%     memcached  [kernel.kallsyms]             [k] atomic_dec_and_test
   - atomic_dec_and_test
      - 99.89% dst_destroy
         - dst_release
            - 98.12% skb_dst_drop.clone.55
                 dev_hard_start_xmit
               + sch_direct_xmit
            + 1.88% skb_release_head_state
-      3.26%     memcached  [kernel.kallsyms]             [k] do_raw_spin_lock
   - do_raw_spin_lock
      - 92.24% _raw_spin_lock
         + 41.39% sch_direct_xmit


