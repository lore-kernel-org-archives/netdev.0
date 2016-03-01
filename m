From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: Support offload cls_flower with
 drop action
Date: Tue, 1 Mar 2016 18:50:57 +0200
Message-ID: <56d5c778.06b01c0a.3dc1a.0045@mx.google.com>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-8-git-send-email-amir@vadai.me>
 <20160301145548.GD2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32922 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbcCAQqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 11:46:51 -0500
Received: by mail-wm0-f67.google.com with SMTP id n186so5098778wmn.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 08:46:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160301145548.GD2098@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2016 at 03:55:48PM +0100, Jiri Pirko wrote:
> Tue, Mar 01, 2016 at 03:24:49PM CET, amir@vadai.me wrote:
> >Parse tc_cls_flower_offload into device specific commands and program
> >the hardware to classify and act accordingly.
> >
> >For example, to drop ICMP (ip_proto 1) packets from specific smac, dmac,
> >src_ip, src_ip, arriving to interface ens9:
> >
> > # tc qdisc add dev ens9 ingress
> >
> > # tc filter add dev ens9 protocol ip parent ffff: \
> >     flower ip_proto 1 \
> >     dst_mac 7c:fe:90:69:81:62 src_mac 7c:fe:90:69:81:56 \
> >     dst_ip 11.11.11.11 src_ip 11.11.11.12 indev ens9 \
> >     action drop
> >
> >Signed-off-by: Amir Vadai <amir@vadai.me>
> >Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> >---
> > drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   9 +
> > drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 287 ++++++++++++++++++++++
> > drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |   5 +
> > 3 files changed, 301 insertions(+)
> >
> >diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> >index cb02b4c..1d1da94 100644
> >--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> >+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> >@@ -1889,6 +1889,15 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
> > 		goto mqprio;
> > 
> > 	switch (tc->type) {
> >+	case TC_SETUP_CLSFLOWER:
> >+		switch (tc->cls_flower->command) {
> >+		case TC_CLSFLOWER_REPLACE:
> >+			return mlx5e_configure_flower(priv, proto, tc->cls_flower);
> >+		case TC_CLSFLOWER_DESTROY:
> >+			return mlx5e_delete_flower(priv, tc->cls_flower);
> >+		default:
> >+			return -EINVAL;
> 
> No need to default case here is you change "command" to enum as I
> suggested it the reply to patch 1.
ack
