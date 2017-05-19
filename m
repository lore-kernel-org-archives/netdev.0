From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH 4/5] net: new XDP feature for reading HW
 rxhash from drivers
Date: Fri, 19 May 2017 13:47:45 +0200
Message-ID: <20170519134745.66eea15c@redhat.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512210827.14733.13997041998775151648.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, brouer@redhat.com,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35692 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751159AbdESLrw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 07:47:52 -0400
In-Reply-To: <149512210827.14733.13997041998775151648.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 May 2017 17:41:48 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Introducing a new XDP feature and associated bpf helper bpf_xdp_rxhash.
> 
> The rxhash and type allow filtering on packets without touching
> packet memory.  The performance difference on my system with a
> 100 Gbit/s mlx5 NIC is 12Mpps to 19Mpps.

The XDP/bpf program I use (called xdp_rxhash) for testing this feature
is available via my github repo here:

 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_rxhash_kern.c
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/samples/bpf/xdp_rxhash_user.c

The cmdline output looks like:

$ sudo ./xdp_rxhash --dev mlx5p2 --sec 2 --notouch

xdp-action     pps        pps-human-readable mem      
XDP_ABORTED    19694682   19,694,682         2.000205  no_touch
XDP_DROP       0          0                  2.000205  no_touch
XDP_PASS       10         10                 2.000205  no_touch
XDP_TX         0          0                  2.000205  no_touch
rx_total       19694701   19,694,701         2.000205  no_touch

hash_type:L3   pps        pps-human-readable sample-period
Unknown        0          0                  2.000205
IPv4           19694725   19,694,725         2.000205
IPv6           0          0                  2.000205

hash_type:L4   pps        pps-human-readable sample-period
Unknown        10         10                 2.000205
TCP            0          0                  2.000205
UDP            19694697   19,694,697         2.000205

^CInterrupted: Removing XDP program on ifindex:5 device:mlx5p2


The 10 pps XDP_PASS is a ping command I rand at the same time. Notice
how these ping-ICMP packets were categorized as L4=Unknown and L3=IPv4.
The L4 categorization is usually UDP or TCP, but looking at driver-code
it seems some HW support detecting other L4 types, like ICMP, SCTP, etc.


$ sudo taskset -c 4 ping -i 0.1 -c 10000 198.18.100.1 -c 100 -q
PING 198.18.100.1 (198.18.100.1) 56(84) bytes of data.

--- 198.18.100.1 ping statistics ---
100 packets transmitted, 100 received, 0% packet loss, time 10294ms
rtt min/avg/max/mdev = 0.010/0.071/0.113/0.043 ms


p.s. xdp-newbies can via this commit find the links back to the netdev
kernel RFC patches/mails:
 https://github.com/netoptimizer/prototype-kernel/commit/9647e1b563970

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
