From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: vxlan: use after free error
Date: Sun, 28 May 2017 19:50:44 -0700
Message-ID: <CAJieiUhNV7=r53mmsHTHAmA8g0PKoxszHyNMXwYKG4OsB20KjQ@mail.gmail.com>
References: <03ac7d79-02b7-4bee-d318-9731413bf97b@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, pravin shelar <pshelar@ovn.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Balki Raman <ramanb@cumulusnetworks.com>
To: Mark Bloch <markb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34598 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdE2Cuq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 22:50:46 -0400
Received: by mail-vk0-f47.google.com with SMTP id y190so25848630vkc.1
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 19:50:46 -0700 (PDT)
In-Reply-To: <03ac7d79-02b7-4bee-d318-9731413bf97b@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 28, 2017 at 3:49 AM, Mark Bloch <markb@mellanox.com> wrote:
> Hi,
>
> I'm getting a KASAN (use after free) error when doing:
>
> ip link add vxlan1 type vxlan external
> ip link set vxlan1 up
> ip link set vxlan1 down
> ip link del vxlan1
>
> [  600.495331] ==================================================================
> [  600.509678] BUG: KASAN: use-after-free in vxlan_dellink+0x33d/0x390 [vxlan]
> [  600.523083] Write of size 8 at addr ffff88056ce54018 by task ip/16216
>
> [  600.542239] CPU: 12 PID: 16216 Comm: ip Not tainted 4.12.0-rc2 #24
> [  600.554442] Hardware name: HP ProLiant DL380p Gen8, BIOS P70 08/02/2014
> [  600.567013] Call Trace:
> [  600.574742]  dump_stack+0x63/0x89
> [  600.583458]  print_address_description+0x78/0x290
> [  600.593612]  kasan_report+0x257/0x370
> [  600.602857]  ? vxlan_dellink+0x33d/0x390 [vxlan]
> [  600.612765]  __asan_report_store8_noabort+0x1c/0x20
> [  600.622937]  vxlan_dellink+0x33d/0x390 [vxlan]
> [  600.632636]  rtnl_delete_link+0xb9/0x110
> [  600.641542]  ? rtnl_af_register+0xc0/0xc0
> [  600.650898]  ? nla_parse+0x36/0x260
> [  600.659558]  rtnl_dellink+0x1fb/0x780
> [  600.668350]  ? unwind_dump+0x360/0x360
> [  600.676802]  ? rtnl_bridge_getlink+0x620/0x620
> [  600.686036]  ? __module_text_address+0x18/0x150
> [  600.695300]  ? ns_capable_common+0xd4/0x110
> [  600.704157]  ? sock_sendmsg+0xba/0xf0
> [  600.712264]  ? ns_capable+0x13/0x20
> [  600.720201]  ? __netlink_ns_capable+0xcc/0x100
> [  600.729131]  rtnetlink_rcv_msg+0x255/0x6c0
> [  600.737464]  ? rtnl_newlink+0x1640/0x1640
> [  600.745604]  ? __read_once_size_nocheck.constprop.7+0x20/0x20
> [  600.755882]  ? __read_once_size_nocheck.constprop.7+0x20/0x20
> [  600.765963]  ? memset+0x31/0x40
> [  600.772985]  netlink_rcv_skb+0x2de/0x460
> [  600.780829]  ? rtnl_newlink+0x1640/0x1640
> [  600.788755]  ? netlink_ack+0xaf0/0xaf0
> [  600.796181]  ? __kmalloc_node_track_caller+0x205/0x2d0
> [  600.805370]  ? __alloc_skb+0xdd/0x580
> [  600.812646]  rtnetlink_rcv+0x28/0x30
> [  600.819882]  netlink_unicast+0x430/0x620
> [  600.827433]  ? netlink_attachskb+0x660/0x660
> [  600.835211]  ? rw_copy_check_uvector+0x90/0x290
> [  600.843097]  ? __module_text_address+0x18/0x150
> [  600.850985]  netlink_sendmsg+0x7df/0xb90
> [  600.858105]  ? netlink_unicast+0x620/0x620
> [  600.865493]  ? kasan_alloc_pages+0x38/0x40
> [  600.873060]  ? netlink_unicast+0x620/0x620
> [  600.880458]  sock_sendmsg+0xba/0xf0
> [  600.886784]  ___sys_sendmsg+0x6c9/0x8e0
> [  600.893300]  ? copy_msghdr_from_user+0x520/0x520
> [  600.901017]  ? memcg_write_event_control+0xd50/0xd50
> [  600.908938]  ? __alloc_pages_slowpath+0x1ef0/0x1ef0
> [  600.916082]  ? mem_cgroup_commit_charge+0xc4/0x1420
> [  600.923049]  ? lru_cache_add_active_or_unevictable+0x7d/0x1a0
> [  600.931943]  ? __handle_mm_fault+0x1bfe/0x2ba0
> [  600.939255]  ? __pmd_alloc+0x240/0x240
> [  600.944767]  __sys_sendmsg+0xce/0x160
> [  600.950154]  ? __sys_sendmsg+0xce/0x160
> [  600.956030]  ? SyS_shutdown+0x190/0x190
> [  600.962546]  ? mntput+0x57/0x70
> [  600.968576]  ? __fput+0x429/0x730
> [  600.973526]  ? handle_mm_fault+0x28a/0x650
> [  600.979844]  ? find_vma+0x1f/0x160
> [  600.985801]  SyS_sendmsg+0x12/0x20
> [  600.991857]  entry_SYSCALL_64_fastpath+0x1a/0xa5
> [  600.999044] RIP: 0033:0x7fe11cd80037
> [  601.005021] RSP: 002b:00007ffe0e7fc738 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
> [  601.014890] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fe11cd80037
> [  601.024808] RDX: 0000000000000000 RSI: 00007ffe0e7fc780 RDI: 0000000000000003
> [  601.035392] RBP: 00007ffe0e7fc780 R08: 0000000000000001 R09: fefefeff77686d74
> [  601.045517] R10: 00000000000005eb R11: 0000000000000246 R12: 00007ffe0e7fc7c0
> [  601.055590] R13: 0000000000669400 R14: 00007ffe0e804830 R15: 0000000000000000
>
> [  601.069998] The buggy address belongs to the page:
> [  601.078182] page:ffffea0015b39500 count:0 mapcount:-127 mapping:          (null) index:0x0
> [  601.089760] flags: 0x2fffff80000000()
> [  601.096304] raw: 002fffff80000000 0000000000000000 0000000000000000 00000000ffffff80
> [  601.107417] raw: ffffea00156b2020 ffffea001836cb20 0000000000000002 0000000000000000
> [  601.118699] page dumped because: kasan: bad access detected
>
> [  601.131352] Memory state around the buggy address:
> [  601.139488]  ffff88056ce53f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> [  601.149179]  ffff88056ce53f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> [  601.159941] >ffff88056ce54000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> [  601.170313]                             ^
> [  601.176429]  ffff88056ce54080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> [  601.187098]  ffff88056ce54100: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> [  601.196978] ==================================================================
>
> The flow is something like this:
> When we are upping the interface, we are calling vxlan_open() and after creating the
> sockets (v4 & v6) we call vxlan_vs_add_dev() and add the vxlan device to each socket's list.
>
> When we put down the interface, we call vxlan_stop() -> vxlan_sock_release() there
> after calling __vxlan_sock_release_prep() we free each socket, the issue is that the vxlan
> device is still part of each socket's list.
>
> When we delete the vxlan interface, vxlan_dellink() is called and there we do:
> hlist_del_rcu(&vxlan->hlist), which access already freed memory.
>
> I'm not too familiar with the vxlan module, so to me a trivial fix like this makes sense.
> Am I missing something?

Thanks for the report and analysis...this looks similar to a rarely
reproducible crash we hit on the 4.1 kernel. I am glad you have a
KASAN recipe to reproduce. Your analysis aligns with ours. I have
ported our patch to latest net-next below (also sent you the patch
separately). It is similar to your patch but adds a vxlan_vs_del_dev
for symmetry with vxlan_vs_add_dev.

From: Balakrishnan Raman <ramanb@cumulusnetworks.com>

Date: Sun, 28 May 2017 19:34:25 -0700

Subject: [PATCH net-next] vxlan: remove vxlan device from socket's device

 list in vxlan_stop


Signed-off-by: Balakrishnan Raman <ramanb@cumulusnetworks.com>

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

---

 drivers/net/vxlan.c | 13 ++++++++++++-

 1 file changed, 12 insertions(+), 1 deletion(-)


diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c

index 328b471..26dac52 100644

--- a/drivers/net/vxlan.c

+++ b/drivers/net/vxlan.c

@@ -2352,6 +2352,16 @@ static void vxlan_vs_add_dev(struct vxlan_sock
*vs, struct vxlan_dev *vxlan)

        spin_unlock(&vn->sock_lock);

 }


+static void vxlan_vs_del_dev(struct vxlan_dev *vxlan)

+{

+       struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);

+

+       spin_lock(&vn->sock_lock);

+       if (!hlist_unhashed(&vxlan->hlist))

+               hlist_del_init_rcu(&vxlan->hlist);

+       spin_unlock(&vn->sock_lock);

+}

+

 /* Setup stats when device is created */

 static int vxlan_init(struct net_device *dev)

 {

@@ -2443,6 +2453,7 @@ static int vxlan_stop(struct net_device *dev)

        del_timer_sync(&vxlan->age_timer);


        vxlan_flush(vxlan, false);

+       vxlan_vs_del_dev(vxlan);

        vxlan_sock_release(vxlan);


        return ret;


@@ -3292,7 +3303,7 @@ static void vxlan_dellink(struct net_device
*dev, struct list_head *head)


        spin_lock(&vn->sock_lock);

        if (!hlist_unhashed(&vxlan->hlist))

-               hlist_del_rcu(&vxlan->hlist);

+               hlist_del_init_rcu(&vxlan->hlist);

        spin_unlock(&vn->sock_lock);


        gro_cells_destroy(&vxlan->gro_cells);
