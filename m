From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Wed, 20 Feb 2013 07:11:04 -0800
Message-ID: <1361373064.19353.180.camel@edumazet-glaptop>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 (sfid-20130219_061917_530878_1ED7A14C) <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <1361290909.19353.140.camel@edumazet-glaptop>
	 (sfid-20130219_172155_748777_C3ED0F5E) <1361351538.8629.3.camel@jlt4.sipsolutions.net>
	 (sfid-20130220_101252_930264_DBD3955C) <1361351703.8629.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc@merlins.org>, David Miller <davem@davemloft.net>,
	Larry.Finger@lwfinger.net, bhutchings@solarflare.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:33721 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933198Ab3BTPLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 10:11:07 -0500
In-Reply-To: <1361351703.8629.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-20 at 10:15 +0100, Johannes Berg wrote:

> OTOH, this affects the protocol, and when you really can't allocate any
> order-1 pages you pointed out yourself that many other things also won't
> work, so I'm not really sure it makes a big difference if we change the
> driver?

It will make a huge difference, even on non pressure mode, as TCP
receive window will grow twice faster.

Unless wifi speed reaches 10Gbps, following patch should do the trick


diff --git a/drivers/net/wireless/iwlwifi/dvm/rx.c b/drivers/net/wireless/iwlwifi/dvm/rx.c
index a4eed20..77a3ee3 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rx.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rx.c
@@ -750,7 +750,12 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 	/* Dont use dev_alloc_skb(), we'll have enough headroom once
 	 * ieee80211_hdr pulled.
 	 */
-	skb = alloc_skb(128, GFP_ATOMIC);
+	fraglen = 128;
+	/* if we use order-1 pages, copy to get better TCP performance */
+	if (rxb->truesize > PAGE_SIZE)
+		fraglen = max_t(unsigned, fraglen, len);
+
+	skb = alloc_skb(fraglen, GFP_ATOMIC);
 	if (!skb) {
 		IWL_ERR(priv, "alloc_skb failed\n");
 		return;
