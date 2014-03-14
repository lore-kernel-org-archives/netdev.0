From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 02/16] ixgbe: fix spinlock recursion with netpoll
 and busy poll
Date: Fri, 14 Mar 2014 14:58:50 -0400 (EDT)
Message-ID: <20140314.145850.706702494963811330.davem@davemloft.net>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1394790446-31591-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, asharma@fb.com,
	stable@vger.kernel.org, jacob.e.keller@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1394790446-31591-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Mar 2014 02:47:12 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch resolves a hang with busy poll when used with netconsole.
> 
> The main change is the check for netpoll packets in ixgbe_poll() which
> prevents a call to spin_lock_bh() while interrupts are disabled.
> 
> In addition it removes the call to netif_rx() since netif_receive_skb()
> can deal with netpoll packets and also replaced the global adapter flag
> with per-q_vector bool that indicates Rx packet from netpoll which
> should help with performance.
> 
> CC: Arun Sharma <asharma@fb.com>
> CC: stable <stable@vger.kernel.org>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Eric Biederman and co. are working to make this completely unnecessary.

What is going to happen is that poll will be called with a budget of
zero, and no RX processing will thus occur, for netpoll.

Nothing in the RX path can handle being invoked from hardware
interrupt context, so we have to prevent it completely in all
drivers that support netpoll.
