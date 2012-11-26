From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: smsc95xx: detect chip revision specific features
Date: Mon, 26 Nov 2012 23:47:22 +0300
Message-ID: <20121126204722.GA26463@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27151 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563Ab2KZUrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 15:47:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Steve Glendinning,

The patch 9ebca5071c86: "smsc95xx: detect chip revision specific 
features" from Nov 22, 2012, leads to the following warning:
drivers/net/usb/smsc95xx.c:1349 smsc95xx_suspend()
	 error: buffer overflow 'filter_mask' 8 <= 31

drivers/net/usb/smsc95xx.c
  1283          if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
  1284                  u32 *filter_mask = kzalloc(32, GFP_KERNEL);
                                                   ^^
We allocate 8 unsigned 32 bit values.  I think this is the mistake here
actually.  It is a typo and should say:

			u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);

If 8 elements was the intent then that's nasty.

  1285                  u32 command[2];
  1286                  u32 offset[2];
  1287                  u32 crc[4];
  1288                  int wuff_filter_count =
  1289                          (pdata->features & FEATURE_8_WAKEUP_FILTERS) ?
  1290                          LAN9500A_WUFF_NUM : LAN9500_WUFF_NUM;

LAN9500A_WUFF_NUM is 8.  LAN9500_WUFF_NUM is 4.

  1291                  int i, filter = 0;
  1292  

[snip]

  1348                  for (i = 0; i < (wuff_filter_count * 4); i++) {
                                         ^^^^^^^^^^^^^^^^^^^^^

We are either counting to 15 or 31, and both are more that 8.

  1349                          ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);
                                                                         ^^^^^^^^^^^^^^
So we're going past the end of the 8 element array.

  1350                          if (ret < 0)
  1351                                  kfree(filter_mask);
  1352                          check_warn_return(ret, "Error writing WUFF\n");
  1353                  }

regards,
dan carpenter
