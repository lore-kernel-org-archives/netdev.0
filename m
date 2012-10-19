From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if update failed
Date: Fri, 19 Oct 2012 11:30:09 +0200
Message-ID: <871uguvmfy.fsf@nemi.mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site> <87ehkvv3ej.fsf@nemi.mork.no>
	<CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
	<878vb3ufnx.fsf@nemi.mork.no>
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
Received: from canardo.mork.no ([148.122.252.1]:42089 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753908Ab2JSJbG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 05:31:06 -0400
In-Reply-To: <878vb3ufnx.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Fri, 19
	Oct 2012 08:41:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:
> Alexey Orishko <alexey.orishko@gmail.com> writes:
>
>> Vendor has to fix firmware.
>
> I agree in principle, and I'll report the problem to them.  But as us=
ual
> I believe we have to support any weird firmware we encounter, if at a=
ll
> possible.

OK, I did some more experiments, and I am wondering if the real firmwar=
e
problem is in the MBIM descriptor.  It is

      CDC MBIM:
        bcdMBIMVersion       1.00
        wMaxControlMessage   1536
        bNumberFilters       16
        bMaxFilterSize       40
        wMaxSegmentSize      4096
        bmNetworkCapabilities 0x20
          8-byte ntb input size


so we use the 8-byte version of USB_CDC_SET_NTB_INPUT_SIZE, which fails
with -EPIPE.  But forcing the 4-byte version seems to work. Hmm, I also
see that the device returns 4 bytes in response to at
USB_CDC_GET_NTB_INPUT_SIZE with an 8-byte buffer.  Maybe we can
auto-quirk based on that?  I.e., if USB_CDC_GET_NTB_INPUT_SIZE returns
only 4 bytes then we assume that the bmNetworkCapabilities flag is
wrong.

Is that acceptable?  Then it seems we are able to inform this device of
the reduced buffer, and the other problems can be ignored.


Bj=C3=B8rn
