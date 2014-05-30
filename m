From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net-next 3/8] net: cdc_ncm: inform usbnet when rx buffers are reduced
Date: Fri, 30 May 2014 13:39:42 +0200
Message-ID: <87d2eva41t.fsf@nemi.mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
	<1401435070-26721-4-git-send-email-bjorn@mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D1725057A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54656 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbaE3LkC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 07:40:02 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725057A@AcuExch.aculab.com>
	(David Laight's message of "Fri, 30 May 2014 09:18:37 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:
> From: Bj=C3=B8rn Mork=20
>> It doesn't matter whether the buffer size goes up or down.  We have =
to
>> keep usbnet and device syncronized to be able to split transfers at =
the
>> correct boundaries. The spec allow skipping short packets when using
>> max sized transfers.  If we don't tell usbnet about our new expected=
 rx
>> buffer size, then it will merge and/or split NTBs.  The driver does =
not
>> support this, and the result will be lots of framing errors.
>>=20
>> Fix by always reallocating usbnet rx buffers when the rx_max value
>> changes.
>
> I'm guessing that the rx_max value is the maximum size of the USB bul=
k
> data 'message' that the device generates?
>
> As such the URB only need to be longer that it.

So did I think too at first.  That's how I added the bug fixed by this
commit :-)

The problem with NCM is that it explicitly allows (and encourage) using
transfers which are multiples of the USB packet size, *without* any
terminating short packet (0 or 1 byte). This means that the USB core
won't know or care about the end of one transfer and the beginning of
the next.  Which is fine.  But the cdc_ncm driver has to know, because
it must split the transfers into frames it can decode.

Now, the current cdc_ncm implementation has a built-in assumption that
the size of the URB =3D=3D rx_max.  This lets it simplify the splitting=
 into
frames to nearly nothing: Any received URB contains exactly one frame.
Therefore we need to keep the rx URB size strictly syncronized the
rx_max.

> (Or multiples of the USB packet size, and the driver then merge URB
> when generating skbs.)
>
> Since you are now copying the data out of the URB's skb before
> passing the ethernet packet upstream, is there ever any real
> requirement to use a small rx_max? or ever change rx_max?

Yes.  usbnet doesn't currently recycle skbs.  Continuously allocating 3=
2
kB skbs (or even 64 kB truesize, which is the current cdc_ncm worst
case) on memory constrained hosts is bound to fail eventually.  Reducin=
g
rx_max will reduce the order of the allocations and thereby the
probability of failing.

I've had reports from OpenWRT users with Huawei modems (which tend to
use extreme buffers), constantly hitting the usbnet allocation failure
event 'EVENT_RX_MEMORY'.  The result is of course terrible performance,
where usbnet gets really busy trying to allocate buffers which just
cannot be allocated...  Reducing rx_max by simply rebuilding the old
driver with a lower hard limit has pretty much eliminated these issues,
but is not generally a solution because it makes some modem firmwares
fail.

True, copying instead of cloning is probably going to help this problem
too, but I believe there are still reasons why you do not want to allow
the 64 kB skb abuse.



Bj=C3=B8rn
