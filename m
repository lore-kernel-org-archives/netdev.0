From: Alexander Aring <aar@pengutronix.de>
Subject: bluetooth 6lowpan interfaces are not virtual anymore
Date: Mon, 17 Apr 2017 19:56:12 +0200
Message-ID: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
        "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>,
        Linux Bluetooth <linux-bluetooth@vger.kernel.org>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48405 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752904AbdDQR4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:56:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

bluetooth-next contains patches which introduces a queue for bluetooth
6LoWPAN interfaces. [0]

At first, the current behaviour is now that 802.15.4 6LoWPAN interfaces
are virtual and bluetooth 6LoWPAN interfaces are not virtual anymore.
To have a different handling in both subsystems is _definitely_ wrong.

What does the 6LoWPAN interface?

It will do a protocol change (an adaptation, because 6LoWPAN should
provide the same functionality as IPv6) from IPv6 to 6LoWPAN (tx) and
vice versa for (rx). In my opinion this should be handled as a virtual
interface and not as an interface with a queue.

What makes a queue on 6LoWPAN interfaces?

It will queue IPv6 packets which waits for it adaptation (the protocol
change) with some additional qdisc handling.
If finally the xmit_do callback will occur it will replace IPv6 header
with 6LoWPAN, etc. After that it should be queued into some queue on
link layer side which should be do the transmit finally.

Why I think bluetooth introduced a queue handling on 6LoWPAN interfaces?

Because I think they don't like their own *qdisc* handling on their link
layer interface. I write *qdisc* here because, they have no net_devices
and use some kind of own qdisc handling.

My question: is this correct?

How to fix that (In my opinion):

So commit [0] says something "out of credits" that's what I think it's
the *qdisc* handling. If you cannot queue anymore -> you need to drop
it. If you don't like how the current behaviour is, you need to change
your *qdisc* handling on your link layer interface. Introducing queue at
6LoWPAN interfaces will introduce "buffer bloating".

---

I don't care what bluetooth does with the 6LoWPAN interface. If bluetooth
people wants such behaviour, then I am okay with that.

I will bookmark this mail for the time when somebody reverts it to a
virtual interface again. I think somebody will change it again, or maybe
somebody will argument why we need a queue here. 

- Alex

[0] https://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git/commit/?id=814f1b243d2c63928f6aa72d66bec0e5fae2f4a9
