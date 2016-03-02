From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 0/2] Fix descriptor counting and avoid Tx hangs on e1000
 w/ TSO
Date: Wed, 02 Mar 2016 16:15:55 -0500
Message-ID: <20160302205129.2124.67042.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jogreene@redhat.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35166 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbcCBW0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 17:26:40 -0500
Received: by mail-pa0-f43.google.com with SMTP id bj10so1853833pad.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 14:26:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses a Tx hang reported in our test lab with
RHEL/CentOS 7.2 running in a VM with an emulated e1000 driver.  We were
able to determine that the issue appears to have been introduced with the
changes that introduced xmit_more.

What we have found is that the pre-check for the number of descriptors
was using a value much larger than the value used for the next transmit at
the end of the xmit path.  As a result we were often not writing the tail,
and then setting then stopping xmit with the next packet and returning
TX_BUSY from the driver.

This patch series addresses the two main issues found.  First it prevents
us from reporting the need for 2 descriptors for every 4K page when we only
needed one.  This wasn't so much an issue when 32K pages are used for a
TSO, but if 4K pages are used then this effectively doubles the size of the
data descriptor count so instead of indicating 1 (head) + 17 (frags) we
were indicating 1 (head) + 32 (frags) because each full 4K frag was
requesting 2 descriptors instead of 1.

The fix for the 82544 is speculative as I don't actually have the hardware
to test with but I suspect it will have a similar issue.  As such I have
build tested it and verified it didn't break existing hardware to increase
the post-xmit test by a couple descriptors, but I have not tested the code
path with an 82544 so I don't know if there are any issues with us
increasing the value by MAX_SKB_FRAGS + 1.

Testing Hints:
The reproduction case for this is pretty simple.  You basically just need
the adapter installed in a multi-CPU system and to perform TSO from a few
threads so that you can hit the point of tx_restart_queue incrementing.
After that the Tx hangs should start being reported since the adapter will
be stopped but the tail never gets updated.  It should be easiest to
reproduce this issue on an 82544 since it will push the upper limit
theoretically as high as trying to request 52 descriptors for a single
frame while the post check is only looking for something like 20.

---

Alexander Duyck (2):
      e1000: Do not overestimate descriptor counts in Tx pre-check
      e1000: Double Tx descriptors needed check for 82544


 drivers/net/ethernet/intel/e1000/e1000_main.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)
