From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: Convert to runtime_pm
Date: Sun, 11 Jan 2015 16:41:20 +0100
Message-ID: <54B299A0.1000504@pengutronix.de>
References: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl> <54AD267C.4060004@pengutronix.de> <12e7202e137e4d5680185748ebf0cf2d@BY2FFO11FD060.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="IIgnhFqQxjSk2sG6boEQrHjQIJpBHqmER"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"wg@grandegger.com" <wg@grandegger.com>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <12e7202e137e4d5680185748ebf0cf2d@BY2FFO11FD060.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IIgnhFqQxjSk2sG6boEQrHjQIJpBHqmER
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/11/2015 06:34 AM, Appana Durga Kedareswara Rao wrote:
[...]
>>>             return ret;
>>>     }
>>>
>>>     priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>>     priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
>>>
>>>     if (netif_running(ndev)) {
>>>             priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>
>> What happens if the device was not in ACTIVE state prior to the
>> runtime_suspend?
>>
>=20
> I am not sure about the state of CAN at this point of time.
> I just followed what other drivers are following for run time  suspend =
:).

Please check the state of the hardware if you go with bus off into
suspend and then resume.

>>>             netif_device_attach(ndev);
>>>             netif_start_queue(ndev);
>>>     }
>>>
>>>     return 0;
>>> }
>>
>>
>>>
>>> @@ -1020,9 +1035,9 @@ static int __maybe_unused xcan_resume(struct
>>> device *dev)
>>>
>>>     priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>>     priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
>>> -   priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>>
>>>     if (netif_running(ndev)) {
>>> +           priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>>             netif_device_attach(ndev);
>>>             netif_start_queue(ndev);
>>>     }
>>> @@ -1030,7 +1045,10 @@ static int __maybe_unused xcan_resume(struct
>> device *dev)
>>>     return 0;
>>>  }
>>>
>>> -static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend,
>> xcan_resume);
>>> +static const struct dev_pm_ops xcan_dev_pm_ops =3D {
>>> +   SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
>>> +   SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend,
>> xcan_runtime_resume,
>>> +NULL) };
>>>
>>>  /**
>>>   * xcan_probe - Platform registration call @@ -1071,7 +1089,7 @@
>>> static int xcan_probe(struct platform_device *pdev)
>>>             return -ENOMEM;
>>>
>>>     priv =3D netdev_priv(ndev);
>>> -   priv->dev =3D ndev;
>>> +   priv->dev =3D &pdev->dev;
>>>     priv->can.bittiming_const =3D &xcan_bittiming_const;
>>>     priv->can.do_set_mode =3D xcan_do_set_mode;
>>>     priv->can.do_get_berr_counter =3D xcan_get_berr_counter; @@ -
>> 1137,15
>>> +1155,22 @@ static int xcan_probe(struct platform_device *pdev)
>>>
>>>     netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
>>>
>>> +   pm_runtime_set_active(&pdev->dev);
>>> +   pm_runtime_irq_safe(&pdev->dev);
>>> +   pm_runtime_enable(&pdev->dev);
>>> +   pm_runtime_get_sync(&pdev->dev);
>> Check error values?
>=20
> Ok
>>> +
>>>     ret =3D register_candev(ndev);
>>>     if (ret) {
>>>             dev_err(&pdev->dev, "fail to register failed (err=3D%d)\n=
",
>> ret);
>>> +           pm_runtime_put(priv->dev);
>>
>> Please move the pm_runtime_put into the common error exit path.
>>
>=20
> Ok
>=20
>>>             goto err_unprepare_disable_busclk;
>>>     }
>>>
>>>     devm_can_led_init(ndev);
>>> -   clk_disable_unprepare(priv->bus_clk);
>>> -   clk_disable_unprepare(priv->can_clk);
>>> +
>>> +   pm_runtime_put(&pdev->dev);
>>> +
>>>     netdev_dbg(ndev, "reg_base=3D0x%p irq=3D%d clock=3D%d, tx fifo
>> depth:%d\n",
>>>                     priv->reg_base, ndev->irq, priv->can.clock.freq,
>>>                     priv->tx_max);
>>>
>>
>> I think you have to convert the _remove() function, too. Have a look a=
t the
>> gpio-zynq.c driver:
>>
>>> static int zynq_gpio_remove(struct platform_device *pdev) {
>>>     struct zynq_gpio *gpio =3D platform_get_drvdata(pdev);
>>>
>>>     pm_runtime_get_sync(&pdev->dev);
>>
>> However I don't understand why the get_sync() is here. Maybe S=C3=B6re=
n can
>> help?
>=20
> I converted the remove function to use the run-time PM and .
> Below is the remove code snippet.
>=20
>        ret =3D pm_runtime_get_sync(&pdev->dev);
>         if (ret < 0) {
>                 netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
>                                 __func__, ret);
>                 return ret;
>         }
>=20
>         if (set_reset_mode(ndev) < 0)
>                 netdev_err(ndev, "mode resetting failed!\n");
>=20
>         unregister_candev(ndev);
>         netif_napi_del(&priv->napi);
>         free_candev(ndev);

>         pm_runtime_disable(&pdev->dev);

Can this make a call to xcan_runtime_*()? I'm asking since the ndev has
been unregistered and already free()ed. Better move this directly after
the set_reset_mode(). This way you are symmetric to the probe() function.=


> Observed the below things in the /sys/kernel/debug/clk/clk_summary.
>=20
>                                 Modprobe        ifconfig up    ifconfig=
 down   rmmod  Modprobe  ifconfig up   ifconfig down  rmmod  Modprobe  if=
config up   ifconfig down  rmmod
> Clk_prepare count:                1             1               1      =
         1       2       2               2               2       3       =
3               3               3
> Clk_enable count:                 0             1               0      =
         1       2       2               2               2       3       =
3               3               3

As the numbers are increasing you have a clk_prepare_enable() leak. Your
remove() function is missing the clk_disable_unprepare() for the can and
bus clock (as you have clk_prepare_enable in probe()).

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--IIgnhFqQxjSk2sG6boEQrHjQIJpBHqmER
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUspmgAAoJECte4hHFiupU3BkP/RNZ+lH57aMC6Wr7E6sA1TNL
emLxcSUvJPfSKSWO0Nd2XTehPd+BlV27+96ioyh5glJUV9GYNEF0iYn7G8Uf4owh
FsE7wmCmn3QNvETMzt680k3g104kvYR9MAjwogJuo4hgmLrlTGijmDXP7i/yed6x
VWH4lQuQbPMqGmQLL8hWchgpdjzjFdTg8Y3M6b0cmE1PUI2Z0H5h2B6O/4fYsWJv
SIU23IwYGbwQCcwK6I8i9w7JfFFDg3q63/wRfbufF1xoRNJA9iAQFO6qIS4BTQlG
FgDV8/3+EHBChwnB+G3796xMNCd7PY2YPZqJCfdEng1RNffNIjlwJfL1o9O6zWA4
5ZzMF7HJQHHbuc7ZPvLpTelEnM3+eLnt66Wj0zqdt6h0x2RTChzdJVoKZ/sBYYYI
4fDuQJSmYFzvvDTRWa5PQuRSDJ3jGdboeTH5TgpUJqM3BkXAhKoLn+yynnlNuFmk
KUpJ303P0O3PGXi7tuNbQadh0eiXbvb57WDpQaqdzY6Li1Y666PyBzBVFSLJ1htV
xlLDo5rSJ6kxOB60pQnPJv47EMLLAzca5dCg/DbyNSlXERji583UIJuqoZwplEEE
OK6+kl2+H6EDK6JPf89Zs2CkRUgivPr7jYIIvIIpeZ52EH/YW2EXxnxxj7eIOdXc
bOedRWD47c+BtVwmF4kW
=lzog
-----END PGP SIGNATURE-----

--IIgnhFqQxjSk2sG6boEQrHjQIJpBHqmER--
