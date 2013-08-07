From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: A soft lockup in vxlan module
Date: Tue, 6 Aug 2013 19:18:07 -0700
Message-ID: <CAOaVG14-vSR-gt+c8zMe+rk6MX4xO3dGxZHi--M6Nun+qTOSVQ@mail.gmail.com>
References: <1375838634.11370.13.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:46729 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756470Ab3HGCSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 22:18:08 -0400
Received: by mail-ve0-f173.google.com with SMTP id cy12so1181287veb.4
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 19:18:07 -0700 (PDT)
In-Reply-To: <1375838634.11370.13.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling unlock in dellink is not safe.
can you reproduce with 3.10 or 3.11-rc?

On Tue, Aug 6, 2013 at 6:23 PM, Cong Wang <amwang@redhat.com> wrote:
> Hi, Stephen
>
> You introduced a soft lockup in vxlan module in
>
> commit fe5c3561e6f0ac7c9546209f01351113c1b77ec8
> Author: stephen hemminger <stephen@networkplumber.org>
> Date:   Sat Jul 13 10:18:18 2013 -0700
>
>     vxlan: add necessary locking on device removal
>
> The problem is that vxlan_dellink(), which is called with RTNL lock
> held, tries to flush the workqueue synchronously, but apparently
> igmp_join and igmp_leave work need to hold RTNL lock too, therefore we
> have a soft lockup! This is 100% reproducible on my 2.6.32 backport
> while running `modprobe -r vxlan`.
>
> A quick but perhaps ugly fix is just releasing RTNL lock before calling
> flush_workqueue():
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 8bf31d9..581d3d5 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1837,7 +1837,9 @@ static void vxlan_dellink(struct net_device *dev,
> struct list_head *head)
>         struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
>         struct vxlan_dev *vxlan = netdev_priv(dev);
>
> +       rtnl_unlock();
>         flush_workqueue(vxlan_wq);
> +       rtnl_lock();
>
>         spin_lock(&vn->sock_lock);
>         hlist_del_rcu(&vxlan->hlist);
>
> However, I think a better way is still what I did, that is, removing
> RTNL lock from ip_mc_join_group() and ip_mc_leave_group().
>
> What do you think? Any other idea to fix it?
>
> Thanks.
>
