From: Sujith Manoharan <sujith-TPRpbcbO+rZAfugRpC6u6w@public.gmane.org>
Subject: ath9k_htc-based adapter unfunctioning after commit ceb26a6013
Date: Tue, 13 Nov 2012 12:58:02 +0530
Message-ID: <20641.63106.943323.923565@gargle.gargle.HOWL>
References: <CA++BO6SuRgOu7A4BKobrdEeSpSc3UUYHXaECmEGE=R17w7HjQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org
To: Corey Richardson <corey-GAYEDG9L0ISsTnJN9+BGXg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA++BO6SuRgOu7A4BKobrdEeSpSc3UUYHXaECmEGE=R17w7HjQA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Corey Richardson wrote:
> I was giving 3.7-rc4 a whirl when I discovered my wireless adapter [0] wasn't
> working: the LED didn't light up. Went and ran 'ip link' and it just hung there.
> Tried a few other things and discovered that sudo was broken too. With
> strace I found that they were hanging in sendto().
> 
> If I then unplug the adapter, everything comes out of the hang.
> 
> Bisected and found that commit ceb26a6013b962b82f644189ea29d802490fc8fc is
> to blame.

I can see this issue too. I am not entirely convinced that the commit in
question is valid. If a HW reset fails for some reason in start(), bailing
out seems the right thing to do instead of continuing to fiddle with the HW
and silently returning a success code to mac80211.

I was able to bring up the device with this patch.

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 756191b..e06bcec 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1456,7 +1456,7 @@ static bool ath9k_hw_set_reset_reg(struct ath_hw *ah, u32 type)
 	switch (type) {
 	case ATH9K_RESET_POWER_ON:
 		ret = ath9k_hw_set_reset_power_on(ah);
-		if (!ret)
+		if (ret)
 			ah->reset_power_on = true;
 		break;
 	case ATH9K_RESET_WARM:

Sujith
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
