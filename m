From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Mon, 20 Jul 2009 07:55:56 -0700 (PDT)
Message-ID: <20090720.075556.92145474.davem@davemloft.net>
References: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com>
	<200907171547.39815.oliver@neukum.org>
	<200907200935.19103.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oliver@neukum.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751038AbZGTOzv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 10:55:51 -0400
In-Reply-To: <200907200935.19103.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Mon, 20 Jul 2009 09:35:18 +0300

> In the racy case, tx_complete() fires, incrementation in
> usbpn_xmit() and decrementation in tx_complete() will cancel each
> other. So, regardless of their respective order, tx_queue will be
> unchanged, and the assertion remains valid. A fortiori, it works
> fine if usbpn_xmit() races with more than one call of tx_complete().

You can only do the wakeup race free without deadlocking the TX queue
state if you grab the TX path lock, as TG3 does:

	/* Need to make the tx_cons update visible to tg3_start_xmit()
	 * before checking for netif_queue_stopped().  Without the
	 * memory barrier, there is a small possibility that tg3_start_xmit()
	 * will miss it and cause the queue to be stopped forever.
	 */
	smp_mb();

	if (unlikely(netif_queue_stopped(tp->dev) &&
		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
		netif_tx_lock(tp->dev);
		if (netif_queue_stopped(tp->dev) &&
		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
			netif_wake_queue(tp->dev);
		netif_tx_unlock(tp->dev);
	}
