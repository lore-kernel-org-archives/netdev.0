From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 3/3] net: can: peak_usb: Do not do dma on the stack
Date: Sat, 14 Dec 2013 14:37:19 +0100
Message-ID: <52AC5F0F.20105@pengutronix.de>
References: <1370261733-22935-1-git-send-email-mkl@pengutronix.de> <1370261733-22935-4-git-send-email-mkl@pengutronix.de> <52A9CBC1.4080809@peak-system.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="5Ud8ifPmqg814BjVfQpIc2xRaNn18etEV"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Stephane Grosjean <s.grosjean@peak-system.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52A9CBC1.4080809@peak-system.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--5Ud8ifPmqg814BjVfQpIc2xRaNn18etEV
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/12/2013 03:44 PM, Stephane Grosjean wrote:
> Going back into linux-can peak_usb, and I'm currently having a quick
> look to what has changed during these several past months.
> I agree with the below patch that fixes the "DMAusage with USB core"
> issue, but - maybe I'm wrong - isn't there now amemory leak issue in
> "pcan_usb_pro_init()" function below?
>=20
> I mean, you now allocate "fi" and "bi" memory objects but, AFAIK, they
> aren't freed anywhere in the function, don't they?

Thanks for pointing out.

[...]

>> b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
>> index 30d79bf..8ee9d15 100644
>> --- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
>> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
[...]
>> @@ -851,21 +860,24 @@ static int pcan_usb_pro_stop(struct
>> peak_usb_device *dev)
>>    */
>>   static int pcan_usb_pro_init(struct peak_usb_device *dev)
>>   {
>> -    struct pcan_usb_pro_interface *usb_if;
>>       struct pcan_usb_pro_device *pdev =3D
>>               container_of(dev, struct pcan_usb_pro_device, dev);
>> +    struct pcan_usb_pro_interface *usb_if =3D NULL;
>> +    struct pcan_usb_pro_fwinfo *fi =3D NULL;
>> +    struct pcan_usb_pro_blinfo *bi =3D NULL;
>> +    int err;
>>         /* do this for 1st channel only */
>>       if (!dev->prev_siblings) {
>> -        struct pcan_usb_pro_fwinfo fi;
>> -        struct pcan_usb_pro_blinfo bi;
>> -        int err;
>> -
>>           /* allocate netdevices common structure attached to first
>> one */
>>           usb_if =3D kzalloc(sizeof(struct pcan_usb_pro_interface),
>>                    GFP_KERNEL);
>> -        if (!usb_if)
>> -            return -ENOMEM;
>> +        fi =3D kmalloc(sizeof(struct pcan_usb_pro_fwinfo), GFP_KERNEL=
);
>> +        bi =3D kmalloc(sizeof(struct pcan_usb_pro_blinfo), GFP_KERNEL=
);
>> +        if (!usb_if || !fi || !bi) {
>> +            err =3D -ENOMEM;
>> +            goto err_out;
>> +        }
>>             /* number of ts msgs to ignore before taking one into
>> account */
>>           usb_if->cm_ignore_count =3D 5;
>> @@ -877,34 +889,34 @@ static int pcan_usb_pro_init(struct
>> peak_usb_device *dev)
>>            */
>>           err =3D pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_INFO,
>>                           PCAN_USBPRO_INFO_FW,
>> -                        &fi, sizeof(fi));
>> +                        fi, sizeof(*fi));
>>           if (err) {
>> -            kfree(usb_if);
>>               dev_err(dev->netdev->dev.parent,
>>                   "unable to read %s firmware info (err %d)\n",
>>                   pcan_usb_pro.name, err);
>> -            return err;
>> +            goto err_out;
>>           }
>>             err =3D pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_INFO,
>>                           PCAN_USBPRO_INFO_BL,
>> -                        &bi, sizeof(bi));
>> +                        bi, sizeof(*bi));
>>           if (err) {
>> -            kfree(usb_if);
>>               dev_err(dev->netdev->dev.parent,
>>                   "unable to read %s bootloader info (err %d)\n",
>>                   pcan_usb_pro.name, err);
>> -            return err;
>> +            goto err_out;
>>           }
>>   +        /* tell the device the can driver is running */
>> +        err =3D pcan_usb_pro_drv_loaded(dev, 1);
>> +        if (err)
>> +            goto err_out;
>> +
>>           dev_info(dev->netdev->dev.parent,
>>                "PEAK-System %s hwrev %u serial %08X.%08X (%u
>> channels)\n",
>>                pcan_usb_pro.name,
>> -             bi.hw_rev, bi.serial_num_hi, bi.serial_num_lo,
>> +             bi->hw_rev, bi->serial_num_hi, bi->serial_num_lo,
>>                pcan_usb_pro.ctrl_count);
>> -
>> -        /* tell the device the can driver is running */
>> -        pcan_usb_pro_drv_loaded(dev, 1);
>>       } else {
>>           usb_if =3D pcan_usb_pro_dev_if(dev->prev_siblings);
>>       }
>> @@ -916,6 +928,13 @@ static int pcan_usb_pro_init(struct
>> peak_usb_device *dev)
>>       pcan_usb_pro_set_led(dev, 0, 1);
>>         return 0;
>> +
>> + err_out:
>> +    kfree(bi);
>> +    kfree(fi);
>> +    kfree(usb_if);
>> +
>> +    return err;
>>   }
>>     static void pcan_usb_pro_exit(struct peak_usb_device *dev)

I'll send a fix.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--5Ud8ifPmqg814BjVfQpIc2xRaNn18etEV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKsXw8ACgkQjTAFq1RaXHO5zACghNPs4g1lYu0UJvq23Te61ALu
KE0An3ZHgzbQm3v5Aa6NH7A3AQcbyWIv
=n8oC
-----END PGP SIGNATURE-----

--5Ud8ifPmqg814BjVfQpIc2xRaNn18etEV--
