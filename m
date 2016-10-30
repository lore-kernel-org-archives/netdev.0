From: John Heenan <john-AMlJbUfTsso@public.gmane.org>
Subject: [PATCH 0/2] rtl8xxxu: Fix allows wpa_supplicant to authenticate
Date: Sun, 30 Oct 2016 20:20:21 +1000
Message-ID: <20161030102021.GA5780@cube>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

With the current kernel release, wpa_supplicant results in authentication failure
with a Cube i9 tablet (a Surface Pro like device):

Successfully initialized wpa_supplicant
wlp0s20f0u7i2: SME: Trying to authenticate with 10:fe:ed:62:7a:78 (SSID='localre' freq=2417 MHz)
wlp0s20f0u7i2: SME: Trying to authenticate with 10:fe:ed:62:7a:78 (SSID='localre' freq=2417 MHz)
wlp0s20f0u7i2: SME: Trying to authenticate with 10:fe:ed:62:7a:78 (SSID='localre' freq=2417 MHz)
wlp0s20f0u7i2: SME: Trying to authenticate with 10:fe:ed:62:7a:78 (SSID='localre' freq=2417 MHz)
wlp0s20f0u7i2: CTRL-EVENT-SSID-TEMP-DISABLED id=0 ssid="localre" auth_failures=1 duration=10 reason=CONN_FAILED

There is a workaround: that ONLY works once per invocation of wpa_supplicant: 
rmmod rtl8xxxu
modprobe rtl8xxxu

The follwing two patches result in reliable behaviour, without a workaround,
of wpa_supplicant:

Successfully initialized wpa_supplicant
wlp0s20f0u7i2: SME: Trying to authenticate with 10:fe:ed:62:7a:78 (SSID='localre' freq=2417 MHz)
wlp0s20f0u7i2: Trying to associate with 10:fe:ed:62:7a:78 (SSID='localre' freq=2417 MHz)
wlp0s20f0u7i2: Associated with 10:fe:ed:62:7a:78
wlp0s20f0u7i2: CTRL-EVENT-SUBNET-STATUS-UPDATE status=0
wlp0s20f0u7i2: WPA: Key negotiation completed with 10:fe:ed:62:7a:78 [PTK=CCMP GTK=CCMP]
wlp0s20f0u7i2: CTRL-EVENT-CONNECTED - Connection to 10:fe:ed:62:7a:78 completed [id=0 id_str=]


The patches are for kernel tree:
git://git.kernel.org/pub/scm/linux/kernel/git/jes/linux.git
branch: rtl8xxxu-devel

The first patch moves init code so that each time wpa_supplicant is invoked
there is similar init behaviour as the alternative working rtl8xxxu driver
https://github.com/lwfinger/rtl8723bu

The second patch enables more complete initialisation to occur. There are three issues:
1. The value returned by "rtl8xxxu_read8(priv, REG_CR);", to set macpower, is never 0xef. 
   The value is either 0x01 (first time with wpa_supplcant after modprobe) or 0x00 
   (re executing wpa_supplicant)

2. Trying to use the value 0x00 or 0x01 retutned to determine macpower setting always 
   resulted in failure

3. At the very least 'rtl8xxxu_init_queue_reserved_page(priv);' must always 
   be invoked, even if not all of the extra init sequence arising from setting
   macpower to false is run.


Patched code with a suitable Makefile will be available from
https://github.com/johnheenan/rtl8xxxu for testing by Cube i9 owners


John Heenan (2):
  rtl8xxxu: Fix for authentication failure
  rtl8xxxu: Fix for bogus data used to determine macpower

 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

-- 
2.10.1
