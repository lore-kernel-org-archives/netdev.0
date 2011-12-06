From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver initialization flow to accommodate SRIOV for Ethernet
Date: Tue, 6 Dec 2011 10:35:53 +0200
Message-ID: <201112061035.54093.jackm@dev.mellanox.co.il>
References: <4ED8A636.40901@mellanox.co.il> <1323120413.2887.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323120413.2887.50.camel@bwh-desktop>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 05 December 2011 23:26, Ben Hutchings wrote:
> The 'probe_vf' parameter is very odd. =C2=A0Why do you think it is ne=
cessary
> to make this a module parameter? =C2=A0It should be possible to bind =
and
> unbind the driver from each VF dynamically via sysfs but this paramet=
er
> appears to restrict that.
>=20
The host which sees the PF will also see all the VFs once they come up.
As each VF appears (as seen by 'lspci'), the O/S will invoke the "probe=
"
method for that VF.  Without the "probe_vf" parameter, this probe would
result in all the VFs being bound to the PF host (and thus unavailable =
for
guests).


The small section of code which makes use of the probe_vf parameter
(file net/ethernet/mellanox/mlx4_main.c):

	/* Detect if this device is a virtual function */
	if (id && id->driver_data & MLX4_VF) {
		/* When acting as pf, we normally skip vfs unless explicitly
		 * requested to probe them. */
		if (sr_iov && extended_func_num(pdev) > probe_vf) {
			mlx4_warn(dev, "Skipping virtual function:%d\n",
						extended_func_num(pdev));
			err =3D -ENODEV;
			goto err_free_dev;
		}

If you invoke "dmesg" on the PF host, you will see a series of the
"Skipping... " messages, one per VF.  If probe_vf > 0, the PF-host will
reserve some VFs for its own use, and not issue the "Skipping..." messa=
ge
for those VFs.

-Jack
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
