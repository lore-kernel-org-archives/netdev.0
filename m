From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 8 Apr 2008 13:56:01 -0500
Message-ID: <20080408135601.5dad3566@speedy>
References: <200804011107.38563.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39899 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757218AbYDHS4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 14:56:08 -0400
In-Reply-To: <200804011107.38563.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the short (not in depth) code review of kernel component of Wimax.

Generic stack: drivers/net/wimax

1. Why spread those over 8 files of 100 lines each. Better to have a single
   file with 1000 lines and get reduced namespace and better compiler inlining
   etc.

2. The debug infrastructure is a mess of ugly macros that are unlikely
   to accepted in the current form, rework or delete it.

3. Use of sysfs for family and version ok, but why bother?
   Please don't build sysfs version checks into the API.

4. __wimax_flush_queue: is a nop, just remove

5. Stack is using generic netlink instead use newer netlink interface
   for management of devices: newlink/dellink instead see macvlan

i2400m hardware driver

1. sysfs
  the inflight file is being used in a /proc style. Either change to
  one value per file or move to /proc/net/i2400m/ethX or better yet use debugfs
  /debugfs/i2400m/ethX/xxx

2. Use internal dev->stats for network stats (may not need get_stats at all)

3. No ioctl stub if not implemented

4. Use netdev_alloc_skb rather than alloc_skb for new code.

5. Use skb_copy_to_linear_data in i2400m_net_rx

6. Since hardware has to copy every received frame. Don't bother with
   checksum offload, the copy does the checksum for you and is safer.

7. Fine grain file organization in i2400m is bogus, put in one file and use
   proper name scope. Having 100 line files is unneeded

8. Fix the FIXME's?

9. Anyway to reuse existing usbnet infrastructure?

10. Since device is USB, Rx is in workqueue, so no need to go through
    netif_rx() softirq, should be able to go through netif_receive_skb

11. net_device and private data are zero on allocation, so no need
   for memset.

12. Since this is new code elminate all legacy ifdef's

