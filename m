From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: XDP redirect measurements, gotchas and tracepoints
Date: Mon, 21 Aug 2017 21:25:06 +0200
Message-ID: <20170821212506.1cb0d5d6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
To: "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33830 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753222AbdHUTZO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 15:25:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'be been playing with the latest XDP_REDIRECT feature, that was
accepted in net-next (for ixgbe), see merge commit[1].
 [1] https://git.kernel.org/davem/net-next/c/6093ec2dc31

At a first glance the performance looks awesome, and it is(!) when
your system is tuned for this workload. When perfectly tuned I can
show 13,096,427 pps forwarding, which is very close to 10Gbit/s
wirespeed at 64bytes (14.88Mpps).  Using only a single CPU (E5-1650 v4
@3.60GHz) core.

First gotcha(1): be aware of what you measure.  The reported numbers from
xdp_redirect_map is how many packets the XDP program received.  It
have no info whether the packet was actually transmitted out.  This
info is avail via TX counters[2] or an xdp tracepoint.

[2] ethtool_stats:
    https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl

Second gotcha(2): you cannot TX out a device, unless it also have a
xdp bpf program attached. (This is an implicit dependency, as the
driver code need to setup XDP resources before it can ndo_xdp_xmit).

Third gotcha(3): You got this far, loaded xdp on both interfaces, and
notice now that (with default setup) you can RX with 14Mpps but only
TX with 6.9Mpps (and might have 5% idle cycles).  I debugged this via
perf tracepoint event xdp:xdp_redirect, and found this was due to
overrunning the xdp TX ring-queue size.

 Thus, for this workload, we need to adjust either the TX ring-queue
size (ethtool -G) or the DMA completion interval (ethtool -C rx-usecs).
See tuning and measurements below signature.

Fourth gotcha(4): Monitoring XDP redirect performance via the
tracepoint xdp:xdp_redirect, is too slow, and affect the measurements
themselves.  I'm working on optimizing these tracepoints, and will
share results tomorrow.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer


No-tuning (default auto-tuning rx-usecs 1):
 Notice tx_packets is too low compared to RX

Show adapter(s) (ixgbe1 ixgbe2) statistics (ONLY that changed!)
Ethtool(ixgbe1  ) stat:     14720134 (     14,720,134) <= fdir_miss /sec
Ethtool(ixgbe1  ) stat:    874951205 (    874,951,205) <= rx_bytes /sec
Ethtool(ixgbe1  ) stat:    952434290 (    952,434,290) <= rx_bytes_nic /sec
Ethtool(ixgbe1  ) stat:       271737 (        271,737) <= rx_missed_errors /sec
Ethtool(ixgbe1  ) stat:        27631 (         27,631) <= rx_no_dma_resources /sec
Ethtool(ixgbe1  ) stat:     14582520 (     14,582,520) <= rx_packets /sec
Ethtool(ixgbe1  ) stat:     14610072 (     14,610,072) <= rx_pkts_nic /sec
Ethtool(ixgbe1  ) stat:    874947566 (    874,947,566) <= rx_queue_2_bytes /sec
Ethtool(ixgbe1  ) stat:     14582459 (     14,582,459) <= rx_queue_2_packets /sec
Ethtool(ixgbe2  ) stat:    417934735 (    417,934,735) <= tx_bytes /sec
Ethtool(ixgbe2  ) stat:    445801114 (    445,801,114) <= tx_bytes_nic /sec
Ethtool(ixgbe2  ) stat:      6965579 (      6,965,579) <= tx_packets /sec
Ethtool(ixgbe2  ) stat:      6965771 (      6,965,771) <= tx_pkts_nic /sec


Tuned with rx-usecs 25:
 ethtool -C ixgbe1 rx-usecs 25 ;\
 ethtool -C ixgbe2 rx-usecs 25

Show adapter(s) (ixgbe1 ixgbe2) statistics (ONLY that changed!)
Ethtool(ixgbe1  ) stat:     14123764 (     14,123,764) <= fdir_miss /sec
Ethtool(ixgbe1  ) stat:    786101618 (    786,101,618) <= rx_bytes /sec
Ethtool(ixgbe1  ) stat:    952807289 (    952,807,289) <= rx_bytes_nic /sec
Ethtool(ixgbe1  ) stat:      1047989 (      1,047,989) <= rx_missed_errors /sec
Ethtool(ixgbe1  ) stat:       737938 (        737,938) <= rx_no_dma_resources /sec
Ethtool(ixgbe1  ) stat:     13101694 (     13,101,694) <= rx_packets /sec
Ethtool(ixgbe1  ) stat:     13839620 (     13,839,620) <= rx_pkts_nic /sec
Ethtool(ixgbe1  ) stat:    786101618 (    786,101,618) <= rx_queue_2_bytes /sec
Ethtool(ixgbe1  ) stat:     13101694 (     13,101,694) <= rx_queue_2_packets /sec
Ethtool(ixgbe2  ) stat:    785785590 (    785,785,590) <= tx_bytes /sec
Ethtool(ixgbe2  ) stat:    838179358 (    838,179,358) <= tx_bytes_nic /sec
Ethtool(ixgbe2  ) stat:     13096427 (     13,096,427) <= tx_packets /sec
Ethtool(ixgbe2  ) stat:     13096519 (     13,096,519) <= tx_pkts_nic /

Tuned with adjusting ring-queue sizes:
 ethtool -G ixgbe1 rx 1024 tx 1024 ;\
 ethtool -G ixgbe2 rx 1024 tx 1024

Show adapter(s) (ixgbe1 ixgbe2) statistics (ONLY that changed!)
Ethtool(ixgbe1  ) stat:     14169252 (     14,169,252) <= fdir_miss /sec
Ethtool(ixgbe1  ) stat:    783666937 (    783,666,937) <= rx_bytes /sec
Ethtool(ixgbe1  ) stat:    957332815 (    957,332,815) <= rx_bytes_nic /sec
Ethtool(ixgbe1  ) stat:      1053052 (      1,053,052) <= rx_missed_errors /sec
Ethtool(ixgbe1  ) stat:       844113 (        844,113) <= rx_no_dma_resources /sec
Ethtool(ixgbe1  ) stat:     13061116 (     13,061,116) <= rx_packets /sec
Ethtool(ixgbe1  ) stat:     13905221 (     13,905,221) <= rx_pkts_nic /sec
Ethtool(ixgbe1  ) stat:    783666937 (    783,666,937) <= rx_queue_2_bytes /sec
Ethtool(ixgbe1  ) stat:     13061116 (     13,061,116) <= rx_queue_2_packets /sec
Ethtool(ixgbe2  ) stat:    783312119 (    783,312,119) <= tx_bytes /sec
Ethtool(ixgbe2  ) stat:    835526092 (    835,526,092) <= tx_bytes_nic /sec
Ethtool(ixgbe2  ) stat:     13055202 (     13,055,202) <= tx_packets /sec
Ethtool(ixgbe2  ) stat:     13055093 (     13,055,093) <= tx_pkts_nic /sec
