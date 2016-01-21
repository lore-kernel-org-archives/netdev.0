From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Tools for sampling ethtool --statistics
Date: Thu, 21 Jan 2016 11:35:42 +0100
Message-ID: <20160121113542.2d2e8e23@redhat.com>
References: <20160120101311.5266cac6@redhat.com>
	<CAJ3xEMiNDU20FVG_9_r11wqMmAFiERBTYcsFmjwaSfbZ25NOiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brouer@redhat.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759093AbcAUKfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 05:35:46 -0500
In-Reply-To: <CAJ3xEMiNDU20FVG_9_r11wqMmAFiERBTYcsFmjwaSfbZ25NOiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jan 2016 00:34:16 +0200
Or Gerlitz <gerlitz.or@gmail.com> wrote:

> On Wed, Jan 20, 2016 at 11:13 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > Hi All,
> >
> > I wrote a small tool[1] to extract ethtool --statistics|-S, sample and
> > present it in a more human readable manor.  You might also find this
> > useful...
> >
> > https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl
> >
> > The reason I wrote this script is that the mlx5 driver (Mellanox 100 Gbit/s)
> > does not report correct ifconfig stats.  It reports the HW counters,
> > not what the network stack is able to handle.  I/we obviously need the
> > stack number when working on improving the stack.  
> 
> correct && we should be fixing that ... 

Yes, this need to be fixed. I'm currently playing around in that code,
and will fix it if you don't ;-)... (although, to be realistic, I will
not have time until after netdev 1.1. to submit upstream patches).

> still it's worthwhile to be
> able and see per ring stats, specially when you're dealing/optimizing
> in multi-stream env.

It is actually also useful for detecting other situation, which are
visible via obscure stats that we usually don't look at. I've been
postponing writing this script for years, and in the end it only took
me 2 hours to write (and 1 hour fixups the next day).


> > Output examples:
> >
> > pktgen (1 core) sending ~20Mpps
> >
> > Show adapter mlx5p2 statistics (ONLY that changed!)
> > Ethtool(mlx5p2) stat:     19431694 (     19,431,694) <= frames_rx /sec
> > Ethtool(mlx5p2) stat:   1243722215 (  1,243,722,215) <= in_octets /sec
> > Ethtool(mlx5p2) stat:     19433161 (     19,433,161) <= in_ucast_pkts /sec
> > Ethtool(mlx5p2) stat:   1243746943 (  1,243,746,943) <= octets /sec
> > Ethtool(mlx5p2) stat:   1243629263 (  1,243,629,263) <= octets_received /sec
> > Ethtool(mlx5p2) stat:     19433654 (     19,433,654) <= p64octets /sec
> > Ethtool(mlx5p2) stat:     19433556 (     19,433,556) <= pkts /sec
> > Ethtool(mlx5p2) stat:      1815546 (      1,815,546) <= rx3_packets /sec
> > Ethtool(mlx5p2) stat:   1165854821 (  1,165,854,821) <= rx_bytes /sec
> > Ethtool(mlx5p2) stat:     19430906 (     19,430,906) <= rx_csum_good /sec
> > Ethtool(mlx5p2) stat:     19430906 (     19,430,906) <= rx_packets /sec
> > Ethtool(mlx5p2) stat:   1165854821 (  1,165,854,821) <= rx_unicast_bytes /sec
> > Ethtool(mlx5p2) stat:     19430906 (     19,430,906) <= rx_unicast_packets /sec  
> 
> was expecting to see tx_XXX stats, something wrong here?

This was a RX only test (with another machine generating packets with
pktgen).

TX_xxx stats does show up when I run netperf.  And the single netperf
results are around 50Gbit/s (if IRQ RX process runs on another CPU that
netperf process, I guess this was Eric point earlier), if IRQ and
netperf runs on same CPU, perf drops to 23-26Gbit/s.  Running multiple
(super_)netperf the result max out at 64Gbit/s.


> > pktgen (4 cores) sending ~50Mpps  
> [...]
> 
> The 20M for single ring/core and 50M pps for four streams are really
> cool results. 

Yes, these 100G NICs are definitely the fastest HW I currently have!
Thanks BTW ;-)

> Do the scripts to get ~such results exist in your
> network testing github repo? last time I looked I wasn't sure if  the
> multi-stream case is supported.
> 
> Could you post the two commands you used for these results along with
> minimal spec of the system (CPU type/freq, special .config directives,
> anything else)?

Two mlx5 100G NICs
 - firmware-version: 12.12.1240
 - Description: ConnectX-4 VPI adapter card; EDR IB (100Gb/s)
                and 100GbE; dual-port QSFP28; PCIe3.0 x16; ROHS R6
  - PSID: MT_2190110032

The sender/generator machine:
 - CPU: i7-4790K CPU @ 4.00GHz

The receiver machine:
 - CPU: i7-6700K CPU @ 4.00GHz ("skylake")

Pktgen command [1] or [2]:
 ./pktgen_sample03_burst_single_flow.sh -i mlx5p2 -d 192.168.100.66 -m e4:1d:2d:af:60:65 -c1 -t 4

For sending multi-threads use parameter "-t X".


> > Show adapter mlx5p2 statistics (ONLY that changed!)
> > Ethtool(mlx5p2) stat:     25710443 (     25,710,443) <= drop_events /sec
> > Ethtool(mlx5p2) stat:     51861645 (     51,861,645) <= frames_rx /sec
> > Ethtool(mlx5p2) stat:     25710502 (     25,710,502) <= in_discards /sec

Notice I had to pressure it more that 26 Mpps before in_discards and
drop_events show up.

> > Ethtool(mlx5p2) stat:   3319134161 (  3,319,134,161) <= in_octets /sec
> > Ethtool(mlx5p2) stat:     26150970 (     26,150,970) <= in_ucast_pkts /sec
> > Ethtool(mlx5p2) stat:   3319128053 (  3,319,128,053) <= octets /sec
> > Ethtool(mlx5p2) stat:   3319145319 (  3,319,145,319) <= octets_received /sec
> > Ethtool(mlx5p2) stat:     51861369 (     51,861,369) <= p64octets /sec
> > Ethtool(mlx5p2) stat:     51861375 (     51,861,375) <= pkts /sec
> > Ethtool(mlx5p2) stat:      1383475 (      1,383,475) <= rx3_packets /sec

The rx3_packets were reduced a little (1.8Mpps -> 1.4Mpps), once
in_discards starts... 

> > Ethtool(mlx5p2) stat:   1569059171 (  1,569,059,171) <= rx_bytes /sec
> > Ethtool(mlx5p2) stat:     26150988 (     26,150,988) <= rx_csum_good /sec
> > Ethtool(mlx5p2) stat:     26150988 (     26,150,988) <= rx_packets /sec
> > Ethtool(mlx5p2) stat:   1569059171 (  1,569,059,171) <= rx_unicast_bytes /sec
> > Ethtool(mlx5p2) stat:     26150988 (     26,150,988) <= rx_unicast_packets /sec  


[1] https://github.com/netoptimizer/network-testing/tree/master/pktgen
[2] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/samples/pktgen
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
