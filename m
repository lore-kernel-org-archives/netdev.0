From: Bing Zhao <bzhao@marvell.com>
Subject: RE: wireless: mwifiex: initial commit for Marvell mwifiex driver
Date: Wed, 25 Apr 2012 15:08:33 -0700
Message-ID: <477F20668A386D41ADCC57781B1F7043083A3CC5FF@SC-VEXCH1.marvell.com>
References: <20120425084445.GA12799@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:51668 "EHLO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757501Ab2DYWKf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 18:10:35 -0400
In-Reply-To: <20120425084445.GA12799@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

> Hi Bing,
> 
> The patch 5e6e3a92b9a4: "wireless: mwifiex: initial commit for
> Marvell mwifiex driver" from Mar 21, 2011, leads to the following
> static checker warning:
> 
> drivers/net/wireless/mwifiex/sta_ioctl.c:1410
> mwifiex_set_gen_ie_helper()
> 	 error: memcmp() 'pvendor_ie->oui' too small (3 vs 4)

Thanks for catching this error.

> 
>   1390  mwifiex_set_gen_ie_helper(struct mwifiex_private *priv, u8 *ie_data_ptr,
>   1391                            u16 ie_len)
>   1392  {
>   1393          int ret = 0;
>   1394          struct ieee_types_vendor_header *pvendor_ie;
>   1395          const u8 wpa_oui[] = { 0x00, 0x50, 0xf2, 0x01 };
>                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^
> 4 byte array.

The last byte 0x01 is actually the oui_type.

	...
	u8 oui[3];
	u8 oui_type;
	...

> 
>   1396          const u8 wps_oui[] = { 0x00, 0x50, 0xf2, 0x04 };
>   1397
>   1398          /* If the passed length is zero, reset the buffer */
>   1399          if (!ie_len) {
>   1400                  priv->gen_ie_buf_len = 0;
>   1401                  priv->wps.session_enable = false;
>   1402
>   1403                  return 0;
>   1404          } else if (!ie_data_ptr) {
>   1405                  return -1;
>   1406          }
>   1407          pvendor_ie = (struct ieee_types_vendor_header *) ie_data_ptr;
>   1408          /* Test to see if it is a WPA IE, if not, then it is a gen IE */
>   1409          if (((pvendor_ie->element_id == WLAN_EID_WPA) &&
>   1410               (!memcmp(pvendor_ie->oui, wpa_oui, sizeof(wpa_oui)))) ||
>                               ^^^^^^^^^^^^^^^
> ->oui is only a 3 byte array so we're reading past the end for this
> comparison.

I will fix the misuse of memcmp's.

By the way, could you please share with me how you check for this kind of errors?
Is it coccinelle? I tried with coccicheck but got "spatch.opt unknown option -D" error.

Thanks,
Bing

> 
>   1411              (pvendor_ie->element_id == WLAN_EID_RSN)) {
> 
> 
> There are a couple other similar warnings as well:
> 
> drivers/net/wireless/mwifiex/sta_ioctl.c:1435 mwifiex_set_gen_ie_helper()
> 	error: memcmp() 'pvendor_ie->oui' too small (3 vs 4)
> drivers/net/wireless/mwifiex/scan.c:1177 mwifiex_update_bss_desc_with_ie()
> 	error: memcmp() 'vendor_ie->vend_hdr.oui' too small (3 vs 4)
> drivers/net/wireless/mwifiex/scan.c:1185 mwifiex_update_bss_desc_with_ie()
> 	error: memcmp() 'vendor_ie->vend_hdr.oui' too small (3 vs 4)
> 
> regards,
> dan carpenter
