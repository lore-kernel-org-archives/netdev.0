From: Roland Dreier <roland@topspin.com>
Subject: Re: Re: LLTX and netif_stop_queue
Date: Sat, 18 Dec 2004 10:26:40 -0800
Message-ID: <52oegrmpi7.fsf@topspin.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<528y7vobze.fsf@topspin.com> <52sm63mqtk.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <52sm63mqtk.fsf@topspin.com> (Roland Dreier's message of "Sat,
	18 Dec 2004 09:58:15 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Roland> So it seems LLTX can be replaced by just having drivers
    Roland> use net_device.xmit_lock instead of their own private
    Roland> tx_lock.  Assuming this works (and I don't see anything
    Roland> wrong with it) then this seems like a pretty nice
    Roland> solution: we remove some code from the networking core and
    Roland> get rid of all the "trylock" logic in driver's
    Roland> hard_start_xmit.

Actually trying it instead of talking out of my ass...

Just doing this naively without changing the net core can deadlock
because the net core acquires dev->xmit_lock without disabling
interrupts.  So if the driver tries to use xmit_lock in its interrupt
handler, it will deadlock if the interrupt occurred during
hard_start_xmit.  Even doing local_irq_save() in hard_start_xmit isn't
good enough, because there's still a window between the net core's
call to hard_start_xmit and the actual local_irq_save where xmit_lock
is held with interrupts on.

Maybe it makes sense to change NETIF_F_LLTX to NETIF_F_TX_IRQ_DIS or
something like that and have that flag mean "disable interrupts when
calling hard_start_xmit."  (We could just do this unconditionally but
I'm not sure if any drivers rely on having interrupts enabled during
hard_start_xmit and I'm worried about making a change in semantics
like that -- not to mention some drivers may not need interrupts
disabled and may not want the cost).

 - Roland
