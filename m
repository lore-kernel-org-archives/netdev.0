From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH next-queue] ixgbe: netdev->vlan_features
 shouldn't have the vlan related flag
Date: Wed, 18 May 2016 08:07:12 -0700
Message-ID: <CAKgT0UeDWfcLgvji41x2Q-_aNGs_jYPoo15Aervb+mMgdQjdpg@mail.gmail.com>
References: <f27abd7ea63660b4f9ba880af16c8395fd340668.1463561728.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	David Miller <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35586 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbcERPHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 11:07:13 -0400
Received: by mail-io0-f194.google.com with SMTP id i75so9956930ioa.2
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 08:07:13 -0700 (PDT)
In-Reply-To: <f27abd7ea63660b4f9ba880af16c8395fd340668.1463561728.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 1:55 AM, Xin Long <lucien.xin@gmail.com> wrote:
> vlan_features is used to set the vlan_dev->features when we create
> a vlan device. it shouldn't have the vlan related flag, like
> NETIF_F_HW_VLAN_CTAG_FILTER, which will cause vlan_dev create fail.
> the call trace is as follow:
>
> [ 5604.264429] Call Trace:
> [ 5604.278980]  [<ffffffff8133ef0f>] dump_stack+0x63/0x84
> [ 5604.341499]  [<ffffffff810883c1>] __warn+0xd1/0xf0
> [ 5604.382004]  [<ffffffff8108843f>] warn_slowpath_fmt+0x5f/0x80
> [ 5604.454602]  [<ffffffff81354359>] ? find_next_bit+0x19/0x20
> [ 5604.541940]  [<ffffffff815a93d2>] register_netdevice+0x3c2/0x490
> [ 5604.631744]  [<ffffffffa048bb43>] register_vlan_dev+0x133/0x290 [8021q]
> [ 5604.710346]  [<ffffffffa048d44c>] vlan_newlink+0xbc/0xf0 [8021q]
> [ 5604.789945]  [<ffffffff815b8e22>] rtnl_newlink+0x6c2/0x880
> [ 5604.854000]  [<ffffffff8136ab93>] ? nla_parse+0xa3/0x100
> [ 5604.889974]  [<ffffffff815b88bc>] ? rtnl_newlink+0x15c/0x880
> [ 5604.951987]  [<ffffffff815b61b4>] rtnetlink_rcv_msg+0xa4/0x240
> [ 5605.017614]  [<ffffffff812c4390>] ? sock_has_perm+0x70/0x90
> [ 5605.083120]  [<ffffffff81590b8d>] ? __alloc_skb+0x8d/0x2b0
> [ 5605.147939]  [<ffffffff815b6110>] ? rtnetlink_rcv+0x30/0x30
> [ 5605.194973]  [<ffffffff815d9d77>] netlink_rcv_skb+0xa7/0xc0
> [ 5605.246380]  [<ffffffff815b6108>] rtnetlink_rcv+0x28/0x30
> [ 5605.308998]  [<ffffffff815d9728>] netlink_unicast+0x178/0x240
> [ 5605.375020]  [<ffffffff815d9b1e>] netlink_sendmsg+0x32e/0x3b0
> [ 5605.463066]  [<ffffffff81587b68>] sock_sendmsg+0x38/0x50
> [ 5605.523910]  [<ffffffff815884b9>] ___sys_sendmsg+0x279/0x290
> [ 5605.574178]  [<ffffffff8118d172>] ? filemap_map_pages+0x252/0x2d0
> [ 5605.675281]  [<ffffffff81206005>] ? mem_cgroup_commit_charge+0x85/0x100
> [ 5605.748882]  [<ffffffff81588ec4>] __sys_sendmsg+0x54/0x90
> [ 5605.811931]  [<ffffffff81588f12>] SyS_sendmsg+0x12/0x20
> [ 5605.873955]  [<ffffffff81003b12>] do_syscall_64+0x62/0x110
> [ 5605.931006]  [<ffffffff816b62a1>] entry_SYSCALL64_slow_path+0x25/0x25
> [ 5606.012017] ---[ end trace 11d7fa6a696c0c02 ]---
>
> it's from register_netdevice:
>
>         if (((dev->hw_features | dev->features) &
>              NETIF_F_HW_VLAN_CTAG_FILTER) &&
>             (!dev->netdev_ops->ndo_vlan_rx_add_vid ||
>              !dev->netdev_ops->ndo_vlan_rx_kill_vid)) {
>                 netdev_WARN(dev, "Buggy VLAN acceleration in driver!\n");
>                 ret = -EINVAL;
>                 goto err_uninit;
>         }
>
> the reason is vlan dev's features has NETIF_F_HW_VLAN_CTAG_FILTER flag,
> but no ndo_vlan_rx_add_vid nor ndo_vlan_rx_kill_vid.
>
> we will fix it by put setting netdev->features' vlan related flags behind
> using features to set netdev->vlan_features.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

There is already a fix for this in Dave Miller's net-next tree.  Take
a look at commit 5eee87cd51df "ixgbe: Fix VLAN features error".

Thanks.

- Alex
