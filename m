From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking event type
Date: Mon, 20 Jan 2014 13:51:22 -0800
Message-ID: <87eh428gpx.fsf@xmission.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49032 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaATVvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 16:51:38 -0500
In-Reply-To: <1389959706-30976-1-git-send-email-dborkman@redhat.com> (Daniel
	Borkmann's message of "Fri, 17 Jan 2014 12:55:06 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <dborkman@redhat.com> writes:

> Jesse Brandeburg reported that commit acaf4e70997f caused a panic
> when adding a network namespace while vxlan module was present in
> the system:
>
> [<ffffffff814d0865>] vxlan_lowerdev_event+0xf5/0x100
> [<ffffffff816e9e5d>] notifier_call_chain+0x4d/0x70
> [<ffffffff810912be>] __raw_notifier_call_chain+0xe/0x10
> [<ffffffff810912d6>] raw_notifier_call_chain+0x16/0x20
> [<ffffffff815d9610>] call_netdevice_notifiers_info+0x40/0x70
> [<ffffffff815d9656>] call_netdevice_notifiers+0x16/0x20
> [<ffffffff815e1bce>] register_netdevice+0x1be/0x3a0
> [<ffffffff815e1dce>] register_netdev+0x1e/0x30
> [<ffffffff814cb94a>] loopback_net_init+0x4a/0xb0
> [<ffffffffa016ed6e>] ? lockd_init_net+0x6e/0xb0 [lockd]
> [<ffffffff815d6bac>] ops_init+0x4c/0x150
> [<ffffffff815d6d23>] setup_net+0x73/0x110
> [<ffffffff815d725b>] copy_net_ns+0x7b/0x100
> [<ffffffff81090e11>] create_new_namespaces+0x101/0x1b0
> [<ffffffff81090f45>] copy_namespaces+0x85/0xb0
> [<ffffffff810693d5>] copy_process.part.26+0x935/0x1500
> [<ffffffff811d5186>] ? mntput+0x26/0x40
> [<ffffffff8106a15c>] do_fork+0xbc/0x2e0
> [<ffffffff811b7f2e>] ? ____fput+0xe/0x10
> [<ffffffff81089c5c>] ? task_work_run+0xac/0xe0
> [<ffffffff8106a406>] SyS_clone+0x16/0x20
> [<ffffffff816ee689>] stub_clone+0x69/0x90
> [<ffffffff816ee329>] ? system_call_fastpath+0x16/0x1b
>
> Apparently loopback device is being registered first and thus we
> receive an event notification when vxlan_net is not ready. Hence,
> when we call net_generic() and request vxlan_net_id, we seem to
> access garbage at that point in time. In setup_net() where we set
> up a newly allocated network namespace, we traverse the list of
> pernet ops ...
>
> list_for_each_entry(ops, &pernet_list, list) {
> 	error = ops_init(ops, net);
> 	if (error < 0)
> 		goto out_undo;
> }
>
> ... and loopback_net_init() is invoked first here, so in the middle
> of setup_net() we get this notification in vxlan. As currently we
> only care about devices that unregister, move access through
> net_generic() there. Fix is based on Cong Wang's proposal, but
> only changes what is needed here. It sucks a bit as we only work
> around the actual cure: right now it seems the only way to check if
> a netns actually finished traversing all init ops would be to check
> if it's part of net_namespace_list. But that I find quite expensive
> each time we go through a notifier callback. Anyway, did a couple
> of tests and it seems good for now.

I am not going to argue against this patch as an immediate bug fix but
something smells here, that bears deeper investigation.  It looks like
the symptom is being patched rather than the actual problem.

In particular net_generic(dev_net(dev), vxlan_net_id) is valid at the
point that it is being called.  As the pointers are allocated in
copy_net_ns in net_alloc prior to setup_net being called.

On the flip side it is the responsibility of code that uses both
register_netdev_notifier and register_pernet_xxx to be ready to handle
events from any namespace as soon as they happen.  vxlan should be using
register_pernet_subsys instead of register_pernet_device to ensure the
vxlan_net structure is initialized before and cleaned up after all
network devices in a given network namespace.  The vlan devices with a
similar problem already do this.

So in summary.  Something smells and I don't believe this patch fixes
the underlying issue.  Please take a deeper look into what vxlan is doing.

Eric


> Fixes: acaf4e70997f ("net: vxlan: when lower dev unregisters remove vxlan dev as well")
> Reported-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  drivers/net/vxlan.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index a2dee80..d6ec71f 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2681,10 +2681,12 @@ static int vxlan_lowerdev_event(struct notifier_block *unused,
>  				unsigned long event, void *ptr)
>  {
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
> -	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
> +	struct vxlan_net *vn;
>  
> -	if (event == NETDEV_UNREGISTER)
> +	if (event == NETDEV_UNREGISTER) {
> +		vn = net_generic(dev_net(dev), vxlan_net_id);
>  		vxlan_handle_lowerdev_unregister(vn, dev);
> +	}
>  
>  	return NOTIFY_DONE;
>  }
