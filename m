From: Patrick McHardy <kaber@trash.net>
Subject: Re: A regression introduced by 802.1ad support patches
Date: Sun, 21 Apr 2013 11:34:40 +0200
Message-ID: <20130421093436.GA26775@macbook.localnet>
References: <1366530184.23100.6.camel@cr0>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36631 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab3DUJfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 05:35:07 -0400
Content-Disposition: inline
In-Reply-To: <1366530184.23100.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Apr 21, 2013 at 03:43:04PM +0800, Cong Wang wrote:
> Hi, Patrick,
> 
> Your recent 802.1ad patches causes the following bug. After resetting
> HEAD to commit c296289 (Merge branch 'intel'), this bug is not
> reproducible any more.
> 
> It is pretty easy to reproduce in my KVM guest, just boot the guest and
> then shut it down, the following traces will be shown. Although it is
> not 100% reproducible, it appears more than 80% times at least.
> 
> I am glad to provide any other information if you need, and of course
> can test any fix if you want.
> 
> [   86.812073] kmemleak: Found object by alias at 0xffff88006ecc76f0
> [   86.816019] Pid: 739, comm: kworker/u:1 Not tainted 3.9.0-rc5+ #842
> [   86.816019] Call Trace:
> [   86.816019]  <IRQ>  [<ffffffff81151c58>] find_and_get_object
> +0x8c/0xdf
> [   86.816019]  [<ffffffff8190e90d>] ? vlan_info_rcu_free+0x33/0x49
> [   86.816019]  [<ffffffff81151cbe>] delete_object_full+0x13/0x2f
> [   86.816019]  [<ffffffff8194bbb6>] kmemleak_free+0x26/0x45
> [   86.816019]  [<ffffffff8113e8c7>] slab_free_hook+0x1e/0x7b
> [   86.816019]  [<ffffffff81141c05>] kfree+0xce/0x14b
> [   86.816019]  [<ffffffff8190e90d>] vlan_info_rcu_free+0x33/0x49
> [   86.816019]  [<ffffffff810d0b0b>] rcu_do_batch+0x261/0x4e7

Thanks. I think the attached patch should fix it.

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="vlan-leak.diff"

commit 77734833d78bcf0a3f58cde8b5b2424e8fc8b7e6
Author: Patrick McHardy <kaber@trash.net>
Date:   Sun Apr 21 11:34:12 2013 +0200

    net: vlan: fix memory leak in vlan_info_rcu_free()
    
    The following leak is reported by kmemleak:
    
    [   86.812073] kmemleak: Found object by alias at 0xffff88006ecc76f0
    [   86.816019] Pid: 739, comm: kworker/u:1 Not tainted 3.9.0-rc5+ #842
    [   86.816019] Call Trace:
    [   86.816019]  <IRQ>  [<ffffffff81151c58>] find_and_get_object+0x8c/0xdf
    [   86.816019]  [<ffffffff8190e90d>] ? vlan_info_rcu_free+0x33/0x49
    [   86.816019]  [<ffffffff81151cbe>] delete_object_full+0x13/0x2f
    [   86.816019]  [<ffffffff8194bbb6>] kmemleak_free+0x26/0x45
    [   86.816019]  [<ffffffff8113e8c7>] slab_free_hook+0x1e/0x7b
    [   86.816019]  [<ffffffff81141c05>] kfree+0xce/0x14b
    [   86.816019]  [<ffffffff8190e90d>] vlan_info_rcu_free+0x33/0x49
    [   86.816019]  [<ffffffff810d0b0b>] rcu_do_batch+0x261/0x4e7
    
    The reason is that in vlan_info_rcu_free() we don't take the VLAN protocol
    into account when iterating over the vlan_devices_array.
    
    Reported-by: Cong Wang <amwang@redhat.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index ebfa2fc..8a15eaa 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -157,10 +157,11 @@ EXPORT_SYMBOL(vlan_untag);
 
 static void vlan_group_free(struct vlan_group *grp)
 {
-	int i;
+	int i, j;
 
-	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
-		kfree(grp->vlan_devices_arrays[i]);
+	for (i = 0; i < VLAN_PROTO_NUM; i++)
+		for (j = 0; j < VLAN_GROUP_ARRAY_SPLIT_PARTS; j++)
+			kfree(grp->vlan_devices_arrays[i][j]);
 }
 
 static void vlan_info_free(struct vlan_info *vlan_info)

--WIyZ46R2i8wDzkSu--
