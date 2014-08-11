From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 11 Aug 2014 00:22:10 -0400
Message-ID: <20140811002210.2a697052767e9ec1989cb219@mindspring.com>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de>
 <20140721.143225.2040366896972949930.davem@davemloft.net>
 <CAFLxGvyfy1UkxN6_-c_ST7f8n7DvqYsCPKChWmt9CerWb0dh7g@mail.gmail.com>
 <EE124450C0AAF944A40DD71E61F878C99149D0@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808033220.GB10503@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991569A@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808134549.GD4427@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991B653@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <53E83DD4.1060500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <stephen@networkplumber.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>,
 Richard Weinberger <richard.weinberger@gmail.com>,
 Greg KH <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, LKML <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>,
 "Yue Zhang \(OSTC DEV\)" <yuezha@microsoft.com>,
 Thomas Shao <huishao@microsoft.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <53E83DD4.1060500@gmail.com>
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

On Sun, 10 Aug 2014, Florian Fainelli wrote:

> Le 10/08/2014 20:23, Dexuan Cui a =E9crit :
> >> -----Original Message-----
> >> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> >>>>>
> >>>>> IMO the most feasible and need-the-least-change solution may be:
> >>>>> the hyperv network VSC driver passes the event
> >>>>> RNDIS_STATUS_NETWORK_CHANGE to the udev daemon?
> >>>>>
> >>>> No, don't do that, again, act like any other network device, drop the
> >>>> link and bring it up when it comes back.
> >>>>
> >>> Hi Greg,
> >>> Do you mean tearing down the net device and re-creating it (by
> >>> register_netdev() and unregister_netdev)?
> >>
> >> No, don't you have link-detect for your network device?  Toggle that, I
> >> thought patches to do this were posted a while ago...
> >>
> >> But if you really want to tear the whole network device down and then
> >> back up again, sure, that would also work.
> > Hi Greg, Stephen,
> >
> > Thanks for the comments!
> >
> > I suppose you meant the below logic:
> > if (refresh) {
> >          rtnl_lock();
> >          netif_carrier_off(net);
> >          netif_carrier_on(net);
> >          rtnl_unlock();
> > }
> >
> > We have discussed this in the previous mails of this thread itself:
> > e.g., http://marc.info/?l=3Dlinux-driver-devel&m=3D140593811715975&w=3D2
> >
> > Unluckily this logic doesn't work because the user-space daemons
> > like ifplugd, usually don't renew the DHCP immediately as long as they
> > receive a link-down message: they usually wait for some seconds and if
> > they find the link becomes up soon, they won't trigger renew operations.
> > (I guess this behavior can be somewhat reasonable: maybe the daemons
> > try to not trigger DHCP renew on temporary link instability)
> =

> Is that such a big deal? If you know you spend much of your time in =

> ifplugd, why not use something different that triggers a DHCP renewal =

> faster, or fix ifplugd?

In the case of ifplugd, it has parameters -u | --delay-up=3D which
defaults to 0 seconds, and -d | --delay-down=3D which defaults to
5 seconds.  Maybe for hyperv you could specify --delay-down=3D0.
I don't know if other daemons such as systemd have similar options.
It might still be good to have some modest delay between the
netif_carrier_off(net) and netif_carrier_on(net).

						-Bill
