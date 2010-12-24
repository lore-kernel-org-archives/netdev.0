From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Fri, 24 Dec 2010 12:44:08 +0100
Message-ID: <4D148788.3010808@pengutronix.de>
References: <20101223093627.GA325@e-circ.dyndns.org>	<20101223094302.GB325@e-circ.dyndns.org>	<4D135BC3.6070707@pengutronix.de>
	<20101224091428.GA375@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7887854063234239745=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20101224091428.GA375-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============7887854063234239745==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA35079F82CD59DBD5116D5E1"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA35079F82CD59DBD5116D5E1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/24/2010 10:14 AM, Kurt Van Dijck wrote:
> Marc,
>=20
> A lot of your remarks do make sense, without further comment.
> Some however, I'm not completely sure ...
>=20
>=20
> On Thu, Dec 23, 2010 at 03:25:07PM +0100, Marc Kleine-Budde wrote:
>>> =20
>>>  obj-y				+=3D usb/
>>> +obj-y				+=3D softing/
>>
>> I think it will (at least marginally) speed up the Kernel build proces=
s
>> only to dive into the softing subdir if Softing is enabled in Kconfig.=

>=20
> Due to the independant driver design, I should
> (CONFIG_CAN_SOFTING || CONFIG_CAN_SOFTINGCS)

In the second patch I see:

+config CAN_SOFTING_CS
+	tristate "Softing CAN pcmcia cards"
+	depends on CAN_SOFTING && PCMCIA

>>
>>> +	ktime_t ts_ref;
>>> +	ktime_t ts_overflow; /* timestamp overflow value, in ktime */
>>> +
>>> +	struct {
>>> +		/* indication of firmware status */
>>> +		int up;
>>> +		/* protection of the 'up' variable */
>>> +		struct mutex lock;
>>> +	} fw;
>>
>> what about using an atomic_t for the firmware status?
> for 'up', yes, but the lock stays. It protects the startup/shutdown
> sequence too, ie. only 1 process enters the shutdown sequence.

okay

>>
>>> +/* SOFTING DPRAM mappings */
>>> +struct softing_rx {
>>> +	u8  fifo[16][32];
>>> +	u8  dummy1;
>>
>> Just curious, why did they put a padding byte here, that makes the res=
t
>> unaligned?
> I did not design the DPRAM layout. It's just the way it is ...
> I did prefer to use structs in virtual memory, and this is the conseque=
nce.

Sure, I was just wondering why the DPRAM designer did this.

>>
>>> +	u32 time;
>>> +	u32 time_wrap;
>>> +	u8  wr_start;
>>> +	u8  wr_end;
>>> +	u8  dummy10;
>>> +	u16 dummy12;
>>> +	u16 dummy12x;
>>> +	u16 dummy13;
>>> +	u16 reset_rcv_fifo;
>>> +	u8  dummy14;
>>> +	u8  reset_xmt_fifo;
>>> +	u8  read_fifo_levels;
>>> +	u16 rcv_fifo_level;
>>> +	u16 xmt_fifo_level;
>>> +} __attribute__((packed));
>>
>> Can you renumber the dummy variables (there are some "x" in there), or=

>> does it correspond to some datasheet?
> no, there's no datasheet. I started from code released by Softing.
>>
>>> +
>>> diff --git a/drivers/net/can/softing/softing_fw.c b/drivers/net/can/s=
ofting/softing_fw.c
>>> +
> [...]
>>> +int softing_fct_cmd(struct softing *card, int cmd, int vector, const=
 char *msg)
>>> +{
>>> +	int ret;
>>> +	unsigned long stamp;
>>> +	if (vector =3D=3D RES_OK)
>>> +		vector =3D RES_NONE;
>>> +	card->dpram.fct->param[0] =3D cmd;
>>
>> param[] is an array of s16 and cmd is an int.
> Is this a problem? Is it usefull to define the function with s16 argume=
nts then?

Yes, I think so, same for the vector.

>> hmmm..all stuff behind dpram is __iomem, isn't it? I think it should
>> only be accessed with via the ioread/iowrite operators. Please check
> I did an ioremap_nocache. Since it is unaligned, ioread/iowrite would r=
ender
> a lot of statements.

The thing is, ioremapped mem should not be accessed directly. Instead
ioread/iowrite should be used. The softing driver should work on non x86
platforms, too.

>> your code with sparse (compile with "make C=3D2").
> (?)

Sparse, a static syntax analyser tool, see "Documentation/sparse.txt".
It throws the following warnings on your driver:

> make drivers/net/can/softing/softing.ko C=3D2
>   CHK     include/linux/version.h
>   CHK     include/generated/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHECK   scripts/mod/empty.c
>   CHECK   drivers/net/can/softing/softing_main.c
> drivers/net/can/softing/softing_main.c:98:15: warning: incorrect type i=
n argument 1 (different address spaces)
> drivers/net/can/softing/softing_main.c:98:15:    expected void volatile=
 [noderef] <asn:2>*dst
> drivers/net/can/softing/softing_main.c:98:15:    got unsigned char [use=
rtype] *[assigned] ptr
> drivers/net/can/softing/softing_main.c:292:31: warning: incorrect type =
in argument 2 (different address spaces)
> drivers/net/can/softing/softing_main.c:292:31:    expected void const v=
olatile [noderef] <asn:2>*src
> drivers/net/can/softing/softing_main.c:292:31:    got unsigned char [us=
ertype] *[assigned] ptr
> drivers/net/can/softing/softing_main.c:522:15: warning: incorrect type =
in argument 1 (different address spaces)
> drivers/net/can/softing/softing_main.c:522:15:    expected void volatil=
e [noderef] <asn:2>*dst
> drivers/net/can/softing/softing_main.c:522:15:    got unsigned char *[a=
ssigned] lp
> drivers/net/can/softing/softing_main.c:525:23: warning: incorrect type =
in argument 2 (different address spaces)
> drivers/net/can/softing/softing_main.c:525:23:    expected void const v=
olatile [noderef] <asn:2>*src
> drivers/net/can/softing/softing_main.c:525:23:    got unsigned char *[a=
ssigned] lp
> drivers/net/can/softing/softing_main.c:654:14: warning: Using plain int=
eger as NULL pointer
> drivers/net/can/softing/softing_main.c:655:14: warning: Using plain int=
eger as NULL pointer
> drivers/net/can/softing/softing_main.c:662:2: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:665:11: warning: Using plain int=
eger as NULL pointer
> drivers/net/can/softing/softing_main.c:696:10: warning: Using plain int=
eger as NULL pointer
> drivers/net/can/softing/softing_main.c:753:1: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:754:1: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:755:1: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:756:1: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:757:1: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:758:1: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:767:2: warning: Using plain inte=
ger as NULL pointer
> drivers/net/can/softing/softing_main.c:790:18: warning: Using plain int=
eger as NULL pointer
> drivers/net/can/softing/softing_main.c:794:21: warning: incorrect type =
in argument 1 (different address spaces)
> drivers/net/can/softing/softing_main.c:794:21:    expected void volatil=
e [noderef] <asn:2>*addr
> drivers/net/can/softing/softing_main.c:794:21:    got unsigned char *vi=
rt
> drivers/net/can/softing/softing_main.c:835:19: warning: incorrect type =
in assignment (different address spaces)
> drivers/net/can/softing/softing_main.c:835:19:    expected unsigned cha=
r *virt
> drivers/net/can/softing/softing_main.c:835:19:    got void [noderef] <a=
sn:2>*
> drivers/net/can/softing/softing_main.c:883:19: warning: Using plain int=
eger as NULL pointer
> drivers/net/can/softing/softing_main.c:902:21: warning: incorrect type =
in argument 1 (different address spaces)
> drivers/net/can/softing/softing_main.c:902:21:    expected void volatil=
e [noderef] <asn:2>*addr
> drivers/net/can/softing/softing_main.c:902:21:    got unsigned char *vi=
rt
>   CHECK   drivers/net/can/softing/softing_fw.c
> drivers/net/can/softing/softing_fw.c:213:20: warning: incorrect type in=
 argument 1 (different address spaces)
> drivers/net/can/softing/softing_fw.c:213:20:    expected void volatile =
[noderef] <asn:2>*dst
> drivers/net/can/softing/softing_fw.c:213:20:    got unsigned char *
> drivers/net/can/softing/softing_fw.c:224:27: warning: incorrect type in=
 argument 2 (different address spaces)
> drivers/net/can/softing/softing_fw.c:224:27:    expected void const vol=
atile [noderef] <asn:2>*src
> drivers/net/can/softing/softing_fw.c:224:27:    got unsigned char *
> drivers/net/can/softing/softing_fw.c:319:33: warning: incorrect type in=
 argument 1 (different address spaces)
> drivers/net/can/softing/softing_fw.c:319:33:    expected void volatile =
[noderef] <asn:2>*dst
> drivers/net/can/softing/softing_fw.c:319:33:    got unsigned char *

You should start with fixing the assignment of the ioremapped memory
(drivers/net/can/softing/softing_main.c:835), the fix the rest.

>>> +		}
>>> +		if ((jiffies - stamp) >=3D 1 * HZ)
>>
>> That's not good. I don't remember the name, but there are some
>> functions/defines to do this kind of things properly.
> I'll do a search

It's "time_after"
http://lxr.linux.no/linux+v2.6.36/include/linux/jiffies.h#L106

>>
>>> +			break;
>>> +		if (in_interrupt())
>>> +			/* go as fast as possible */
>>
>> In the worst case this means you lock up the system for one second. Do=
es
>> the card issue an interrupt if it's finished? Another option is to wri=
te
>> a threaded interrupt handler.
> Yep, threaded interrupt handler is something to look at ... later.
>>
>>
>>> +{
>>> +	int ret;
>>> +	unsigned long stamp;
>>> +	card->dpram.receipt[0] =3D RES_NONE;
>>> +	card->dpram.command[0] =3D command;
>>> +	/* be sure to flush this to the card */
>>> +	wmb();
>>> +	stamp =3D jiffies;
>>> +	/*wait for card */
>>> +	do {
>>> +		ret =3D card->dpram.receipt[0];
>>> +		/* don't have any cached variables */
>>> +		rmb();
>>> +		if (ret =3D=3D RES_OK)
>>> +			return 0;
>>> +		if ((jiffies - stamp) >=3D (3 * HZ))
>>> +			break;
>>> +		schedule();
>>
>> same applies here, too. Although this command seems not to be called
>> from interrupt context, what about using a msleep() instead of a sched=
ule?
> Not calling schedule was really annoying.

sure, but a *sleep might be better.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA35079F82CD59DBD5116D5E1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0Uh4gACgkQjTAFq1RaXHNI7QCfbJSMrM9xe53wfcr3jF51Q8sM
pCcAn2iYmcWYtcXvr2jinMXmdHCbnjeh
=jlHM
-----END PGP SIGNATURE-----

--------------enigA35079F82CD59DBD5116D5E1--

--===============7887854063234239745==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7887854063234239745==--
