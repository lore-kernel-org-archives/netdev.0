From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] e1000 - get rid of tx_lock
Date: Thu, 10 Jun 2004 00:50:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610005021.A10503@electric-eye.fr.zoreil.com>
References: <20040608102729.620dd1fc@dell_ss3.pdx.osdl.net> <20040609144120.1655eee0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeb Cramer <cramerj@intel.com>, John Ronciak <john.ronciak@intel.com>,
        Ganesh Venkatesan <ganesh.venkatesan@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040609144120.1655eee0@dell_ss3.pdx.osdl.net>; from shemminger@osdl.org on Wed, Jun 09, 2004 at 02:41:20PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> The e1000 driver has an tx_lock which unneeded.  It is only used to protect
> the start/stop queue flags which are already handled by doing atomic bit
> operations.

I am not terribly used to this code but as far as I can read it, the lock
avoids that the condition which leads to netif_stop_queue() in the xmit
thread changes (due to an irq) "just before" netif_stop_queue() is actually
called. 

So, if the lock is removed, I would be tempted to have the xmit thread
issue an smp_rmb() and revalidate that it was fine to netif_stop_queue().

Otherwise, one could have:

[e1000_xmit_frame]
	if (E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2 ) {
	<- at the same time on a different CPU ->
	[...]
	e1000_clean_tx_irq::netif_wake_queue() // Plenty of room has been made
	[...]
	<- back to e1000_xmit_frame() ->
		netif_stop_queue
		return 1; 
	}


--
Ueimor
