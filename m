From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC PATCH 0/3] usbnet: support runtime PM triggered by link change
Date: Thu, 20 Sep 2012 10:30:54 +0200
Message-ID: <87r4pxumdd.fsf@nemi.mork.no>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
	<2236952.YSZj5xxzHO@linux-lqwf.site>
	<CACVXFVONb+pKkydhp3iesLt0tKvc+56uv6sd5S0UwUnGZiowYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fink Dmitry <finik@ti.com>, Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60048 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab2ITIb0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 04:31:26 -0400
In-Reply-To: <CACVXFVONb+pKkydhp3iesLt0tKvc+56uv6sd5S0UwUnGZiowYA@mail.gmail.com>
	(Ming Lei's message of "Mon, 17 Sep 2012 16:25:59 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:
> On Mon, Sep 17, 2012 at 4:04 PM, Oliver Neukum <oneukum@suse.de> wrot=
e:
>
>> 1) Does it actually save power? You are constantly waking up a CPU.
>
> Of course, it does. I don't know it will save how much power just on
> usbnet device, but it may save power from usb hub and usb host
> controller in the bus at least.
>
> Anyway we don't need to waste power if the link of usbnet is down.
>
> It just wake up CPU one time each 3sec. In modern linux distribution,
> the CPU will be wakup tens times per second, so it shouldn't be a
> big problem.

I do not buy that constantly polling a device necessarily saves any
power compared to keeping the USB link to the device alive.  You need t=
o
measure the savings if you want us to believe that.

You are not only waking the host CPU.  You are also waking the device
CPU.=20

Any usbnet device will consist of more than one building block, having
at least a network block, a USB block and a CPU.  For all you know, the
device CPU might be in deep sleep until it has to service either the
network or USB block, and those might also be sleeping until they see a=
n
interrupt.  Constantly polling the device to receive network link statu=
s
might use considerably more power than keeping the USB link up waiting
for a link notification.

If you were to implement this feature anyway, then I would prefer a
userspace based approach instead.  I see no reason to keep the timer in
the kernel.  You could decide to suspend whenever the netdev is down,
and only poll the link when userspace tries to bring up the netdev.
That would let a userspace daemon implement the same feature by trying
to bring up the netdev every 3 seconds (or whatever frequency the user
selected).  And it would allow me to avoid the polling until I know I
have plugged in a cable.

>> From that perspective it is possible that leaving on the ethernet is=
 actually
>> better in terms of power. Only measurements can answer that question=
=2E
>
> You know it is a bit difficult to test power save for this situation.=
 And
> most of runtime PM patches didn't provide power save data. In fact,
> I'd like to do it, but I have not some equipment to measure it, :-(.

We don't know, you don't know.  But you claim that your change saves
power, so please provide some documentation showing that it does.

>> 2) Do we have many devices that would be serviced with this approach=
?
>
> At least I found asix can be serviced by this approach. Considered as=
ix
> is quite popular, it is worthy of the effort. Also the below devices =
can be
> serviced by the patch in theory:
>
>                    dm9601.c / mcs7830.c / sierra_net.c

The sierra_net.c driver is only used for wireless devices AFAIK. I
really don't see the use case for network link based resume of that.
There is no cable to plug.  Userspace will have to initiate a
connection.

And the DirectIP device I've got (MC7710) supports remote wakeup.  I
assume that will be the case for all such devices, given that this is
mostly a firmware feature. So the correct fix for sierra_net.c is to ad=
d
support for remote wakeup.  Then you will be able to suspend the device
regardless of whether the link is up or down, without the constant
polling.


Bj=C3=B8rn
