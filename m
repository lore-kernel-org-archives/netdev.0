From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 net-next 00/13] at86rf230: rework
	driver implementation
Date: Wed,  2 Jul 2014 17:09:57 +0200
Message-ID: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

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

changes since v2:
 - add check if necessary functions are implemented when hw flags are set in patch
   ("mac802154: at86rf230: add hw flags and merge ops"). I choosed the second variant.
 - remove unnecessary includes for workqueue and mutex in patch
   ("at86rf230: rework transmit and receive").
 - remove unnecessary cast in patch ("at86rf230: rework transmit and receive").
 - acivate regmap cache with REGCACHE_RBTREE in patch
   ("at86rf230: add regmap support").

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
 drivers/net/ieee802154/at86rf230.c | 1466 +++++++++++++++++++++++-------------
 include/net/mac802154.h            |   19 +
 net/mac802154/ieee802154_dev.c     |   60 +-
 4 files changed, 991 insertions(+), 555 deletions(-)

-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
