From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 1/2] vxlan: unregister on namespace exit
Date: Thu, 18 Jul 2013 11:28:14 -0700
Message-ID: <CALnjE+p_TvGYuEQw1U8kVAMOxMWTBB0wxhXYoE-LWv8cTvxknA@mail.gmail.com>
References: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
	<CALnjE+rStFY0nmTytAX7nLeg2O2kxP7WRSo-M3r_K59ELT1Y+A@mail.gmail.com>
	<20130718095828.715cc9f4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:50133 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932496Ab3GRS2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 14:28:16 -0400
Received: by mail-qa0-f53.google.com with SMTP id g10so1872812qah.19
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 11:28:14 -0700 (PDT)
In-Reply-To: <20130718095828.715cc9f4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 18, 2013 at 9:58 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 18 Jul 2013 09:40:07 -0700
> Pravin Shelar <pshelar@nicira.com> wrote:
>
>> On Thu, Jul 18, 2013 at 8:38 AM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>> > Fix memory leaks and other badness from VXLAN network namespace
>> > teardown. When network namespace is removed, all the vxlan devices should
>> > be unregistered (not closed).
>> >
>> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> >
>> >
>> > --- a/drivers/net/vxlan.c       2013-07-17 16:32:10.826955800 -0700
>> > +++ b/drivers/net/vxlan.c       2013-07-17 16:47:35.275690741 -0700
>> > @@ -1878,10 +1878,12 @@ static __net_exit void vxlan_exit_net(st
>> >  {
>> >         struct vxlan_net *vn = net_generic(net, vxlan_net_id);
>> >         struct vxlan_dev *vxlan;
>> > +       LIST_HEAD(list);
>> >
>> >         rtnl_lock();
>> > -       list_for_each_entry(vxlan, &vn->vxlan_list, next)
>> > -               dev_close(vxlan->dev);
>> > +       list_for_each_entry(vxlan, &vn->vxlan_list, next)
>> > +               unregister_netdevice_queue(vxlan->dev, &list);
>> > +       unregister_netdevice_many(&list);
>> >         rtnl_unlock();
>> >  }
>> >
>> Looks good.
>> Reviewed-by: Pravin B Shelar <pshelar@nicira.com>
>
> vxlan might be a candidate for integration with the generic ip_tunnel
> code, but haven't looked at all the details.

ip_tunnel already does same on net-exit.
