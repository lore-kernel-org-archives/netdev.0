From: Anton Blanchard <anton@samba.org>
Subject: Spurious "TCP: too many of orphaned sockets", unable to allocate
 sockets
Date: Wed, 25 Aug 2010 17:16:26 +1000
Message-ID: <20100825071626.GA13681@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: miltonm@bga.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33277 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355Ab0HYHRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 03:17:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

We have a machine running a network test that regularly hits:

TCP: too many of orphaned sockets

Which comes from:

                int orphan_count = percpu_counter_read_positive(
                                                sk->sk_prot->orphan_count);

                sk_mem_reclaim(sk);
                if (tcp_too_many_orphans(sk, orphan_count)) {
                        if (net_ratelimit())
                                printk(KERN_INFO "TCP: too many of orphaned "
                                       "sockets\n");
                        tcp_set_state(sk, TCP_CLOSE);
                        tcp_send_active_reset(sk, GFP_ATOMIC);
                        NET_INC_STATS_BH(sock_net(sk),
                                        LINUX_MIB_TCPABORTONMEMORY);
                }

Looking closer we have:

# cat /proc/sys/net/ipv4/tcp_max_orphans
4096

# grep processor /proc/cpuinfo | wc -l
128

The problem is we are using percpu_counter_read_positive, so the value can be
out num_online_cpus() * percpu_counter_batch. percpu_counter_batch is going to
be 32, so we might be out by 32 * 128 = 4k. Considering tcp_max_orphans is 4k
that explains the spurious printout and the inability to allocate sockets.

A couple of issues:

1. We size sysctl_tcp_max_orphans based on some second order heuristic
that uses pages which could be anything from 4k to 64k:

        /* Try to be a bit smarter and adjust defaults depending
         * on available memory.
         */
        for (order = 0; ((1 << order) << PAGE_SHIFT) <
                        (tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket));
                        order++)
                ;
        if (order >= 4) {
                tcp_death_row.sysctl_max_tw_buckets = 180000;
                sysctl_tcp_max_orphans = 4096 << (order - 4);
                sysctl_max_syn_backlog = 1024;
        } else if (order < 3) {
                tcp_death_row.sysctl_max_tw_buckets >>= (3 - order);
                sysctl_tcp_max_orphans >>= (3 - order);
                sysctl_max_syn_backlog = 128;
        }

I'll follow up with a patch to fix this for PAGE_SIZE != 4k

2. Even with this fixed we could hit the original issue. We have been known to
test on 1024 thread boxes and we would have the possibility of 32 * 1024
= 32k slack in the percpu counters. On this box tcp_max_orphans will be
64k after the fix which is a bit close for comfort. Should we do anything here?

Anton
