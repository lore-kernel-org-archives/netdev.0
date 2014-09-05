From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: fix and review whole driver locking
Date: Thu, 04 Sep 2014 22:22:40 -0700 (PDT)
Message-ID: <20140904.222240.631527743151693875.davem@davemloft.net>
References: <1409637603-17347-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bigeasy@linutronix.de,
	khoroshilov@ispras.ru
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaIEFWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:22:43 -0400
In-Reply-To: <1409637603-17347-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 2 Sep 2014 08:00:03 +0200

> The patch reviews the tx lock removing it because the driver
> claims the resource in NAPI context and, as designed, can run
> w/o any own extra lock (so just netif_tx_lock).
> This shows an impact on performances too.

It's not that simple, you have to make some changes if you really
want to allow these two threads of control to run asynchronously.

Look at this comment from tg3_tx() in the tg3 driver for example:

====================
	tnapi->tx_cons = sw_idx;

	/* Need to make the tx_cons update visible to tg3_start_xmit()
	 * before checking for netif_queue_stopped().  Without the
	 * memory barrier, there is a small possibility that tg3_start_xmit()
	 * will miss it and cause the queue to be stopped forever.
	 */
	smp_mb();

	if (unlikely(netif_tx_queue_stopped(txq) &&
====================

With the lock removed, these two code paths will operate and execute
completely in parallel with eachother.  Therefore the updates of
certain TX ring state variables will need to be strictly ordered.
