From: Alexander Aring <alex.aring@gmail.com>
Subject: IEEE 802.15.4 - Realization interframe spacing time after each
 ndo_start_xmit
Date: Sun, 2 Nov 2014 15:33:48 +0100
Message-ID: <20141102143345.GA15591@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wpan@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:62450 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbaKBOdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 09:33:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the IEEE 802.15.4 standard describes an interframe spacing time.

This spacing time describes that after each transmit we need to wait
some microseconds before we doing the next transmit.

The current workaround is a udelay in driver layer for the at86rf230
driver. [0]

This is a very terrible solution and I need some better one. If I don't
do this wait time I got fragmentation issues at 6LoWPAN layer.

To do a interframe spacing time depends on payload. If the payload is
below 18 bytes we need to wait the "sifs - short interframe spacing time".
If the payload is above or equal 18 bytes we need to wait "lifs - long
interframe spacing time".

Also some transceiver do the interframe spacing time on transceiver level.
For example the at86rf230 do the interframe spacing time on his own when
max_frame_retries parameter is above 1. (Then automatic retransmission
is activated).

I need some solution which I can turn on/off at runtime while running
'ieee802154_xmit_complete". The function "ieee802154_xmit_complete" will
consume the skb and wake the netdev queue again. 



Possible better solution would be:

Better solution would be to take some timestamps after each transmit
complete and wait "if necessary" the calculated lifs/sifs delta time
inside of "ndo_start_xmit" - means before doing next transmit. If we see
in "ndo_start_xmit" that we need some time because the next transmit is
inside the lifs/sifs time of the last transmit we wait the delta time
of last completed transmit timestamp and now to hold the lifs/sifs
timing contraints. But I don't feeling well to do a "udelay" inside of
ndo_start_xmit.



I would be grateful for any suggestion how we can deal which such
interframe spacing time. Maybe there exist already some other L2 layer
which have already a solution for something like that.

- Alex

[0] http://git.kernel.org/cgit/linux/kernel/git/bluetooth/bluetooth-next.git/tree/drivers/net/ieee802154/at86rf230.c?id=fe58d016e396fc685364b5a1743faf83c1fb8103#n722
