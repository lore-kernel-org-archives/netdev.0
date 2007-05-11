From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] ppp_generic: lockdep class for ppp _xmit_lock Re: ppp_generic: fix lockdep warning
Date: Fri, 11 May 2007 09:00:30 +0200
Message-ID: <20070511070030.GA978@ff.dom.local>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net> <20070426.013911.69219176.davem@davemloft.net> <20070426104950.GA3145@ff.dom.local> <20070509093536.GA2436@ff.dom.local> <001801c79275$80cd5e00$0701010a@note>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	paulus@samba.org, greearb@candelatech.com, mostrows@speakeasy.net,
	davem@davemloft.net
To: "Yuriy N\. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:35998 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755028AbXEKGyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 02:54:09 -0400
Content-Disposition: inline
In-Reply-To: <001801c79275$80cd5e00$0701010a@note>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Read below, please:

On Thu, May 10, 2007 at 12:06:09AM +0400, Yuriy N. Shkandybin wrote:
> After applying this patch i've got this:
> 
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.21-gentoo #2
> -------------------------------------------------------
> ospfd/3984 is trying to acquire lock:
> (&ppp->wlock){-...}, at: [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
> 
> but task is already holding lock:
> (&dev->_xmit_lock){-+..}, at: [<ffffffff8038d778>] __qdisc_run+0x88/0x1c3
> 
> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #3 (&dev->_xmit_lock){-+..}:
...
>       [<ffffffff8038663c>] dev_mc_add+0x3c/0x148
>       [<ffffffff8025e14c>] _spin_lock_bh+0x23/0x2c
>       [<ffffffff8038663c>] dev_mc_add+0x3c/0x148
>       [<ffffffff803bf0fc>] vlan_dev_set_multicast_list+0xfc/0x2a0
>       [<ffffffff80386707>] dev_mc_add+0x107/0x148
...
> -> #2 (&vlan_netdev_xmit_lock_key){-...}:
...
>       [<ffffffff8022de38>] dev_queue_xmit+0x178/0x263
>       [<ffffffff8025e120>] _spin_lock+0x1e/0x27
>       [<ffffffff8022de38>] dev_queue_xmit+0x178/0x263
>       [<ffffffff80354f57>] __pppoe_xmit+0x217/0x23b
>       [<ffffffff803523e3>] ppp_channel_push+0x43/0xb9
>       [<ffffffff8035331a>] ppp_write+0x10a/0x120
...
> -> #1 (&pch->downl){-...}:
...
>       [<ffffffff803509d5>] ppp_push+0x45/0xaf
>       [<ffffffff8025e14c>] _spin_lock_bh+0x23/0x2c
>       [<ffffffff803509d5>] ppp_push+0x45/0xaf
>       [<ffffffff803516e7>] ppp_xmit_process+0x467/0x4f0
>       [<ffffffff80287dca>] trace_hardirqs_on+0x12e/0x164
...
> -> #0 (&ppp->wlock){-...}:
...
>       [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
>       [<ffffffff8025e14c>] _spin_lock_bh+0x23/0x2c
>       [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
>       [<ffffffff80287daf>] trace_hardirqs_on+0x113/0x164
>       [<ffffffff803531bc>] ppp_start_xmit+0x1dc/0x230
>       [<ffffffff8038d7f5>] __qdisc_run+0x105/0x1c3
>       [<ffffffff8022dddf>] dev_queue_xmit+0x11f/0x263
>       [<ffffffff80237533>] ip_mc_output+0x333/0x370
>       [<ffffffff803a9460>] raw_sendmsg+0x560/0x729
...
> other info that might help us debug this:
> 
> 1 lock held by ospfd/3984:
> #0:  (&dev->_xmit_lock){-+..}, at: [<ffffffff8038d778>] 
> __qdisc_run+0x88/0x1c3
...

Here is a patch to do for ppp something similar as in vlan:
kind of lockdep configuration. I think this is useful, even
if it doesn't fix this particular problem, and IMHO should
be safe - likewise - my previous, vlan patch. These patches
should enough with simpler situations, up to two types of
interfaces (e.g. vlan with ppp with eth). There could be
something like vlan with ppp with eth with other ppp or
something virtual, so lockdep is going crazy. 

It seems that above "-> #3 (&dev->_xmit_lock)" is on eth (not
ppp at least), while "#0: (&dev->_xmit_lock)" held at the end
belongs to ppp. After this patch we should be at least sure
of this.

Yuriy, could you try this patch, please?
This is done on 2.6.21, but could be applied to current -mm
or -git, too. (My previous: vlan & ppp_generic patches should
stay too.)

> Yes, there is no real lockup with pppoe
> ll repeat my configuration:
> vpn (pptp(mostly)+pppoe) concentrator
> PPPoE provided through 802.1q
> +OSPF (quagga)
> 
> Jura

Jura, it would be useful to know, at least, which types of
interfaces are added to your vlans/802.1q and pppoe, so
maybe you could send some parts of configs or at least
"ip link" output.

Regards,
Jarek P.
--->

This patch's aim is to let lockdep see ppp dev->_xmit_lock as
different from others, after register_netdev inits this lock.

Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michal Ostrowski <mostrows@speakeasy.net>
Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.21-/drivers/net/ppp_generic.c 2.6.21/drivers/net/ppp_generic.c
--- 2.6.21-/drivers/net/ppp_generic.c	2007-05-10 20:05:42.000000000 +0200
+++ 2.6.21/drivers/net/ppp_generic.c	2007-05-10 21:35:46.000000000 +0200
@@ -2399,6 +2399,10 @@ ppp_get_stats(struct ppp *ppp, struct pp
  * or if there is already a unit with the requested number.
  * unit == -1 means allocate a new number.
  */
+
+/* ppp dev->_xmit_lock shouldn't be mixed with others used e.g. with pppoe */
+static struct lock_class_key ppp_netdev_xmit_lock_key;
+
 static struct ppp *
 ppp_create_interface(int unit, int *retp)
 {
@@ -2456,6 +2460,7 @@ ppp_create_interface(int unit, int *retp
 	if (ret != 0)
 		goto out3;
 
+	lockdep_set_class(&dev->_xmit_lock, &ppp_netdev_xmit_lock_key);
 	mutex_unlock(&all_ppp_mutex);
 	*retp = 0;
 	return ppp;
