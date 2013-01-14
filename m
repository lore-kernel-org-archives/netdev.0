From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] netpoll: fix a rtnl lock assertion failure
Date: Mon, 14 Jan 2013 18:42:48 +0800
Message-ID: <1358160168.338.12.camel@cr0>
References: <1358159054-21951-1-git-send-email-amwang@redhat.com>
	 <20130114103201.GA1633@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954Ab3ANKm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 05:42:56 -0500
In-Reply-To: <20130114103201.GA1633@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 11:32 +0100, Jiri Pirko wrote:
> Mon, Jan 14, 2013 at 11:24:14AM CET, amwang@redhat.com wrote:
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
> >Just hold RCU read lock and call netdev_master_upper_dev_get_rcu(),
> >as suggested by Jiri.
> >
> >Cc: Jiri Pirko <jiri@resnulli.us>
> >Cc: David S. Miller <davem@davemloft.net>
> >Signed-off-by: Cong Wang <amwang@redhat.com>
> >
> >---
> >diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> >index 9f05067..6d56b57 100644
> >--- a/net/core/netpoll.c
> >+++ b/net/core/netpoll.c
> >@@ -1055,11 +1055,15 @@ int netpoll_setup(struct netpoll *np)
> > 		return -ENODEV;
> > 	}
> > 
> >-	if (netdev_master_upper_dev_get(ndev)) {
> >+	rcu_read_lock();
> >+	/* We permit devices with VLAN attached to */
> 
> I think that this comment might be misleading. Master upper is not set
> not only for VLAN but for macvlan (and in future possibly for others) as well.	
> 

OK, I will remove it.
