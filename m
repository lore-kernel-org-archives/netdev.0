From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Fri, 25 Jul 2008 19:04:36 +0200
Message-ID: <200807251904.37302.netdev@axxeo.de>
References: <1216806614.7257.152.camel@twins> <1216810696.7257.175.camel@twins> <20080723.131441.200166513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, jarkao2@gmail.com, Larry.Finger@lwfinger.net,
	kaber@trash.net, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	mingo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:44648 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbYGYRHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 13:07:08 -0400
In-Reply-To: <20080723.131441.200166513.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller schrieb:
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Wed, 23 Jul 2008 12:58:16 +0200
> 
> > So I guess my question is, is netif_tx_lock() here to stay, or is the
> > right fix to convert all those drivers to use __netif_tx_lock() which
> > locks only a single queue?
> 
> It's staying.
> 
> It's trying to block all potential calls into the ->hard_start_xmit()
> method of the driver, and the only reliable way to do that is to take
> all the TX queue locks.  And in one form or another, we're going to
> have this "grab/release all the TX queue locks" construct.
> 
> I find it interesting that this cannot be simply described to lockdep
> :-)

I'm sure as hell, I miss sth. but can't it be done by this pseudo-code:

netif_tx_lock(device)
{
	mutex_lock(device->queue_entry_mutex);
	foreach_queue_entries(queue, device->queues)
	{
		spin_lock(queue->tx_lock);
		set_noop_tx_handler(queue);
		spin_unlock(queue->tx_lock);
	}
	mutex_unlock(device->queue_entry_mutex);
}

netif_tx_unlock(device)
{
	mutex_lock(device->queue_entry_mutex);
	foreach_queue_entries(queue, device->queues)
	{
		spin_lock(queue->tx_lock);
		set_useful_tx_handler(queue);
		spin_unlock(queue->tx_lock);
	}
	mutex_unlock(device->queue_entry_mutex);
}

Then protect use of the queues by queue->tx_lock in transmit path.
The first setup of the queue doesn't need to be protected, since no-one
knows the device. The final cleanup of the device doesn't need to be
protected either, because netif_tx_lock() and netif_tx_unlock() should
not be called after entering the final cleanup.

Some VM locking works this way...


Best Regards

Ingo Oeser
