From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 0/2] Add packet capture support on macvtap device
Date: Wed, 11 Dec 2013 13:27:09 -0500
Message-ID: <1386786431-22592-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, kaber@trash.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab3LKS1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 13:27:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change from RFC:
  - moved to the rx_handler approach.

This series adds support for packet capturing on macvtap device.
The initial approach was to simply export the capturing code as
a function from the core network.  While simple, it was not
a very architecturally clean approach.

The new appraoch is to provide macvtap with its rx_handler which can
is attached to the macvtap device itself.   Macvlan will simply requeue
the packet with an updated skb->dev.  BTW, macvlan layer already does this
for macvlan devices.  So, now macvtap and macvlan have almost the
same exact input path.

I've toyed with short-circuting the input path for macvtap by returning
RX_HANDLER_ANOTHER, but that just made the code more complicated and
didn't provide any kind of measurable gain (at least according to
netperf and perf runs on the host).

To see if there was a performance regression, I ran 1, 2 and 4 netperf
STREAM and MAERTS tests agains the VM from both remote host and another
guest on the same system.   The command ran was
    netperf -H $host -t $test -l 20 -i 10 -I 95 -c -C

The numbers I was getting with the new code were consistently very
slightly (1-2%) better then the old code.  I don't consider this
an improvement, but it's not a regression! :)

Running 'perf record' on the host didn't show any new hot spots
and cpu utilization stayed about the same.  This was better
then I expected from simply looking at the code.

Vlad Yasevich (2):
  macvtap: Add support of packet capture on macvtap device.
  macvlan: Remove custom recieve and forward handlers

 drivers/net/macvlan.c      | 17 ++++---------
 drivers/net/macvtap.c      | 63 +++++++++++++++++++++++++---------------------
 include/linux/if_macvlan.h |  7 +-----
 3 files changed, 41 insertions(+), 46 deletions(-)

-- 
1.8.4.2
