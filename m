From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network throughput is reducedof in total bandwidth in Mips.
Date: Mon, 24 Nov 2014 16:55:34 -0800
Message-ID: <1416876934.29427.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <d1b4ee5706f2dcb796b53ffb41cad1f8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Sadasivan Shaiju <sshaiju@mvista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d1b4ee5706f2dcb796b53ffb41cad1f8@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-24 at 14:31 -0800, Sadasivan Shaiju wrote:
> HI,
> 
> When  using iperf   with  small  buffers  there  is a performance
> degradation   for  3.10  kernel   from  2.6.32  kernel .   Using
> profiling  tools   I am getting  the  following  data.
> 
> 2.6.32   kerne  data
> ........
> samples  %        symbol name
> 160321   39.1122  r4k_wait
> 43731    10.6687  __do_softirq
> 27547     6.7204  cvm_oct_napi_poll_68
> 16569     4.0422  _raw_spin_unlock_irqrestore
> 12537     3.0586  cvm_oct_xmit
> 7362      1.7960  kfree
> 5916      1.4433  tcp_ack
> 5480      1.3369  net_rx_action
> 5353      1.3059  __copy_user_common
> 5097      1.2435  put_page
> 4447      1.0849  __kmalloc
> 4361      1.0639  kmem_cache_alloc
> 4359      1.0634  skb_segment
> 4309      1.0512  tcp_v4_rcv
> 4120      1.0051  __inet_lookup_established
> 4016      0.9798  ip_route_input
> 4010      0.9783  napi_complete
> 3766      0.9188  tcp_write_xmit
> 3297      0.8043  free_hot_cold_page
> 3189      0.7780  kmem_cache_free
> 
> 3.10  kernel  data
> .......
> samples  %        symbol name
> 186       8.6431  __do_softirq
> 127       5.9015  cvm_oct_napi_poll_68
> 80        3.7175  tcp_sendmsg
> 76        3.5316  tcp_write_xmit
> 72        3.3457  cvm_oct_xmit_lockless
> 71        3.2993  _raw_spin_lock_bh
> 48        2.2305  tcp_release_cb
> 47        2.1840  release_sock
> 44        2.0446  add_preempt_count
> 44        2.0446  tcp_transmit_skb
> 34        1.5799  skb_split
> 31        1.4405  sub_preempt_count
> 27        1.2546  dev_hard_start_xmit
> 25        1.1617  __srcu_read_lock
> 25        1.1617  skb_release_data
> 24        1.1152  tcp_ack
> 23        1.0688  __bzero
> 23        1.0688  _raw_spin_unlock_irqrestore
> 23        1.0688  ip_finish_output
> 22        1.0223  __copy_skb_header
> 21        0.9758  __kfree_skb
> 21        0.9758  ip_queue_xmit
> 
> Looks  like  mainly the  delay  is  causing   by  tcp_sendmsg()  and
> tcp_write_xmit()   from  the  stack .   However   if  the  buffer  is
> increased   to  default  (128k)  there  is  no  performance
> Degradation .  This is  happening  only    for  small  buffers.
> 
> When  iperf is    used   as  below    the  bandwidth  on  3.10 kernel  is
> only  around   600Mbps    compared   to  900Mbps   in  2.6.32  kernel.
> 
> ./iperf3 -c 10.162.103.131 -l 1500
> 
> When  iperf  is  ran  with  default  buffers  as  follows  the  bandwidth
> is same  in 3.10  kernel  and 2.6.32  kernel.
> 
> ./iperf3 -c 10.162.103.131
> 
> Please  let me know  if  there is any fixes  available for  this .
> --

CC netdev, where you can actually find some help ;)

Quite frankly, there are probably some reasons Octeon ethernet driver is
still in staging.

1) This REUSE_SKBUFFS_WITHOUT_FREE kludge is quite horrible... Dont know
if it was used in 2.6.32 and still used in 3.10 on your config.

2) TX completions seem to be delayed by undefined amount of time.
   TCP Small Queues was added in 3.6 so this driver problem could
explain a lower throughput.

You could try adding skb_orphan() into this driver...

diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 4e54d854021955868e2c602ac829b9b217960efd..85f42f32419aabcda28f1b2aa44e396a462b3fb2 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -175,6 +175,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	prefetch(priv);
 
+	skb_orphan(skb);
 	/*
 	 * The check on CVMX_PKO_QUEUES_PER_PORT_* is designed to
 	 * completely remove "qos" in the event neither interface
