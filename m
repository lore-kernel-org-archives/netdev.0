From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: wireless: mwifiex: initial commit for Marvell mwifiex driver
Date: Wed, 25 Apr 2012 11:44:45 +0300
Message-ID: <20120425084445.GA12799@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: bzhao@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:47432 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699Ab2DYIow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 04:44:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bing,

The patch 5e6e3a92b9a4: "wireless: mwifiex: initial commit for
Marvell mwifiex driver" from Mar 21, 2011, leads to the following
static checker warning:

drivers/net/wireless/mwifiex/sta_ioctl.c:1410
mwifiex_set_gen_ie_helper()
	 error: memcmp() 'pvendor_ie->oui' too small (3 vs 4)

  1390  mwifiex_set_gen_ie_helper(struct mwifiex_private *priv, u8 *ie_data_ptr,
  1391                            u16 ie_len)
  1392  {
  1393          int ret = 0;
  1394          struct ieee_types_vendor_header *pvendor_ie;
  1395          const u8 wpa_oui[] = { 0x00, 0x50, 0xf2, 0x01 };
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^
4 byte array.

  1396          const u8 wps_oui[] = { 0x00, 0x50, 0xf2, 0x04 };
  1397  
  1398          /* If the passed length is zero, reset the buffer */
  1399          if (!ie_len) {
  1400                  priv->gen_ie_buf_len = 0;
  1401                  priv->wps.session_enable = false;
  1402  
  1403                  return 0;
  1404          } else if (!ie_data_ptr) {
  1405                  return -1;
  1406          }
  1407          pvendor_ie = (struct ieee_types_vendor_header *) ie_data_ptr;
  1408          /* Test to see if it is a WPA IE, if not, then it is a gen IE */
  1409          if (((pvendor_ie->element_id == WLAN_EID_WPA) &&
  1410               (!memcmp(pvendor_ie->oui, wpa_oui, sizeof(wpa_oui)))) ||
                              ^^^^^^^^^^^^^^^
->oui is only a 3 byte array so we're reading past the end for this
comparison.

  1411              (pvendor_ie->element_id == WLAN_EID_RSN)) {


There are a couple other similar warnings as well:

drivers/net/wireless/mwifiex/sta_ioctl.c:1435 mwifiex_set_gen_ie_helper()
	error: memcmp() 'pvendor_ie->oui' too small (3 vs 4)
drivers/net/wireless/mwifiex/scan.c:1177 mwifiex_update_bss_desc_with_ie()
	error: memcmp() 'vendor_ie->vend_hdr.oui' too small (3 vs 4)
drivers/net/wireless/mwifiex/scan.c:1185 mwifiex_update_bss_desc_with_ie()
	error: memcmp() 'vendor_ie->vend_hdr.oui' too small (3 vs 4)

regards,
dan carpenter
