From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [RFC PATCH 0/3] usbnet: support runtime PM triggered by link change
Date: Tue, 25 Sep 2012 01:10:31 +0800
Message-ID: <CACVXFVOYt5MBvrBN3mvUnnvK0kEwKxhk3ypRLRtCBPEEbfsu-w@mail.gmail.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
	<2236952.YSZj5xxzHO@linux-lqwf.site>
	<CACVXFVONb+pKkydhp3iesLt0tKvc+56uv6sd5S0UwUnGZiowYA@mail.gmail.com>
	<87r4pxumdd.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fink Dmitry <finik@ti.com>, Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35617 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755934Ab2IXRKd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 13:10:33 -0400
In-Reply-To: <87r4pxumdd.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 20, 2012 at 4:30 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>> On Mon, Sep 17, 2012 at 4:04 PM, Oliver Neukum <oneukum@suse.de> wro=
te:
>>
>>> 1) Does it actually save power? You are constantly waking up a CPU.
>>
>> Of course, it does. I don't know it will save how much power just on
>> usbnet device, but it may save power from usb hub and usb host
>> controller in the bus at least.
>>
>> Anyway we don't need to waste power if the link of usbnet is down.
>>
>> It just wake up CPU one time each 3sec. In modern linux distribution=
,
>> the CPU will be wakup tens times per second, so it shouldn't be a
>> big problem.
>
> I do not buy that constantly polling a device necessarily saves any
> power compared to keeping the USB link to the device alive.  You need=
 to
> measure the savings if you want us to believe that.

Yes, good suggestion.

>
> You are not only waking the host CPU.  You are also waking the device
> CPU.

Some usbnet devices doesn't have CPU, and I don't think there are
one in smsc95xx or asix, :-)

>
> Any usbnet device will consist of more than one building block, havin=
g
> at least a network block, a USB block and a CPU.  For all you know, t=
he
> device CPU might be in deep sleep until it has to service either the
> network or USB block, and those might also be sleeping until they see=
 an
> interrupt.  Constantly polling the device to receive network link sta=
tus
> might use considerably more power than keeping the USB link up waitin=
g
> for a link notification.
>
> If you were to implement this feature anyway, then I would prefer a
> userspace based approach instead.  I see no reason to keep the timer =
in
> the kernel.  You could decide to suspend whenever the netdev is down,
> and only poll the link when userspace tries to bring up the netdev.

I am wondering if userspace knows when it should bring up the interface=
,
maybe it depends on the link becomes up, maybe udev always bring it up.

> That would let a userspace daemon implement the same feature by tryin=
g
> to bring up the netdev every 3 seconds (or whatever frequency the use=
r
> selected).  And it would allow me to avoid the polling until I know I
> have plugged in a cable.

I don't see any advantage by using a userspace timer, and it will conve=
rt to
a kernel timer finally.

Also putting the interface down may introduce some side effect on user
space: the IP address may be lost, etc.

>
>>> From that perspective it is possible that leaving on the ethernet i=
s actually
>>> better in terms of power. Only measurements can answer that questio=
n.
>>
>> You know it is a bit difficult to test power save for this situation=
=2E And
>> most of runtime PM patches didn't provide power save data. In fact,
>> I'd like to do it, but I have not some equipment to measure it, :-(.
>
> We don't know, you don't know.  But you claim that your change saves
> power, so please provide some documentation showing that it does.

The motivation of the patch is that suspending the usbnet device may pu=
t
all usb devices in the bus into suspend.

I am trying to get some data by powertop, but looks it is not reliable =
enough.

I even found that the discharge rate of battery when the asix is discon=
nected
and let the whole bus suspend is even more than when the asix is connec=
ted
with ethernet cable link down and all devices in the whole usb bus are =
active.
There is about 1w difference, so odd.

I will try to get some correct power data.

>
>>> 2) Do we have many devices that would be serviced with this approac=
h?
>>
>> At least I found asix can be serviced by this approach. Considered a=
six
>> is quite popular, it is worthy of the effort. Also the below devices=
 can be
>> serviced by the patch in theory:
>>
>>                    dm9601.c / mcs7830.c / sierra_net.c
>
> The sierra_net.c driver is only used for wireless devices AFAIK. I
> really don't see the use case for network link based resume of that.
> There is no cable to plug.  Userspace will have to initiate a
> connection.

Wireless link is still one kind of link, :-)

Otherwise, why sierra_net.c bother to use netif_carrier_on?

>
> And the DirectIP device I've got (MC7710) supports remote wakeup.  I
> assume that will be the case for all such devices, given that this is
> mostly a firmware feature. So the correct fix for sierra_net.c is to =
add
> support for remote wakeup.  Then you will be able to suspend the devi=
ce
> regardless of whether the link is up or down, without the constant
> polling.

In fact, the patch supports link change via remote wakeup, and it may b=
e
useful if remote wakeup is not supported by incoming packet.

Not mention the power save data, the patch is not mature enough, for ex=
ample,
ethtool_ops interface may access a suspended device.

I will update it if some progresses are got.

Thanks,
--
Ming Lei
