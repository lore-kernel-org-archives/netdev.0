From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Wed, 13 Aug 2014 08:34:48 -0500
Message-ID: <1407936888.1825.0.camel@dcbw.local>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de>
 <20140721.143225.2040366896972949930.davem@davemloft.net>
 <CAFLxGvyfy1UkxN6_-c_ST7f8n7DvqYsCPKChWmt9CerWb0dh7g@mail.gmail.com>
 <EE124450C0AAF944A40DD71E61F878C99149D0@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808033220.GB10503@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991569A@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808134549.GD4427@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991B653@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <CAG-2HqVE8Qk0pcW+36f44RkE-Kbp+qPqRT+vgg-v35W52bsKgg@mail.gmail.com>
 <EE124450C0AAF944A40DD71E61F878C9921258@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <CAG-2HqWZtOk=mnsaAh5-zpWG-fv=Omq43GV9dMKHNfr1xEFQTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: Tom Gundersen <teg@jklm.no>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAG-2HqWZtOk=mnsaAh5-zpWG-fv=Omq43GV9dMKHNfr1xEFQTw@mail.gmail.com>
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

On Wed, 2014-08-13 at 15:15 +0200, Tom Gundersen wrote:
> On Tue, Aug 12, 2014 at 10:29 AM, Dexuan Cui <decui@microsoft.com> wrote:
> >> From: Tom Gundersen
> >> > Unluckily this logic doesn't work because the user-space daemons
> >> > like ifplugd, usually don't renew the DHCP immediately as long as they
> >> > receive a link-down message: they usually wait for some seconds and if
> >> > they find the link becomes up soon, they won't trigger renew operations.
> >> > (I guess this behavior can be somewhat reasonable: maybe the daemons
> >> > try to not trigger DHCP renew on temporary link instability)
> >> >
> >> networkd does not suffer from this problem, and in ifplugd it can be
> > I didn't have time to check the code of networkd, but I think it does have the
> > same behavior.
> > e.g., on a bare metal host with Ubuntu 14.04, when I plug the RJ45 cable out
> > of the network card and then plug the cable back into the network card
> > quickly -- in ~3 seconds, networkd doesn't trigger DHCP renew request: in
> > /var/log/syslog, we see
> > Aug 12 11:07:07 decui-lin NetworkManager[828]: <info> (eth0): carrier now OFF (device state 100, deferring action for 4 seconds)
> > Aug 12 11:07:07 decui-lin kernel: [  246.975453] e1000e: eth0 NIC Link is Down
> > Aug 12 11:07:10 decui-lin NetworkManager[828]: <info> (eth0): carrier now ON (device state 100)
> > Aug 12 11:07:10 decui-lin kernel: [  250.028533] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
> >
> > It looks there is a delay of 4s.
> > I'm going to find out if there is a configurable parameter for this.
> 
> Just to avoid any confusion: you are referring to "networkd" (and so
> did my comments), but the above logs are from "NetworkManager".

And yes, NM does have a 4-second delay before processing a carrier down
event, and NM currently does not renew DHCP on link changes, but that's
certainly something we can/should change.

Dan

> >> disabled. Most other network drivers will send
> >> IFF_LOWER_DOWN/IFF_LOWER_UP upon suspend/resume so if you were to
> >> do the same you will not work any worse than the others. What would be
> > suspend/resume(ACPI S3?) is different  as this is usually > 4 seconds?  :-)
> 
> Sure, but that's clearly not something we should rely on.
> 
> >> nice, as mentioned by Dan and Lennart, would be to send an additional
> >> explicit event such as "resumed from suspend" or "L3 may be wrong".
> > Sorry, I neglected to reply this.
> > IMHO even if we add the new event, we still need lots of efforts to
> > make the various userland daemons(ifplugd, networkd, etc) to use the
> > new event.
> > And looks we're the first user of this new event. I'm not sure if this issue
> > here can convince the network subsystem maintainers such a new event
> > is a must.
> >
> >> That should be a generic thing though, to fix all such issues in one
> >> go.
> > I agree, though this requires we update all the userland daemons...
> >
> >> > I'm not sure our attempt to "fix" the daemons can be easily accepted.
> >> > BTW, by CPUID, an application has a reliable way to determine  if it's
> >> > running on hyper-v on not. Maybe we can "fix" the behavior of the
> >> > daemons when they run on hyper-v?
> >> > BTW2, according to my limited experience, I doubt other VMMs can
> >> > handle this auto-DHCP-renew-in-guest issue properly.
> >>
> >> To the extent this is a problem, it is a generic one, so we should not
> >> need any hyper-v specific logic in userspace.
> > OK, I understood.
> >
> >> > That was why Yue's patch wanted to add a SLEEP(10s) between the
> >> > link-down and link-up events and hoped this could be an acceptable
> >> > fix(while it turned out not, obviously), though we admit it's not so good
> >> > to add such a magic number "10s" in a kernel driver.
> >> >
> >> > Please point it out if I missed or misunderstand something.
> >> >
> >> > Now I understand it's not good to pass the event to the udev daemon,
> >> > and it's not good to use a SLEEP(10s) in the kernel space(even if it's in a
> >> > "work" task here).
> >>
> >> Please just expose to userspace what is happening (link lost/gained,
> >> resumed from suspend/...), and let us sort out how to react to that.
> >> If you put assumptions about what kind of timeouts (long-dead)
> >> userspace uses into your drivers you'll just create a mess.
> > OK, I got it now.
> > So I think I'm supposed to send out a netif_carrier_off()/on() patch,
> > and I'd better do this after I verify the daemons can work with
> > proper parameters specified.
> >
> >> > Please let me know if it's the correct direction to fix the user-space
> >> > daemons (ifplugd, systemd-networkd, etc).
> >> > If you think this is viable and we should do this, I'll submit a
> >> > netif_carrier_off/on patch first and will start to work with the
> >> > projects of ifplugd, systemd-networkd and many OSVs to make the
> >> > while thing work eventually.
> >>
> >> Have you actually checked that carrier_off/on does not work on
> >> anything but ifplugd? It would surprise me...
> > I can confirm carrier_off/on with 0 delay between the off and on
> > doesn't work for ifplugd and networkd.
> >
> > Thanks,
> > -- Dexuan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
