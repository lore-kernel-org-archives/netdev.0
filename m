From: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Sun, 15 Jan 2012 16:33:18 +0100
Message-ID: <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
 <1326621743.3448.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1326621743.3448.1.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 15, 2012 at 11:02, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
>> These drivers need to be fixed to load their firmware during ifup,
>> which would be the most flexible solution. That way, it should also
>> work if the driver is built-in, or is loaded from initramfs and no
>> firmware is available.
>> Alternatively, the firmware request should be able to use the aync
>> firmware_request API and not the blocking one.
>
> Will udev now also return the async load only after root is booted if it
> can't be satisfied earlier?

Not sure, let me explain what happens here, maybe it contains the answer:

Udev gets an event for a pci device:
  /devices/pci0000:00/0000:00:1c.1/0000:03:00.0

This device has a modalias, which let's udev load the matching module
into the kernel. The module_init() syscall triggers the firmware
loading request, which causes another event:
  /devices/pci0000:00/0000:00:1c.1/0000:03:00.0/firmware/0000:03:00.0

This event is a direct child of the pci device and udev delays the
execution of child devices until the parent devices return from
handling. This dependency logic is needed for many things to ensure a
proper operation, like partitions which need to make sure the events
for the disk devices are handled before the partition events are
started.

Now the problem, the pcidev event is blocking in modprobe and waits
for the child event it has generated to finish, but udev does not
start the event because the parent still blocks in modprobe ->
deadlock until default firmware timeout of 60 sec. What we want here,
for several reasons not only udev's dependency logic, is that modprobe
never waits for userspace transactions to finish.

> There are a number of devices, particularly
> wireless, that need firmware before they can register with mac80211 for
> capability advertisement reasons.

Right, ideally all firmware loading would be delayed until the netif
is brought up, and that's what we shoudl use if possible. In all other
cases, I think what iwlwifi is doing here looks fine from the
userspace side. It does not register any netdev/mac80211 device, the
firmware request is the only thing that it issued, and modprobe
returns immediately, regardless of the firmware request handling.

If userspace is not responding, the firmware request times out after
60 seconds and the driver is not associated with any hardware. To
retry the firmware loading, the module needs to be unloaded and
reloaded, or the driver needs to be asked to bind to a device again by
writing to the 'bind' in file in the sysfs driver directory.

Firmware requests stay around in the system for by default 60 seconds.
If the driver would be built-in the request would be issued long
before userspace is ready, but udev's coldplug step during bootup will
cause all events to be replayed, so it would catch also the
outstanding firmware requests, and would be able to handle them.

Kay
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
