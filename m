From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 00/13] at86rf230: rework driver implementation
Date: Sat, 28 Jun 2014 20:33:38 +0200
Message-ID: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, werner@almesberger.net,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:53851 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755858AbaF1Sef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 14:34:35 -0400
Received: by mail-wg0-f46.google.com with SMTP id y10so6456667wgg.5
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 11:34:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series includes a rework of the at86rf230 driver.

There are several changes:

 - Add regmap support.
 - Merge at86rf212 operations with generic at86rf2xx operations, all chips
   supports these operations.
 - Drop of irqworker. This is a workqueue which will scheduled by an irq to
   handle synchronous spi handling. Instead using asynchronous spi handling,
   then no scheduler is involved at irq handling.
 - Also detected some bugs by receiving frame like CRC can be correct and a
   802.15.4 frame length could be above 127 bytes. This would crash the whole
   kernel (but should be handled by the mac layer). Another bug is the handling
   with RX_SAFE_MODE which protect the frame buffer after a readout. This is
   currently not working because we read out the buffer twice and the first one
   to get the frame size. Solution is to readout always the whole frame buffer.
 - Added some timing relevants things from the datasheet for state changes And
   IEEE 802.15.4 standard like interframe spacing. Interframe spacing is needed
   to insert some receiving space time between frame transmitting. This should be
   also handled by MAC layer, but it's currently a workaround to add this inside
   the driver layer.
 - Add some callback setting for chip specific handling, instead of runtime decisions
   if (is_chip_type()). Callbacks are set only once at probe time.
 - We don't using a force state change anymore. A force state change will do a
   abort of receiving frames while we want to transmit a new frame. This should
   decrease the drop rate of packets.
 - And many others changes and bug fixes...


- Alex

Alexander Aring (13):
  mac802154: at86rf230: add hw flags and merge ops
  at86rf230: add regmap support
  at86rf230: rework detect device handling
  at86rf230: remove is212 and add driver data
  at86rf230: add support for at86rf23x desense
  at86rf230: rework transmit and receive handling
  at86rf230: move RX_SAFE_MODE setting to hw_init
  at86rf230: rework irq_pol setting
  at86rf230: rework state change and start/stop
  at86rf230: rework reset to trx_off state change
  at86rf230: add timing for channel switch
  at86rf230: add sleep cycle timing
  at86rf230: add new author

 drivers/net/ieee802154/Kconfig     |    1 +
 drivers/net/ieee802154/at86rf230.c | 1464 +++++++++++++++++++++++-------------
 include/net/mac802154.h            |   19 +
 net/mac802154/ieee802154_dev.c     |   12 +-
 4 files changed, 951 insertions(+), 545 deletions(-)

-- 
2.0.1
