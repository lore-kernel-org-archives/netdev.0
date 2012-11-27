From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] smsc95xx: fix suspend buffer overflow
Date: Tue, 27 Nov 2012 15:34:54 +0100
Message-ID: <87a9u39ks1.fsf@nemi.mork.no>
References: <1354022623-7317-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43614 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab2K0OfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 09:35:02 -0500
In-Reply-To: <1354022623-7317-1-git-send-email-steve.glendinning@shawell.net>
	(Steve Glendinning's message of "Tue, 27 Nov 2012 13:23:43 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve.glendinning@shawell.net> writes:

> This patch fixes a buffer overflow introduced by bbd9f9e, where
> the filter_mask array is accessed beyond its bounds.
>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
> ---
>  drivers/net/usb/smsc95xx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 79d495d..6cdc504 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1281,7 +1281,7 @@ static int smsc95xx_suspend(struct usb_interfac=
e *intf, pm_message_t message)
>  	}
> =20
>  	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCA=
ST)) {
> -		u32 *filter_mask =3D kzalloc(32, GFP_KERNEL);
> +		u32 *filter_mask =3D kzalloc(sizeof(u32) * 32, GFP_KERNEL);
>  		u32 command[2];
>  		u32 offset[2];
>  		u32 crc[4];

I wonder... all these magic constants (32, 2, 2, 4) obviously relate to
the maximum number of supported filters (8).  It would be much easier t=
o
avoid such bugs if the code documented this.  Like

		u32 *filter_mask =3D kzalloc(4 * sizeof(u32) * N, GFP_KERNEL);
 		u32 command[N/4];
  		u32 offset[N/4];
  		u32 crc[N/2];


And even better if you let the base types be "native" size so you could
avoid all the complicated indexing math:

		u8 *filter_mask =3D kzalloc(4 * sizeof(u32) * N, GFP_KERNEL);
 		u8 command[N];
  		u8 offset[N];
  		u16 crc[N];

Yes, you will then have to do type conversions when writing to the chip=
,
but I believe the overall code will be much easier to follow with this

			command[filter/4] |=3D 0x05UL << ((filter % 4) * 8);
			offset[filter/4] |=3D 0x00 << ((filter % 4) * 8);
			crc[filter/2] |=3D smsc_crc(bcast, 6, filter);

replaced by the IMHO more obvious

			command[filter] =3D 0x05UL;
			offset[filter] =3D 0x00;
			crc[filter] =3D  bitrev16(crc16(0xFFFF, bcast, 6));


BTW, the smsc_crc() function cannot work.  It returns a u16 which it
sometimes will attemt to shift 16 bits...

And you don't test the kzalloc() return value.

And if I am really going to be a nitpick (which comes naturally to me
:-), then I don't think you need to allocate anything at all.  You neve=
r
set more than a few bits in the first byte of the filter mask.  Why not
create a small helper function which writes a filter mask with these
bits and fill the rest with zeroes?

Something along the lines of

int write_filter(struct usbnet *dev, u8 firstbyte)
{
        int i, ret =3D 0;
        u32 v =3D (u32)firstbyte << 24;

        for (i =3D 0; i < 4 && !ret; i++) {
                ret =3D smsc95xx_write_reg_nopm(dev, WUFF, v);
                v =3D 0;
        }
        return ret;
}

    u8 filter_mask_byte[N];
=2E.
    filter_mask_byte[filter] =3D 0x3F;
=2E.
    for (i =3D 0; i < wuff_filter_count; i++) {
	ret =3D write_filter(dev, filter_mask_byte[i]);
	check_warn_return(ret, "Error writing WUFF\n");
    }
  =20





Bj=C3=B8rn
