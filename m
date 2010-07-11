From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Sun, 11 Jul 2010 04:11:45 -0300
Message-ID: <AANLkTikqNLp5HN0Puu00_bbJEQCUNCCtSsOFxuxfX5g0@mail.gmail.com>
References: <1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<20100710.123011.260095467.davem@davemloft.net>
	<AANLkTilQbM8F27a5SLZLMzndLYfz-eRhzyxP18KCFz2K@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, kaber@trash.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilQbM8F27a5SLZLMzndLYfz-eRhzyxP18KCFz2K@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2010/7/11 Felipe W Damasio <felipewd@gmail.com>:
> What do you mean "from elsewhere"? You mean elsewhere on the network code?
>
> Since the function that had the problem was tcp_recvmsg and we're
> talking about a squid process, we're either talking about a typical
> webserver-objet response, or about about an incorrect/faulty http
> request from the user.

I'm trying to understand the network code to see if I can help track
this down...

So I looked at the code of tcp_recvmsg, and I saw that the function
that calls __kfree_skb is sk_eat_skb, which is called in tcp_recvmsg:

                if (tcp_hdr(skb)->fin)
                        goto found_fin_ok;
                if (!(flags & MSG_PEEK)) {
                        sk_eat_skb(sk, skb, copied_early);
                        copied_early = 0;
                }
                continue;

        found_fin_ok:
                /* Process the FIN. */
                ++*seq;
                if (!(flags & MSG_PEEK)) {
                        sk_eat_skb(sk, skb, copied_early);
                        copied_early = 0;
                }
                break;


  Now, I'm no kernel programmer, but I saw the "Process the FIN" thing
on the code. I'm tuning these proc parameters....maybe some of these
are triggering the bug?

   The production machine has 8GB of RAM:


echo 1 >  /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/lo/rp_filter
echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind
echo 1 >  /proc/sys/net/ipv4/tcp_low_latency

echo 0 > /proc/sys/net/ipv4/conf/eth2/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/eth1/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/eth0/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/br0/rp_filter

echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
echo 1 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 1 > /proc/sys/net/ipv4/conf/eth0/send_redirects

echo 16384 > /proc/sys/net/ipv4/neigh/default/gc_thresh1
echo 32768 > /proc/sys/net/ipv4/neigh/default/gc_thresh2
echo 65535 > /proc/sys/net/ipv4/neigh/default/gc_thresh3

echo 1024 65535 > /proc/sys/net/ipv4/ip_local_port_range

echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/tcp_ecn
echo 1 > /proc/sys/net/ipv4/tcp_low_latency
echo 100000 > /proc/sys/net/core/netdev_max_backlog
echo 409600  > /proc/sys/net/ipv4/tcp_max_syn_backlog


echo 3 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 15 > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo 3 > /proc/sys/net/ipv4/tcp_keepalive_probes
echo 65536 > /proc/sys/vm/min_free_kbytes
echo "262144 1024000 4194304" > /proc/sys/net/ipv4/tcp_rmem
echo "262144 1024000 4194304" > /proc/sys/net/ipv4/tcp_wmem
echo "1024000" > /proc/sys/net/core/rmem_max
echo "1024000" > /proc/sys/net/core/wmem_max
echo "512000" > /proc/sys/net/core/rmem_default
echo "512000" > /proc/sys/net/core/wmem_default
echo "524288" > /proc/sys/net/ipv4/netfilter/ip_conntrack_max

echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
echo "2" > /proc/sys/net/ipv4/tcp_syn_retries
echo "262144" > /proc/sys/net/ipv4/tcp_max_orphans
echo "262144" > /proc/sys/net/core/somaxconn

  Maybe these can help?

  Cheers,

Felipe Damasio
