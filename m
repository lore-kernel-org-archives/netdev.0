From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
Date: Mon, 17 Mar 2014 13:56:16 +0100
Message-ID: <877g7tm1an.fsf@nemi.mork.no>
References: <1394746907.15946.8.camel@dcbw.local>
	<20140313220812.GW3200@reaktio.net>
	<20140314075548.GX3200@reaktio.net> <87wqfxnppc.fsf@nemi.mork.no>
	<20140314084159.GA3200@reaktio.net> <87siqlnol8.fsf@nemi.mork.no>
	<20140314090525.GB3200@reaktio.net> <87ob19nndo.fsf@nemi.mork.no>
	<20140314125934.GC3200@reaktio.net> <87vbvgnbv3.fsf@nemi.mork.no>
	<20140314142559.GD3200@reaktio.net> <87k3btm57a.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k3btm57a.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Mon, 17
	Mar 2014 12:31:53 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:

> But here we have a device which does not comform to spec (that's OK,
> Huawei doesn't claim it does - this is a vendor specific function aft=
er
> all), and which seems to be locked to 32 bit mode?  Either it require=
s
> the 32 bit variant, or we are doing something "wrong" during setup to
> make the device go into this mode.

Yuck.  Looking at the code, we do definitely do something wrong here.
We do this during setup:

        /* set NTB format, if both formats are supported */
        if (ntb_fmt_supported & USB_CDC_NCM_NTH32_SIGN) {
                err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_FORMAT,
                                       USB_TYPE_CLASS | USB_DIR_OUT
                                       | USB_RECIP_INTERFACE,
                                       USB_CDC_NCM_NTB16_FORMAT,
                                       iface_no, NULL, 0);
                if (err < 0)
                        dev_dbg(&dev->intf->dev, "Setting NTB format to=
 16-bit failed\n");
        }


But USB_CDC_NCM_NTH32_SIGN isn't a flag mask.  It is a constant matchin=
g
the the header signature.  I.e. the 'ncmh' string, or 0x686D636E as the
little endian 32 bit number the macro expands to. The ntb_fmt_supported
variable is the bmNtbFormatsSupported bitmap in CPU endianness.  Bit 0
indicates 16 bit support, bit 1 indicates 32 bit support and the rest i=
s
reserved (zero/ignored).  So the test does actually work because it wil=
l
return true of bit 1 is set, but it is fundamentally wrong because it
also inspects a number of bits which the host is required to ignore.

And looking at your dump, I see that the GET_NTB_PARAMETERS response is=
:

=46rame 151: 92 bytes on wire (736 bits), 92 bytes captured (736 bits) =
on interface 0
[..]
0040  1c 00 03 00 00 00 04 00 04 00 02 00 04 00 00 00   ...............=
=2E
0050  00 80 00 00 04 00 02 00 04 00 00 00               ............

This is the structure:

struct usb_cdc_ncm_ntb_parameters {
        __le16  wLength;
        __le16  bmNtbFormatsSupported;
        __le32  dwNtbInMaxSize;
        __le16  wNdpInDivisor;
        __le16  wNdpInPayloadRemainder;
        __le16  wNdpInAlignment;
        __le16  wPadding1;
        __le32  dwNtbOutMaxSize;
        __le16  wNdpOutDivisor;
        __le16  wNdpOutPayloadRemainder;
        __le16  wNdpOutAlignment;
        __le16  wNtbOutMaxDatagrams;
} __attribute__ ((packed));


So bmNtbFormatsSupported is 0x00000003 as expected and we should execut=
e
the SET_NTB_FORMAT above.  And we do.  I can see these NCM control
requests:

frame 150: in GET_NTB_PARAMETERS
frame 152: out SET_NTB_INPUT_SIZE
frame 154: out SET_CRC_MODE
frame 156: out SET_NTB_FORMAT
frame 158: in GET_MAX_DATAGRAM_SIZE

But looking closer, I see that the SET_NTB_FORMAT returned -EPIPE,
i.e. stall.  The driver currently ignores this error, which is why we
end up with different device and host settings.=20

Anyone know what the proper driver action is? Note that this error
cannot happen with a spec conforming device, because SET_NTB_FORMAT
support is required for devices claiming 32 bit support.  So the spec
doesn't tell us what to do.

We do of course want to support all devices.  Is the proper action to
add 32 bit support and fall back to setting that?  What if that fails a=
s
well?  Just silently accept 32 bit NTBs?  I have played with that
thought.  It is possible.  But it's likely not more successful unless w=
e
make it automacally switch to sending such NTBs as well, and I'm not
sure that's a good idea.

Just fail?  Well, that doesn't make this device work...

Wonder what happens if you comment out the SET_NTB_FORMAT command?
Maybe the firmware have some odd logic which unconditionally switches
to 32 bit assuming that the host will only send this command for that
case?  And it fails because the "set 16 bit" parameter is unexpected
given this assumption?



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
