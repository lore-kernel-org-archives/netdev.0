From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats using ethtool
Date: Fri, 16 May 2014 21:48:17 +0200
Message-ID: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52160 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754787AbaEPTss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 15:48:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting the previous description of this series (skip to the
changelog below if you only want a summary of the changes):

"I have got quite a few reports from frustrated users of OpenWRT
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

Please test and/or comment!"


Changes:

** RFC -> v1 **

Patch 10 - a follow-up to a comment Joe Perches made in November
           2013.  I don't always forget :-)
Patch 11 - removes the redundant "connected" driver state, and the
           associated .check_connect callbacks.

** v1 -> v2 **

Patch 1  - Better handling of minium rx buffer size, based on feedback
           from Oliver Neukum and Enrico Mioso
Patch 5  - fixed locking around timer interval update
Patch 9  - fixed whitespace error
Patch 12 - new fix related to the tuneable tx timer

=2E..and spelling fixes all over the commit messages.  I have finally
added a spelling hook, which I'm sure may of you will appreciate :-)


Bj=C3=B8rn Mork (12):
  net: cdc_ncm: split out rx_max/tx_max update of setup
  net: cdc_ncm: factor out one-time device initialization
  net: cdc_ncm: split .bind device initialization
  net: cdc_ncm: support rx_max/tx_max updates when running
  net: cdc_ncm: use ethtool to tune coalescing settings
  net: cdc_ncm: use true max dgram count for header estimates
  net: cdc_ncm: set reasonable padding limits
  net: cdc_ncm/cdc_mbim: adding NCM protocol statistics
  net: cdc_ncm: use sane defaults for rx/tx buffers
  net: cdc_ncm: fix argument alignment
  net: cdc_ncm: remove redundant "disconnected" flag
  net: cdc_ncm: do not start timer on an empty skb

 drivers/net/usb/cdc_mbim.c       |   6 +
 drivers/net/usb/cdc_ncm.c        | 590 ++++++++++++++++++++++++++++---=
--------
 drivers/net/usb/huawei_cdc_ncm.c |  13 -
 include/linux/usb/cdc_ncm.h      |  33 ++-
 4 files changed, 455 insertions(+), 187 deletions(-)

--=20
2.0.0.rc2
