From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] l2tp: fix race condition in l2tp_tunnel_delete
Date: Fri, 15 Sep 2017 22:38:39 +0200
Message-ID: <20170915203839.v7zu54675o4manwy@alphalink.fr>
References: <f07e7ba88b9b4651900a888796e3f8816d06a8a8.1505396134.git.sd@queasysnail.net>
 <20170915094259.GA3209@jackdaw>
 <20170915145502.GA18157@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
        Xin Long <lucien.xin@gmail.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60264 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751556AbdIOUim (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 16:38:42 -0400
Content-Disposition: inline
In-Reply-To: <20170915145502.GA18157@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 04:55:02PM +0200, Sabrina Dubroca wrote:
> 2017-09-15, 10:42:59 +0100, Tom Parkin wrote:
> > On Fri, Sep 15, 2017 at 11:08:07AM +0200, Sabrina Dubroca wrote:
> > > The tunnel is currently removed from the list during destruction. This
> > > can lead to a double-free of the struct sock if we try to delete the tunnel
> > > twice fast enough.
> > > 
> > > The first delete operation does a lookup (l2tp_tunnel_get), finds the
> > > tunnel, calls l2tp_tunnel_delete, which queues it for deletion by
> > > l2tp_tunnel_del_work.
> > >
> > > The second delete operation also finds the tunnel and calls
> > > l2tp_tunnel_delete. If the workqueue has already fired and started
> > > running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
> > > same tunnel a second time, and try to free the socket again.
> > > 
> > > Add a dead flag and remove tunnel from its list earlier. Then we can
> > > remove the check of queue_work's result that was meant to prevent that
> > > race but doesn't.
> > 
> > How do we avoid leaving stale information on the tunnel list for
> > use-cases which don't delete tunnels using netlink?  For example the
> > L2TPv2 ppp/socket API depends on sk_destruct to clean up the kernel
> > context on socket destruction.  Similarly, userspace may just close
> > the tunnel socket without first making netlink calls to delete the
> > tunnel.
> > 
> > By moving the tunnel list removal from l2tp_tunnel_destruct to
> > l2tp_tunnel_delete I can't see how codepaths which don't involve
> > l2tp_tunnel_delete don't end up with a corrupted tunnel list.
> 
> Ok, thanks for pointing that out. We could go with just the ->dead
> flag then.
> 
Yes, I guess that's the least instrusive way to fix this issue.

> I'm not sure whether we need to set it in l2tp_tunnel_destruct as
> well.
> 
It shouldn't be necessary. If the socket is managed by userspace, then
l2tp_tunnel_del_work() gets it using sockfd_lookup(). Therefore it
shouldn't find it if userspace is in the process of releasing it.
Also l2tp_tunnel_del_work() doesn't try to release sockets handled by
userspace, so not checking ->dead in l2tp_tunnel_destruct() should be
safe.
