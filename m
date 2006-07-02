From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Belkin F5D7001de locks up my Athlon64 system
Date: Sun, 2 Jul 2006 20:28:39 +0200
Message-ID: <200607022028.39852.mb@bu3sch.de>
References: <20060701092313.225240@gmx.net> <200607011828.37874.mb@bu3sch.de> <20060702113205.16230@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com, Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:3814
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S964877AbWGBS2K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 14:28:10 -0400
To: "Johann Uhrmann" <Johann.Uhrmann@gmx.de>
In-Reply-To: <20060702113205.16230@gmx.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 02 July 2006 13:32, Johann Uhrmann wrote:
> here is another log from the 2.6.17-mm4 kernel. This oops was the only
> one since reboot:
> 
> bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1490:bc)[   87.484118] bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1490:bcm43xx_find_lopair()
> [   87.559086] bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1490:bcm43xx_find_lopair()
> [   87.641350] bcm43xx: ASSERTION FAILED (radio_attenuation < 10) at: drivers/net/wireless/bcm43xx/bcm43xx_phy.c:1490:bcm43xx_find_lopair()
> [ ok ]
>  * Configuring network interfaces...       [   88.126654] BUG: spinlock recursion on CPU#0, sh/9441
> [   88.161695]  lock: ffff81003acd93f0, .magic: dead4ead, .owner: sh/9441, .owner_cpu: 0
> [   88.208502]
> [   88.208503] Call Trace:
> [   88.232081]  [<ffffffff8026fbde>] show_trace+0xae/0x280
> [   88.263329]  [<ffffffff8026fff5>] dump_stack+0x15/0x20
> [   88.294085]  [<ffffffff80213db4>] spin_bug+0xb4/0xd0
> [   88.324030]  [<ffffffff80207651>] _raw_spin_lock+0x51/0x180
> [   88.357591]  [<ffffffff8026bd99>] _spin_lock_irqsave+0x39/0x50
> [   88.392575]  [<ffffffff885a86a5>] :bcm43xx:bcm43xx_ieee80211_hard_start_xmit+0x35/0xc0
> [   88.439931]  [<ffffffff80439d1b>] ieee80211_tx_frame+0x23b/0x2b0
> [   88.476307]  [<ffffffff80441764>] ieee80211softmac_send_mgt_frame+0x3f4/0x420
> [   88.519427]  [<ffffffff8044204f>] ieee80211softmac_auth_resp+0x30f/0x4c0
> [   88.559954]  [<ffffffff8043e3b9>] ieee80211_rx_mgt+0x759/0x830
> [   88.595291]  [<ffffffff885c00e5>] :bcm43xx:bcm43xx_rx+0x7f5/0x870
> [   88.631757]  [<ffffffff885c3601>] :bcm43xx:bcm43xx_dma_rx+0x581/0x680
> [   88.670306]  [<ffffffff885aba35>] :bcm43xx:bcm43xx_interrupt_tasklet+0x765/0xa80
> [   88.714562]  [<ffffffff80290e33>] tasklet_action+0x73/0xd0
> [   88.747394]  [<ffffffff802127c7>] __do_softirq+0x67/0xe0
> [   88.779187]  [<ffffffff80266c36>] call_softirq+0x1e/0x28

The following patch is supposed to fix this.
I did only compile-test it. Please runtime-test it.

Thanks.

--

Softmac Shared Key Auth:
Fix recursive call into the driver by doing schedule_work.
recursive calls may result in a driver lock recursion.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_auth.c	2006-07-02 19:37:26.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c	2006-07-02 20:19:12.000000000 +0200
@@ -116,6 +116,16 @@
 	kfree(auth);
 }
 
+/* Sends an auth challenge. */
+static void
+ieee80211softmac_auth_challenge(void *_aq)
+{
+	struct ieee80211softmac_auth_queue_item *aq = _aq;
+
+	/* Send our response */
+	ieee80211softmac_send_mgt_frame(aq->mac, aq->net, IEEE80211_STYPE_AUTH, aq->state);
+}
+
 /* Handle the auth response from the AP
  * This should be registered with ieee80211 as handle_auth 
  */
@@ -197,24 +207,25 @@
 		case IEEE80211SOFTMAC_AUTH_SHARED_CHALLENGE:
 			/* Check to make sure we have a challenge IE */
 			data = (u8 *)auth->info_element;
-			if(*data++ != MFIE_TYPE_CHALLENGE){
+			if (*data++ != MFIE_TYPE_CHALLENGE) {
 				printkl(KERN_NOTICE PFX "Shared Key Authentication failed due to a missing challenge.\n");
 				break;	
 			}
 			/* Save the challenge */
 			spin_lock_irqsave(&mac->lock, flags);
 			net->challenge_len = *data++; 	
-			if(net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
+			if (net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
 				net->challenge_len = WLAN_AUTH_CHALLENGE_LEN;
-			if(net->challenge != NULL)
+			if (net->challenge != NULL)
 				kfree(net->challenge);
 			net->challenge = kmalloc(net->challenge_len, GFP_ATOMIC);
 			memcpy(net->challenge, data, net->challenge_len);
 			aq->state = IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE; 
-			spin_unlock_irqrestore(&mac->lock, flags);
 
-			/* Send our response */
-			ieee80211softmac_send_mgt_frame(mac, aq->net, IEEE80211_STYPE_AUTH, aq->state);
+			cancel_delayed_work(&aq->work);
+			INIT_WORK(&aq->work, &ieee80211softmac_auth_challenge, (void *)aq);
+			schedule_work(&aq->work);
+			spin_unlock_irqrestore(&mac->lock, flags);
 			return 0;
 		case IEEE80211SOFTMAC_AUTH_SHARED_PASS:
 			kfree(net->challenge);


-- 
Greetings Michael.
