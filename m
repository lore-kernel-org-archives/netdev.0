From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: +157.8% netperf throughput by "ipv4: raise IP_MAX_MTU to
 theoretical limit"
Date: Thu, 26 Sep 2013 09:35:58 +0800
Message-ID: <20130926013558.GA10050@localhost>
References: <20130926012144.GA9931@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Willem de Bruijn <willemb@google.com>, lkp@01.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130926012144.GA9931@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 26, 2013 at 09:21:44AM +0800, Fengguang Wu wrote:
> Hi Eric,
> 
> We are glad to find that your below commit brings large increase in
> lo netperf throughput:
> 
>     35596b2796713c6a9dc0      734d2725db879f3f6fcd  
> ------------------------  ------------------------  
>                   761.80      +534.6%      4834.60  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
>                   168.10     +1317.4%      2382.70  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
>                   169.60      +979.4%      1830.70  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
>                  2154.20      +135.7%      5077.50  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
>                  3559.00        -3.5%      3435.20  lkp-t410/micro/netperf/120s-200%-TCP_STREAM
>                  6812.70      +157.8%     17560.70  TOTAL netperf.Throughput_Mbps
> 
> The side effects are some increased/decreased lock contentions:

This direct view may be more clear. Before patch:

                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquis
itions   holdtime-min   holdtime-max holdtime-total
-------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------

                 &(&nf->lru_lock)->rlock:      19017744       19034681           0.15        5884.35  5772892473.69       20428335       20
475976           0.10        1109.59    77448429.38
                 -----------------------
                 &(&nf->lru_lock)->rlock        4905538          [<ffffffff819227b9>] ip_defrag+0xa4f/0xbd3
                 &(&nf->lru_lock)->rlock        5695105          [<ffffffff8195bd6f>] inet_frag_find+0x2c7/0x30d
                 &(&nf->lru_lock)->rlock        5629414          [<ffffffff8195be74>] inet_frag_kill+0xbf/0x117
                 &(&nf->lru_lock)->rlock        2804624          [<ffffffff8195bf29>] inet_frag_evictor+0x5d/0x103
                 -----------------------
                 &(&nf->lru_lock)->rlock        6172104          [<ffffffff8195bd6f>] inet_frag_find+0x2c7/0x30d
                 &(&nf->lru_lock)->rlock        5348696          [<ffffffff8195be74>] inet_frag_kill+0xbf/0x117
                 &(&nf->lru_lock)->rlock        4421308          [<ffffffff819227b9>] ip_defrag+0xa4f/0xbd3
                 &(&nf->lru_lock)->rlock        3092573          [<ffffffff8195bf29>] inet_frag_evictor+0x5d/0x103

...............................................................................................................................................................................................

                      &(&q->lock)->rlock:       2322575        2323896           0.22        5802.58   934469091.38        3041941       13000848           0.10        5902.91  2811690638.18
                      ------------------
                      &(&q->lock)->rlock        2163449          [<ffffffff8195bf7e>] inet_frag_evictor+0xb2/0x103
                      &(&q->lock)->rlock         160447          [<ffffffff81921e91>] ip_defrag+0x127/0xbd3
                      ------------------
                      &(&q->lock)->rlock        2165896          [<ffffffff81921e91>] ip_defrag+0x127/0xbd3
                      &(&q->lock)->rlock         158000          [<ffffffff8195bf7e>] inet_frag_evictor+0xb2/0x103

...............................................................................................................................................................................................

                   &(&zone->lock)->rlock:       1845042        1851805           0.18        4917.52    19475590.18        9003807       10134386           0.13        3747.70     8347088.06
                   ---------------------
                   &(&zone->lock)->rlock         866751          [<ffffffff8116fbbc>] __free_pages_ok.part.47+0x94/0x2a1
                   &(&zone->lock)->rlock         984597          [<ffffffff8116f856>] get_page_from_freelist+0x4a3/0x6e8
                   &(&zone->lock)->rlock            112          [<ffffffff8116fe3b>] free_pcppages_bulk+0x35/0x31a
                   &(&zone->lock)->rlock            116          [<ffffffff8116f72c>] get_page_from_freelist+0x379/0x6e8
                   ---------------------
                   &(&zone->lock)->rlock         918190          [<ffffffff8116fbbc>] __free_pages_ok.part.47+0x94/0x2a1
                   &(&zone->lock)->rlock            722          [<ffffffff8116f72c>] get_page_from_freelist+0x379/0x6e8
                   &(&zone->lock)->rlock            861          [<ffffffff8116fe3b>] free_pcppages_bulk+0x35/0x31a
                   &(&zone->lock)->rlock         922607          [<ffffffff8116f856>] get_page_from_freelist+0x4a3/0x6e8


After patch, top contented locks become:

                   &(&zone->lock)->rlock:      58469530       58470181           0.16        4838.84   238618042.87      107374530      107408478           0.13        3610.05    73617127.93
                   ---------------------
                   &(&zone->lock)->rlock       29783268          [<ffffffff8116f856>] get_page_from_freelist+0x4a3/0x6e8
                   &(&zone->lock)->rlock            837          [<ffffffff8116f72c>] get_page_from_freelist+0x379/0x6e8
                   &(&zone->lock)->rlock           1105          [<ffffffff8116fe3b>] free_pcppages_bulk+0x35/0x31a
                   &(&zone->lock)->rlock       28684627          [<ffffffff8116fbbc>] __free_pages_ok.part.47+0x94/0x2a1
                   ---------------------
                   &(&zone->lock)->rlock          11356          [<ffffffff8116fe3b>] free_pcppages_bulk+0x35/0x31a
                   &(&zone->lock)->rlock           6741          [<ffffffff8116f72c>] get_page_from_freelist+0x379/0x6e8
                   &(&zone->lock)->rlock       28880589          [<ffffffff8116f856>] get_page_from_freelist+0x4a3/0x6e8
                   &(&zone->lock)->rlock       29558251          [<ffffffff8116fbbc>] __free_pages_ok.part.47+0x94/0x2a1

...............................................................................................................................................................................................

                           slock-AF_INET:        507780         508036           0.20        1167.78     2564695.48       11115246      106594271           0.12        1196.01   989718694.82
                           -------------
                           slock-AF_INET         434691          [<ffffffff818ed738>] lock_sock_fast+0x2f/0x84
                           slock-AF_INET          73294          [<ffffffff819482dc>] udp_queue_rcv_skb+0x1ba/0x3aa
                           slock-AF_INET             51          [<ffffffff818ed6b5>] lock_sock_nested+0x34/0x88
                           -------------
                           slock-AF_INET         434615          [<ffffffff819482dc>] udp_queue_rcv_skb+0x1ba/0x3aa
                           slock-AF_INET          73370          [<ffffffff818ed738>] lock_sock_fast+0x2f/0x84
                           slock-AF_INET             51          [<ffffffff8193fae1>] tcp_v4_rcv+0x390/0x978

..............................................................................................................................................................................................

                               &rq->lock:        286309         286456           0.21         294.85     1768779.90        5887506      244517912           0.09        1080.71   315600465.71
                               ---------
                               &rq->lock          92057          [<ffffffff81a0aa65>] __schedule+0x103/0x852
                               &rq->lock          18386          [<ffffffff810ecc02>] try_to_wake_up+0x95/0x26c
                               &rq->lock            730          [<ffffffff810f13fb>] update_blocked_averages+0x30/0x47f
                               &rq->lock            304          [<ffffffff81a0af43>] __schedule+0x5e1/0x852
                               ---------
                               &rq->lock         107807          [<ffffffff810ecd7b>] try_to_wake_up+0x20e/0x26c
                               &rq->lock         144391          [<ffffffff81a0aa65>] __schedule+0x103/0x852
                               &rq->lock            924          [<ffffffff810ecc02>] try_to_wake_up+0x95/0x26c
                               &rq->lock             29          [<ffffffff810e9090>] task_rq_lock+0x4b/0x85

Thanks,
Fengguang
