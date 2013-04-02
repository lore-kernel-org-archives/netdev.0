From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Tue, 02 Apr 2013 15:00:38 -0700
Message-ID: <1364940038.5113.187.camel@edumazet-glaptop>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
	 <20100125.163612.582489483209420341.anders@netinsight.net>
	 <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
	 <20100126.093439.651115405791675606.anders@netinsight.net>
	 <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
	 <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com>
	 <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk>
	 <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com>
	 <20130402211524.GE4924@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Huang, Xiong" <xiong@qca.qualcomm.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Anders =?ISO-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f181.google.com ([209.85.210.181]:55884 "EHLO
	mail-ia0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758889Ab3DBWAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 18:00:42 -0400
Received: by mail-ia0-f181.google.com with SMTP id o25so719742iad.26
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 15:00:42 -0700 (PDT)
In-Reply-To: <20130402211524.GE4924@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-02 at 23:15 +0200, Hannes Frederic Sowa wrote:

> The error vanishes as soon as I put a gso size limit of MAX_TX_BUF_LEN
> in the driver. MAX_TX_BUF_LEN seems to be arbitrary set to 0x2000. I
> can even raise it to 0x3000 and don't see any tcp retransmits. Do you
> have an advice on how to size this value (e.g. should we switch to the
> windows values)?

This looks like an overflow error...

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 7e0a822..7965f89 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1569,18 +1569,17 @@ static u16 atl1e_cal_tdp_req(const struct sk_buff *skb)
 {
 	int i = 0;
 	u16 tpd_req = 1;
-	u16 fg_size = 0;
-	u16 proto_hdr_len = 0;
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		fg_size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+		u32 fg_size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+
 		tpd_req += ((fg_size + MAX_TX_BUF_LEN - 1) >> MAX_TX_BUF_SHIFT);
 	}
 
 	if (skb_is_gso(skb)) {
 		if (skb->protocol == htons(ETH_P_IP) ||
 		   (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6)) {
-			proto_hdr_len = skb_transport_offset(skb) +
+			u32 proto_hdr_len = skb_transport_offset(skb) +
 					tcp_hdrlen(skb);
 			if (proto_hdr_len < skb_headlen(skb)) {
 				tpd_req += ((skb_headlen(skb) - proto_hdr_len +
