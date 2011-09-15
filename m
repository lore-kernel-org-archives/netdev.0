From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: macvtap mode private - IFF_PROMISC flag visibility for userspace
Date: Thu, 15 Sep 2011 16:56:16 -0500
Message-ID: <184D23435BECB444AB6B9D4630C8EC83028548AC@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <mst@redhat.com>, "Roopa Prabhu (roprabhu)" <roprabhu@cisco.com>,
	"David Wang (dwang2)" <dwang2@cisco.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-6.cisco.com ([173.37.86.77]:49134 "EHLO
	rcdn-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934961Ab1IOV4S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 17:56:18 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When you use/create a macvtap interface in passthrou mode, the lowerdev
is put
into promiscuous mode (NOTE: this may change if/once Roopa's rx_filter
changes
get merged - http://www.spinics.net/lists/netdev/msg174245.html).

However, macvtap also puts the lowerdev into promiscuous mode when
- mode is "macvtap private"
AND
- the lowerdev does not support ndo_set_rx_mode

This would be the codepath in the latter case:

macvlan_open
|
+--> dev_uc_add
     |
     +--> __dev_set_rx_mode
         |
         +--> if (!ndo_set_rx_mode)
                __dev_set_promiscuity

The difference between the two cases above (passthru vs private) however
is that the status of IFF_PROMISC is not exported the same way to user
space:
In the second case (private) dev_get_flags does not return the
IFF_PROMISC flag.
This means that, for example, neither 'ifconfig' nor 'ip link' show that
the
lowerdev is in promisc mode. This does not help throubleshooting.

Yes, the kernel generates a log message when it changes the promiscuity
mode
of the card, but...

Yes, you can check whether IFF_PROMISC is set or not by looking at

  /sys/class/net/<dev_name>/flags

but I can't see why dev_get_flags should not return it too.
Right now dev_get_flags returns IFF_PROMISC only if it set in
dev->gflags, ie it
ignores dev->flags & IFF_PROMISC.
Is this the expected behavior by design?

/Chris
