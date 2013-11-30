From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Sat, 30 Nov 2013 19:59:02 +0800
Message-ID: <5299D306.7070701@gmail.com>
References: <528AEFB7.4060301@gmail.com>  <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>  <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>  <52957ADA.2080704@gmail.com> (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	rkuo <rkuo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:59949 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab3K3L67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 06:58:59 -0500
In-Reply-To: <1385739487.8656.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2013 11:38 PM, Johannes Berg wrote:
> 
>> +++ b/net/mac80211/tx.c
>> @@ -1814,8 +1814,9 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>>  			break;
>>  		/* fall through */
>>  	case NL80211_IFTYPE_AP:
>> -		if (sdata->vif.type == NL80211_IFTYPE_AP)
>> -			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
>> +		if (sdata->vif.type != NL80211_IFTYPE_AP)
>> +			goto fail_rcu;
>> +		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
> 
> This change is completely wrong.
> 

Oh, it is.

Hmm... for me, this work flow still can be implemented with a little
clearer way (at least it will avoid related warning):

-------------------------diff begin------------------------------

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index c558b24..7076128 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1810,14 +1810,14 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		if (!chanctx_conf)
 			goto fail_rcu;
 		band = chanctx_conf->def.chan->band;
-		if (sta)
-			break;
-		/* fall through */
+		if (!sta)
+			goto try_next;
+		break;
 	case NL80211_IFTYPE_AP:
-		if (sdata->vif.type == NL80211_IFTYPE_AP)
-			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
+		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
 		if (!chanctx_conf)
 			goto fail_rcu;
+try_next:
 		fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
 		/* DA BSSID SA */
 		memcpy(hdr.addr1, skb->data, ETH_ALEN);



-------------------------diff end--------------------------------


Thanks.
-- 
Chen Gang
