From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] r8169: non-NAPI netif_poll_disable removal
Date: Sat, 6 Nov 2004 15:56:18 +0100
Message-ID: <20041106145618.GA4895@electric-eye.fr.zoreil.com>
References: <200411021203.17013.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200411021203.17013.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
> rtl8169_close contains a call to netif_poll_disable.  This call sets and spins 
> on the __LINK_STATE_RX_SCHED bit, which isn't really a problem if this 
> function is only called in close (as that bit is off with NAPI off).  
> However, if the driver hits a transmit timeout (or any other call that 
> references rtl8169_wait_for_quiescence), the the module will hang 
> indefinitely during any subsequent call to netif_poll_disable or dev_close 
> function call because this bit is now set.
> 
> Since this function should not really be called with NAPI off, I chose to 
> remove the calls if NAPI is not defined (See patch below).  The patch is 
> against the 2.6.10-rc1-mm2 version of the driver.  I have verified that this 
> fixes the problem on ppc64 and x86_64.

Yep but it seems to me that there is still a window for a race with NAPI
if the relevant error path is taken:

1 - Tx timeout
2 - rtl8169_reset_task: netif_poll_disable is issued. Assume that the
    refilling of the Rx buffers fails -> rtl8169_reset_task schedules
    itself for later
3 - operator closes the device: netif_running(dev) == 0 and rtl8169_close()
    is issued
4 - rtl8169_close() loops on netif_poll_disable()

Neither __netif_rx_schedule nor netif_poll_enable was issued. Deadlock.

It should be enough to change rtl8169_wait_for_quiescence() for:

static void rtl8169_wait_for_quiescence(struct net_device *dev)
{
        synchronize_irq(dev->irq);

        /* Wait for any pending NAPI task to complete */
        netif_poll_disable(dev);

	RTL_W16(IntrMask, 0x00);

        netif_poll_enable(dev);
}

There will be a few "interrupt XXX taken in poll" when it races with
the irq handler but they are harmless anyway [*].

The lack of netif_poll_enable() after netif_wake_queue() in
rtl8169_reset_task() which you suggested to me should also be fixed
with this change.

[*] Ok, it should be possible to have a BUG_ON due to the simultaneous
    invocation of rtl8169_reinit_task() and rtl8169_reset_task() under
    weird circumstances but this one will be easily fixed by an 
    adequate netif_queue_stopped() in rtl8169_pcierr_interrupt().

--
Ueimor
