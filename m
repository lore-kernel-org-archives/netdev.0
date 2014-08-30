From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Sat, 30 Aug 2014 03:51:29 +0200
Message-ID: <1409363489.2980.17.camel@localhost>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	 <CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	 <20140829195339.GA9780@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140829195339.GA9780@kria>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sabrina,

On Fr, 2014-08-29 at 21:53 +0200, Sabrina Dubroca wrote:
> 2014-08-29, 11:14:48 -0700, Cong Wang wrote:
> > On Fri, Aug 29, 2014 at 8:26 AM, Tommi Rantala <tt.rantala@gmail.com> wrote:
> > > [   77.297196] RTNL: assertion failed at net/ipv6/addrconf.c (1699)
> > > [   77.298080] CPU: 0 PID: 4842 Comm: trinity-main Not tainted 3.17.0-rc2+ #30
> > > [   77.299039] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > > [   77.299789]  ffff88003d76a618 ffff880026133c50 ffffffff8238ba79
> > > ffff880037c84520
> > > [   77.300829]  ffff880026133c90 ffffffff820bd52b 0000000000000000
> > > ffffffff82d86c40
> > > [   77.301869]  0000000000000000 00000000f76fd1e1 ffff8800382d8000
> > > ffff8800382d8220
> > > [   77.302906] Call Trace:
> > > [   77.303246]  [<ffffffff8238ba79>] dump_stack+0x4d/0x66
> > > [   77.303928]  [<ffffffff820bd52b>] addrconf_join_solict+0x4b/0xb0
> > > [   77.304731]  [<ffffffff820b031b>] ipv6_dev_ac_inc+0x2bb/0x330
> > > [   77.305498]  [<ffffffff820b0060>] ? ac6_seq_start+0x260/0x260
> > > [   77.306257]  [<ffffffff820b05fe>] ipv6_sock_ac_join+0x26e/0x360
> > > [   77.307046]  [<ffffffff820b0429>] ? ipv6_sock_ac_join+0x99/0x360
> > > [   77.307798]  [<ffffffff820cdd60>] do_ipv6_setsockopt.isra.5+0xa70/0xf20
> > 
> > 
> > I think we should just use rtnl_lock() instead of rcu_read_lock() there,
> > it is not a hot path worth optimization.
> > 
> > Please try the attached patch.
> 
> note: it doesn't build as it is now, it needs:
> 
> -EXPORT_SYMBOL(dev_get_by_flags_rcu);
> +EXPORT_SYMBOL(dev_get_by_flags);
> 
> 
> I just tried your patch with a basic test program (open
> socket/join/leave/close and open socket/join/close).
> 
> I think you need to modify ipv6_sock_ac_close as well, or you can still
> trigger the assertion when closing the socket without leaving first.
> 
> Modified patch attached.

Sorry, just had time to look at this.

The reason is not to have list corruption but that the calls down to
ndo_set_rx_mode expect rtnl to be locked by the drivers. Filter lists
are locked by addr_list_lock and that's why I think we never saw any
problems with that, but drivers expect rtnl locked for those calls.

But this problem also affects multicast join, so patch seems incomplete
to me (and for that matter ssm multicast join, too).

Also rtnl_lock and rcu_read_lock compose in that order, so we don't need
to change dev_get_by_flags, but as this is the only user it sure is
possible. RCU locked version is just easier composeable, so I wouldn't
touch that if needed in future, just also take rcu lock as before.

So just adding rtnl_lock add appropriate places seems to be ok to me,
but still need to review parts of the ssm code.

Also we should move ASSERT_RTNL checks from addrconf_join_solict to
ipv6_dev_mc_inc/dec.

Thanks,
Hannes
