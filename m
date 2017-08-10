From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working
 with wireless drivers
Date: Thu, 10 Aug 2017 14:43:06 +0200
Message-ID: <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
References: <87shh0gewn.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, James Feeney <james@nurealm.net>
To: Kalle Valo <kvalo@codeaurora.org>,
        Mahesh Bandewar <maheshb@google.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33838 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752231AbdHJMnL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 08:43:11 -0400
Received: by mail-wm0-f53.google.com with SMTP id t138so20715992wmt.1
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 05:43:10 -0700 (PDT)
In-Reply-To: <87shh0gewn.fsf@kamboji.qca.qualcomm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10-08-17 07:39, Kalle Valo wrote:
> Hi Mahesh and Andy,
> 
> James Feeney reported that there's a serious regression in bonding
> module since v4.12, it doesn't work with wireless drivers anymore as
> wireless drivers don't report the link speed via ethtool:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=196547
> 
> In the bug report it's said that this commit is the culprit:
> 
> 3f3c278c94dd bonding: fix active-backup transition

This commit references another one. ie. commit c4adfc822bf5 ("bonding: 
make speed, duplex setting consistent with link state"). Before this 
commit the result of __ethtool_get_link_ksettings() was simply ignored.

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -365,9 +365,10 @@ int bond_set_carrier(struct bonding *bond)
  /* Get link speed and duplex from the slave's base driver
   * using ethtool. If for some reason the call fails or the
   * values are invalid, set speed and duplex to -1,
- * and return.
+ * and return. Return 1 if speed or duplex settings are
+ * UNKNOWN; 0 otherwise.
   */
-static void bond_update_speed_duplex(struct slave *slave)
+static int bond_update_speed_duplex(struct slave *slave)
  {
         struct net_device *slave_dev = slave->dev;
         struct ethtool_link_ksettings ecmd;
@@ -377,24 +378,27 @@ static void bond_update_speed_duplex(struct slave 
*slave)
         slave->duplex = DUPLEX_UNKNOWN;

         res = __ethtool_get_link_ksettings(slave_dev, &ecmd);
-       if (res < 0)
-               return;
-
-       if (ecmd.base.speed == 0 || ecmd.base.speed == ((__u32)-1))
-               return;
-
+       if (res < 0) {
+               slave->link = BOND_LINK_DOWN;
+               return 1;
+       }
+       if (ecmd.base.speed == 0 || ecmd.base.speed == ((__u32)-1)) {
+               slave->link = BOND_LINK_DOWN;
+               return 1;
+       }

Commit 3f3c278c94dd ("bonding: fix active-backup transition") moves 
setting the link state to the call sites of bond_update_speed_duplex(), 
just not all call sites.

> Is there a fix for this or should that commit be reverted? This seems to
> be a serious regression as there are multiple reports already and we
> should get it fixed for v4.13, and the fix backported to v4.12 stable
> release.

The ethtool callbacks really seem optional. At least in brcmfmac, the 
wireless driver I maintain, I only provide get_drvinfo callback and 
there is no warning triggered upon registering the netdev. The changes 
above now require each netdev to implement the get_link_ksettings 
callback (get_settings is deprecated) or the link is marked as DOWN 
ruling it out to be used as active bond slave. To the end-users who were 
using bonding this is simply a regression. So to fix that both changes 
should be reverted in my opinion.

Now specifically for wireless interfaces we could implement 
get_link_ksettings callback although most of the fields requested are 
meaningless in wireless context. Regarding the speed and half-duplex 
values we raised some concerns in an earlier discussion with James. 
Wireless is always half-duplex as there can be only one (unintended ref 
to [1]). If the reported speed in wifi is difficult. In wifi we have 
txrate and rxrate which are inherently asynchronous and it is a 
per-packet value so it is going to change a lot. Seeing only 4 call 
sites in the bonding code tells me that is not taken into account. All 
in all this shenanigan seems netconf material to me.

Regards,
Arend

[1] https://en.wikipedia.org/wiki/Highlander_(film)
