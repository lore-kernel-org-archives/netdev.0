From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 0/12]: Proper compat WEXT support.
Date: Wed, 04 Jun 2008 19:09:06 +0900
Message-ID: <20080604184955.B033.40F06B3A@sm.sony.co.jp>
References: <20080603.132755.262737024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080603.132755.262737024.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Thanks for updating the patch set!!

On Tue, 03 Jun 2008 13:27:55 -0700 (PDT)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:


> This is a refresh of my previous WEXT compat patch set.
> 
> I've actually tested these exact patches on sparc64 with a RNDIS based
> USB wireless device from Linksys.  I was able to perform iwconfig
> commands, check iwlist, bring up the interface and use it properly.
> All with 32-bit tools.  I've also done an allmodconfig sanity
> build check on sparc64.
> 
> The one thing I was not able to test yet is wpa_supplicant use, and
> that likely doesn't work properly yet, but we can fix that on top and
> these patches do not break native non-compat binaries.  They do make a
> lot of compat stuff work which wasn't the case before.  So applying
> this stuff makes sense, and we can get wpa_supplicant working if it
> isn't working using follow-on patches.
> 
> The patch set starts by cleaning up the code so that we can avoid
> having multiple copies of the WEXT main dispatch routines, one for
> compat and one for the non-compat case.
> 
> Next, basic compat level handling of the WEXT ioctl is added, and the
> equivalent code in the compat_ioctl.c file is removed.
> 
> Finally, compat IWE stream munging is added for the wireless layer.
> When we get a compat WEXT ioctl request, we set a bit in the request
> info blob, and the stream building helpers tip off this to format the
> stream entries properly.


I'm testing these patches on my PS3.  I've found a problem.

With 32-bit wireless-tools v28, the bitrates from the scan result were
wrong (with gelic/rt2x00 driver):

[root@localhost wireless_tools.28]# ./iwlist wlan3 scanning
Warning: Driver for device wlan3 has been compiled with version 22
of Wireless Extension, while this program supports up to version 20.
Some things may be broken...

wlan3     Scan completed :
          Cell 01 - Address: 00:06:25:C6:B9:A7
                    ESSID:"planexuser"
                    Mode:Master
                    Channel:1
                    Frequency:2.412 GHz (Channel 1)
                    Quality=51/100  Signal level=-50 dBm  
                    Encryption key:on
                    IE: WPA Version 1
                        Group Cipher : CCMP 
                        Pairwise Ciphers (1) : CCMP 
                        Authentication Suites (1) : PSK  
                    Bit Rates:0 kb/s; 0 kb/s; 0 kb/s; 0 kb/s; 0 kb/s
                              0 kb/s; 0 kb/s; 0 kb/s; 0 kb/s; 0 kb/s
                              0 kb/s; 0 kb/s
                    Extra:tsf=000000013f454d92

With 32-bit wireless-tools v30 (i.e. the SOIGIWSCAN workaround
included):

[root@localhost wireless_tools.30]# ./iwlist wlan3 scanning
wlan3     Scan completed :
          Cell 01 - Address: 00:06:25:C6:B9:A7
                    ESSID:"planexuser"
                    Mode:Master
                    Channel:1
                    Frequency:2.412 GHz (Channel 1)
                    Quality=48/100  Signal level=-68 dBm  
                    Encryption key:on
                    IE: WPA Version 1
                        Group Cipher : CCMP
                        Pairwise Ciphers (1) : CCMP
                        Authentication Suites (1) : PSK
                    Bit Rates:1 Mb/s; 2 Mb/s; 5.5 Mb/s; 11 Mb/s; 18 Mb/s
                              24 Mb/s; 36 Mb/s; 54 Mb/s; 6 Mb/s; 9 Mb/s
                              12 Mb/s; 48 Mb/s
                    Extra:tsf=000000014e16ea91

I think the callers of iwe_stream_add_value() need to do some
preparations before the call if iocompat is needed, like the following.

---
 drivers/net/ps3_gelic_wireless.c |    7 +++++++
 net/mac80211/mlme.c              |   11 ++++++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -605,7 +605,14 @@ static char *gelic_wl_translate_scan(str
 	iwe.cmd = SIOCGIWRATE;
 	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
 	/* to stuff multiple values in one event */
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT)
+		tmp = ev + IW_EV_COMPAT_LCP_LEN;
+	else
+		tmp = ev + IW_EV_LCP_LEN;
+#else
 	tmp = ev + IW_EV_LCP_LEN;
+#endif
 	/* put them in ascendant order (older is first) */
 	i = 0;
 	j = 0;
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -4147,9 +4147,18 @@ ieee80211_sta_scan_result(struct net_dev
 
 	if (bss && bss->supp_rates_len > 0) {
 		/* display all supported rates in readable format */
-		char *p = current_ev + IW_EV_LCP_LEN;
+		char *p;
 		int i;
 
+#ifdef CONFIG_COMPAT
+		if (info->flags & IW_REQUEST_FLAG_COMPAT)
+			p = current_ev + IW_EV_COMPAT_LCP_LEN;
+		else
+			p = current_ev + IW_EV_LCP_LEN;
+#else
+		p = current_ev + IW_EV_LCP_LEN;
+#endif
+
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = SIOCGIWRATE;
 		/* Those two flags are ignored... */

-- 
Masakazu Mokuno

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
