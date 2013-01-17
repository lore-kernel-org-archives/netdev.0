From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4] netpoll: fix a rtnl lock assertion failure
Date: Thu, 17 Jan 2013 11:30:18 +0800
Message-ID: <1358393418.3855.3.camel@cr0>
References: <1358242446-4273-1-git-send-email-amwang@redhat.com>
	 <1358385885.32167.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757238Ab3AQDwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 22:52:22 -0500
In-Reply-To: <1358385885.32167.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 17:24 -0800, Eric Dumazet wrote:
> On Tue, 2013-01-15 at 17:34 +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > v4: hold rtnl lock for the whole netpoll_setup()
> > v3: remove the comment
> > v2: use RCU read lock
> > 
> > This patch fixes the following warning:
> > 
> > [   72.013864] RTNL: assertion failed at net/core/dev.c (4955)
> > [   72.017758] Pid: 668, comm: netpoll-prep-v6 Not tainted 3.8.0-rc1+ #474
> > [   72.019582] Call Trace:
> > [   72.020295]  [<ffffffff8176653d>] netdev_master_upper_dev_get+0x35/0x58
> > [   72.022545]  [<ffffffff81784edd>] netpoll_setup+0x61/0x340
> > [   72.024846]  [<ffffffff815d837e>] store_enabled+0x82/0xc3
> > [   72.027466]  [<ffffffff815d7e51>] netconsole_target_attr_store+0x35/0x37
> > [   72.029348]  [<ffffffff811c3479>] configfs_write_file+0xe2/0x10c
> > [   72.030959]  [<ffffffff8115d239>] vfs_write+0xaf/0xf6
> > [   72.032359]  [<ffffffff81978a05>] ? sysret_check+0x22/0x5d
> > [   72.033824]  [<ffffffff8115d453>] sys_write+0x5c/0x84
> > [   72.035328]  [<ffffffff819789d9>] system_call_fastpath+0x16/0x1b
> > 
> > In case of other races, hold rtnl lock for the entire netpoll_setup() function.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Jiri Pirko <jiri@resnulli.us>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > ---
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> 
> ...
> 
> >  	if (np->dev_name)
> > -		ndev = dev_get_by_name(&init_net, np->dev_name);
> > +		ndev = __dev_get_by_name(&init_net, np->dev_name);
> 
> This change brings interesting bugs.

Hmm, I didn't realize __dev_get_by_name() doesn't hold the device, so
just call dev_hold() after this?

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a5ad1c1..a9b1004 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1056,6 +1056,7 @@ int netpoll_setup(struct netpoll *np)
                err = -ENODEV;
                goto unlock;
        }
+       dev_hold(ndev);
 
        if (netdev_master_upper_dev_get(ndev)) {
                np_err(np, "%s is a slave device, aborting\n",
np->dev_name);


> 
> All the "goto put;" are basically wrong, and the section waiting for the
> carrier and releasing/getting rtnl is buggy.

Either we have to sleep for few seconds with rtnl lock held, or leave as
it is. The original code doesn't hold rtnl lock either.

Thanks!
