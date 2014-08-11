From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 11 Aug 2014 12:45:50 +0200
Message-ID: <CAG-2HqVE8Qk0pcW+36f44RkE-Kbp+qPqRT+vgg-v35W52bsKgg@mail.gmail.com>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de>
 <20140721.143225.2040366896972949930.davem@davemloft.net>
 <CAFLxGvyfy1UkxN6_-c_ST7f8n7DvqYsCPKChWmt9CerWb0dh7g@mail.gmail.com>
 <EE124450C0AAF944A40DD71E61F878C99149D0@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808033220.GB10503@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991569A@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808134549.GD4427@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991B653@SINEX14MBXC417.southpacific.corp.microsoft.com>
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
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <EE124450C0AAF944A40DD71E61F878C991B653@SINEX14MBXC417.southpacific.corp.microsoft.com>
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

On Mon, Aug 11, 2014 at 5:23 AM, Dexuan Cui <decui@microsoft.com> wrote:
>> -----Original Message-----
>> From: Greg KH [mailto:gregkh@linuxfoundation.org]
>> > > >
>> > > > IMO the most feasible and need-the-least-change solution may be:
>> > > > the hyperv network VSC driver passes the event
>> > > > RNDIS_STATUS_NETWORK_CHANGE to the udev daemon?
>> > > >
>> > > No, don't do that, again, act like any other network device, drop the
>> > > link and bring it up when it comes back.
>> > >
>> > Hi Greg,
>> > Do you mean tearing down the net device and re-creating it (by
>> > register_netdev() and unregister_netdev)?
>>
>> No, don't you have link-detect for your network device?  Toggle that, I
>> thought patches to do this were posted a while ago...
>>
>> But if you really want to tear the whole network device down and then
>> back up again, sure, that would also work.
> Hi Greg, Stephen,
>
> Thanks for the comments!
>
> I suppose you meant the below logic:
> if (refresh) {
>         rtnl_lock();
>         netif_carrier_off(net);
>         netif_carrier_on(net);
>         rtnl_unlock();
> }
>
> We have discussed this in the previous mails of this thread itself:
> e.g., http://marc.info/?l=linux-driver-devel&m=140593811715975&w=2
>
> Unluckily this logic doesn't work because the user-space daemons
> like ifplugd, usually don't renew the DHCP immediately as long as they
> receive a link-down message: they usually wait for some seconds and if
> they find the link becomes up soon, they won't trigger renew operations.
> (I guess this behavior can be somewhat reasonable: maybe the daemons
> try to not trigger DHCP renew on temporary link instability)
>
> If we use this logic in the kernel space, we'll have to "fix" the user-space
> daemons, like ifplugd, systemd-networkd...,etc.

networkd does not suffer from this problem, and in ifplugd it can be
disabled. Most other network drivers will send
IFF_LOWER_DOWN/IFF_LOWER_UP upon suspend/resume so if you were to do
the same you will not work any worse than the others. What would be
nice, as mentioned by Dan and Lennart, would be to send an additional
explicit event such as "resumed from suspend" or "L3 may be wrong".
That should be a generic thing though, to fix all such issues in one
go.

> I'm not sure our attempt to "fix" the daemons can be easily accepted.
> BTW, by CPUID, an application has a reliable way to determine  if it's
> running on hyper-v on not. Maybe we can "fix" the behavior of the
> daemons when they run on hyper-v?
> BTW2, according to my limited experience, I doubt other VMMs can
> handle this auto-DHCP-renew-in-guest issue properly.

To the extent this is a problem, it is a generic one, so we should not
need any hyper-v specific logic in userspace.

> That was why Yue's patch wanted to add a SLEEP(10s) between the
> link-down and link-up events and hoped this could be an acceptable
> fix(while it turned out not, obviously), though we admit it's not so good
> to add such a magic number "10s" in a kernel driver.
>
> Please point it out if I missed or misunderstand something.
>
> Now I understand it's not good to pass the event to the udev daemon,
> and it's not good to use a SLEEP(10s) in the kernel space(even if it's in a
> "work" task here).

Please just expose to userspace what is happening (link lost/gained,
resumed from suspend/...), and let us sort out how to react to that.
If you put assumptions about what kind of timeouts (long-dead)
userspace uses into your drivers you'll just create a mess.

> Please let me know if it's the correct direction to fix the user-space
> daemons (ifplugd, systemd-networkd, etc).
> If you think this is viable and we should do this, I'll submit a
> netif_carrier_off/on patch first and will start to work with the
> projects of ifplugd, systemd-networkd and many OSVs to make the
> while thing work eventually.

Have you actually checked that carrier_off/on does not work on
anything but ifplugd? It would surprise me...

Cheers,

Tom
