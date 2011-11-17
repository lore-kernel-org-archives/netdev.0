From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH FIX net v2] net-e1000(e): Fix default interrupt throttle
 rate not set in NIC HW
Date: Wed, 16 Nov 2011 20:02:12 -0800
Message-ID: <1321502533.2304.24.camel@jtkirshe-mobl>
References: <cover.1321494268.git.david.decotigny@google.com>
	 <75e944ced8ad7c58a0b838c0fe2a9e315f9e0c37.1321494268.git.david.decotigny@google.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ClrCnE4q7mSk5TK9Aekk"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Ying Cai <ycai@google.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <75e944ced8ad7c58a0b838c0fe2a9e315f9e0c37.1321494268.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ClrCnE4q7mSk5TK9Aekk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-11-16 at 17:46 -0800, David Decotigny wrote:
> From: Ying Cai <ycai@google.com>
>=20
> This change ensures that the itr/itr_setting adjustment logic is used,
> even for the default/compiled-in value.
>=20
> Context:
>   When we changed the default InterruptThrottleRate value from default
>   (3 =3D dynamic mode) to 8000 for example, only adapter->itr_setting
>   (which controls interrupt coalescing mode) was set to 8000, but
>   adapter->itr (which controls the value set in NIC register) was not
>   updated accordingly. So from ethtool, it seemed the interrupt
>   throttling is enabled at 8000 intr/s, but the NIC actually was
>   running in dynamic mode which has lower CPU efficiency especially
>   when throughput is not high.
>=20
>=20
>=20
> Signed-off-by: David Decotigny <david.decotigny@google.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_param.c |   81 +++++++++++-------=
-
>  drivers/net/ethernet/intel/e1000e/param.c      |   98 +++++++++++++-----=
------
>  2 files changed, 99 insertions(+), 80 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net=
/ethernet/intel/e1000/e1000_param.c
> index 1301eba..595e462 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_param.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
> @@ -173,7 +173,7 @@ E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrup=
t Delay");
> =20
>  /* Interrupt Throttle Rate (interrupts/sec)
>   *
> - * Valid Range: 100-100000 (0=3Doff, 1=3Ddynamic, 3=3Ddynamic conservati=
ve)
> + * Valid Range: 100-100000 or one of: 0=3Doff, 1=3Ddynamic, 3=3Ddynamic =
conservative
>   */
>  E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
>  #define DEFAULT_ITR                    3
> @@ -460,41 +460,54 @@ void __devinit e1000_check_options(struct e1000_ada=
pter *adapter)
>  		};
> =20
>  		if (num_InterruptThrottleRate > bd) {
> -			adapter->itr =3D InterruptThrottleRate[bd];
> -			switch (adapter->itr) {
> -			case 0:
> -				e_dev_info("%s turned off\n", opt.name);
> -				break;
> -			case 1:
> -				e_dev_info("%s set to dynamic mode\n",
> -					   opt.name);
> -				adapter->itr_setting =3D adapter->itr;
> -				adapter->itr =3D 20000;
> -				break;
> -			case 3:
> -				e_dev_info("%s set to dynamic conservative "
> -					   "mode\n", opt.name);
> -				adapter->itr_setting =3D adapter->itr;
> -				adapter->itr =3D 20000;
> -				break;
> -			case 4:
> -				e_dev_info("%s set to simplified "
> -				           "(2000-8000) ints mode\n", opt.name);
> -				adapter->itr_setting =3D adapter->itr;
> -				break;
> -			default:
> -				e1000_validate_option(&adapter->itr, &opt,
> -				        adapter);
> -				/* save the setting, because the dynamic bits
> -				 * change itr.
> -				 * clear the lower two bits because they are
> -				 * used as control */
> -				adapter->itr_setting =3D adapter->itr & ~3;
> -				break;
> -			}
> +			/* Make sure a message is printed for
> +			 * non-special values. And in case of an
> +			 * invalid option, display warning, use
> +			 * default and go through itr/itr_setting
> +			 * adjustment logic below */
> +			if ((adapter->itr < 0 || adapter->itr > 4)
> +			    && e1000_validate_option(&adapter->itr, &opt,
> +						     adapter))
> +				adapter->itr =3D opt.def;
>  		} else {
> -			adapter->itr_setting =3D opt.def;
> +			/* if no option specified, use default value
> +			   and go through the logic below to adjust
> +			   itr/itr_setting */
> +			adapter->itr =3D opt.def;
> +
> +			/* Make sure a message is printed for
> +			 * non-special default values */
> +			if (adapter->itr < 0 || adapter->itr > 4)
> +				e_dev_info("%s set to default %d\n",
> +					   opt.name, adapter->itr);
> +		}
> +
> +		adapter->itr_setting =3D adapter->itr;
> +		switch (adapter->itr) {
> +		case 0:
> +			e_dev_info("%s turned off\n", opt.name);
> +			break;
> +		case 1:
> +			e_dev_info("%s set to dynamic mode\n",
> +				   opt.name);
> +			adapter->itr =3D 20000;
> +			break;
> +		case 3:
> +			e_dev_info("%s set to dynamic conservative "
> +				   "mode\n", opt.name);
>  			adapter->itr =3D 20000;
> +			break;
> +		case 4:
> +			e_dev_info("%s set to simplified "
> +				   "(2000-8000) ints mode\n", opt.name);
> +			break;
> +		default:
> +			/* save the setting, because the dynamic bits
> +			 * change itr.
> +			 * clear the lower two bits because they are
> +			 * used as control */
> +			adapter->itr_setting &=3D ~3;
> +			break;
>  		}
>  	}
>  	{ /* Smart Power Down */
> diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethe=
rnet/intel/e1000e/param.c
> index 20e93b0..41937e5 100644
> --- a/drivers/net/ethernet/intel/e1000e/param.c
> +++ b/drivers/net/ethernet/intel/e1000e/param.c
> @@ -106,7 +106,7 @@ E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrup=
t Delay");
>  /*
>   * Interrupt Throttle Rate (interrupts/sec)
>   *
> - * Valid Range: 100-100000 (0=3Doff, 1=3Ddynamic, 3=3Ddynamic conservati=
ve)
> + * Valid Range: 100-100000 or one of: 0=3Doff, 1=3Ddynamic, 3=3Ddynamic =
conservative
>   */
>  E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
>  #define DEFAULT_ITR 3
> @@ -335,53 +335,59 @@ void __devinit e1000e_check_options(struct e1000_ad=
apter *adapter)
> =20
>  		if (num_InterruptThrottleRate > bd) {
>  			adapter->itr =3D InterruptThrottleRate[bd];
> -			switch (adapter->itr) {
> -			case 0:
> -				e_info("%s turned off\n", opt.name);
> -				break;
> -			case 1:
> -				e_info("%s set to dynamic mode\n", opt.name);
> -				adapter->itr_setting =3D adapter->itr;
> -				adapter->itr =3D 20000;
> -				break;
> -			case 3:
> -				e_info("%s set to dynamic conservative mode\n",
> -					opt.name);
> -				adapter->itr_setting =3D adapter->itr;
> -				adapter->itr =3D 20000;
> -				break;
> -			case 4:
> -				e_info("%s set to simplified (2000-8000 ints) "
> -				       "mode\n", opt.name);
> -				adapter->itr_setting =3D 4;
> -				break;
> -			default:
> -				/*
> -				 * Save the setting, because the dynamic bits
> -				 * change itr.
> -				 */
> -				if (e1000_validate_option(&adapter->itr, &opt,
> -							  adapter) &&
> -				    (adapter->itr =3D=3D 3)) {
> -					/*
> -					 * In case of invalid user value,
> -					 * default to conservative mode.
> -					 */
> -					adapter->itr_setting =3D adapter->itr;
> -					adapter->itr =3D 20000;
> -				} else {
> -					/*
> -					 * Clear the lower two bits because
> -					 * they are used as control.
> -					 */
> -					adapter->itr_setting =3D
> -						adapter->itr & ~3;
> -				}
> -				break;
> -			}
> +
> +			/* Make sure a message is printed for
> +			 * non-special values. And in case of an
> +			 * invalid option, display warning, use
> +			 * default and go through itr/itr_setting
> +			 * adjustment logic below */
> +			if ((adapter->itr < 0 || adapter->itr > 4)
> +			    && e1000_validate_option(&adapter->itr, &opt,
> +						     adapter))
> +				adapter->itr =3D opt.def;
>  		} else {
> -			adapter->itr_setting =3D opt.def;
> +			/* if no option specified, use default value
> +			   and go through the logic below to adjust
> +			   itr/itr_setting */
> +			adapter->itr =3D opt.def;
> +
> +			/* Make sure a message is printed for
> +			 * non-special default values */
> +			if (adapter->itr < 0 || adapter->itr > 4)
> +				e_info("%s set to default %d\n",
> +				       opt.name, adapter->itr);
> +		}
> +
> +
> +
> +		adapter->itr_setting =3D adapter->itr;
> +		switch (adapter->itr) {
> +		case 0:
> +			e_info("%s turned off\n", opt.name);
> +			break;
> +		case 1:
> +			e_info("%s set to dynamic mode\n", opt.name);
> +			adapter->itr =3D 20000;
> +			break;
> +		case 3:
> +			e_info("%s set to dynamic conservative mode\n",
> +			       opt.name);
>  			adapter->itr =3D 20000;
> +			break;
> +		case 4:
> +			e_info("%s set to simplified (2000-8000 ints) "
> +			       "mode\n", opt.name);
> +			break;
> +		default:
> +			/*
> +			 * Save the setting, because the dynamic bits
> +			 * change itr.
> +			 *
> +			 * Clear the lower two bits because
> +			 * they are used as control.
> +			 */
> +			adapter->itr_setting &=3D ~3;
> +			break;
>  		}
>  	}
>  	{ /* Interrupt Mode */

Thanks David, I have added this to my e1000e queue of patches.

--=-ClrCnE4q7mSk5TK9Aekk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOxIdEAAoJEOVv75VaS+3OXeQQAJFt3rIPLTaWNv2Yi918A68b
K5byA89RU62ftKJO4rYjDVA8oy/UooBYpU8MkMhRtD3Mq2OVEtoALFOscVvD6ZSh
Rjun+o7HoVSbGqfjDZkPoeDFyDtB8kJidf+/Nlq4jEDk+2568a5KdB6jwOXcqVDq
au5WimBipWgzKDR+EV8mKvUgze1G15tMdf3kEGkpzdYSMKJidGGirDHq1otxJait
Twi5o2ruoTrHbbT7i1/irW8PrqYl9l1aPOORpen2XYctsxaR/UjqB8BNKQ/FttAH
cNeJLWzNOSOOA/DV0DJE3JpaLPxt7SXCPbDrhcCGQnwmCcZO3jicc0taJMxegPJo
lNy7W11SOjIhckpzQLgacIOs5LiwGlIczbBoG7j6yXtccztUMOpXRoE8wD6woD/0
pZNI7wwjFE/JcnJasJ9X2XsN2zFosg3RPWxNmNRSayHffgbhu82k8JljBr8N3jbh
8fMHuw1dC68eqXdygSBPyChQoJnVl7biQSE/qSGWADyI6fkmLoIc1HjXfADHcR8A
sPJpkNzDvfRfdAriaOq3bWV3I6cyhSGZOBqCeN7m/W70Qd3VrR+o/KXMuvM0oGfn
9xy7i23gfBEQpgeUDewfA/qHrHNNyajebW8q4FmFDIikDPpXJtAj8udKK9gYl8qV
mPFz6YBpwhcktIYzHjjJ
=NmX0
-----END PGP SIGNATURE-----

--=-ClrCnE4q7mSk5TK9Aekk--
