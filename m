From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if update failed
Date: Fri, 19 Oct 2012 08:41:54 +0200
Message-ID: <878vb3ufnx.fsf@nemi.mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site> <87ehkvv3ej.fsf@nemi.mork.no>
	<CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi \(Franko\)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40087 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab2JSGmN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 02:42:13 -0400
In-Reply-To: <CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
	(Alexey Orishko's message of "Fri, 19 Oct 2012 01:30:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Orishko <alexey.orishko@gmail.com> writes:
> On Fri, Oct 19, 2012 at 12:09 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wro=
te:
>> Oliver Neukum <oliver@neukum.org> writes:
>>> On Thursday 18 October 2012 22:40:55 Bj=C3=B8rn Mork wrote:
>>>> If the device refuses our updated value, then we must be prepared
>>>> to receive URBs as big as the device wants to send.  Set rx_max
>>>> to the device provided value on error.
>>>
>>> Problematic in principle. How do you allocate a buffer of arbitrary=
 size?
>>
>> You cannot of course.  You can only try and give up if it doesn't wo=
rk.
>> rx_submit would end up returning -ENOMEM, but we are not always chec=
king
>> that so it will most likely fail silently.
>>
>> But I don't think we can just continue with the smaller buffer size
>> without having the device agree to that either.  That is also likely=
 to
>> fail silently.  Note that this patch was added exactly because one o=
f
>> the MBIM test devices did refuse the lower rx_max we tried to enforc=
e.
>> The device insists on using 128kB buffers.
>>
>> Maybe we should cap it at some arbitrary reasonable value, and just =
bail
>> out from bind if the device insists on a larger buffer?  Would that =
be
>> OK?  How big buffers are (semi-)reasonable?
>>
>
> I recommend to drop this.

OK, will drop patch 01 (only necessary if some usbnet minidriver uses
buffers > 60 * 1518) and 02 from the next version of this series.

> Vendor has to fix firmware.

I agree in principle, and I'll report the problem to them.  But as usua=
l
I believe we have to support any weird firmware we encounter, if at all
possible.

> Current version of the driver supports 16-bit NTB, which means you ca=
n address
> (64K only - NTB header). So, how do you plan to use 64K-128K buffer s=
pace,
> if it can't be addressed by 16 bit offset?

This is of course true.  The device does obey the 16bit header choice,
so I would hope that it does not send us buffers it can't use.  But it
does send buffers in the range 32K-64K, which makes the current driver
fail in a rather ugly way.

I assume the current CDC_NCM_NTB_MAX_SIZE_RX is set to 32K as a sane
default, but how about allowing up to 64K for devices which does not
accept this?  The other options are
 - silently failing, or
 - refusing to load with an error the user cannot do anything with,
and I don't think either of those are wanted, even if the NCM spec is
quite clear that the device is wrong here.

> Another angle to big buffers, even while using 64K buffers your TCP c=
onnection
> will suffer, so what's the point making huge buffers?

Agreed.  There is no point.  It's bloat.  Which makes you kind of wonde=
r
why they bothered to define a separate 32bit header format at all,
complicating the protocol quite a lot...  Or why those writing the MBIM
spec didn't take their opportunity to remove this useless complication?
I am not holding it against you though ;-)

A nice side effect of the refactoring done to support MBIM is that most
of the 16bit header parsing has been isolated in separate functions,
making it trivial to implement the missing 32bit header support.  Maybe
we should do that?



Bj=C3=B8rn
