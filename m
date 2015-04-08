From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [Patch net-next] vxlan: do not exit on error in vxlan_stop()
Date: Wed, 08 Apr 2015 20:03:09 -0300
Message-ID: <5525B3AD.4040300@gmail.com>
References: <1428529710-19798-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33782 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbbDHXDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 19:03:16 -0400
Received: by qkx62 with SMTP id 62so100167523qkx.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 16:03:15 -0700 (PDT)
In-Reply-To: <1428529710-19798-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/15 18:48, Cong Wang wrote:
> We need to clean up vxlan despite vxlan_igmp_leave() fails.
>
> This fixes the following kernel warning:
>
>   WARNING: CPU: 0 PID: 6 at lib/debugobjects.c:263 debug_print_object+0x7c/0x8d()
>   ODEBUG: free active (active state 0) object type: timer_list hint: vxlan_cleanup+0x0/0xd0
>   CPU: 0 PID: 6 Comm: kworker/u8:0 Not tainted 4.0.0-rc7+ #953
>   Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>   Workqueue: netns cleanup_net
>    0000000000000009 ffff88011955f948 ffffffff81a25f5a 00000000253f253e
>    ffff88011955f998 ffff88011955f988 ffffffff8107608e 0000000000000000
>    ffffffff814deba2 ffff8800d4e94000 ffffffff82254c30 ffffffff81fbe455
>   Call Trace:
>    [<ffffffff81a25f5a>] dump_stack+0x4c/0x65
>    [<ffffffff8107608e>] warn_slowpath_common+0x9c/0xb6
>    [<ffffffff814deba2>] ? debug_print_object+0x7c/0x8d
>    [<ffffffff81076116>] warn_slowpath_fmt+0x46/0x48
>    [<ffffffff814deba2>] debug_print_object+0x7c/0x8d
>    [<ffffffff81666bf1>] ? vxlan_fdb_destroy+0x5b/0x5b
>    [<ffffffff814dee02>] __debug_check_no_obj_freed+0xc3/0x15f
>    [<ffffffff814df728>] debug_check_no_obj_freed+0x12/0x16
>    [<ffffffff8117ae4e>] slab_free_hook+0x64/0x6c
>    [<ffffffff8114deaa>] ? kvfree+0x31/0x33
>    [<ffffffff8117dc66>] kfree+0x101/0x1ac
>    [<ffffffff8114deaa>] kvfree+0x31/0x33
>    [<ffffffff817d4137>] netdev_freemem+0x18/0x1a
>    [<ffffffff817e8b52>] netdev_release+0x2e/0x32
>    [<ffffffff815b4163>] device_release+0x5a/0x92
>    [<ffffffff814bd4dd>] kobject_cleanup+0x49/0x5e
>    [<ffffffff814bd3ff>] kobject_put+0x45/0x49
>    [<ffffffff817d3fc1>] netdev_run_todo+0x26f/0x283
>    [<ffffffff817d4873>] ? rollback_registered_many+0x20f/0x23b
>    [<ffffffff817e0c80>] rtnl_unlock+0xe/0x10
>    [<ffffffff817d4af0>] default_device_exit_batch+0x12a/0x139
>    [<ffffffff810aadfa>] ? wait_woken+0x8f/0x8f
>    [<ffffffff817c8e14>] ops_exit_list+0x2b/0x57
>    [<ffffffff817c9b21>] cleanup_net+0x154/0x1e7
>    [<ffffffff8108b05d>] process_one_work+0x255/0x4ad
>    [<ffffffff8108af69>] ? process_one_work+0x161/0x4ad
>    [<ffffffff8108b4b1>] worker_thread+0x1cd/0x2ab
>    [<ffffffff8108b2e4>] ? process_scheduled_works+0x2f/0x2f
>    [<ffffffff81090686>] kthread+0xd4/0xdc
>    [<ffffffff8109eca3>] ? local_clock+0x19/0x22
>    [<ffffffff810905b2>] ? __kthread_parkme+0x83/0x83
>    [<ffffffff81a31c48>] ret_from_fork+0x58/0x90
>    [<ffffffff810905b2>] ? __kthread_parkme+0x83/0x83
>
> For the long-term, we should handle NETDEV_{UP,DOWN} event
> from the lower device of a tunnel device.
>
> Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   drivers/net/vxlan.c | 5 +----
>   1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 682838b..577c9b0 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2256,11 +2256,8 @@ static int vxlan_stop(struct net_device *dev)
>   	int ret = 0;
>
>   	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
> -	    !vxlan_group_used(vn, vxlan)) {
> +	    !vxlan_group_used(vn, vxlan))
>   		ret = vxlan_igmp_leave(vxlan);
> -		if (ret)
> -			return ret;
> -	}
>
>   	del_timer_sync(&vxlan->age_timer);
>
>

We could remove ret handling entirely, as nobody will check for that 
return value anyway. A pity, but..

Anyway, I'm good with the change as is. Thanks Cong.

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

   Marcelo
