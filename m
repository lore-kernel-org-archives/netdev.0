From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v3] netpoll: fix a rtnl lock assertion failure
Date: Mon, 14 Jan 2013 11:54:22 +0100
Message-ID: <20130114105422.GB1633@minipsycho.brq.redhat.com>
References: <1358160234-24996-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:55678 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756612Ab3ANKy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 05:54:27 -0500
Received: by mail-wi0-f177.google.com with SMTP id hm2so1145211wib.10
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 02:54:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1358160234-24996-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 14, 2013 at 11:43:54AM CET, amwang@redhat.com wrote:
>From: Cong Wang <amwang@redhat.com>
>
>This patch fixes the following warning:
>
>[   72.013864] RTNL: assertion failed at net/core/dev.c (4955)
>[   72.017758] Pid: 668, comm: netpoll-prep-v6 Not tainted 3.8.0-rc1+ #474
>[   72.019582] Call Trace:
>[   72.020295]  [<ffffffff8176653d>] netdev_master_upper_dev_get+0x35/0x58
>[   72.022545]  [<ffffffff81784edd>] netpoll_setup+0x61/0x340
>[   72.024846]  [<ffffffff815d837e>] store_enabled+0x82/0xc3
>[   72.027466]  [<ffffffff815d7e51>] netconsole_target_attr_store+0x35/0x37
>[   72.029348]  [<ffffffff811c3479>] configfs_write_file+0xe2/0x10c
>[   72.030959]  [<ffffffff8115d239>] vfs_write+0xaf/0xf6
>[   72.032359]  [<ffffffff81978a05>] ? sysret_check+0x22/0x5d
>[   72.033824]  [<ffffffff8115d453>] sys_write+0x5c/0x84
>[   72.035328]  [<ffffffff819789d9>] system_call_fastpath+0x16/0x1b
>
>Just hold RCU read lock and call netdev_master_upper_dev_get_rcu(),
>as suggested by Jiri.
>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: David S. Miller <davem@davemloft.net>
>Signed-off-by: Cong Wang <amwang@redhat.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>


>
>---
>diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>index 9f05067..5d1f856 100644
>--- a/net/core/netpoll.c
>+++ b/net/core/netpoll.c
>@@ -1055,11 +1055,14 @@ int netpoll_setup(struct netpoll *np)
> 		return -ENODEV;
> 	}
> 
>-	if (netdev_master_upper_dev_get(ndev)) {
>+	rcu_read_lock();
>+	if (netdev_master_upper_dev_get_rcu(ndev)) {
>+		rcu_read_unlock();
> 		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
> 		err = -EBUSY;
> 		goto put;
> 	}
>+	rcu_read_unlock();
> 
> 	if (!netif_running(ndev)) {
> 		unsigned long atmost, atleast;

Thanks Amerigo.
