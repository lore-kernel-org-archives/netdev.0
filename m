From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/4 - 2.6.15]net: 32 bit (socket layer) ioctl emulation for 64 bit kernels
Date: Fri, 13 Jan 2006 11:46:47 +0000
Message-ID: <200601131146.48128.arnd@arndb.de>
References: <1137045732.5221.21.camel@spereira05.tusc.com.au> <200601121924.02747.arnd@arndb.de> <1137122079.5589.34.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Andi Kleen <ak@muc.de>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, SP <pereira.shaun@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161255AbWAMLrZ@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1137122079.5589.34.camel@spereira05.tusc.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 January 2006 03:14, Shaun Pereira wrote:
> Thank you for reviewing that bit of code. =A0
> I had a look at compat_sys_gettimeofday and sys32_gettimeofday codes.
> They seem to work in a similar way, casting a pointer to the structur=
e
> from user space to a compat_timeval type.

The part with the case is ok, except that you don't have to write

struct compat_timeval __user *ctv;
ctv =3D (struct compat_timeval __user*) userstamp;

Instead,

struct compat_timeval __user *ctv =3D userstamp;

is the more common way to write it. The result is the same, since
userstamp is a 'void __user *'.

> But to make sure I have tested the routine by forcing the sk-
> >sk_stamp.tv_sec value to 0 in the x25_module ( for testing purposes
> only, as it is initialised to -1). Now when
> I make a 32 bit userspace SIOCGSTAMP ioctl to the 64 bit kernel I sho=
uld
> get the current time back in user space. This seems to work, the ioct=
l
> returns the system time (just after TEST6:)
>=20
> So I have left the patch as is for now. However if necessary to use
> the element-by-element __put_user routine as in put_tv32, then I can
> make the change, just let me know.

You need to to exactly that, yes. I'm not sure what exactly you have
tested, but the expected result of your code would be that you see
the sk_stamp.tv_sec value in the output, but not the tv_usec value.

On little-endian system like x86_64, that is not much of a difference
(less than a second) that you might miss in a test case, but on
big-endian, it would be fatal.

The layout of the structures on most systems is=20

		64 bit LE	64 bit BE	32 bit

bytes 0-3	tv_sec low	tv_sec high	tv_sec low
bytes 4-7	tv_sec high	tv_sec low	tv_usec low
bytes 8-11	tv_usec low	tv_usec high
bytes 12-15	tv_usec high	tv_usec low

You code copies the first eight bytes of the 64 bit data structure
into the 32 bit data structure.

	Arnd <><
