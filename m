From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] Drivers: isdn: gigaset: checkpatch cleanup
Date: Thu, 01 Jan 2015 19:46:29 +0100
Message-ID: <54A59605.80503@imap.cc>
References: <1420047298-7798-1-git-send-email-baspeters93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, gigaset307x-common@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>, hjlipp@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420047298-7798-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello Bas,

I have several objections to your patch.

Am 31.12.2014 um 18:34 schrieb Bas Peters:
> I have not been able to test the code as I do not have access to
> the hardware but since no new features were really added I don't
> think that should pose a problem.

It's always problematic to change code you cannot test.
At the very least, if you do coding style cleanups you should test
whether the result still compiles and generates the same code as before=
=2E

> --- a/drivers/isdn/gigaset/bas-gigaset.c +++
> b/drivers/isdn/gigaset/bas-gigaset.c @@ -261,11 +261,12 @@ static
> inline void dump_urb(enum debuglevel level, const char *tag, {=20
> #ifdef CONFIG_GIGASET_DEBUG int i; + gig_dbg(level, "%s
> urb(0x%08lx)->{", tag, (unsigned long) urb); if (urb) {=20
> gig_dbg(level, -			"  dev=3D0x%08lx, pipe=3D%s:EP%d/DV%d:%s, " -
> "hcpriv=3D0x%08lx, transfer_flags=3D0x%x,", +			"  dev=3D0x%08lx,
> pipe=3D%s:EP%d/DV%d:%s, +			hcpriv=3D0x%08lx, transfer_flags=3D0x%x,"=
,

This is syntactically wrong and won't compile. You cannot have an
unescaped newline inside a string literal.

> @@ -2312,13 +2312,13 @@ static int gigaset_probe(struct
> usb_interface *interface, /* Reject application specific
> interfaces */ if (hostif->desc.bInterfaceClass !=3D 255) { -
> dev_warn(&udev->dev, "%s: bInterfaceClass =3D=3D %d\n", +
> dev_warn(&udev->dev, "%s: bInterfaceClass =3D=3D %d\n",\ __func__,
> hostif->desc.bInterfaceClass); return -ENODEV; }
>=20
> dev_info(&udev->dev, -		 "%s: Device matched (Vendor: 0x%x,
> Product: 0x%x)\n", +		 "%s: Device matched (Vendor: 0x%x, Product:
> 0x%x)\n",\ __func__, le16_to_cpu(udev->descriptor.idVendor),=20
> le16_to_cpu(udev->descriptor.idProduct));

This looks strange, and not like correct coding style. Why would you
want to escape the end of line after a function argument?

> --- a/drivers/isdn/gigaset/common.c +++
> b/drivers/isdn/gigaset/common.c @@ -53,7 +53,7 @@ void
> gigaset_dbg_buffer(enum debuglevel level, const unsigned char
> *msg, { unsigned char outbuf[80]; unsigned char c; -	size_t space =3D
> sizeof outbuf - 1; +	size_t space =3D sizeof(outbuf - 1);

This is wrong. The sizeof operator must be applied to the array
variable outbuf, not to the expression (outbuf - 1).

> --- a/drivers/isdn/gigaset/ev-layer.c +++
> b/drivers/isdn/gigaset/ev-layer.c

> @@ -1355,8 +1351,20 @@ static void do_action(int action, struct
> cardstate *cs, }
>=20
> for (i =3D 0; i < 4; ++i) { -			val =3D simple_strtoul(s, (char **) &=
e,
> 10); -			if (val > INT_MAX || e =3D=3D s) +			unsigned long *e; + +
> val =3D kstrtoul(s, 10, e); +			if (val =3D=3D -EINVAL) { +
> dev_err(cs->dev, "Parsing error on converting string to\ +
> unsigned long\n"); +				break; +			} +			if (val =3D=3D -ERANGE) { +
> dev_err(cs->dev, "Overflow error converting string to\ +
> unsigned long\n"); +				break; +			} +			if (val > INT_MAX || *e =3D=3D
> s) break; if (i =3D=3D 3) { if (*e)

This cannot work. The pointer variable e gets dereferenced without
ever being initialized. The type mismatches when declaring e as
pointing to an unsigned long but comparing *e to s in one place and to
a character literal in another point make me wonder which semantics
you had in mind for e in the first place.
Also your error messages are not helpful for someone reading the log
and trying to find out what went wrong, and not very readable because
of the big stretch of whitespace you insert between the words "to" and
"unsigned". In fact I'm not even convinced it's a good idea to emit a
log message at all here.

> --- a/drivers/isdn/gigaset/gigaset.h +++
> b/drivers/isdn/gigaset/gigaset.h @@ -94,8 +94,7 @@ enum debuglevel
> { #define gig_dbg(level, format, arg...)					\ do {								\ if
> (unlikely(((enum debuglevel)gigaset_debuglevel) & (level))) \ -
> printk(KERN_DEBUG KBUILD_MODNAME ": " format "\n", \ -			       ##
> arg);					\ +			dev_dbg(cs->dev, KBUILD_MODNAME ": " format "\n")\=20
> } while (0) #define DEBUG_DEFAULT (DEBUG_TRANSCMD | DEBUG_CMD |
> DEBUG_USBREQ)
>=20

This will not work when
- - there is no cs variable in the context where the macro is used or
- - cs->dev doesn't contain a valid device pointer or
- - the format string references additional arguments,
all of which actually occur in the driver.

> --- a/drivers/isdn/gigaset/i4l.c +++ b/drivers/isdn/gigaset/i4l.c=20
> @@ -624,14 +624,14 @@ int gigaset_isdn_regdev(struct cardstate *cs,
> const char *isdnid) { isdn_if *iif;
>=20
> -	iif =3D kmalloc(sizeof *iif, GFP_KERNEL); +	iif =3D
> kmalloc(sizeof(*iif, GFP_KERNEL)); if (!iif) { pr_err("out of
> memory\n"); return -ENOMEM;

You're calling kmalloc with too few arguments here.

> --- a/drivers/isdn/gigaset/proc.c +++
> b/drivers/isdn/gigaset/proc.c @@ -27,13 +27,18 @@ static ssize_t
> set_cidmode(struct device *dev, struct device_attribute *attr,=20
> const char *buf, size_t count) { struct cardstate *cs =3D
> dev_get_drvdata(dev); -	long int value; -	char *end; +	long int
> *value; +	int result;
>=20
> -	value =3D simple_strtol(buf, &end, 0); -	while (*end) -		if
> (!isspace(*end++)) -			return -EINVAL; +	result =3D kstrtol(buf, 0,
> &value); +	if (result =3D=3D -ERANGE) +		/* Overflow error */ +
> dev_err(cs->dev, "Overflow error on conversion from string to\ +
> long\n"); +	if (result =3D=3D -EINVAL) +		/* Parsing error  */ +
> dev_err(cs->dev, "Parsing error on conversion from string to\ +
> long\n"); if (value < 0 || value > 1) return -EINVAL;

This changes semantics. Your code will not accept the same input as
the original code, and it will emit messages of its own instead of
just returning an error code to the caller as it should.

> --- a/drivers/isdn/gigaset/usb-gigaset.c +++
> b/drivers/isdn/gigaset/usb-gigaset.c

> default: rate =3D  9600; -		dev_err(cs->dev, "unsupported baudrate
> request 0x%x," -			" using default of B9600\n", cflag); +
> dev_err(cs->dev, "unsupported baudrate request 0x%x,\ +				 using
> default of B9600\n", cflag);

This makes the message much less readable by inserting a long stretch
of whitespace after the comma.

In sum: NACK.

Regards,
Tilman

- --=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUpZYFAAoJEFPuqx0v+F+qEcsH/1yyu8A8tHPhiW60DzQWhCj7
kxKw7gUS24ATLEEl5jUmrua2xPM0Exg7FknBSYRmNmOEj8j3sl7mQ0dDzDcJgOgI
BaDXV5YqnnqppmYkdT7OMykAuhdt2rk1w4khc2EjyyKrAdGJyB+j3ROgRDtG0wsY
zI/Uz7yKe540cwVWc6VCNQvS7cVEasQZnJzzTGBcPW35RjTYpvWEieJ/yY3tphIe
TQRl+SrKgiwGuzi0p886Vk8Mu4cfHHO5/EXyzpVdMVg6wxwxNs+YeW5xRf/mjzQe
YyygRKUA4VtZTno/rabdA2QvLkdDMHoiUNYa0InmBpAlLVol8OLh5mTit9yozwY=3D
=3DuU+S
-----END PGP SIGNATURE-----
