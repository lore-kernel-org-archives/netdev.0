From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC 0/9] cdc_ncm: add buffer tuning and stats using ethtool
Date: Fri,  2 May 2014 23:11:47 +0200
Message-ID: <1399065116-19946-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55171 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747AbaEBVMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 17:12:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have got quite a few reports from frustrated users of OpenWRT
hosts trying to use some powerful LTE modem, but not achieving
full speed.  This is typically caused by a combination of
big buffers and little memory, giving in allocation errors and
bad performance as a result.

This series is an attempt to let users adjust the size of these
buffers without having to rebuild the driver.

Patches 1 - 4 are mostly rearranging existing code, in preparing
for the dynamic buffer size changes.

Patch 5 adds userspace control (ab)using the ethtool coalescing
API. This isn't a perfect match, which is the main reason why I
post this series as a RFC.

Patch 6 is an unrelated framing optimization, reducing the
overhead quite a bit and allowing for better use of smaller
buffers.

Patch 7 changes the way we calculate frame padding cutoff. The
problem with big buffers is made much worse by the current padding
strategy where zero padding often can account for more than 90% of
the frames.

Patch 8 add some counters giving some insight into how well the
NCM/MBIM protocol works, supporting further tuning.

Patch 9 reduce the initial maximum buffer size from 32kB to 16kB
in an attempt to make the default better suit all. It is still
possible to tune this up again to the old fixed max, using the
new tuning knobs.

I must admit that I had higher hopes for this series before I
tested it on my own modems.  One really unexpected result was
that one of the MBIM modems accepted the new rx buffer size we
set, but happily continued sending buffers of the same size as
before.  Needless to say:  This did not work very well...

So don't really expect to be able to use any values with any
given device. Firmware implementations are still... I don't
think I have words suitable for a public mailing list.

But I am hoping this will help the many users who have had success
rebuilding the driver with lower fixed limits.

Please test and/or comment!


Bj=C3=B8rn Mork (9):
  net: cdc_ncm: split out rx_max/tx_max update of setup
  net: cdc_ncm: factor out one-time device initialization
  net: cdc_ncm: split .bind device initialization
  net: cdc_ncm: support rx_max/tx_max updates when running
  net: cdc_ncm: use ethtool to tune coalescing settings
  net: cdc_ncm: use true max dgram count for header estimates
  net: cdc_ncm: set reasonable padding limits
  net: cdc_ncm/cdc_mbim: adding NCM protocol statiscics
  net: cdc_ncm: use sane defaults for rx/tx buffers

 drivers/net/usb/cdc_mbim.c  |   6 +
 drivers/net/usb/cdc_ncm.c   | 545 +++++++++++++++++++++++++++++++++---=
--------
 include/linux/usb/cdc_ncm.h |  32 ++-
 3 files changed, 434 insertions(+), 149 deletions(-)

--=20
2.0.0.rc0
