From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v9 00/11] Add driver bpf hook for early packet drop and
 forwarding
Date: Mon, 18 Jul 2016 10:16:37 -0700
Message-ID: <20160718171635.GB29243@gmail.com>
References: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
 <f94302fd-da02-c03d-e9ab-5292e6594b10@gmail.com>
 <20160718163827.GA29243@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33800 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbcGRRQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 13:16:43 -0400
Received: by mail-pf0-f173.google.com with SMTP id p64so33720670pfb.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 10:16:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160718163827.GA29243@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 09:38:28AM -0700, Brenden Blanco wrote:
> On Mon, Jul 18, 2016 at 04:39:38PM +0300, Tariq Toukan wrote:
> > After applying the patchset, I get no ping between two VLAN
> > interfaces (w/o activating any BPF program).
> > I'm debugging it, and will update once I find the bug.
> > 
> > Brenden, please check if you can repro the issue.
> I was able to reproduce it also. I suspect a bug in patch 8/11.
I clearly didn't test vlans, sorry for that! The fix is pretty obvious, see
below if you want to double check. I will fix up 8/11 in the next iteration.
> > 
> > Regards,
> > Tariq
> > 

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 5d8452d..9df87ca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -833,7 +831,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	bf_ok = ring->bf_enabled;
 	if (skb_vlan_tag_present(skb)) {
-		qpn_vlan.vlan_tag = skb_vlan_tag_get(skb);
+		qpn_vlan.vlan_tag = cpu_to_be16(skb_vlan_tag_get(skb));
 		vlan_proto = be16_to_cpu(skb->vlan_proto);
 		if (vlan_proto == ETH_P_8021AD)
 			qpn_vlan.ins_vlan = MLX4_WQE_CTRL_INS_SVLAN;
