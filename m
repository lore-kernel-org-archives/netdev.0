From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Sun, 11 Jun 2006 20:11:31 -0500
Message-ID: <448CBF43.6000200@lwfinger.net>
References: <4485D66B.7080108@lwfinger.net> <1149682213.3999.14.camel@johannes> <4486F513.5050906@lwfinger.net> <1149695470.3925.7.camel@johannes> <1149695859.3925.11.camel@johannes> <1149701352.2625.20.camel@localhost.localdomain> <44871723.3040803@lwfinger.net> <1149853494.3864.6.camel@johannes.berg> <44899462.6070002@lwfinger.net> <1149867292.3864.30.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:3051 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750703AbWFLBLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 21:11:36 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1149867292.3864.30.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Fri, 2006-06-09 at 10:31 -0500, Larry Finger wrote:
> 
>> Do you mean a special dump, or is the kernel debug output and wpa_supplicant debug output sufficient?
> 
> I was thinking of packet dumps but earlier you said you couldn't create
> any so I'm out of ideas for now.

I was finally able to get my second laptop running with bcm43xx so I could get packet dumps. When I 
analyzed them, the Association Response packet contained the following information:

"Association denied due to requesting station not supporting short preamble operation (0x0013)"

I think this is a bug in the code on my WRT54G V5 and I will report it to Linksys; however, in the 
meantime, I am able to connect using the following _ugly_ hack to softmac_assoc_req and 
softmac_reassoc_req:

diff --git a/net/ieee80211/softmac/ieee80211softmac_io.c b/net/ieee80211/softmac/ieee80211softmac_io.c
index cc6cd56..a1d0c10 100644
--- a/net/ieee80211/softmac/ieee80211softmac_io.c
+++ b/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -199,6 +199,8 @@ ieee80211softmac_assoc_req(struct ieee80
         (*pkt)->capability |= mac->ieee->short_slot ?
                         cpu_to_le16(WLAN_CAPABILITY_SHORT_SLOT_TIME) : 0;
          */
+       /* add short preamble operation capability */
+       (*pkt)->capability |= cpu_to_le16(WLAN_CAPABILITY_SHORT_PREAMBLE);
         (*pkt)->capability |= mac->ieee->sec.level ? cpu_to_le16(WLAN_CAPABILITY_PRIVACY) : 0;
         /* Fill in Listen Interval (?) */
         (*pkt)->listen_interval = cpu_to_le16(10);
@@ -247,6 +249,8 @@ ieee80211softmac_reassoc_req(struct ieee
         (*pkt)->capability |= mac->ieee->short_slot ?
                         cpu_to_le16(WLAN_CAPABILITY_SHORT_SLOT_TIME) : 0;
          */
+       /* add short preamble operation capability */
+       (*pkt)->capability |= cpu_to_le16(WLAN_CAPABILITY_SHORT_PREAMBLE);
         (*pkt)->capability |= mac->ieee->sec.level ?
                         cpu_to_le16(WLAN_CAPABILITY_PRIVACY) : 0;


I expect that softmac should be listening to the driver as to whether this capability is available; 
however, I'm now up and running once again.

Larry
