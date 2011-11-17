From: Tom Herbert <therbert@google.com>
Subject: root_lock vs. device's TX lock
Date: Thu, 17 Nov 2011 08:10:01 -0800
Message-ID: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:59287 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932457Ab1KQQKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 11:10:02 -0500
Received: by iage36 with SMTP id e36so2290578iag.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 08:10:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From sch_direct_xmit:

        /* And release qdisc */
        spin_unlock(root_lock);

        HARD_TX_LOCK(dev, txq, smp_processor_id());
        if (!netif_tx_queue_frozen_or_stopped(txq))
                ret = dev_hard_start_xmit(skb, dev, txq);

        HARD_TX_UNLOCK(dev, txq);

        spin_lock(root_lock);

This is a lot of lock manipulation to basically switch from one lock
to another and possibly thrashing just to send a packet.  I am
thinking that if the there is a 1-1 correspondence between qdisc and
device queue then we could actually use the device's lock as the root
lock for the qdisc.  So in that case, we would need to touch any locks
from sch_direct_xmit (just hold root lock which is already device lock
for the duration).

Is there any reason why this couldn't work?
