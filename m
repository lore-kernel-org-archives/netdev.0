From: Nate Case <ncase@xes-inc.com>
Subject: Re: bug: mutex_lock() in interrupt conntext via phy_stop() in gianfar
Date: Mon, 21 Jul 2008 17:57:08 -0500
Message-ID: <1216681028.7559.993.camel@localhost.localdomain>
References: <20080718121008.GA28871@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Vitaly Bordug <vbordug@ru.mvista.com>, Li Yang <leoli@freescale.com>
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080718121008.GA28871@Chamillionaire.breakpoint.cc>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-07-18 at 14:10 +0200, Sebastian Siewior wrote:
> Commit 35b5f6b1a aka [PHYLIB: Locking fixes for PHY I/O potentially sleeping]
> changed the phydev->lock from spinlock into a mutex. Now, the following
> code path got triggered while NFS was unavailable:
> 
[snip]
> |[  194.864733] BUG: sleeping function called from invalid context at /home/bigeasy/git/linux-2.6-powerpc/kernel/mutex.c:87
> |[  194.875529] in_atomic():1, irqs_disabled():0
> |[  194.879805] Call Trace:
> |[  194.882250] [c0383d90] [c0006dd8] show_stack+0x48/0x184 (unreliable)
> |[  194.888649] [c0383db0] [c001e938] __might_sleep+0xe0/0xf4
> |[  194.894069] [c0383dc0] [c025a43c] mutex_lock+0x24/0x3c
> |[  194.899234] [c0383de0] [c019005c] phy_stop+0x20/0x70
> |[  194.904234] [c0383df0] [c018d4ec] stop_gfar+0x28/0xf4
> |[  194.909305] [c0383e10] [c018e8c4] gfar_timeout+0x30/0x60
> |[  194.914638] [c0383e20] [c01fe7c0] dev_watchdog+0xa8/0x144

Hmm..  I'm not sure what the best solution is to this.  Make the
stop_gfar() call happen in a workqueue, and make a similar change to
ucc_geth, fec_mpc52xx, and fs_enet? Modify phy_stop() to do the work in
a workqueue conditionally if in interrupt context?  Between these two
I'd lean toward the latter.

Does anyone have any better ideas?

-- 
Nate Case <ncase@xes-inc.com>
