From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Tue, 12 Aug 2014 07:48:56 +0000
Message-ID: <EE124450C0AAF944A40DD71E61F878C9921095@SINEX14MBXC417.southpacific.corp.microsoft.com>
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>,
 Richard Weinberger <richard.weinberger@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, LKML <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>,
 "Yue Zhang \(OSTC DEV\)" <yuezha@microsoft.com>,
 Thomas Shao <huishao@microsoft.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>
To: Florian Fainelli <f.fainelli@gmail.com>, Greg KH
 <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <53E83DD4.1060500@gmail.com>
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

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Monday, August 11, 2014 11:52 AM
> > I suppose you meant the below logic:
> > if (refresh) {
> >          rtnl_lock();
> >          netif_carrier_off(net);
> >          netif_carrier_on(net);
> >          rtnl_unlock();
> > }
> >
> > We have discussed this in the previous mails of this thread itself:
> > e.g., http://marc.info/?l=linux-driver-devel&m=140593811715975&w=2
> >
> > Unluckily this logic doesn't work because the user-space daemons
> > like ifplugd, usually don't renew the DHCP immediately as long as they
> > receive a link-down message: they usually wait for some seconds and if
> > they find the link becomes up soon, they won't trigger renew operations.
> > (I guess this behavior can be somewhat reasonable: maybe the daemons
> > try to not trigger DHCP renew on temporary link instability)
> 
> Is that such a big deal? If you know you spend much of your time in
> ifplugd, why not use something different that triggers a DHCP renewal
> faster, or fix ifplugd?
 
Hi Florian,
Thanks for the comment!
Yes, we can fix ifplugd and ALL other equivalent daemons, but that would
need much more efforts, so I was trying to add a workaround in the kernel
driver -- now I've realized this is not a good solution. :-)

> > If we use this logic in the kernel space, we'll have to "fix" the user-space
> > daemons, like ifplugd, systemd-networkd...,etc.
> 
> You mean the opposite here don't you? If you put that logic in kernel
> space you don't have to fix the userland.

I think we'll have to fix the userland or customize the userland by passing
proper parameters(if there is any) to the userland daemons(when they run
in a hyper-v guest) if we use the below logic in the driver:
if (refresh) {
          rtnl_lock();
          netif_carrier_off(net);
          netif_carrier_on(net);
          rtnl_unlock();
}
e.g., as Bill told in another mail, ifplugd has --delay-down.

> > I'm not sure our attempt to "fix" the daemons can be easily accepted.
> > BTW, by CPUID, an application has a reliable way to determine  if it's
> > running on hyper-v on not. Maybe we can "fix" the behavior of the
> > daemons when they run on hyper-v?
> 
> That is not acceptable as well, why would an user-space application
> would have to care that much whether it runs on hyper-v or a physical
> host? Not to mention that anytime someone develops a similar but new
> application they would have to become aware of such platform and its
> "specicities".
Ok, I understood.

> > BTW2, according to my limited experience, I doubt other VMMs can
> > handle this auto-DHCP-renew-in-guest issue properly.
> >
> > That was why Yue's patch wanted to add a SLEEP(10s) between the
> > link-down and link-up events and hoped this could be an acceptable
> > fix(while it turned out not, obviously), though we admit it's not so good
> > to add such a magic number "10s" in a kernel driver.
> >
> > Please point it out if I missed or misunderstand something.
> 
> I think this is just an integration issue that you are having, and I
> would not be focusing on any particular user-space implementation, but
> rather put something in the driver that is sensible, just like what was
> suggested before: toggling the carrier state.
OK, let me send a netif_carrier_off()/on() patch after I verify the daemons
can work with proper parameters specified.

Thanks,
-- Dexuan
