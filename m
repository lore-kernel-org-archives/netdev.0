From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 09:41:23 -0700
Message-ID: <CAE4R7bCxb8Ni4b5=o80FG+iGEA_dtpefWm9o5eqqKLboC35stg@mail.gmail.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
 <20150827074525.GA8094@lunn.ch> <CAE4R7bD0Ka0187Qq=+6cZL7UqgnxJASKL_6AmaC2z_jiF5Jp1w@mail.gmail.com>
 <20150827090603.GC8094@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?Smk/P8OtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36620 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbbH0Qln convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 12:41:43 -0400
Received: by obkg7 with SMTP id g7so20978122obk.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 09:41:42 -0700 (PDT)
In-Reply-To: <20150827090603.GC8094@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 2:06 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Thu, Aug 27, 2015 at 01:42:24AM -0700, Scott Feldman wrote:
>> On Thu, Aug 27, 2015 at 12:45 AM, Andrew Lunn <andrew@lunn.ch> wrote=
:
>> >> I don't know about how this overlaps with DSA platform_class.  Fl=
orian?
>> >
>> > There is some overlap with DSA, but the current DSA model, with
>> > respect to probing, is broken. So this might be interesting as a w=
ay
>> > towards fix that.
>> >
>> > One thing to keep in mind is the D in DSA. You talk about switch,
>> > singular. DSA has a number of switches in a cluster. We currently
>> > export a single switchdev interface for the cluster, but there are
>> > some properties which are per switch, e.g. temperature, eeprom
>> > contents, statistics, power management etc.
>>
>> Export a single 'switchdev' or 'netdev' for the cluster?  I hope tha=
t
>> was a typo.
>
> I probably expressed that badly. The hardware i have on my desk has
> three Marvell switches in a chain, with one end of the chain connecte=
d
> to a host Ethernet interface.
>
> From the switchdev ops level, you don't see anything of this
> chain. But some of the operations do need to be aware of this chain,
> for example vlans which span multiple chips in this chain.
>
>> With switchdev device class, you'd instantiate one per
>> phy switch, and have per-switch props (temp, eeprom, etc) thru each
>> switchdev instance.
>
> O.K. This is fine, but we need people to understand that a switchdev
> device class represents some middle layer in the hierarchy, not the
> top layer. Otherwise false assumptions might be made.

So with kobj, a device can have a parent.  So I experimented with my
RFC patch and changed register_switchdev to take a parent switchdev
arg, which is NULL for leaf switchdevs:

int register_switchdev(struct switchdev *sdev, const char *name,
                       struct switchdev *parent)
{
        struct device *dev =3D &sdev->dev;
        int err;

        device_initialize(dev);

        dev->class =3D &switchdev_class;
        if (parent)
                dev->parent =3D &parent->dev;

        err =3D dev_set_name(dev, "%s", name);
        if (err)
                return err;

        return device_add(dev);
}

Then I tried this with rocker and it works as expected.  On module
load, I create the master switchdev, and then on PCI probe for each
phys switch dev, I put the slave switchdev in the master using
register_switchdev.  Here's one slave in the master "rockers" switch:

tree /sys/class/switchdev/rockers
/sys/class/switchdev/rockers
=E2=94=9C=E2=94=80=E2=94=80 5254001235010000
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 device -> ../../rocker
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 foo
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 power
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 async
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 autosuspend_delay_m=
s
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 control
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_active_kids
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_active_time
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_enabled
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_status
=E2=94=82   =E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_suspended_t=
ime
=E2=94=82   =E2=94=82   =E2=94=94=E2=94=80=E2=94=80 runtime_usage
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 subsystem -> ../../../../../cla=
ss/switchdev
=E2=94=82   =E2=94=94=E2=94=80=E2=94=80 uevent
=E2=94=9C=E2=94=80=E2=94=80 foo
=E2=94=9C=E2=94=80=E2=94=80 power
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 async
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 autosuspend_delay_ms
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 control
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_active_kids
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_active_time
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_enabled
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_status
=E2=94=82   =E2=94=9C=E2=94=80=E2=94=80 runtime_suspended_time
=E2=94=82   =E2=94=94=E2=94=80=E2=94=80 runtime_usage
=E2=94=9C=E2=94=80=E2=94=80 subsystem -> ../../../../class/switchdev
=E2=94=94=E2=94=80=E2=94=80 uevent

With this, we can stack switchdevs, I guess as high as we want.  Does
this look usable for DSA?   An attr set on the master would get pushed
down to the leaves.  We'd can do it with the same style of recursive
algos we use for switchdev port attrs.
