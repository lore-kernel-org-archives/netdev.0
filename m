From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: 100% CPU load when generating traffic to destination network that
 nexthop is not reachable
Date: Wed, 16 Aug 2017 12:07:24 +0200
Message-ID: <d54b2cce-db22-0c9c-2fca-708a682b4b65@itcare.pl>
References: <177465a0-aaba-4063-e451-ebbf46728b77@itcare.pl>
 <1502816253.4936.85.camel@edumazet-glaptop3.roam.corp.google.com>
 <baa1807d-cc00-0182-4b34-4d986d62ebcb@itcare.pl>
 <1502824260.4936.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.20.1708152236360.1666@ja.home.ssi.bg>
 <1502831185.4936.87.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.20.1708161026280.1778@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.iq.pl ([86.111.242.224]:43545 "EHLO smtp19.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751068AbdHPKI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 06:08:28 -0400
In-Reply-To: <alpine.LFD.2.20.1708161026280.1778@ja.home.ssi.bg>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


Patch applied - but no big change - from 0.7Mpps per vlan to 1.2Mpps per 
vlan

previously(without patch) 100% cpu load:

   bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
   input: /proc/net/dev type: rate
   |         iface                   Rx Tx                Total
============================================================================== 

          vlan1002:            0.00 P/s             1.99 P/s             
1.99 P/s
          vlan1001:            0.00 P/s        717227.12 P/s 717227.12 P/s
        enp175s0f0:      2713679.25 P/s             0.00 P/s 2713679.25 P/s
          vlan1000:            0.00 P/s        716145.44 P/s 716145.44 P/s
------------------------------------------------------------------------------ 

             total:      2713679.25 P/s       1433374.50 P/s 4147054.00 P/s


With patch (100% cpu load a little better pps performance)

  bwm-ng v0.6.1 (probing every 1.000s), press 'h' for help
   input: /proc/net/dev type: rate
   |         iface                   Rx Tx                Total
==============================================================================
          vlan1002:            0.00 P/s             1.00 P/s             
1.00 P/s
          vlan1001:            0.00 P/s       1202161.50 P/s 1202161.50 P/s
        enp175s0f0:      3699864.50 P/s             0.00 P/s 3699864.50 P/s
          vlan1000:            0.00 P/s       1196870.38 P/s 1196870.38 P/s
------------------------------------------------------------------------------
             total:      3699864.50 P/s       2399033.00 P/s 6098897.50 P/s


perf top attached below:

      1.90%     0.00%  ksoftirqd/39    [kernel.vmlinux] [k] run_ksoftirqd
             |
              --1.90%--run_ksoftirqd
                        |
                         --1.90%--__softirqentry_text_start
                                   |
                                    --1.90%--net_rx_action
                                              |
--1.90%--mlx5e_napi_poll
                                                         |
--1.89%--mlx5e_poll_rx_cq
|
--1.88%--mlx5e_handle_rx_cqe
|
--1.85%--napi_gro_receive
|
--1.85%--netif_receive_skb_internal
|
--1.85%--__netif_receive_skb
|
--1.85%--__netif_receive_skb_core
|
--1.85%--ip_rcv
|
--1.85%--ip_rcv_finish
|
--1.83%--ip_forward
|
--1.82%--ip_forward_finish
|
--1.82%--ip_output
|
--1.82%--ip_finish_output
|
--1.82%--ip_finish_output2
|
--1.79%--neigh_resolve_output
|
--1.77%--neigh_event_send
|
--1.77%--__neigh_event_send
|
--1.74%--_raw_write_lock_bh
|
--1.74%--queued_write_lock
queued_write_lock_slowpath
|
--1.70%--queued_spin_lock_slowpath


     1.90%     0.00%  ksoftirqd/34    [kernel.vmlinux] [k] 
__softirqentry_text_start
             |
             ---__softirqentry_text_start
                |
                 --1.90%--net_rx_action
                           |
                            --1.90%--mlx5e_napi_poll
                                      |
                                       --1.89%--mlx5e_poll_rx_cq
                                                 |
--1.88%--mlx5e_handle_rx_cqe
                                                            |
--1.86%--napi_gro_receive
                                                                       |
--1.85%--netif_receive_skb_internal
|
--1.85%--__netif_receive_skb
|
--1.85%--__netif_receive_skb_core
|
--1.85%--ip_rcv
|
--1.85%--ip_rcv_finish
|
--1.83%--ip_forward
|
--1.82%--ip_forward_finish
|
--1.82%--ip_output
|
--1.82%--ip_finish_output
|
--1.82%--ip_finish_output2
|
--1.79%--neigh_resolve_output
|
--1.77%--neigh_event_send
|
--1.77%--__neigh_event_send
|
--1.74%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.71%--queued_spin_lock_slowpath

  1.85%     0.00%  ksoftirqd/38    [kernel.vmlinux]          [k] 
ip_rcv_finish
             |
              --1.85%--ip_rcv_finish
                        |
                         --1.83%--ip_forward
                                   |
                                    --1.82%--ip_forward_finish
                                              |
                                               --1.82%--ip_output
                                                         |
--1.82%--ip_finish_output
|
--1.82%--ip_finish_output2
|
--1.79%--neigh_resolve_output
|
--1.77%--neigh_event_send
|
--1.77%--__neigh_event_send
|
--1.74%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.71%--queued_spin_lock_slowpath

      1.85%     0.00%  ksoftirqd/22    [kernel.vmlinux] [k] ip_rcv
             |
              --1.85%--ip_rcv
                        |
                         --1.85%--ip_rcv_finish
                                   |
                                    --1.83%--ip_forward
                                              |
--1.82%--ip_forward_finish
                                                         |
--1.82%--ip_output
|
--1.82%--ip_finish_output
|
--1.82%--ip_finish_output2
|
--1.79%--neigh_resolve_output
|
--1.77%--neigh_event_send
|
--1.77%--__neigh_event_send
|
--1.73%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.70%--queued_spin_lock_slowpath

     1.83%     0.00%  ksoftirqd/9     [kernel.vmlinux]          [k] 
ip_forward
             |
              --1.83%--ip_forward
                        |
                         --1.82%--ip_forward_finish
                                   |
                                    --1.82%--ip_output
                                              |
--1.82%--ip_finish_output
                                                         |
--1.82%--ip_finish_output2
                                                                    |
--1.79%--neigh_resolve_output
|
--1.77%--neigh_event_send
|
--1.77%--__neigh_event_send
|
--1.74%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.70%--queued_spin_lock_slowpath


      1.82%     0.00%  ksoftirqd/35    [kernel.vmlinux]          [k] 
ip_output
             |
              --1.82%--ip_output
                        |
                         --1.82%--ip_finish_output
                                   |
                                    --1.82%--ip_finish_output2
                                              |
--1.79%--neigh_resolve_output
                                                         |
--1.77%--neigh_event_send
                                                                    |
--1.77%--__neigh_event_send
|
--1.74%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.71%--queued_spin_lock_slowpath

      1.82%     0.00%  ksoftirqd/38    [kernel.vmlinux]          [k] 
ip_finish_output
             |
              --1.82%--ip_finish_output
                        |
                         --1.82%--ip_finish_output2
                                   |
                                    --1.79%--neigh_resolve_output
                                              |
--1.77%--neigh_event_send
                                                         |
--1.77%--__neigh_event_send
                                                                    |
--1.74%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.71%--queued_spin_lock_slowpath

      1.82%     0.00%  ksoftirqd/37    [kernel.vmlinux]          [k] 
ip_forward_finish
             |
              --1.82%--ip_forward_finish
                        ip_output
                        |
                         --1.82%--ip_finish_output
                                   |
                                    --1.82%--ip_finish_output2
                                              |
--1.79%--neigh_resolve_output
                                                         |
--1.76%--neigh_event_send
__neigh_event_send
                                                                    |
--1.73%--_raw_write_lock_bh
queued_write_lock
queued_write_lock_slowpath
|
--1.70%--queued_spin_lock_slowpath


W dniu 2017-08-16 o 09:42, Julian Anastasov pisze:
> 	Hello,
>
> On Tue, 15 Aug 2017, Eric Dumazet wrote:
>
>> It must be possible to add a fast path without locks.
>>
>> (say if jiffies has not changed before last state change)
> 	New day - new idea. Something like this? But it
> has bug: without checking neigh->dead under lock we don't
> have the right to access neigh->parms, it can be destroyed
> immediately by neigh_release->neigh_destroy->neigh_parms_put->
> neigh_parms_destroy->kfree. Not sure, may be kfree_rcu can help
> for this...
>
> diff --git a/include/net/neighbour.h b/include/net/neighbour.h
> index 9816df2..f52763c 100644
> --- a/include/net/neighbour.h
> +++ b/include/net/neighbour.h
> @@ -428,10 +428,10 @@ static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>   {
>   	unsigned long now = jiffies;
>   	
> -	if (neigh->used != now)
> -		neigh->used = now;
>   	if (!(neigh->nud_state&(NUD_CONNECTED|NUD_DELAY|NUD_PROBE)))
>   		return __neigh_event_send(neigh, skb);
> +	if (neigh->used != now)
> +		neigh->used = now;
>   	return 0;
>   }
>   
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 16a1a4c..52a8718 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -991,8 +991,18 @@ static void neigh_timer_handler(unsigned long arg)
>   
>   int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>   {
> -	int rc;
>   	bool immediate_probe = false;
> +	unsigned long now = jiffies;
> +	int rc;
> +
> +	if (neigh->used != now) {
> +		neigh->used = now;
> +	} else if (neigh->nud_state == NUD_INCOMPLETE &&
> +		   (!skb || neigh->arp_queue_len_bytes + skb->truesize >
> +		    NEIGH_VAR(neigh->parms, QUEUE_LEN_BYTES))) {
> +		kfree_skb(skb);
> +		return 1;
> +	}
>   
>   	write_lock_bh(&neigh->lock);
>   
> @@ -1005,7 +1015,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>   	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
>   		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
>   		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
> -			unsigned long next, now = jiffies;
> +			unsigned long next;
>   
>   			atomic_set(&neigh->probes,
>   				   NEIGH_VAR(neigh->parms, UCAST_PROBES));
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
