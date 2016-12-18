From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: mlx4: Bug in XDP_TX + 16 rx-queues
Date: Sun, 18 Dec 2016 10:14:38 -0800
Message-ID: <20161218181438.GA44759@kafai-mba.local>
References: <20161217101803.GB8732@kafai-mba.local>
 <fd3b36fa-8365-3873-b3e5-fff47939c330@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36908 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752995AbcLRSOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 13:14:49 -0500
Content-Disposition: inline
In-Reply-To: <fd3b36fa-8365-3873-b3e5-fff47939c330@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 18, 2016 at 12:31:30PM +0200, Tariq Toukan wrote:
> Hi Martin,
>
>
> On 17/12/2016 12:18 PM, Martin KaFai Lau wrote:
> >Hi All,
> >
> >I have been debugging with XDP_TX and 16 rx-queues.
> >
> >1) When 16 rx-queues is used and an XDP prog is doing XDP_TX,
> >it seems that the packet cannot be XDP_TX out if the pkt
> >is received from some particular CPUs (/rx-queues).
> Does the rx_xdp_tx_full counter increase?
The rx_xdp_tx_full counter did not increase.  A capture of
ethtool -S eth0:

[root@kerneltest003.14.prn2 ~]# ethtool -S eth0 | egrep 'rx.*_xdp_tx.*:'
rx_xdp_tx: 1024
rx_xdp_tx_full: 0
rx0_xdp_tx: 64
rx0_xdp_tx_full: 0
rx1_xdp_tx: 64
rx1_xdp_tx_full: 0
rx2_xdp_tx: 64
rx2_xdp_tx_full: 0
rx3_xdp_tx: 64
rx3_xdp_tx_full: 0
rx4_xdp_tx: 64
rx4_xdp_tx_full: 0
rx5_xdp_tx: 64
rx5_xdp_tx_full: 0
rx6_xdp_tx: 64
rx6_xdp_tx_full: 0
rx7_xdp_tx: 64
rx7_xdp_tx_full: 0
rx8_xdp_tx: 64
rx8_xdp_tx_full: 0
rx9_xdp_tx: 63
rx9_xdp_tx_full: 0
rx10_xdp_tx: 65
rx10_xdp_tx_full: 0
rx11_xdp_tx: 64
rx11_xdp_tx_full: 0
rx12_xdp_tx: 64
rx12_xdp_tx_full: 0
rx13_xdp_tx: 64
rx13_xdp_tx_full: 0
rx14_xdp_tx: 64
rx14_xdp_tx_full: 0
rx15_xdp_tx: 64
rx15_xdp_tx_full: 0

> Does the problem repro if you turn off PFC?
>     ethtool -A <intf> rx off tx off
Turning pause off does not help.

> >
> >2) If 8 rx-queues is used, it does not have problem.
> >
> >3) The 16 rx-queues problem also went away after reverting these
> >two patches:
> >15fca2c8eb41 net/mlx4_en: Add ethtool statistics for XDP cases
> >67f8b1dcb9ee net/mlx4_en: Refactor the XDP forwarding rings scheme
> >
> >4) I can reproduce the problem by running samples/bof/xdp_ip_tunnel at
> >the receiver side.  The sender side sends out TCP packets with
> >source port ranging from 1 to 1024.  At the sender side also, do
> >a tcpdump to capture the ip-tunnel packet reflected by xdp_ip_tunnel.
> >With 8 rx-queues,  I can get all 1024 packets back.  With 16 rx-queues,
> >I can only get 512 packets back.  It is a 40 CPUs machine.
> >I also checked the rx*_xdp_tx counters (from ethtool -S eth0) to ensure
> >the xdp prog has XDP_TX-ed it out.
> So all packets were transmitted (according to rx*_xdp_tx), and only half the
> of them received on the other side?
Correct.  The XDP program 'samples/bpf/xdp_tx_iptunnel' received,
processed and sent out 1024 packets.  The rx*_xdp_tx also showed all of the
1024 packets.  However, only half of them reached to the other side (by
observing the tcpdump) when 16 rx-queues was used.

Thanks,
--Martin
