From: Andrew Morton <akpm@osdl.org>
Subject: Re: "deadlock" between smc91x driver and link_watch
Date: Tue, 23 Nov 2004 15:31:58 -0800
Message-ID: <20041123153158.6f20a7d7.akpm@osdl.org>
References: <1101230194.14370.12.camel@icampbell-debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ian Campbell <icampbell@arcom.com>
In-Reply-To: <1101230194.14370.12.camel@icampbell-debian>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ian Campbell <icampbell@arcom.com> wrote:
>
> Hi,
> 
> I'm seeing a deadlock in linkwatch_event() when bringing down an
> Ethernet interface using the smc91x driver (drivers/net/smc91x.c).
> 
> What I am seeing is that smc_close() is calling netif_carrier_off which
> has the call chain:
> 	netif_carrier_off
> 	-> linkwatch_fire_event
> 	   -> schedule_work or schedule_delayed_work
> The function that is scheduled is linkwatch_event().
> 
> smc_close() then goes on to call flush_scheduled_work() in order to
> ensure that it's own pending workqueue stuff (smc_phy_configure()) is
> completed before powering down the PHY.
> 
> What I am seeing is that linkwatch_event() is deadlocking trying take
> rtnl_sem via rtnl_shlock(). The lock appears to already be held by a
> call to rtnl_lock() from devinet_ioctl().
> 
> Any ideas? Perhaps smc_phy_configure calls could just check that the
> interface is up before continuing, then there would be no need to flush
> the queue to get rid of it.
> 

linkwatch probably doesn't need the flush_scheduled_work(), because it
correctly does refcounting on the device.  Presumably that
flush_scheduled_work() in smc_close() is there to force out any pending
calls to smc_phy_configure().

One possible fix would be to remove that flush_scheduled_work() and to do
refcounting around smc_phy_configure(): dev_hold() when scheduling the work
(if schedule_work() returned true), dev_put() in the handler.
