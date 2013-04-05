From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Fri, 05 Apr 2013 08:28:22 -0700
Message-ID: <1365175702.3405.2.camel@edumazet-glaptop>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:46415 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762185Ab3DEP21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 11:28:27 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so2073477pbc.17
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 08:28:26 -0700 (PDT)
In-Reply-To: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-05 at 15:20 +0200, Erik Hugne wrote:
> I'm adding GRO support for the TIPC protocol and
> tried to test it on a pair of HP G7 blades with 
> Emulex Corporation OneConnect 10Gb NIC (be3) (rev 01) NICs.
> 
> However, my GRO callback is never invoked on this setup, and 
> i suspect the be2net driver is to blame.
> I had a brief look at the driver, first suspecting that the
> do_gro check only passed for inet protocols (tcpf must be set 
> in the be_rx_compl_info struct).
> However, removing this check did not change the behavior.

Try following instead :

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 536afa2..1b9e467 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1355,7 +1355,7 @@ static void skb_fill_rx_data(struct be_rx_obj *rxo, struct sk_buff *skb,
 }
 
 /* Process the RX completion indicated by rxcp when GRO is disabled */
-static void be_rx_compl_process(struct be_rx_obj *rxo,
+static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
 				struct be_rx_compl_info *rxcp)
 {
 	struct be_adapter *adapter = rxo->adapter;
@@ -1385,7 +1385,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo,
 	if (rxcp->vlanf)
 		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
 
-	netif_receive_skb(skb);
+	napi_gro_receive(&napi, skb);
 }
 
 /* Process the RX completion indicated by rxcp when GRO is enabled */
@@ -2113,7 +2113,7 @@ static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
 		if (do_gro(rxcp))
 			be_rx_compl_process_gro(rxo, napi, rxcp);
 		else
-			be_rx_compl_process(rxo, rxcp);
+			be_rx_compl_process(rxo, napi, rxcp);
 loop_continue:
 		be_rx_stats_update(rxo, rxcp);
 	}
