From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
	during init
Date: Tue, 17 Jul 2012 17:33:16 -0700
Message-ID: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: davem@davemloft.net, gaofeng@cn.fujitsu.com, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13727 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab2GRAsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 20:48:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the netprio cgroup is built in the kernel cgroup_init will call
cgrp_create which eventually calls update_netdev_tables. This is
being called before do_initcalls() so a null ptr dereference occurs
on init_net.

This patch adds a check on init_net.count to verify the structure
has been initialized. The failure was introduced here,

commit ef209f15980360f6945873df3cd710c5f62f2a3e
Author: Gao feng <gaofeng@cn.fujitsu.com>
Date:   Wed Jul 11 21:50:15 2012 +0000

    net: cgroup: fix access the unallocated memory in netprio cgroup

Tested with ping with netprio_cgroup as a module and built in.

Marked RFC for now I think DaveM might have a reason why this needs
some improvement.

Reported-by: Mark Rustad <mark.d.rustad@intel.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/netprio_cgroup.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index b2e9caa..e9fd7fd 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -116,6 +116,9 @@ static int update_netdev_tables(void)
 	u32 max_len;
 	struct netprio_map *map;
 
+	if (!atomic_read(&init_net.count))
+		return ret;
+
 	rtnl_lock();
 	max_len = atomic_read(&max_prioidx) + 1;
 	for_each_netdev(&init_net, dev) {
