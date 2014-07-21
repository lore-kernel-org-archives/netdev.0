From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 16:06:48 +0200
Message-ID: <CAG-2HqXNi1_yNOTLcvDys3hHJ4wHU+aJLOCgdu4uiYLBTwyFdw@mail.gmail.com>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <CAG-2HqXFBUmpTAE8h13-DmP6Fq42viHzmuH9OfNoLgjW8XcQ3Q@mail.gmail.com> <DC7803B42427924284F2D5252E076A3B4476A6D1@SINEX14MBXC416.southpacific.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	Thomas Shao <huishao@microsoft.com>,
	Dexuan Cui <decui@microsoft.com>,
	Lennart Poettering <lennart@poettering.net>
To: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:58143 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423AbaGUOHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 10:07:09 -0400
Received: by mail-yh0-f51.google.com with SMTP id f73so4060182yha.10
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 07:07:08 -0700 (PDT)
In-Reply-To: <DC7803B42427924284F2D5252E076A3B4476A6D1@SINEX14MBXC416.southpacific.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014 at 12:21 PM, Yue Zhang (OSTC DEV)
<yuezha@microsoft.com> wrote:
>> From: Tom Gundersen [mailto:teg@jklm.no]
>> Sent: Monday, July 21, 2014 5:42 PM
>>
>> On Fri, Jul 18, 2014 at 12:55 PM, Yue Zhang <yuezha@microsoft.com> wrote:
>> > From: Yue Zhang <yuezha@microsoft.com>
>> >
>> > This patch addresses the comment from Olaf Hering and Greg KH
>> > for a previous commit 3a494e710367 ("hyperv: Add handler for
>> > RNDIS_STATUS_NETWORK_CHANGE event")
>> >
>> > In previous solution, the driver calls "network restart" to
>> > force a DHCP renew when the host is back from hibernation.
>> >
>> > In this fix, the driver will keep network carrier offline for
>> > 10 seconds and then bring it back. So that ifplugd daemon will
>> > notice this change and refresh DHCP lease.
>> >
>> > Cc: Haiyang Zhang <haiyangz@microsoft.com>
>> > Cc: K. Y. Srinivasan <kys@microsoft.com>
>> >
>> > Signed-off-by: Yue Zhang <yuezha@microsoft.com>
>> > ---
>> >  drivers/net/hyperv/netvsc_drv.c | 21 +++++++++++++++++----
>> >  1 file changed, 17 insertions(+), 4 deletions(-)
>> >
>> > diff --git a/drivers/net/hyperv/netvsc_drv.c
>> b/drivers/net/hyperv/netvsc_drv.c
>> > index a9c5eaa..559c97d 100644
>> > --- a/drivers/net/hyperv/netvsc_drv.c
>> > +++ b/drivers/net/hyperv/netvsc_drv.c
>> > @@ -33,6 +33,7 @@
>> >  #include <linux/if_vlan.h>
>> >  #include <linux/in.h>
>> >  #include <linux/slab.h>
>> > +#include <linux/delay.h>
>> >  #include <net/arp.h>
>> >  #include <net/route.h>
>> >  #include <net/sock.h>
>> > @@ -792,8 +793,7 @@ static void netvsc_link_change(struct work_struct
>> *w)
>> >         struct netvsc_device *net_device;
>> >         struct rndis_device *rdev;
>> >         bool notify, refresh = false;
>> > -       char *argv[] = { "/etc/init.d/network", "restart", NULL };
>> > -       char *envp[] = { "HOME=/", "PATH=/sbin:/usr/sbin:/bin:/usr/bin",
>> NULL };
>> > +       int delay;
>> >
>> >         rtnl_lock();
>> >
>> > @@ -816,8 +816,21 @@ static void netvsc_link_change(struct work_struct
>> *w)
>> >
>> >         rtnl_unlock();
>> >
>> > -       if (refresh)
>> > -               call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
>> > +       if (refresh) {
>> > +               /*
>> > +                * Keep the carrier offline for 10 seconds
>> > +                * to notify ifplugd daemon network change
>> > +                */
>> > +               for (delay = 0; delay < 10; delay++) {
>> > +                       rtnl_lock();
>> > +                       netif_carrier_off(net);
>> > +                       rtnl_unlock();
>> > +                       ssleep(1);
>> > +               }
>> > +               rtnl_lock();
>> > +               netif_carrier_on(net);
>> > +               rtnl_unlock();
>> > +       }
>>
>> Why is it necessary to wait for ten seconds? Why not just:
>>
>> if (refresh) {
>>         rtnl_lock();
>>         netif_carrier_off(net);
>>         netif_carrier_on(net);
>>         rtnl_unlock();
>> }
>>
>> At least systemd-networkd will renew the dhcp lease as long as it gets
>> NEWLINK messages indicating that the carrier was lost and regained,
>> regardless of the time between events. Is there any reason not to do
>> this?
>>
>> Cheers,
>>
>> Tom
>>
>
> Hi, Tom
>
> Some network monitoring daemon, like ifplugd has a deferring mechanism.
> When it detects carriers is offline, it doesn't trigger DHCP renew immediately.
> Instead it will wait for another 5 seconds to check whether carrier is back to
> online status. In that case, it will avoid renew DHCP lease.
>
> And also there is some optimization in Linux's network stack. If link state
> flipped so quickly, like the code you proposed. It is very likely the event won't
> be delivered to user space.

Ah, ok, I don't know the kernel side of this too well, you may need
some sort of flush or sync between the calls I suggested. At any rate,
I would say that the solution should be to send a "lower down"
followed immediately by "lower up" and never have any sort of timeout.
All the drivers I have tried send out such events immediately when the
machine is resumed, so I guess most network software should know how
to deal with that.

I really think the policy of what to do in response to the various
events should be left to userspace to figure out.

Cheers,

Tom
