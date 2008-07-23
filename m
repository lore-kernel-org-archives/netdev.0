From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 17:19:46 +0200
Message-ID: <48874C12.10606@trash.net>
References: <bug-11144-10286@http.bugzilla.kernel.org/>	<20080722034850.dbbc5566.akpm@linux-foundation.org>	<4886E49D.6010700@tvcablenet.be> <20080723010522.389a948f.akpm@linux-foundation.org> <4886F727.6010301@tvcablenet.be> <48870425.50908@trash.net> <48871632.3010205@tvcablenet.be> <4887169B.6090102@trash.net> <488725D5.8030900@tvcablenet.be> <488727B3.7040007@trash.net> <48872968.9000103@trash.net> <488746DF.1050501@tvcablenet.be> <48874BD8.60600@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060809030809080308010209"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: =?ISO-8859-15?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc@tvcablenet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37687 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbYGWPTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 11:19:49 -0400
In-Reply-To: <48874BD8.60600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060809030809080308010209
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit

Patrick McHardy wrote:
> François Valenduc wrote:
>> I did the bisection again, this time on the whole tree and the first 
>> bad commit is again the one I mentioned previously:
>>
>> 175f9c1bba9b825d22b142d183c9e175488b260c is first bad commit
>> commit 175f9c1bba9b825d22b142d183c9e175488b260c
>> Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
>> Date:   Sun Jul 20 00:08:47 2008 -0700
>>
>>    net_sched: Add size table for qdiscs
>>
>>    Add size table functions for qdiscs and calculate packet size in
>>    qdisc_enqueue().
>>
>>    Based on patch by Patrick McHardy
>>     http://marc.info/?l=linux-netdev&m=115201979221729&w=2
>>
>> This time, I didn't encounter kernels which didn't compile. So, I 
>> didn't use git-reset or git-bisect skip.
> 
> 
> I think I know whats happening (Jussi CCed). That commit introduced
> a qdisc_skb_cb, which conflicts with the mac80211 usage of skb->cb.
> mac80211 seems to expect the CB to survive the qdisc layer, which
> is wrong. One possibility to fix this (or just test my theory)
> would be to make sure they don't clash by adding the struct
> ieee80211_tx_info to qdisc_skb_cb->data. Something like this patch.
> 

 > +#include <net/sched_generic.h>

That should be sch_generic.h.


--------------060809030809080308010209
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 4dd3d93..e19815e 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -19,6 +19,7 @@
 #include <linux/wireless.h>
 #include <linux/device.h>
 #include <linux/ieee80211.h>
+#include <net/sch_generic.h>
 #include <net/wireless.h>
 #include <net/cfg80211.h>
 
@@ -343,7 +344,10 @@ struct ieee80211_tx_info {
 
 static inline struct ieee80211_tx_info *IEEE80211_SKB_CB(struct sk_buff *skb)
 {
-	return (struct ieee80211_tx_info *)skb->cb;
+	BUILD_BUG_ON(sizeof(skb->cb) <
+		     sizeof(struct qdisc_skb_cb) +
+		     sizeof(struct ieee80211_tx_info));
+	return (struct ieee80211_tx_info *)qdisc_skb_cb(skb)->data;
 }
 
 

--------------060809030809080308010209--
