From: Alexander Aring <aar@pengutronix.de>
Subject: drop all fragments inside tx queue if one gets dropped
Date: Wed, 20 Apr 2016 11:52:22 +0200
Message-ID: <57175156.3050501@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42695 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932980AbcDTJwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 05:52:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On linux-wpan we had a discussion about setting the right tx_queue_len
and came to some issues in 802.15.4 6LoWPAN networks.

Our hardware parameters are:
 
 - Bandwidth: 250kb/s
 - One framebuffer at hardware side for transmit a frame.
 - MTU - 127 bytes (without mac headers)

To provide 6LoWPAN (IPv6) on such interface, we have two interfaces.

One wpan interface (which works on 802.15.4 layer and has a queue) and
another lowpan interface (gets IPv6 and queue 6LoWPAN into wpan
interface, has no queue - it's virtual interface).

If the IPv6 packets needs fragmentation, mostly if payload is 127 bytes.
We have the following situation:

 - 6lowpan interface gets IPv6 packet:
   - generate 6LoWPAN fragments
     - dev_queue_xmit(wpan_dev, frag1)
     - dev_queue_xmit(wpan_dev, frag2)
     - dev_queue_xmit(wpan_dev, frag3)
     - dev_queue_xmit(wpan_dev, ...)

And then a lot of fragments laying inside the tx_queue and waits to
transfer to the transceiver which has only one framebuffer to transmit
one frame and waits for tx completion to transfer the next one.

My question is, if qdisc drops some fragment because the queue is full
or something else. Exists there some way to remove all fragments inside
the queue? If one fragment will be dropped and all related are still
inside the queue then we send mostly garbage.

I want to add a behaviour which drops all related fragments for
6LoWPAN fragmentation at first, if the payload is above 1280 bytes, then
we have also IPv6 fragmentation on it. In future I also like to remove
all related 6LoWPAN fragments which are related according to the IPv6
fragment.

- Alex
