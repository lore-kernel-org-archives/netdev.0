From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Fri, 24 May 2013 06:51:36 -0700
Message-ID: <1369403496.3301.401.camel@edumazet-glaptop>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <1369244868.3301.343.camel@edumazet-glaptop>
	 <20130524151647.18388e27@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130524151647.18388e27@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-05-24 at 15:16 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 22 May 2013 10:47:48 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > nf_conntrack_lock is a monolithic lock and suffers from huge
> > contention on current generation servers (8 or more core/threads).
> > 
> [...]
> > Results on a 32 threads machine, 200 concurrent instances of "netperf
> > -t TCP_CRR" : 
> > 
> > ~390000 tps instead of ~300000 tps.
> 
> Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> I gave the patch a quick run in my testlab, and the results are
> amazing, you are amazing Eric! :-)
> 
> Basic testlab setup:
>  I'm generating a 2700 Kpps SYN-flood against port 80 (with trafgen)
> 
> Baseline result from a  3.9.0-rc5 kernel:
> - With nf_conntrack my performance is 749 Kpps.
> 
> If removing all iptables and nf_contrack modules:
> - the performance hits 1095 Kpps.
> But it looks like we are hitting a new spin_lock in ip_send_reply()
> 
> If start a LISTEN process on the port, then we hit the "old" SYN
> scalability issues again, performance drops tp 227 Kpps.
> 
> On a patched net-next (close to 3.10.0-rc1) kernel, with Eric's new
> locking scheme patch:
> - I measured an amazing 2431 Kpps.
> 
>  13.45%  [kernel]                [k] fib_table_lookup
>   9.07%  [nf_conntrack]          [k] __nf_conntrack_alloc
>   6.50%  [nf_conntrack]          [k] nf_conntrack_free
>   5.24%  [ip_tables]             [k] ipt_do_table
>   3.66%  [nf_conntrack]          [k] nf_conntrack_in
>   3.54%  [kernel]                [k] inet_getpeer
>   3.52%  [nf_conntrack]          [k] tcp_packet
>   2.44%  [ixgbe]                 [k] ixgbe_poll
>   2.30%  [kernel]                [k] __ip_route_output_key
>   2.04%  [nf_conntrack]          [k] nf_conntrack_tuple_taken
>   1.98%  [kernel]                [k] icmp_send
> 
> Then, I realized that I didn't have any iptables rules that accepted
> port 80 on my testlab system, thus this were basically a drop packets
> test with a nf_conntrack lookup.
> 
> If I add a rule that accept new connection to that port e.g:
>  iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j
> ACCEPT
> 
> New ruleset:
>  -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
>  -A INPUT -p icmp -j ACCEPT 
>  -A INPUT -i lo -j ACCEPT 
>  -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
>  -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT 
>  -A INPUT -j REJECT --reject-with icmp-host-prohibited 
> 
> Then, performance drops again:
> - to approx 883 Kpps.
> 
> Discover that the NAT stuff is to blame:
> 
> -  17.71%        swapper  [kernel.kallsyms]       [k] _raw_spin_lock_bh
>    - _raw_spin_lock_bh
>       + 47.17% nf_nat_cleanup_conntrack
>       + 45.81% nf_nat_setup_info
>       + 6.43% nf_nat_get_offset
> 
> Removing the nat modules, improves the performance:
> - to 1182 Kpps (not listen on port 80)
> 
>  sudo iptables -t nat -F
>  sudo rmmod iptable_nat nf_nat_ipv4
> 
> And the perf output looks more like what I would expect:
> 
> -  14.85%       swapper  [kernel.kallsyms]        [k] _raw_spin_lock
>    - _raw_spin_lock
>       + 82.86% mod_timer
>       + 11.14% nf_conntrack_double_lock
>       + 2.50% nf_ct_del_from_dying_or_unconfirmed_list
>       + 1.48% nf_conntrack_in
>       + 1.30% nf_ct_delete_from_lists
> -  12.78%       swapper  [kernel.kallsyms]        [k]
>   _raw_spin_lock_irqsave
>    - _raw_spin_lock_irqsave
>       - 99.44% lock_timer_base
>          + 99.07% del_timer
>          + 0.93% mod_timer
> +   2.69%       swapper  [ip_tables]              [k] ipt_do_table
> +   2.28%   ksoftirqd/0  [kernel.kallsyms]        [k]
>   _raw_spin_lock_irqsave
> +   2.18%       swapper  [nf_conntrack]           [k] tcp_packet
> +   2.16%       swapper  [kernel.kallsyms]        [k] fib_table_lookup
> 
> 
> Again if I start a LISTEN process on the port, performance drops to
> 169Kpps, due to the LISTEN and SYN-cookie scalability issues.
> 
> I'm amazed, this patch will actually make it a viable choice to load
> the conntrack modules on a DDoS based filtering box, and use the
> conntracks to protect against ACK and SYN+ACK attacks.
> 
> Simply by not accepting the ACK or SYN+ACK to create a conntrack entry.
> Via the command:
>  sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
> 
> A quick test show; now I can run a LISTEN process on the port, and
> handle an SYN+ACK attack of approx 2580Kpps (and the same for ACK
> attacks), while running a LISTEN process on the port.
> 
> Thanks for the great work Eric!
> 
> ps. also tested resizing the hash tables, both:
>  /proc/sys/net/netfilter/nf_conntrack_max
> and resizing the buckets via:
>  /sys/module/nf_conntrack/parameters/hashsize
> 

Wow, this is very interesting !

Did you test the thing when expectations are possible ? (say ftp module
loaded)

I think we should add RCU in the fast path, instead of having to lock
the expectation lock. Its totally doable.



