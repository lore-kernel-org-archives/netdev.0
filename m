From: Matthew Wilcox <willy@debian.org>
Subject: Re: [Kernel-janitors] Fw: [CHECKER] Probable security holes in 2.6.5
Date: Fri, 16 Apr 2004 19:00:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416180031.GK18329@parcelfarce.linux.theplanet.co.uk>
References: <20040416141827.6e38cd14.lcapitulino@prefeitura.sp.gov.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: kernel-janitors@lists.osdl.org, cramerj@intel.com, scott.feldman@intel.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luiz Fernando N. Capitulino" <lcapitulino@prefeitura.sp.gov.br>
Content-Disposition: inline
In-Reply-To: <20040416141827.6e38cd14.lcapitulino@prefeitura.sp.gov.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 16, 2004 at 02:18:27PM -0300, Luiz Fernando N. Capitulino wro=
te:
> In=EDcio da mensagem encaminhada:
>=20
> Date: Fri, 16 Apr 2004 10:01:57 -0700
> From: Ken Ashcraft <ken@coverity.com>
> To: linux-kernel@vger.kernel.org
> Cc: mc@cs.stanford.edu
> Subject: [CHECKER] Probable security holes in 2.6.5
>=20
> The error reports below are sorted roughly by their severity.  The last
> 12 of the errors are fairly minor because they are either protected by =
a
> capable() check or the scalar is only 8 bits.  I also consider it to be
> a minor error to pass an unchecked value to kmalloc().  I realize that
> kmalloc() will fail when asked for more than 128k, but it may not be
> appropriate to allow the user to allocate that much memory.  All of
> these minor errors will be marked by [MINOR] and/or [CAPABLE] tags in
> the error report.
>=20
> ---------------------------------------------------------
> [BUG]
> /home/kash/linux/linux-2.6.5/drivers/net/e1000/e1000_ethtool.c:1494:e10=
00_ethtool_ioctl: ERROR:TAINT: 1487:1494:Passing unbounded user value "(r=
egs).len" as arg 2 to function "copy_to_user", which uses it unsafely in =
model [SOURCE_MODEL=3D(lib,copy_from_user,user,taintscalar)] [SINK_MODEL=3D=
(lib,copy_to_user,user,trustingsink)]    [PATH=3D]=20
> 	}
> 	case ETHTOOL_GREGS: {
> 		struct ethtool_regs regs =3D {ETHTOOL_GREGS};
> 		uint32_t regs_buff[E1000_REGS_LEN];
>=20
> Start --->
> 		if(copy_from_user(&regs, addr, sizeof(regs)))
> 			return -EFAULT;
> 		e1000_ethtool_gregs(adapter, &regs, regs_buff);
> 		if(copy_to_user(addr, &regs, sizeof(regs)))
> 			return -EFAULT;
>=20
> 		addr +=3D offsetof(struct ethtool_regs, data);
> Error --->
> 		if(copy_to_user(addr, regs_buff, regs.len))
> 			return -EFAULT;
>=20
> 		return 0;

This one is probably best fixed by converting the e1000 driver to use
ethtool_ops which does all the user-access stuff in generic code and
gets looked at by dozens more people than a driver does.  cc'ing the
e1000 people on this in case they want to do it themselves.

--=20
"Next the statesmen will invent cheap lies, putting the blame upon=20
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince=20
himself that the war is just, and will thank God for the better sleep=20
he enjoys after this process of grotesque self-deception." -- Mark Twain
