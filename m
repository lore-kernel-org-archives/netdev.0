From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmfmac: BRCMFMAC should depend on HAS_DMA
Date: Mon, 1 Sep 2014 14:54:57 +0200
Message-ID: <54046CA1.4040108@broadcom.com>
References: <1409329464-768-1-git-send-email-geert@linux-m68k.org>	<54042CA1.6010904@broadcom.com> <CAMuHMdV2hV_r_OASkv+U-AGVov18qFOrAVm-nDHHPHXZ6fcxxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdV2hV_r_OASkv+U-AGVov18qFOrAVm-nDHHPHXZ6fcxxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/01/14 10:44, Geert Uytterhoeven wrote:
> Hi Arend,
>
> On Mon, Sep 1, 2014 at 10:21 AM, Arend van Spriel<arend@broadcom.com>  wrote:
>>>    config BRCMFMAC
>>>          tristate "Broadcom IEEE802.11n embedded FullMAC WLAN driver"
>>> -       depends on CFG80211
>>> +       depends on CFG80211A&&   HAS_DMA
>>
>> Not sure what happened here, but CFG80211 kconfig option did was not renamed
>> as far as I know. Anyway, I would like to propose a different solution. Will
>
> Oops, that was me typing the vim append-command twice :-(
> Thanks for noticing!
>
>> get back to you when I have it ready.
>
> OK. Thanks again!

Hi Geert,

I added Kconfig options for the proto layer which are selected by the 
host interface selection. So the HAS_DMA dependency is checked for 
BRCMFMAC_PCIE. I am wondering whether GENERIC_IO should also be checked.

Can you verify the patch below works with your configuration?

Regards,
Arend
---
diff --git a/drivers/net/wireless/brcm80211/Kconfig 
b/drivers/net/wireless/brcm80211/Kconfig
index b8e2561..fe3dc12 100644
--- a/drivers/net/wireless/brcm80211/Kconfig
+++ b/drivers/net/wireless/brcm80211/Kconfig
@@ -27,10 +27,17 @@ config BRCMFMAC
  	  one of the bus interface support. If you choose to build a module,
  	  it'll be called brcmfmac.ko.

+config BRCMFMAC_PROTO_BCDC
+	bool
+
+config BRCMFMAC_PROTO_MSGBUF
+	bool
+
  config BRCMFMAC_SDIO
  	bool "SDIO bus interface support for FullMAC driver"
  	depends on (MMC = y || MMC = BRCMFMAC)
  	depends on BRCMFMAC
+	select BRCMFMAC_PROTO_BCDC
  	select FW_LOADER
  	default y
  	---help---
@@ -42,6 +49,7 @@ config BRCMFMAC_USB
  	bool "USB bus interface support for FullMAC driver"
  	depends on (USB = y || USB = BRCMFMAC)
  	depends on BRCMFMAC
+	select BRCMFMAC_PROTO_BCDC
  	select FW_LOADER
  	---help---
  	  This option enables the USB bus interface support for Broadcom
@@ -52,6 +60,8 @@ config BRCMFMAC_PCIE
  	bool "PCIE bus interface support for FullMAC driver"
  	depends on BRCMFMAC
  	depends on PCI
+	depends on HAS_DMA
+	select BRCMFMAC_PROTO_MSGBUF
  	select FW_LOADER
  	---help---
  	  This option enables the PCIE bus interface support for Broadcom
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/Makefile 
b/drivers/net/wireless/brcm80211/brcmfmac/Makefile
index c35adf4..90a977f 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/Makefile
+++ b/drivers/net/wireless/brcm80211/brcmfmac/Makefile
@@ -30,16 +30,18 @@ brcmfmac-objs += \
  		fwsignal.o \
  		p2p.o \
  		proto.o \
-		bcdc.o \
-		commonring.o \
-		flowring.o \
-		msgbuf.o \
  		dhd_common.o \
  		dhd_linux.o \
  		firmware.o \
  		feature.o \
  		btcoex.o \
  		vendor.o
+brcmfmac-$(CONFIG_BRCMFMAC_PROTO_BCDC) += \
+		bcdc.o
+brcmfmac-$(CONFIG_BRCMFMAC_PROTO_MSGBUF) += \
+		commonring.o \
+		flowring.o \
+		msgbuf.o
  brcmfmac-$(CONFIG_BRCMFMAC_SDIO) += \
  		dhd_sdio.o \
  		bcmsdh.o
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h 
b/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
index 17e8c03..6003179 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
@@ -16,9 +16,12 @@
  #ifndef BRCMFMAC_BCDC_H
  #define BRCMFMAC_BCDC_H

-
+#ifdef CONFIG_BRCMFMAC_PROTO_BCDC
  int brcmf_proto_bcdc_attach(struct brcmf_pub *drvr);
  void brcmf_proto_bcdc_detach(struct brcmf_pub *drvr);
-
+#else
+static inline int brcmf_proto_bcdc_attach(struct brcmf_pub *drvr) { 
return 0; }
+static inline void brcmf_proto_bcdc_detach(struct brcmf_pub *drvr) {}
+#endif

  #endif /* BRCMFMAC_BCDC_H */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h 
b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
index f901ae5..e6395ee 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
@@ -32,9 +32,16 @@


  int brcmf_proto_msgbuf_rx_trigger(struct device *dev);
+void brcmf_msgbuf_delete_flowring(struct brcmf_pub *drvr, u8 flowid);
+#ifdef CONFIG_BRCMFMAC_PROTO_MSGBUF
  int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr);
  void brcmf_proto_msgbuf_detach(struct brcmf_pub *drvr);
-void brcmf_msgbuf_delete_flowring(struct brcmf_pub *drvr, u8 flowid);
-
+#else
+static inline int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr)
+{
+	return 0;
+}
+static inline void brcmf_proto_msgbuf_detach(struct brcmf_pub *drvr) {}
+#endif

  #endif /* BRCMFMAC_MSGBUF_H */
> Gr{oetje,eeting}s,
>
>                          Geert
>
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
>
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                  -- Linus Torvalds
