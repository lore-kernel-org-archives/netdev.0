From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net 0/5] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Fri, 11 Sep 2015 11:06:16 -0700
Message-ID: <1441994781-2718585-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57989 "EHLO
	m0041696.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751749AbbIKSHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 14:07:34 -0400
Received: from pps.filterd (m0041696 [127.0.0.1])
	by m0041696.ppops.net (8.14.5/8.14.5) with SMTP id t8BI7KNS032453
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 11:07:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0041696.ppops.net with ESMTP id 1wv08dgqaw-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 11:07:33 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 f051d80a58af11e5af6a0002c95209d8-d71fa240 for <netdev@vger.kernel.org>;	Fri,
 11 Sep 2015 11:07:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3:
- Merge a 'if else if' test in patch 4
- Use rcu_dereference_protected in patch 5 to fix a sparse check when
  CONFIG_SPARSE_RCU_POINTER is enabled

v2:
- Add patch 4 and 5 to remove the spinlock

v1:
This patch series is to fix the dst refcnt bugs in ip6_tunnel.

Patch 1 and 2 are the prep works.  Patch 3 is the fix.

I can reproduce the bug by adding and removing the ip6gre tunnel
while running a super_netperf TCP_CRR test.  I get the following
trace by adding WARN_ON_ONCE(newrefcnt < 0) to dst_release():

[  312.760432] ------------[ cut here ]------------
[  312.774664] WARNING: CPU: 2 PID: 10263 at net/core/dst.c:288 dst_release+0xf3/0x100()
[  312.776041] Modules linked in: k10temp coretemp hwmon ip6_gre ip6_tunnel tunnel6 ipmi_devintf ipmi_ms\
ghandler ip6table_filter ip6_tables xt_NFLOG nfnetlink_log nfnetlink xt_comment xt_statistic iptable_fil\
ter ip_tables x_tables nfsv3 nfs_acl nfs fscache lockd grace mptctl netconsole autofs4 rpcsec_gss_krb5 a\
uth_rpcgss oid_registry sunrpc ipv6 dm_mod loop iTCO_wdt iTCO_vendor_support serio_raw rtc_cmos pcspkr i\
2c_i801 i2c_core lpc_ich mfd_core ehci_pci ehci_hcd e1000e mlx4_en ptp pps_core vxlan udp_tunnel ip6_udp\
_tunnel mlx4_core sg button ext3 jbd mpt2sas raid_class
[  312.785302] CPU: 2 PID: 10263 Comm: netperf Not tainted 4.2.0-rc8-00046-g4db9b63-dirty #15
[  312.791695] Hardware name: Quanta Freedom /Windmill-EP, BIOS F03_3B04 09/12/2013
[  312.792965]  ffffffff819dca2c ffff8811dfbdf6f8 ffffffff816537de ffff88123788fdb8
[  312.794263]  0000000000000000 ffff8811dfbdf738 ffffffff81052646 ffff8811dfbdf768
[  312.795593]  ffff881203a98180 00000000ffffffff ffff88242927a000 ffff88120a2532e0
[  312.796946] Call Trace:
[  312.797380]  [<ffffffff816537de>] dump_stack+0x45/0x57
[  312.798288]  [<ffffffff81052646>] warn_slowpath_common+0x86/0xc0
[  312.799699]  [<ffffffff8105273a>] warn_slowpath_null+0x1a/0x20
[  312.800852]  [<ffffffff8159f9b3>] dst_release+0xf3/0x100
[  312.801834]  [<ffffffffa03f1308>] ip6_tnl_dst_store+0x48/0x70 [ip6_tunnel]
[  312.803738]  [<ffffffffa03fd0b6>] ip6gre_xmit2+0x536/0x720 [ip6_gre]
[  312.804774]  [<ffffffffa03fd40a>] ip6gre_tunnel_xmit+0x16a/0x410 [ip6_gre]
[  312.805986]  [<ffffffff8159934b>] dev_hard_start_xmit+0x23b/0x390
[  312.808810]  [<ffffffff815a2f5f>] ? neigh_destroy+0xef/0x140
[  312.809843]  [<ffffffff81599a6c>] __dev_queue_xmit+0x48c/0x4f0
[  312.813931]  [<ffffffff81599ae3>] dev_queue_xmit_sk+0x13/0x20
[  312.814993]  [<ffffffff815a0832>] neigh_direct_output+0x12/0x20
[  312.817448]  [<ffffffffa021d633>] ip6_finish_output2+0x183/0x460 [ipv6]
[  312.818762]  [<ffffffff81306fc5>] ? find_next_bit+0x15/0x20
[  312.819671]  [<ffffffffa021fd79>] ip6_finish_output+0x89/0xe0 [ipv6]
[  312.820720]  [<ffffffffa021fe14>] ip6_output+0x44/0xe0 [ipv6]
[  312.821762]  [<ffffffff815c8809>] ? nf_hook_slow+0x69/0xc0
[  312.823123]  [<ffffffffa021d232>] ip6_xmit+0x242/0x4c0 [ipv6]
[  312.824073]  [<ffffffffa021c9f0>] ? ac6_proc_exit+0x20/0x20 [ipv6]
[  312.825116]  [<ffffffffa024c751>] inet6_csk_xmit+0x61/0xa0 [ipv6]
[  312.826127]  [<ffffffff815eb590>] tcp_transmit_skb+0x4f0/0x9b0
[  312.827441]  [<ffffffff815ed267>] tcp_connect+0x637/0x7a0
[  312.828327]  [<ffffffffa0245906>] tcp_v6_connect+0x2d6/0x550 [ipv6]
[  312.829581]  [<ffffffff81606f05>] __inet_stream_connect+0x95/0x2f0
[  312.830600]  [<ffffffff810ae13a>] ? hrtimer_try_to_cancel+0x1a/0xf0
[  312.833456]  [<ffffffff812fba19>] ? timerqueue_add+0x59/0xb0
[  312.834407]  [<ffffffff81607198>] inet_stream_connect+0x38/0x50
[  312.835886]  [<ffffffff8157cb17>] SYSC_connect+0xb7/0xf0
[  312.840035]  [<ffffffff810af6d3>] ? do_setitimer+0x1b3/0x200
[  312.840983]  [<ffffffff810af75a>] ? alarm_setitimer+0x3a/0x70
[  312.841941]  [<ffffffff8157d7ae>] SyS_connect+0xe/0x10
[  312.842818]  [<ffffffff81659297>] entry_SYSCALL_64_fastpath+0x12/0x6a
[  312.844206] ---[ end trace 43f3ecd86c3b1313 ]---
