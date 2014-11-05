From: Florian Westphal <fw@strlen.de>
Subject: mlx4+vxlan offload breaks gre tunnels
Date: Wed, 5 Nov 2014 16:04:48 +0100
Message-ID: <20141105150448.GA20776@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amirv@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50670 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755907AbaKEPEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 10:04:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tl,dr: all tcp packets sent via gre tunnel have broken tcp csum if vxlan offload
is enabled with mlx4 driver.

Given following config on tx-side:
dev=enp3s0
ip addr add dev $dev 192.168.23.1/24
ip link set $dev up
ip link add mygre type gretap remote 192.168.23.2 local 192.168.23.1
ip addr add dev mygre 192.168.42.1/24
ip link set gre0 up
ip link set mygre up

and

options mlx4_core log_num_mgm_entry_size=-1 debug_level=1
port_type_array=2,2

in
/etc/modprobe.d/mlx4.conf

all tcp packets sent to destinations over the gre tunnel have bogus tcp
checksums (and are tossed on rx side when stack validates tcp checksum).

net-next head is commit 30349bdbc4da5ecf0efa25556e3caff9c9b8c5f7 .

What makes things work for me:
either

options mlx4_core 1 debug_level=1 port_type_array=2,2

(ie. no MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)

or not setting NETIF_F_IP_CSUM in enc_features:

--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2579,10 +2579,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
                dev->priv_flags |= IFF_UNICAST_FLT;
 
        if (mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
-               dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+               dev->hw_enc_features |= NETIF_F_RXCSUM |
                                        NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;

I am not sure if its right fix, but to my eyes this basically looks like
mlx4 is telling stack that it can handle tcp checksum offload within
tunnels, and that doesn't seem to be the case for all types (e.g. gre).

Could someone who understand the enc_features specifics better confirm that
above patch is correct (or provide a better/proper fix)?

Thanks,
Florian
