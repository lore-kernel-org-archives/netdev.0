From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: lock-warning seen on giving rds-info command
Date: Fri, 18 Nov 2011 13:37:34 +0530
Message-ID: <1321603654-17179-1-git-send-email-kumaras@chelsio.com>
Cc: davem@davemloft.net, venkat.x.venkatsubra@oracle.com,
	Kumar Sanghvi <kumaras@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17103 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab1KRHwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 02:52:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev team,

I am trying to investigate one issue with RDS.
On giving command rds-info, we get below trace in dmesg:

------------[ cut here ]------------
WARNING: at /root/chelsio/git_repos/linux-2.6/kernel/softirq.c:159 local_bh_enable_ip+0x7a/0xa0()
Hardware name: X7DB8
Modules linked in: rds_rdma rds rdma_cm iw_cm ib_addr autofs4 sunrpc
p4_clockmod freq_table speedstep_lib ib_ipoib ib_cm ib_sa ipv6 ib_uverbs
ib_umad ib_mad iw_nes libcrc32c ib_core dm_mirror dm_region_hash dm_log
uinput ppdev sg parport_pc parport pcspkr serio_raw i2c_i801 iTCO_wdt
iTCO_vendor_support ioatdma dca i5k_amb i5000_edac edac_core e1000e shpchp
ext4 mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif pata_acpi ata_generic ata_piix
floppy radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core dm_mod
[last unloaded: mdio]
Pid: 1937, comm: rds-info Not tainted 3.1.0 #1
Call Trace:
 [<ffffffff8106446f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff810644ca>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8106af6a>] local_bh_enable_ip+0x7a/0xa0
 [<ffffffff814d3126>] _raw_read_unlock_bh+0x16/0x20
 [<ffffffff813f83b4>] sock_i_ino+0x44/0x60
 [<ffffffffa046ab02>] rds_sock_info+0xd2/0x140 [rds]
 [<ffffffffa046c7a7>] rds_info_getsockopt+0x197/0x200 [rds]
 [<ffffffffa046a1b4>] rds_getsockopt+0x84/0xe0 [rds]
 [<ffffffff813f3453>] sys_getsockopt+0x73/0xe0
 [<ffffffff814dafd7>] tracesys+0xd9/0xde
---[ end trace 4e7838d2e1e53231 ]---

I tested this on 3.1 kernel. However, this problem seems to be present on most
recent kernels. I tried to investigate, and the RDS problem seems to stem(I might be wrong)
after this upstream commit:

----
commit f064af1e500a2bf4607706f0f458163bdb2a6ea5
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Sep 22 12:43:39 2010 +0000

    net: fix a lockdep splat
----

In the above commit, sock_i_ino is modified to use read_lock/unlock_bh instead
of plain read_lock/unlock.

Now, everywhere in Linux network stack, it seems that callers of sock_i_ino
are not disabling interrupts and are also not holding any lock while calling
sock_i_ino function. However, RDS seems to be only one who is calling sock_i_ino
with spin_lock_irqsave i.e. with interrupts disabled.
As a result, when sock_i_ino finally calls read_unlock_bh -  which in turn will lead to
local_bh_enable_ip - which in turn throws the WARN-ON-ONCE since interrupts are
disabled at this stage.

Below patch is a quick fix which seems to make this lock-warning disappear.
With this patch, the WARN-ON-ONCE is no longer seen on giving rds-info command.

However, I am not much aware of RDS stack, and I don't know the motive of using
spin-lock-irqsave in rds code for the sock-lock. I am also not aware if the below
patch could introduce regressions in RDS code. So, it would be helpful if someone
who knows RDS can review the patch and comment on what should be the proper fix.

Thanks,
Kumar.

----------------------
[PATCH] net/rds: Use spin_lock for rds_sock_lock

On giving rds-info command, we get below lock-warning in dmesg:
....
Call Trace:
 [<ffffffff8106446f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff810644ca>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8106af6a>] local_bh_enable_ip+0x7a/0xa0
 [<ffffffff814d3126>] _raw_read_unlock_bh+0x16/0x20
 [<ffffffff813f83b4>] sock_i_ino+0x44/0x60
 [<ffffffffa046ab02>] rds_sock_info+0xd2/0x140 [rds]
 [<ffffffffa046c7a7>] rds_info_getsockopt+0x197/0x200 [rds]
 [<ffffffffa046a1b4>] rds_getsockopt+0x84/0xe0 [rds]
 [<ffffffff813f3453>] sys_getsockopt+0x73/0xe0
 [<ffffffff814dafd7>] tracesys+0xd9/0xde
....

Fix this by using spin_lock for rds_sock_lock, instead of using
spin_lock_irqsave.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 net/rds/af_rds.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index bb6ad81..5080ae2 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -68,7 +68,6 @@ static int rds_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct rds_sock *rs;
-	unsigned long flags;
 
 	if (!sk)
 		goto out;
@@ -94,10 +93,10 @@ static int rds_release(struct socket *sock)
 	rds_rdma_drop_keys(rs);
 	rds_notify_queue_get(rs, NULL);
 
-	spin_lock_irqsave(&rds_sock_lock, flags);
+	spin_lock(&rds_sock_lock);
 	list_del_init(&rs->rs_item);
 	rds_sock_count--;
-	spin_unlock_irqrestore(&rds_sock_lock, flags);
+	spin_unlock(&rds_sock_lock);
 
 	rds_trans_put(rs->rs_transport);
 
@@ -409,7 +408,6 @@ static const struct proto_ops rds_proto_ops = {
 
 static int __rds_create(struct socket *sock, struct sock *sk, int protocol)
 {
-	unsigned long flags;
 	struct rds_sock *rs;
 
 	sock_init_data(sock, sk);
@@ -426,10 +424,10 @@ static int __rds_create(struct socket *sock, struct sock *sk, int protocol)
 	spin_lock_init(&rs->rs_rdma_lock);
 	rs->rs_rdma_keys = RB_ROOT;
 
-	spin_lock_irqsave(&rds_sock_lock, flags);
+	spin_lock(&rds_sock_lock);
 	list_add_tail(&rs->rs_item, &rds_sock_list);
 	rds_sock_count++;
-	spin_unlock_irqrestore(&rds_sock_lock, flags);
+	spin_unlock(&rds_sock_lock);
 
 	return 0;
 }
@@ -471,12 +469,11 @@ static void rds_sock_inc_info(struct socket *sock, unsigned int len,
 {
 	struct rds_sock *rs;
 	struct rds_incoming *inc;
-	unsigned long flags;
 	unsigned int total = 0;
 
 	len /= sizeof(struct rds_info_message);
 
-	spin_lock_irqsave(&rds_sock_lock, flags);
+	spin_lock(&rds_sock_lock);
 
 	list_for_each_entry(rs, &rds_sock_list, rs_item) {
 		read_lock(&rs->rs_recv_lock);
@@ -492,7 +489,7 @@ static void rds_sock_inc_info(struct socket *sock, unsigned int len,
 		read_unlock(&rs->rs_recv_lock);
 	}
 
-	spin_unlock_irqrestore(&rds_sock_lock, flags);
+	spin_unlock(&rds_sock_lock);
 
 	lens->nr = total;
 	lens->each = sizeof(struct rds_info_message);
@@ -504,11 +501,10 @@ static void rds_sock_info(struct socket *sock, unsigned int len,
 {
 	struct rds_info_socket sinfo;
 	struct rds_sock *rs;
-	unsigned long flags;
 
 	len /= sizeof(struct rds_info_socket);
 
-	spin_lock_irqsave(&rds_sock_lock, flags);
+	spin_lock(&rds_sock_lock);
 
 	if (len < rds_sock_count)
 		goto out;
@@ -529,7 +525,7 @@ out:
 	lens->nr = rds_sock_count;
 	lens->each = sizeof(struct rds_info_socket);
 
-	spin_unlock_irqrestore(&rds_sock_lock, flags);
+	spin_unlock(&rds_sock_lock);
 }
 
 static void rds_exit(void)
-- 
1.7.6.2
