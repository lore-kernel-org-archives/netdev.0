From: Martin KaFai Lau <kafai@fb.com>
Subject: mlx4: Bug in XDP_TX + 16 rx-queues
Date: Sat, 17 Dec 2016 02:18:03 -0800
Message-ID: <20161217101803.GB8732@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45073 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755218AbcLQKSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 05:18:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have been debugging with XDP_TX and 16 rx-queues.

1) When 16 rx-queues is used and an XDP prog is doing XDP_TX,
it seems that the packet cannot be XDP_TX out if the pkt
is received from some particular CPUs (/rx-queues).

2) If 8 rx-queues is used, it does not have problem.

3) The 16 rx-queues problem also went away after reverting these
two patches:
15fca2c8eb41 net/mlx4_en: Add ethtool statistics for XDP cases
67f8b1dcb9ee net/mlx4_en: Refactor the XDP forwarding rings scheme

4) I can reproduce the problem by running samples/bof/xdp_ip_tunnel at
the receiver side.  The sender side sends out TCP packets with
source port ranging from 1 to 1024.  At the sender side also, do
a tcpdump to capture the ip-tunnel packet reflected by xdp_ip_tunnel.
With 8 rx-queues,  I can get all 1024 packets back.  With 16 rx-queues,
I can only get 512 packets back.  It is a 40 CPUs machine.
I also checked the rx*_xdp_tx counters (from ethtool -S eth0) to ensure
the xdp prog has XDP_TX-ed it out.

Not saying that 67f8b1dcb9ee is 100% the cause because there are other
changes since then.  It is merely a brain dump on what I have already
tried.

Tariq/Saeed, any thoughts?  I can easily test some patches in
my setup.

Thanks,
--Martin
