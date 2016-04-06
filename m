From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Tue, 5 Apr 2016 21:05:04 -0700
Message-ID: <20160406040503.GA18574@gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160402024710.GA59703@ast-mbp.thefacebook.com>
 <20160404165701.2a25a17a@redhat.com>
 <1459783323.6473.341.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160404185010.GD68392@ast-mbp.thefacebook.com>
 <5703C878.7050307@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	daniel@iogearbox.net, john.fastabend@gmail.com,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33130 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbcDFEFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 00:05:08 -0400
Received: by mail-pf0-f179.google.com with SMTP id 184so24722525pff.0
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 21:05:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5703C878.7050307@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 05:15:20PM +0300, Or Gerlitz wrote:
> On 4/4/2016 9:50 PM, Alexei Starovoitov wrote:
> >On Mon, Apr 04, 2016 at 08:22:03AM -0700, Eric Dumazet wrote:
> >>A single flow is able to use 40Gbit on those 40Gbit NIC, so there is not
> >>a single 10GB trunk used for a given flow.
> >>
> >>This 14Mpps thing seems to be a queue limitation on mlx4.
> >yeah, could be queueing related. Multiple cpus can send ~30Mpps of the same 64 byte packet,
> >but mlx4 can only receive 14.5Mpps. Odd.
> >
> >Or (and other mellanox guys), what is really going on inside 40G nic?
> 
> Hi Alexei,
> 
> Not that I know everything that goes inside there, and not that if I
> knew it all I could have posted that here (I heard HWs sometimes
> have IP)... but, anyway, as for your questions:
> 
> ConnectX3 40Gbs NIC can receive > 10Gbs packet-worthy (14.5M) in
> single ring and Mellanox
> 100Gbs NICs can receive > 25Gbs packet-worthy (37.5M) in single
> ring, people that use DPDK (...) even see this numbers and AFAIU we
> now attempt to see that in the kernel with XDP :)
> 
> I realize that we might have some issues in the mlx4 driver
> reporting on HW drops. Eran (cc-ed) and Co are looking on that.
Thanks!
> 
> In parallel to doing so, I would suggest you to do some experiments
> that might shed some more light, if on the TX side you do
> 
> $ ./pktgen_sample03_burst_single_flow.sh -i $DEV -d $IP -m $MAC -t 4
> 
> On the RX side,  skip RSS and force the packets that match that
> traffic pattern to go to (say) ring (==action) 0
> 
> $ ethtool -U $DEV flow-type ip4 dst-mac $MAC dst-ip $IP action 0 loc 0

I added the module parameter:
  options mlx4_core log_num_mgm_entry_size=-1
And with this I was able to reach to >20 Mpps. This is actually
regardless of the ethtool settings mentioned above.

 25.31%  ksoftirqd/0   [mlx4_en]         [k] mlx4_en_process_rx_cq
 20.18%  ksoftirqd/0   [mlx4_en]         [k] mlx4_en_alloc_frags
  8.42%  ksoftirqd/0   [mlx4_en]         [k] mlx4_en_free_frag
  5.59%  swapper       [kernel.vmlinux]  [k] poll_idle
  5.38%  ksoftirqd/0   [kernel.vmlinux]  [k] get_page_from_freelist
  3.06%  ksoftirqd/0   [mlx4_en]         [k] mlx4_call_bpf
  2.73%  ksoftirqd/0   [mlx4_en]         [k] 0x000000000001cf94
  2.72%  ksoftirqd/0   [kernel.vmlinux]  [k] free_pages_prepare
  2.19%  ksoftirqd/0   [kernel.vmlinux]  [k] percpu_array_map_lookup_elem
  2.08%  ksoftirqd/0   [kernel.vmlinux]  [k] sk_load_byte_positive_offset
  1.72%  ksoftirqd/0   [kernel.vmlinux]  [k] free_one_page
  1.59%  ksoftirqd/0   [kernel.vmlinux]  [k] bpf_map_lookup_elem
  1.30%  ksoftirqd/0   [mlx4_en]         [k] 0x000000000001cfc1
  1.07%  ksoftirqd/0   [kernel.vmlinux]  [k] __alloc_pages_nodemask
  1.00%  ksoftirqd/0   [mlx4_en]         [k] mlx4_alloc_pages.isra.23

> 
> to go back to RSS remove the rule
> 
> $ ethtool -U $DEV delete action 0
> 
> FWIW (not that I see how it helps you now), you can do HW drop on
> the RX side with ring -1
> 
> $ ethtool -U $DEV flow-type ip4 dst-mac $MAC dst-ip $IP action -1 loc 0
> 
> Or.
> 

Here also is the output from the two machines using a tool to get
ethtool delta stats at 1 second intervals:

----------- sender -----------
           tx_packets: 20,246,059
             tx_bytes: 1,214,763,540 bps    = 9,267.91 Mbps
            xmit_more: 19,463,226
        queue_stopped: 36,982
           wake_queue: 36,982
             rx_pause: 6,351
    tx_pause_duration: 124,974
  tx_pause_transition: 3,176
    tx_novlan_packets: 20,244,344
      tx_novlan_bytes: 1,295,629,440 bps    = 9,884.86 Mbps
          tx0_packets: 5,151,029
            tx0_bytes: 309,061,680 bps      = 2,357.95 Mbps
          tx1_packets: 5,094,532
            tx1_bytes: 305,671,920 bps      = 2,332.9 Mbps
          tx2_packets: 5,130,996
            tx2_bytes: 307,859,760 bps      = 2,348.78 Mbps
          tx3_packets: 5,135,513
            tx3_bytes: 308,130,780 bps      = 2,350.85 Mbps
                 UP 0: 9,389.68             Mbps = 100.00%
                 UP 0: 20,512,070           Tran/sec = 100.00%

----------- receiver -----------
           rx_packets: 20,207,929
             rx_bytes: 1,212,475,740 bps    = 9,250.45 Mbps
           rx_dropped: 236,604
    rx_pause_duration: 128,436
  rx_pause_transition: 3,258
             tx_pause: 6,516
    rx_novlan_packets: 20,208,906
      rx_novlan_bytes: 1,293,369,984 bps    = 9,867.62 Mbps
          rx0_packets: 20,444,526
            rx0_bytes: 1,226,671,560 bps    = 9,358.76 Mbps
