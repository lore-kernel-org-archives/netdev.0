From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 07:18:29 -0500
Message-ID: <20110301121829.GM9763@canuck.infradead.org>
References: <20110228141322.GF9763@canuck.infradead.org>
 <1298910174.2941.585.camel@edumazet-laptop>
 <20110228163742.GH9763@canuck.infradead.org>
 <1298912869.2941.687.camel@edumazet-laptop>
 <20110301101955.GI9763@canuck.infradead.org>
 <1298975602.3284.13.camel@edumazet-laptop>
 <20110301110708.GJ9763@canuck.infradead.org>
 <1298977984.3284.15.camel@edumazet-laptop>
 <20110301112759.GK9763@canuck.infradead.org>
 <1298979909.3284.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33293 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512Ab1CAMSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 07:18:35 -0500
Content-Disposition: inline
In-Reply-To: <1298979909.3284.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 12:45:09PM +0100, Eric Dumazet wrote:
> ethtool -S eth0 | grep rx_pk
>      rxq0: rx_pkts: ??
>      rxq1: rx_pkts: ??
>      rxq2: rx_pkts: ??
>      rxq3: rx_pkts: ??
>      rxq4: rx_pkts: ??

It could do multiqueue but it doesnt:

[root@hp-bl460cg7-01 ~]# ethtool -S eth0 | grep rx_pk
     rxq0: rx_pkts: 1512
     rxq1: rx_pkts: 462
     rxq2: rx_pkts: 122
     rxq3: rx_pkts: 24751393
     rxq4: rx_pkts: 35

So, adding a third client making sure it would hit another queue:
     rxq0: rx_pkts: 3041
     rxq1: rx_pkts: 867
     rxq2: rx_pkts: 4610476
     rxq3: rx_pkts: 57418776
     rxq4: rx_pkts: 40

... makes it use CPU 5 for rxq2 and the qps goes up from 250kqps to 270kqps

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
   PerfTop:   18417 irqs/sec  kernel:50.2%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 5)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ___________________________________________________________

            12712.00 18.5% _raw_spin_unlock_irqrestore   [kernel.kallsyms]                                          
             3697.00  5.4% isc_rwlock_lock               /usr/lib64/libisc.so.62.0.1                                
             1948.00  2.8% dns_rbt_findnode              /usr/lib64/libdns.so.69.0.1                                
             1809.00  2.6% isc_rwlock_unlock             /usr/lib64/libisc.so.62.0.1                                
             1631.00  2.4% __do_softirq                  [kernel.kallsyms]                                          
             1237.00  1.8% isc_stats_increment           /usr/lib64/libisc.so.62.0.1                                
             1106.00  1.6% clflush_cache_range           [kernel.kallsyms]                                          
              964.00  1.4% _raw_spin_lock                [kernel.kallsyms]                                          
              714.00  1.0% be_poll_rx                    /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
              630.00  0.9% __pthread_mutex_lock_internal /lib64/libpthread-2.12.so                                  
              627.00  0.9% dns_name_fullcompare          /usr/lib64/libdns.so.69.0.1                                
              582.00  0.8% dns_rbtnodechain_init         /usr/lib64/libdns.so.69.0.1                                
              552.00  0.8% sk_run_filter                 [kernel.kallsyms]                                          
              527.00  0.8% dns_name_getlabelsequence     /usr/lib64/libdns.so.69.0.1                                
              525.00  0.8% __pthread_mutex_unlock        /lib64/libpthread-2.12.so                                  
              492.00  0.7% dns_name_equal                /usr/lib64/libdns.so.69.0.1                                
              468.00  0.7% isc___mempool_get             /usr/lib64/libisc.so.62.0.1                                
              462.00  0.7% __udp4_lib_lookup             [kernel.kallsyms]                                          
              457.00  0.7% dns_acl_match                 /usr/lib64/libdns.so.69.0.1                                
              453.00  0.7% dns_zone_attach               /usr/lib64/libdns.so.69.0.1                                
              451.00  0.7% fget_light                    [kernel.kallsyms]                                          
              443.00  0.6% dns_message_rendersection     /usr/lib64/libdns.so.69.0.1                                
              431.00  0.6% ipt_do_table                  [kernel.kallsyms]                                          
              429.00  0.6% nf_iterate                    [kernel.kallsyms]                                          
              422.00  0.6% __kmalloc_node_track_caller   [kernel.kallsyms]                                          
              408.00  0.6% __domain_mapping              [kernel.kallsyms]                                          
              387.00  0.6% dns_name_hash                 /usr/lib64/libdns.so.69.0.1                                
              353.00  0.5% copy_user_generic_string      [kernel.kallsyms]                                          
              349.00  0.5% dns_name_fromwire             /usr/lib64/libdns.so.69.0.1                          
