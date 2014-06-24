From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 2/3] cxgb4: make configuration load use request_firmware_direct()
Date: Tue, 24 Jun 2014 15:54:44 -0700
Message-ID: <D46B557B-AF4A-4E60-8D83-6181D406C64F@chelsio.com>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com> <1403649583-12707-3-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tiwai@suse.de, chunkeey@googlemail.com, cocci@systeme.lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, "Luis R. Rodriguez" <mcgrof@suse.com>,
	Philip Oswald <poswald@suse.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Jeffrey Cheung <jcheung@suse.com>,
	David Chang <dchang@suse.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403649583-12707-3-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[[ Hopefully this makes it through to the kernel.org lists -- I=92m usi=
ng the Mac OS/X Mailer and it=92s not clear how to force it not to use =
HTML format. -- Casey ]]

  So does request_firmware_direct() only fail if the requested file is =
not present on the file system or does it fail in other cases as well?

  If it=92s the former, then the change to cxgb4 is fine.

  But if it=92s the latter, then it=92s definitely not okay.  While the=
 driver _can_ continue running without the local on-disk Firmware Confi=
guration File, that file can be used to significantly change the behavi=
or and capabilities of the adapter and is user-customizable.  If a user=
 makes changes to the local on-disk Firmware Configuration File and the=
se are randomly silently ignored this will lead to highly annoying supp=
ort issues.

Casey


On Jun 24, 2014, at 3:39 PM, Luis R. Rodriguez <mcgrof@do-not-panic.com=
> wrote:

> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>=20
> cxgb4 uses request_firmware() 3 times, one for firmware, one for
> optional configuration files and another for ethtools flash. Since th=
e
> configuration update is optional on devices that don't have a
> configuration file update it means we'd wait unnecessarily for the
> extra udev timeout, which by default is 60 seconds. Avoid this
> extra delay.
>=20
> This was found with the following SmPL patch.
>=20
> @ firmware_not_critical @
> expression cf;
> expression config_file;
> expression dev;
> int ret;
> identifier l;
> statement S;
> @@
>=20
> -	ret =3D request_firmware(&cf, config_file, dev);
> +	ret =3D request_firmware_direct(&cf, config_file, dev);
> 	if (ret < 0) {
> 		... when !=3D goto l;
> 		    when !=3D return ret;
> 		    when any
> 	} else {
> 		...
> 		release_firmware(cf);
> 		...
> 	}
>=20
> Cc: Philip Oswald <poswald@suse.com>
> Cc: Santosh Rastapur <santosh@chelsio.com>
> Cc: Jeffrey Cheung <jcheung@suse.com>
> Cc: David Chang <dchang@suse.com>
> Cc: Casey Leedom <leedom@chelsio.com>
> Cc: Hariprasad Shenai <hariprasad@chelsio.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> Cc: cocci@systeme.lip6.fr
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/driver=
s/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 02a0ebf..bd57177 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4999,7 +4999,7 @@ static int adap_init0_config(struct adapter *ad=
apter, int reset)
>  		goto bye;
>  	}
>=20
> -	ret =3D request_firmware(&cf, fw_config_file, adapter->pdev_dev);
> +	ret =3D request_firmware_direct(&cf, fw_config_file, adapter->pdev_=
dev);
>  	if (ret < 0) {
>  		config_name =3D "On FLASH";
>  		mtype =3D FW_MEMTYPE_CF_FLASH;
> --=20
> 2.0.0
>=20
