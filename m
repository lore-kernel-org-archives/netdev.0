From: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>
Subject: RE: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 02:44:35 +0000
Message-ID: <DC7803B42427924284F2D5252E076A3B44769DCA@SINEX14MBXC416.southpacific.corp.microsoft.com>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <CAFLxGvxQU_z+mChHsNSu9VZEdXrU+RU75k6H18uKbdAj2TKD5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, LKML <linux-kernel@vger.kernel.org>,
 Thomas Shao <huishao@microsoft.com>, Greg KH <gregkh@linuxfoundation.org>,
 "David S. Miller" <davem@davemloft.net>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAFLxGvxQU_z+mChHsNSu9VZEdXrU+RU75k6H18uKbdAj2TKD5g@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

> From: Richard Weinberger [mailto:richard.weinberger@gmail.com]
> Sent: Friday, July 18, 2014 9:41 PM
> 
> On Fri, Jul 18, 2014 at 12:55 PM, Yue Zhang <yuezha@microsoft.com> wrote:
> > From: Yue Zhang <yuezha@microsoft.com>
> >
> > This patch addresses the comment from Olaf Hering and Greg KH
> > for a previous commit 3a494e710367 ("hyperv: Add handler for
> > RNDIS_STATUS_NETWORK_CHANGE event")
> >
> > In previous solution, the driver calls "network restart" to
> > force a DHCP renew when the host is back from hibernation.
> >
> > In this fix, the driver will keep network carrier offline for
> > 10 seconds and then bring it back. So that ifplugd daemon will
> > notice this change and refresh DHCP lease.
> >
> > Cc: Haiyang Zhang <haiyangz@microsoft.com>
> > Cc: K. Y. Srinivasan <kys@microsoft.com>
> >
> > Signed-off-by: Yue Zhang <yuezha@microsoft.com>
> > ---
> >  drivers/net/hyperv/netvsc_drv.c | 21 +++++++++++++++++----
> >  1 file changed, 17 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> > index a9c5eaa..559c97d 100644
> > --- a/drivers/net/hyperv/netvsc_drv.c
> > +++ b/drivers/net/hyperv/netvsc_drv.c
> > @@ -33,6 +33,7 @@
> >  #include <linux/if_vlan.h>
> >  #include <linux/in.h>
> >  #include <linux/slab.h>
> > +#include <linux/delay.h>
> >  #include <net/arp.h>
> >  #include <net/route.h>
> >  #include <net/sock.h>
> > @@ -792,8 +793,7 @@ static void netvsc_link_change(struct work_struct
> *w)
> >         struct netvsc_device *net_device;
> >         struct rndis_device *rdev;
> >         bool notify, refresh = false;
> > -       char *argv[] = { "/etc/init.d/network", "restart", NULL };
> > -       char *envp[] = { "HOME=/", "PATH=/sbin:/usr/sbin:/bin:/usr/bin",
> NULL };
> > +       int delay;
> >
> >         rtnl_lock();
> >
> > @@ -816,8 +816,21 @@ static void netvsc_link_change(struct work_struct
> *w)
> >
> >         rtnl_unlock();
> >
> > -       if (refresh)
> > -               call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
> > +       if (refresh) {
> > +               /*
> > +                * Keep the carrier offline for 10 seconds
> > +                * to notify ifplugd daemon network change
> > +                */
> 
> Why 10? Is this a random number which works by accident for ifplugd?
> What about other networking implementations, is 10 also ok for them?
> --
> Thanks,
> //richard

Hi, Richard

I checked ifplugd's code. The deferring time is 5 seconds. That's how  comes 
the "10s". I agree with you this is a magic number and should be avoid. However, 
this is the only feasible solution right now. If there is a better solution, I will be 
glad to switch to it.

I tested the fix in Redhat, Ubuntu and SUSE and it works in all of them.

Thanks
Yie
