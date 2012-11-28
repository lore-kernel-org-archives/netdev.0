From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 12:42:19 +0100
Message-ID: <87k3t62btw.fsf@nemi.mork.no>
References: <87y5hm9ap5.fsf@nemi.mork.no>
	<Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
	<CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
	<874nka3wgx.fsf@nemi.mork.no>
	<CAKh2mn5UGRN5U0w_bj25e4VnCwr9kK3f798nHSwmF4WE4dORMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35258 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236Ab2K1Lmj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 06:42:39 -0500
In-Reply-To: <CAKh2mn5UGRN5U0w_bj25e4VnCwr9kK3f798nHSwmF4WE4dORMw@mail.gmail.com>
	(Steve Glendinning's message of "Wed, 28 Nov 2012 10:16:27 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve@shawell.net> writes:

> Hi Bjorn,
>
> On 28 November 2012 09:31, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>>
>> Remote wakeup will not be enabled on system suspend unless the user =
(or
>> a userspace program on the users behalf) has requested it.
>
> If a user types "ethtool -s eth2 wol p" they *are* explicitly
> requesting the ethernet device to bring the system out of suspend, so
> I think the ethernet driver should set the feature automatically.
>
> from drivers/base/power/wakeup.c:
>
>  * By default, most devices should leave wakeup disabled.  The except=
ions are
>  * devices that everyone expects to be wakeup sources: keyboards, pow=
er buttons,
>  * possibly network interfaces, etc.

Right.  That seems logical.  But the ethtool setting should still
probably be reflected in the device attributes so that the user can see
them there?

Just doing a simple test of what other ethernet drivers does, I tried
this on the e1000e adapter in my laptop.  Initially:

nemi:/tmp# grep .  /sys/bus/pci/devices/0000:00:19.0/power/*
/sys/bus/pci/devices/0000:00:19.0/power/async:enabled
grep: /sys/bus/pci/devices/0000:00:19.0/power/autosuspend_delay_ms: Inp=
ut/output error
/sys/bus/pci/devices/0000:00:19.0/power/control:auto
/sys/bus/pci/devices/0000:00:19.0/power/runtime_active_kids:0
/sys/bus/pci/devices/0000:00:19.0/power/runtime_active_time:266378772
/sys/bus/pci/devices/0000:00:19.0/power/runtime_enabled:enabled
/sys/bus/pci/devices/0000:00:19.0/power/runtime_status:active
/sys/bus/pci/devices/0000:00:19.0/power/runtime_suspended_time:56833381=
6
/sys/bus/pci/devices/0000:00:19.0/power/runtime_usage:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup:disabled
nemi:/tmp# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: off
        Supports Wake-on: pumbg
        Wake-on: d
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes


Enabling WOL:

nemi:/tmp# ethtool -s eth0 wol p
nemi:/tmp# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: off
        Supports Wake-on: pumbg
        Wake-on: p
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes
nemi:/tmp# grep .  /sys/bus/pci/devices/0000:00:19.0/power/*
/sys/bus/pci/devices/0000:00:19.0/power/async:enabled
grep: /sys/bus/pci/devices/0000:00:19.0/power/autosuspend_delay_ms: Inp=
ut/output error
/sys/bus/pci/devices/0000:00:19.0/power/control:auto
/sys/bus/pci/devices/0000:00:19.0/power/runtime_active_kids:0
/sys/bus/pci/devices/0000:00:19.0/power/runtime_active_time:266414488
/sys/bus/pci/devices/0000:00:19.0/power/runtime_enabled:enabled
/sys/bus/pci/devices/0000:00:19.0/power/runtime_status:active
/sys/bus/pci/devices/0000:00:19.0/power/runtime_suspended_time:56833381=
6
/sys/bus/pci/devices/0000:00:19.0/power/runtime_usage:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup:enabled
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_abort_count:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_active:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_active_count:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_count:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_expire_count:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_last_time_ms:834745779
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_max_time_ms:0
/sys/bus/pci/devices/0000:00:19.0/power/wakeup_total_time_ms:0


So this driver does set wakeup:enabled, and if this had been a USB
device then the USB core would have set the Remote Wakeup feature on
suspend without the driver having to do anything special in its
driver->suspend function.

Looking at the different ethernet drivers, the normal way do do this
seems to be something like this in their .set_wol implementation:

        device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);


where "adapter" is a netdev_priv private struct, "pdev" is a pci device
and "wol" is an u32.  I don't see any problem doing the same for USB
network devices implementing ethtool "set_wol".

Note that according to Documentation/power/devices.txt:

"Device drivers, however, are not supposed to call device_set_wakeup_en=
able()
 directly in any case."

which I guess really means that wakeup:enabled is supposed to be user
controlled and not driver controlled.  I assume the ethtool userspace
interface make the above void, as drivers implementing the ethtool
interface will have to call device_set_wakeup_enable() to syncronize
ethtool and sysfs settings.

Does this make sense?


Bj=C3=B8rn
