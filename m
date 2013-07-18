From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 1/2] vxlan: unregister on namespace exit
Date: Thu, 18 Jul 2013 09:58:28 -0700
Message-ID: <20130718095828.715cc9f4@nehalam.linuxnetplumber.net>
References: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
	<CALnjE+rStFY0nmTytAX7nLeg2O2kxP7WRSo-M3r_K59ELT1Y+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:57283 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757070Ab3GRQ6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 12:58:32 -0400
Received: by mail-pa0-f45.google.com with SMTP id bi5so3422162pad.18
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 09:58:32 -0700 (PDT)
In-Reply-To: <CALnjE+rStFY0nmTytAX7nLeg2O2kxP7WRSo-M3r_K59ELT1Y+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Jul 2013 09:40:07 -0700
Pravin Shelar <pshelar@nicira.com> wrote:

> On Thu, Jul 18, 2013 at 8:38 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > Fix memory leaks and other badness from VXLAN network namespace
> > teardown. When network namespace is removed, all the vxlan devices should
> > be unregistered (not closed).
> >
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> >
> >
> > --- a/drivers/net/vxlan.c       2013-07-17 16:32:10.826955800 -0700
> > +++ b/drivers/net/vxlan.c       2013-07-17 16:47:35.275690741 -0700
> > @@ -1878,10 +1878,12 @@ static __net_exit void vxlan_exit_net(st
> >  {
> >         struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> >         struct vxlan_dev *vxlan;
> > +       LIST_HEAD(list);
> >
> >         rtnl_lock();
> > -       list_for_each_entry(vxlan, &vn->vxlan_list, next)
> > -               dev_close(vxlan->dev);
> > +       list_for_each_entry(vxlan, &vn->vxlan_list, next)
> > +               unregister_netdevice_queue(vxlan->dev, &list);
> > +       unregister_netdevice_many(&list);
> >         rtnl_unlock();
> >  }
> >
> Looks good.
> Reviewed-by: Pravin B Shelar <pshelar@nicira.com>

vxlan might be a candidate for integration with the generic ip_tunnel
code, but haven't looked at all the details.
