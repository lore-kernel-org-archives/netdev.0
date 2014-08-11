From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Sun, 10 Aug 2014 20:51:48 -0700
Message-ID: <53E83DD4.1060500@gmail.com>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com> <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de> <20140721.143225.2040366896972949930.davem@davemloft.net> <CAFLxGvyfy1UkxN6_-c_ST7f8n7DvqYsCPKChWmt9CerWb0dh7g@mail.gmail.com> <EE124450C0AAF944A40DD71E61F878C99149D0@SINEX14MBXC417.southpacific.corp.microsoft.com> <20140808033220.GB10503@kroah.com> <EE124450C0AAF944A40DD71E61F878C991569A@SINEX14MBXC417.southpacific.corp.microsoft.com> <20140808134549.GD4427@kroah.com> <EE124450C0AAF944A40DD71E61F878C991B653@SINEX14MBXC417.southpacific.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Shao <huishao@microsoft.com>,
	"Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Dexuan Cui <decui@microsoft.com>,
	Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:39976 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbaHKDvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 23:51:52 -0400
In-Reply-To: <EE124450C0AAF944A40DD71E61F878C991B653@SINEX14MBXC417.southpacific.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/08/2014 20:23, Dexuan Cui a =E9crit :
>> -----Original Message-----
>> From: Greg KH [mailto:gregkh@linuxfoundation.org]
>>>>>
>>>>> IMO the most feasible and need-the-least-change solution may be:
>>>>> the hyperv network VSC driver passes the event
>>>>> RNDIS_STATUS_NETWORK_CHANGE to the udev daemon?
>>>>>
>>>> No, don't do that, again, act like any other network device, drop =
the
>>>> link and bring it up when it comes back.
>>>>
>>> Hi Greg,
>>> Do you mean tearing down the net device and re-creating it (by
>>> register_netdev() and unregister_netdev)?
>>
>> No, don't you have link-detect for your network device?  Toggle that=
, I
>> thought patches to do this were posted a while ago...
>>
>> But if you really want to tear the whole network device down and the=
n
>> back up again, sure, that would also work.
> Hi Greg, Stephen,
>
> Thanks for the comments!
>
> I suppose you meant the below logic:
> if (refresh) {
>          rtnl_lock();
>          netif_carrier_off(net);
>          netif_carrier_on(net);
>          rtnl_unlock();
> }
>
> We have discussed this in the previous mails of this thread itself:
> e.g., http://marc.info/?l=3Dlinux-driver-devel&m=3D140593811715975&w=3D=
2
>
> Unluckily this logic doesn't work because the user-space daemons
> like ifplugd, usually don't renew the DHCP immediately as long as the=
y
> receive a link-down message: they usually wait for some seconds and i=
f
> they find the link becomes up soon, they won't trigger renew operatio=
ns.
> (I guess this behavior can be somewhat reasonable: maybe the daemons
> try to not trigger DHCP renew on temporary link instability)

Is that such a big deal? If you know you spend much of your time in=20
ifplugd, why not use something different that triggers a DHCP renewal=20
faster, or fix ifplugd?

>
> If we use this logic in the kernel space, we'll have to "fix" the use=
r-space
> daemons, like ifplugd, systemd-networkd...,etc.

You mean the opposite here don't you? If you put that logic in kernel=20
space you don't have to fix the userland.

>
> I'm not sure our attempt to "fix" the daemons can be easily accepted.
> BTW, by CPUID, an application has a reliable way to determine  if it'=
s
> running on hyper-v on not. Maybe we can "fix" the behavior of the
> daemons when they run on hyper-v?

That is not acceptable as well, why would an user-space application=20
would have to care that much whether it runs on hyper-v or a physical=20
host? Not to mention that anytime someone develops a similar but new=20
application they would have to become aware of such platform and its=20
"specicities".

> BTW2, according to my limited experience, I doubt other VMMs can
> handle this auto-DHCP-renew-in-guest issue properly.
>
> That was why Yue's patch wanted to add a SLEEP(10s) between the
> link-down and link-up events and hoped this could be an acceptable
> fix(while it turned out not, obviously), though we admit it's not so =
good
> to add such a magic number "10s" in a kernel driver.
>
> Please point it out if I missed or misunderstand something.

I think this is just an integration issue that you are having, and I=20
would not be focusing on any particular user-space implementation, but=20
rather put something in the driver that is sensible, just like what was=
=20
suggested before: toggling the carrier state.

>
> Now I understand it's not good to pass the event to the udev daemon,
> and it's not good to use a SLEEP(10s) in the kernel space(even if it'=
s in a
> "work" task here).
>
> Please let me know if it's the correct direction to fix the user-spac=
e
> daemons (ifplugd, systemd-networkd, etc).
> If you think this is viable and we should do this, I'll submit a
> netif_carrier_off/on patch first and will start to work with the
> projects of ifplugd, systemd-networkd and many OSVs to make the
> while thing work eventually.
>
> Thanks,
> -- Dexuan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--=20
=46lorian
