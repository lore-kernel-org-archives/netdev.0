From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: rtnl_lock deadlock on 3.10
Date: Mon, 29 Jul 2013 18:02:16 -0500
Message-ID: <20130729230216.GB4396@sbohrermbp13-local.rgmadvisors.com>
References: <20130701145456.GA7756@sbohrermbp13-local.rgmadvisors.com>
 <20130702082818.GA26178@order.stressinduktion.org>
 <kqul4h$ib8$1@ger.gmane.org>
 <20130703051152.GA12615@order.stressinduktion.org>
 <20130703053307.GB12615@order.stressinduktion.org>
 <20130703172239.GA3439@sbohrermbp13-local.rgmadvisors.com>
 <51D45EB3.7030404@mellanox.com>
 <20130715143819.GA3084@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, roland@purestorage.com,
	swise@chelsio.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:35086 "EHLO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755005Ab3G2XCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 19:02:20 -0400
Received: by mail-oa0-f50.google.com with SMTP id i4so1708942oah.23
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 16:02:19 -0700 (PDT)
In-Reply-To: <20130715143819.GA3084@sbohrermbp13-local.rgmadvisors.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 15, 2013 at 09:38:19AM -0500, Shawn Bohrer wrote:
> On Wed, Jul 03, 2013 at 08:26:11PM +0300, Or Gerlitz wrote:
> > On 03/07/2013 20:22, Shawn Bohrer wrote:
> > >On Wed, Jul 03, 2013 at 07:33:07AM +0200, Hannes Frederic Sowa wrote:
> > >>On Wed, Jul 03, 2013 at 07:11:52AM +0200, Hannes Frederic Sowa wrote:
> > >>>On Tue, Jul 02, 2013 at 01:38:26PM +0000, Cong Wang wrote:
> > >>>>On Tue, 02 Jul 2013 at 08:28 GMT, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > >>>>>On Mon, Jul 01, 2013 at 09:54:56AM -0500, Shawn Bohrer wrote:
> > >>>>>>I've managed to hit a deadlock at boot a couple times while testing
> > >>>>>>the 3.10 rc kernels.  It seems to always happen when my network
> > >>>>>>devices are initializing.  This morning I updated to v3.10 and made a
> > >>>>>>few config tweaks and so far I've hit it 4 out of 5 reboots.  It looks
> > >>>>>>like most processes are getting stuck on rtnl_lock.  Below is a boot
> > >>>>>>log with the soft lockup prints.  Please let know if there is any
> > >>>>>>other information I can provide:
> > >>>>>Could you try a build with CONFIG_LOCKDEP enabled?
> > >>>>>
> > >>>>The problem is clear: ib_register_device() is called with rtnl_lock,
> > >>>>but itself needs device_mutex, however, ib_register_client() first
> > >>>>acquires device_mutex, then indirectly calls register_netdev() which
> > >>>>takes rtnl_lock. Deadlock!
> > >>>>
> > >>>>One possible fix is always taking rtnl_lock before taking
> > >>>>device_mutex, something like below:
> > >>>>
> > >>>>diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
> > >>>>index 18c1ece..890870b 100644
> > >>>>--- a/drivers/infiniband/core/device.c
> > >>>>+++ b/drivers/infiniband/core/device.c
> > >>>>@@ -381,6 +381,7 @@ int ib_register_client(struct ib_client *client)
> > >>>>  {
> > >>>>  	struct ib_device *device;
> > >>>>+	rtnl_lock();
> > >>>>  	mutex_lock(&device_mutex);
> > >>>>  	list_add_tail(&client->list, &client_list);
> > >>>>@@ -389,6 +390,7 @@ int ib_register_client(struct ib_client *client)
> > >>>>  			client->add(device);
> > >>>>  	mutex_unlock(&device_mutex);
> > >>>>+	rtnl_unlock();
> > >>>>  	return 0;
> > >>>>  }
> > >>>>diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> > >>>>index b6e049a..5a7a048 100644
> > >>>>--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
> > >>>>+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> > >>>>@@ -1609,7 +1609,7 @@ static struct net_device *ipoib_add_port(const char *format,
> > >>>>  		goto event_failed;
> > >>>>  	}
> > >>>>-	result = register_netdev(priv->dev);
> > >>>>+	result = register_netdevice(priv->dev);
> > >>>>  	if (result) {
> > >>>>  		printk(KERN_WARNING "%s: couldn't register ipoib port %d; error %d\n",
> > >>>>  		       hca->name, port, result);
> > >>>Looks good to me. Shawn, could you test this patch?
> > >>ib_unregister_device/ib_unregister_client would need the same change,
> > >>too. I have not checked the other ->add() and ->remove() functions. Also
> > >>cc'ed linux-rdma@vger.kernel.org, Roland Dreier.
> > >Cong's patch is missing the #include <linux/rtnetlink.h> but otherwise
> > >I've had 34 successful reboots with no deadlocks which is a good sign.
> > >It sounds like there are more paths that need to be audited and a
> > >proper patch submitted.  I can do more testing later if needed.
> > >
> > >Thanks,
> > >Shawn
> > >
> > 
> > Guys, I was a bit busy today looking into that, but I don't think we
> > want the IB core layer  (core/device.c) to
> > use rtnl locking which is something that belongs to the network stack.
> 
> Has anymore thought been put into a proper fix for this issue?

I'm no expert in this area but I'm having a hard time seeing a
different solution than the one Cong suggested.  Just to be clear the
deadlock I hit was between cxgb3 and the ipoib module, so I've Cc'd
Steve Wise in case he has a better solution from the Chelsio side.
Here are those two stacks again as a reminder:

[  243.301380] INFO: task modprobe:2635 blocked for more than 120 seconds.
[  243.321495] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  243.343008] modprobe        D ffffffff81607960     0  2635   1917 0x00000000
[  243.363956]  ffff880612c11b98 0000000000000002 ffffffff81a10440 ffff880612c11b90
[  243.385305]  00003ffffffff000 ffff880612a8adc0 ffff880612c11fd8 ffff880612c11fd8
[  243.406670]  ffff880612c11fd8 ffff880612a8adc0 ffff880612c11fd8 ffffffff81a9c9e0
[  243.428043] Call Trace:
[  243.444258]  [<ffffffff814c4969>] schedule+0x29/0x70
[  243.463136]  [<ffffffff814c4c6e>] schedule_preempt_disabled+0xe/0x10
[  243.483464]  [<ffffffff814c2f62>] __mutex_lock_slowpath+0x112/0x1b0
[  243.503753]  [<ffffffff814c2dda>] mutex_lock+0x2a/0x50
[  243.530031]  [<ffffffff814261e5>] rtnl_lock+0x15/0x20
[  243.549063]  [<ffffffff8141b6f6>] register_netdev+0x16/0x30
[  243.568635]  [<ffffffffa02a71db>] ipoib_add_one+0x32b/0x4c0 [ib_ipoib]
[  243.589253]  [<ffffffff8113361d>] ? kmem_cache_alloc_trace+0x12d/0x160
[  243.609940]  [<ffffffffa00f5be7>] ib_register_client+0x87/0xc0 [ib_core]
[  243.630862]  [<ffffffffa02b9000>] ? 0xffffffffa02b8fff
[  243.650169]  [<ffffffffa02b90e6>] ipoib_init_module+0xe6/0x137 [ib_ipoib]
[  243.671213]  [<ffffffff810002ca>] do_one_initcall+0xea/0x190
[  243.690975]  [<ffffffff81090377>] load_module+0x1407/0x1af0
[  243.710445]  [<ffffffff812868c0>] ? ddebug_add_module+0xf0/0xf0
[  243.730098]  [<ffffffff81090b32>] SyS_init_module+0xd2/0x120
[  243.749357]  [<ffffffff814ce2b9>] tracesys+0xd0/0xd5

[  243.767809] INFO: task ip:2662 blocked for more than 120 seconds.
[  243.787583] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  243.809193] ip              D ffffffff81607960     0  2662   2637 0x00000000
[  243.830165]  ffff880c04b5f558 0000000000000002 ffff880c13d844a0 ffffffff8127d463
[  243.851709]  000080d00030c0d0 ffff880c12e8db80 ffff880c04b5ffd8 ffff880c04b5ffd8
[  243.873311]  ffff880c04b5ffd8 ffff880c12e8db80 0000000000008000 ffffffffa00fd400
[  243.894929] Call Trace:
[  243.911445]  [<ffffffff8127d463>] ? gen_pool_add_virt+0x53/0xb0
[  243.931762]  [<ffffffff814c4969>] schedule+0x29/0x70
[  243.951054]  [<ffffffff814c4c6e>] schedule_preempt_disabled+0xe/0x10
[  243.971786]  [<ffffffff814c2f62>] __mutex_lock_slowpath+0x112/0x1b0
[  243.992424]  [<ffffffff8127d463>] ? gen_pool_add_virt+0x53/0xb0
[  244.012708]  [<ffffffff814c2dda>] mutex_lock+0x2a/0x50
[  244.032203]  [<ffffffffa00f5c5f>] ib_register_device+0x3f/0x4d0 [ib_core]
[  244.053500]  [<ffffffff8113361d>] ? kmem_cache_alloc_trace+0x12d/0x160
[  244.074665]  [<ffffffffa01fba3e>] ? iwch_register_device+0x2ae/0x3d0 [iw_cxgb3]
[  244.096749]  [<ffffffffa01fbac8>] iwch_register_device+0x338/0x3d0 [iw_cxgb3]
[  244.118752]  [<ffffffffa01fc1e7>] open_rnic_dev+0x247/0x340 [iw_cxgb3]
[  244.140170]  [<ffffffffa0a192be>] cxgb3_add_clients+0x3e/0x60 [cxgb3]
[  244.161569]  [<ffffffffa0a069c0>] cxgb_open+0x320/0x360 [cxgb3]
[  244.182341]  [<ffffffff8141aa3f>] __dev_open+0xcf/0x150
[  244.202210]  [<ffffffff8141ad11>] __dev_change_flags+0xa1/0x180
[  244.222602]  [<ffffffff8141aea8>] dev_change_flags+0x28/0x70
[  244.242568]  [<ffffffff81426652>] do_setlink+0x252/0x960
[  244.262128]  [<ffffffffa005500a>] ? inet6_fill_link_af+0x1a/0x30 [ipv6]
[  244.283144]  [<ffffffff81286fc0>] ? nla_parse+0x30/0xe0
[  244.302572]  [<ffffffff81429a19>] rtnl_newlink+0x359/0x560
[  244.322229]  [<ffffffff814295dd>] rtnetlink_rcv_msg+0x14d/0x230
[  244.342348]  [<ffffffff8140b22b>] ? __alloc_skb+0x8b/0x2b0
[  244.361988]  [<ffffffff81429490>] ? __rtnl_unlock+0x20/0x20
[  244.381664]  [<ffffffff81444079>] netlink_rcv_skb+0xa9/0xd0
[  244.401320]  [<ffffffff81426215>] rtnetlink_rcv+0x25/0x40
[  244.420848]  [<ffffffff81443a31>] netlink_unicast+0x161/0x1e0
[  244.440693]  [<ffffffff81443d4b>] netlink_sendmsg+0x29b/0x340
[  244.460443]  [<ffffffff81400776>] sock_sendmsg+0x76/0x90
[  244.479751]  [<ffffffff81403564>] ? move_addr_to_kernel+0x44/0x60
[  244.499905]  [<ffffffff8140f426>] ? verify_iovec+0x56/0xd0
[  244.519493]  [<ffffffff8140292c>] ___sys_sendmsg+0x38c/0x3a0
[  244.539314]  [<ffffffff8110fee0>] ? handle_mm_fault+0x210/0x310
[  244.559424]  [<ffffffff814c9714>] ? __do_page_fault+0x274/0x4c0
[  244.579490]  [<ffffffff811135d5>] ? __vma_link_rb+0x105/0x120
[  244.599250]  [<ffffffff811136bf>] ? vma_link+0xcf/0xe0
[  244.618153]  [<ffffffff810ac809>] ? rcu_eqs_exit+0x59/0xb0
[  244.637209]  [<ffffffff81403f19>] __sys_sendmsg+0x49/0x90
[  244.656010]  [<ffffffff81403f79>] SyS_sendmsg+0x19/0x20
[  244.674518]  [<ffffffff814ce2b9>] tracesys+0xd0/0xd5

Looking back at the history these code paths it looks like they've
been there since day one, so I suppose I've just been lucky to not his
this before.  Even so I'd like to see some kind of official fix for
this so I don't have to carry a custom patch in my tree forever.

--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
