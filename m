From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: dereference after null check in usbnet_start_xmit() and __usbnet_read_cmd()
Date: Wed, 19 Aug 2015 14:03:19 +0200
Message-ID: <87bne3eb94.fsf@nemi.mork.no>
References: <907196681.281711439983295252.JavaMail.weblogic@ep2mlwas02b>
	<87fv3febt3.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nitin.j@samsung.com, hemanshu.s@samsung.com
To: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45351 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753318AbbHSMDd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 08:03:33 -0400
In-Reply-To: <87fv3febt3.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Wed, 19
	Aug 2015 13:51:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:
> Vivek Kumar Bhagat <vivek.bhagat@samsung.com> writes:
>
>> @@ -1906,7 +1908,8 @@ static int __usbnet_read_cmd(struct usbnet *de=
v, u8 cmd, u8 reqtype,
>>  		buf =3D kmalloc(size, GFP_KERNEL);
>>  		if (!buf)
>>  			goto out;
>> -	}
>> +	} else
>> +		goto out;
>> =20
>>  	err =3D usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
>>  			      cmd, reqtype, value, index, buf, size,
>
>
> This is also wrong.  It makes __usbnet_read_cmd() return -ENOMEM if
> called with a NULL data pointer.  I don't know if it is used, but it'=
s
> perfectly valid to call __usbnet_read_cmd() with data =3D=3D NULL if
> size =3D=3D 0. No memcpy will happen in this case because usb_control=
_msg
> can only return 0 or an error

Just for the record - a simple grep for usbnet_read_cmd shows that at
least drivers/net/usb/plusb.c depends on the current behaviour:

static inline int
pl_vendor_req(struct usbnet *dev, u8 req, u8 val, u8 index)
{
        return usbnet_read_cmd(dev, req,
                                USB_DIR_IN | USB_TYPE_VENDOR |
                                USB_RECIP_DEVICE,
                                val, index, NULL, 0);
}



Bj=C3=B8rn
