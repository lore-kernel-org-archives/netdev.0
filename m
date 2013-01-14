From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] netpoll: fix a rtnl lock assertion failure
Date: Mon, 14 Jan 2013 17:58:00 +0800
Message-ID: <1358157480.338.6.camel@cr0>
References: <1358153708-9099-1-git-send-email-amwang@redhat.com>
	 <20130114091543.GA1620@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755277Ab3ANJ6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 04:58:08 -0500
In-Reply-To: <20130114091543.GA1620@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 10:15 +0100, Jiri Pirko wrote:
> Mon, Jan 14, 2013 at 09:55:08AM CET, amwang@redhat.com wrote:
> >From: Cong Wang <amwang@redhat.com>
> >
> >This patch fixes the following warning:
> >
> >[   72.013864] RTNL: assertion failed at net/core/dev.c (4955)
> >[   72.017758] Pid: 668, comm: netpoll-prep-v6 Not tainted 3.8.0-rc1+ #474
> >[   72.019582] Call Trace:
> >[   72.020295]  [<ffffffff8176653d>] netdev_master_upper_dev_get+0x35/0x58
> >[   72.022545]  [<ffffffff81784edd>] netpoll_setup+0x61/0x340
> >[   72.024846]  [<ffffffff815d837e>] store_enabled+0x82/0xc3
> >[   72.027466]  [<ffffffff815d7e51>] netconsole_target_attr_store+0x35/0x37
> >[   72.029348]  [<ffffffff811c3479>] configfs_write_file+0xe2/0x10c
> >[   72.030959]  [<ffffffff8115d239>] vfs_write+0xaf/0xf6
> >[   72.032359]  [<ffffffff81978a05>] ? sysret_check+0x22/0x5d
> >[   72.033824]  [<ffffffff8115d453>] sys_write+0x5c/0x84
> >[   72.035328]  [<ffffffff819789d9>] system_call_fastpath+0x16/0x1b
> >
> >by holding the rtnl_lock. And as we just want test if the device
> >has any upper device, so I think netdev_has_any_upper_dev() is enough.
> >
> >Cc: Jiri Pirko <jiri@resnulli.us>
> >Cc: David S. Miller <davem@davemloft.net>
> >Signed-off-by: Cong Wang <amwang@redhat.com>
> >
> >---
> >diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> >index 9f05067..dd28cdd 100644
> >--- a/net/core/netpoll.c
> >+++ b/net/core/netpoll.c
> >@@ -1055,7 +1055,9 @@ int netpoll_setup(struct netpoll *np)
> > 		return -ENODEV;
> > 	}
> > 
> >-	if (netdev_master_upper_dev_get(ndev)) {
> >+	rtnl_lock();
> >+	if (netdev_has_any_upper_dev(ndev)) {
> 
> 	
> This would prevent from using dev with for example vlan dev attached to
> it. Is it desirable? I suppose not.

No, it should not. I didn't notice netdev_has_any_upper_dev() could
prevent the device under vlan, I will keep
netdev_master_upper_dev_get().

> 
> Also I think in this situation, netdev_master_upper_dev_get_rcu() would
> be probably better to use. Not sure though.
> 

Yes, as we only read it.

Thanks!
