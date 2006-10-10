From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 2/3] d80211: remove poorly documented ieee80211_hw extra_hdr_room flag
Date: Tue, 10 Oct 2006 12:00:12 +0200
Message-ID: <200610101200.12454.mb@bu3sch.de>
References: <20061009170159.804032000@devicescape.com> <20061009170306.GB27239@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:22926
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965130AbWJJKAf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 06:00:35 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061009170306.GB27239@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 09 October 2006 19:03, David Kimdon wrote:
> This flag is unused by all in tree drivers.  Furthermore, the way that
> it is documented is not consistent with the way it is actually used by
> ieee80211.c.  The original attempt appears to be something to do with
> adding extra header room for low-level drivers which need to pad the
> IEEE 802.11 header (example: Atheros).

What about not removing it, but extending it.
In the current form it's rather useless. But we could make extra_hdr_room
a value instead of a flag. Bcm43xx needs somewhere around 30bytes extra
header room. So every driver which does not need header room, sets this
to 0. Every other driver to the specific value.

We currently workaround the problem by using an extra DMA descriptor
just for the header. That's not really a problem, though. But it means
a little bit of additional overhead in the TX path. Well.

> Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
> 
> Index: wireless-dev/include/net/d80211.h
> ===================================================================
> --- wireless-dev.orig/include/net/d80211.h
> +++ wireless-dev/include/net/d80211.h
> @@ -476,10 +476,6 @@ struct ieee80211_hw {
>  	/* Force software encryption for TKIP packets if WMM is enabled. */
>  	unsigned int no_tkip_wmm_hwaccel:1;
>  
> -	/* set if the payload needs to be padded at even boundaries after the
> -	 * header */
> -	unsigned int extra_hdr_room:1;
> -
>  	/* Some devices handle Michael MIC internally and do not include MIC in
>  	 * the received packets passed up. device_strips_mic must be set
>  	 * for such devices. The 'encryption' frame control bit is expected to
> Index: wireless-dev/net/d80211/ieee80211.c
> ===================================================================
> --- wireless-dev.orig/net/d80211/ieee80211.c
> +++ wireless-dev/net/d80211/ieee80211.c
> @@ -1551,7 +1551,7 @@ static int ieee80211_subif_start_xmit(st
>  	 * build in headroom in __dev_alloc_skb() (linux/skbuff.h) and
>  	 * alloc_skb() (net/core/skbuff.c)
>  	 */
> -	head_need = hdrlen + encaps_len + (local->hw->extra_hdr_room ? 2 : 0);
> +	head_need = hdrlen + encaps_len;
>  	head_need -= skb_headroom(skb);
>  
>  	/* We are going to modify skb data, so make a copy of it if happens to
> Index: wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/adm8211/adm8211.c
> +++ wireless-dev/drivers/net/wireless/d80211/adm8211/adm8211.c
> @@ -2018,7 +2018,6 @@ static int __devinit adm8211_probe(struc
>  	hw->wep_include_iv = 1;
>  	hw->data_nullfunc_ack = 0;
>  	hw->no_tkip_wmm_hwaccel = 1;
> -	hw->extra_hdr_room = 0;
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 0;
>  	hw->fraglist = 0;
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> @@ -2578,7 +2578,6 @@ static int rt2400pci_init_hw(struct rt2x
>  	hw->wep_include_iv = 1;
>  	hw->data_nullfunc_ack = 1;
>  	hw->no_tkip_wmm_hwaccel = 1;
> -	hw->extra_hdr_room = 0;
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> @@ -2732,7 +2732,6 @@ static int rt2500pci_init_hw(struct rt2x
>  	hw->wep_include_iv = 1;
>  	hw->data_nullfunc_ack = 1;
>  	hw->no_tkip_wmm_hwaccel = 1;
> -	hw->extra_hdr_room = 0;
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
> @@ -2419,7 +2419,6 @@ static int rt2500usb_init_hw(struct rt2x
>  	hw->wep_include_iv = 1;
>  	hw->data_nullfunc_ack = 1;
>  	hw->no_tkip_wmm_hwaccel = 1;
> -	hw->extra_hdr_room = 0;
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
> @@ -3252,7 +3252,6 @@ static int rt61pci_init_hw(struct rt2x00
>  	hw->wep_include_iv = 1;
>  	hw->data_nullfunc_ack = 1;
>  	hw->no_tkip_wmm_hwaccel = 1;
> -	hw->extra_hdr_room = 0;
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> Index: wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> +++ wireless-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
> @@ -2792,7 +2792,6 @@ static int rt73usb_init_hw(struct rt2x00
>  	hw->wep_include_iv = 1;
>  	hw->data_nullfunc_ack = 1;
>  	hw->no_tkip_wmm_hwaccel = 1;
> -	hw->extra_hdr_room = 0;
>  	hw->device_strips_mic = 0;
>  	hw->monitor_during_oper = 1;
>  	hw->fraglist = 0;
> 
> --
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Greetings Michael.
