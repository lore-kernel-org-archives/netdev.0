From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] netpoll: fix a rtnl lock assertion failure
Date: Mon, 14 Jan 2013 10:15:43 +0100
Message-ID: <20130114091543.GA1620@minipsycho.orion>
References: <1358153708-9099-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:64893 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab3ANJPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 04:15:47 -0500
Received: by mail-we0-f181.google.com with SMTP id t11so1906817wey.12
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 01:15:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1358153708-9099-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 14, 2013 at 09:55:08AM CET, amwang@redhat.com wrote:
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
>by holding the rtnl_lock. And as we just want test if the device
>has any upper device, so I think netdev_has_any_upper_dev() is enough.
>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Cc: David S. Miller <davem@davemloft.net>
>Signed-off-by: Cong Wang <amwang@redhat.com>
>
>---
>diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>index 9f05067..dd28cdd 100644
>--- a/net/core/netpoll.c
>+++ b/net/core/netpoll.c
>@@ -1055,7 +1055,9 @@ int netpoll_setup(struct netpoll *np)
> 		return -ENODEV;
> 	}
> 
>-	if (netdev_master_upper_dev_get(ndev)) {
>+	rtnl_lock();
>+	if (netdev_has_any_upper_dev(ndev)) {

	
This would prevent from using dev with for example vlan dev attached to
it. Is it desirable? I suppose not.

Also I think in this situation, netdev_master_upper_dev_get_rcu() would
be probably better to use. Not sure though.

	
>+		rtnl_unlock();
> 		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
> 		err = -EBUSY;
> 		goto put;
>@@ -1066,7 +1068,6 @@ int netpoll_setup(struct netpoll *np)
> 
> 		np_info(np, "device %s not up yet, forcing it\n", np->dev_name);
> 
>-		rtnl_lock();
> 		err = dev_open(ndev);
> 		rtnl_unlock();
> 
>@@ -1094,7 +1095,8 @@ int netpoll_setup(struct netpoll *np)
> 			np_notice(np, "carrier detect appears untrustworthy, waiting 4 seconds\n");
> 			msleep(4000);
> 		}
>-	}
>+	} else
>+		rtnl_unlock();
> 
> 	if (!np->local_ip.ip) {
> 		if (!np->ipv6) {
