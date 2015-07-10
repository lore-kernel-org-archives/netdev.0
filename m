From: Dmitry Torokhov <dtor@google.com>
Subject: [PATCH] nf: IDLETIMER: fix lockdep warning
Date: Thu, 9 Jul 2015 17:15:01 -0700
Message-ID: <20150710001501.GA32570@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35609 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbbGJAPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 20:15:04 -0400
Received: by igcqs7 with SMTP id qs7so2100130igc.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 17:15:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dynamically allocated sysfs attributes should be initialized with
sysfs_attr_init() otherwise lockdep will be angry with us:

[   45.468653] BUG: key ffffffc030fad4e0 not in .data!
[   45.468655] ------------[ cut here ]------------
[   45.468666] WARNING: CPU: 0 PID: 1176 at /mnt/host/source/src/third_party/kernel/v3.18/kernel/locking/lockdep.c:2991 lockdep_init_map+0x12c/0x490()
[   45.468672] DEBUG_LOCKS_WARN_ON(1)
[   45.468672] CPU: 0 PID: 1176 Comm: iptables Tainted: G     U  W 3.18.0 #43
[   45.468674] Hardware name: XXX
[   45.468675] Call trace:
[   45.468680] [<ffffffc0002072b4>] dump_backtrace+0x0/0x10c
[   45.468683] [<ffffffc0002073d0>] show_stack+0x10/0x1c
[   45.468688] [<ffffffc000a86cd4>] dump_stack+0x74/0x94
[   45.468692] [<ffffffc000217ae0>] warn_slowpath_common+0x84/0xb0
[   45.468694] [<ffffffc000217b84>] warn_slowpath_fmt+0x4c/0x58
[   45.468697] [<ffffffc0002530a4>] lockdep_init_map+0x128/0x490
[   45.468701] [<ffffffc000367ef0>] __kernfs_create_file+0x80/0xe4
[   45.468704] [<ffffffc00036862c>] sysfs_add_file_mode_ns+0x104/0x170
[   45.468706] [<ffffffc00036870c>] sysfs_create_file_ns+0x58/0x64
[   45.468711] [<ffffffc000930430>] idletimer_tg_checkentry+0x14c/0x324
[   45.468714] [<ffffffc00092a728>] xt_check_target+0x170/0x198
[   45.468717] [<ffffffc000993efc>] check_target+0x58/0x6c
[   45.468720] [<ffffffc000994c64>] translate_table+0x30c/0x424
[   45.468723] [<ffffffc00099529c>] do_ipt_set_ctl+0x144/0x1d0
[   45.468728] [<ffffffc0009079f0>] nf_setsockopt+0x50/0x60
[   45.468732] [<ffffffc000946870>] ip_setsockopt+0x8c/0xb4
[   45.468735] [<ffffffc0009661c0>] raw_setsockopt+0x10/0x50
[   45.468739] [<ffffffc0008c1550>] sock_common_setsockopt+0x14/0x20
[   45.468742] [<ffffffc0008bd190>] SyS_setsockopt+0x88/0xb8
[   45.468744] ---[ end trace 41d156354d18c039 ]---

Change-Id: I1da5cd96fc8e1e1e4209e81eba1165a42d4d45e9
Signed-off-by: Dmitry Torokhov <dtor@google.com>
---
 net/netfilter/xt_IDLETIMER.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
index 31f76cd..0975c993 100644
--- a/net/netfilter/xt_IDLETIMER.c
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -286,6 +286,7 @@ static int idletimer_tg_create(struct idletimer_tg_info *info)
 		goto out;
 	}
 
+	sysfs_attr_init(&info->timer->attr.attr);
 	info->timer->attr.attr.name = kstrdup(info->label, GFP_KERNEL);
 	if (!info->timer->attr.attr.name) {
 		ret = -ENOMEM;
-- 
2.4.3.573.g4eafbef


-- 
Dmitry
