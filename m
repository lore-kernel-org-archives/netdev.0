From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 1/6] bridge: add rtnl_lock in fdb_flush in br_sysfs_br.c
Date: Wed, 16 Mar 2016 21:34:44 +0800
Message-ID: <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34162 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966228AbcCPNfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:35:02 -0400
Received: by mail-pf0-f196.google.com with SMTP id n5so6720649pfn.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:35:02 -0700 (PDT)
In-Reply-To: <cover.1458134414.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In fdb_delete, it will send rtnl msg, so before that, we should
hold rtnl_lock in the function that call it in sysfs.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 6b80914..095a751 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -345,7 +345,12 @@ static ssize_t flush_store(struct device *d,
 	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	br_fdb_flush(br);
+	rtnl_unlock();
+
 	return len;
 }
 static DEVICE_ATTR_WO(flush);
-- 
2.1.0
