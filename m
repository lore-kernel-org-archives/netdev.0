From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: [sungem] proposal for a new locking strategy
Date: Sun, 5 Nov 2006 14:00:31 +0100
Message-ID: <5cac192f0611050500m19f72209vc349f235680023a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:6207 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S965875AbWKENAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 08:00:34 -0500
Received: by nf-out-0910.google.com with SMTP id c2so370635nfe
        for <netdev@vger.kernel.org>; Sun, 05 Nov 2006 05:00:32 -0800 (PST)
To: "David S. Miller" <davem@davemloft.net>,
	"Benjamin Herrenschmidt" <benh@kernel.crashing.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Some (long) time ago benh wrote a blaming comment in sungem.c about
that driver's locking strategy. That comment basically says that we
probably don't need two spinlocks.

I agree!

Proposal:

Today's sungem effectively uses two spinlock's: "lock" and "tx_lock".

"tx_lock" is held by the xmit function when sending out a packet. Lots
of functions grab "tx_lock" not to mess up with xmit (gem_stop_phy(),
gem_change_mtu(), etc.).

All of these funcs also take "lock"!

What we could do is remove "lx_lock", have the above functions take
only "lock", and rely on dev->_xmit_lock to protect the xmit func from
reentrance. In that case, obviously, the driver wouldn't feature LLTX
anymore.

When (re-)configuring we'd now quiesce the device, with the new
functions gem_netif_stop() and gem_full_lock(), in the same way as tg3
does.

gem_interrupt(), gem_poll(), and gem_start_xmit() could become lockless. Fast!

Basically this proposal makes the data path faster, the control path
slower, and simplifies the code by using one single spinlock within
the driver.

If the idea seems reasonable to you guys I can go ahead and cook up something...

Thanks,

-- 
Eric
