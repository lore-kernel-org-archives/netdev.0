From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 23 Jul 2004 10:41:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090593676.1128.25.camel@jzny.localdomain>
References: <20040716103759.1928c2ae@dell_ss3.pdx.osdl.net>
	 <200407172357.15832.arekm@pld-linux.org>
	 <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	 <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: shemminger@osdl.org, "David S. Miller" <davem@redhat.com>,
        arekm@pld-linux.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-22 at 20:04, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> In article <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net> (at Thu, 22 =
Jul 2004 13:45:22 -0700), Stephen Hemminger <shemminger@osdl.org> says:
>=20
> > The recent changes to (6 Jul 04) pkt_cls.h are evil, you can't build =
a version
> > of 'tc' to work unless you know the kernel config!
> >=20
> > It has several API problems:
> >   - API data structures change on kernel config options
> >   - new fields should be added at the end of a structure to allow
> >     binary compatibility.
>     - We cannot add new variable(s) after the last member which is=20
>       an variable-length array in effect.

Agreed.=20
The enum types are easy to handle - we just keep adding to the end which
doesnt break any ABI (as long as we keep the enum types in the same spot
even if they are no longer being used).=20
For the data structures it does get tricky to augment as proposed above
because it does _break the ABI_.
In particular it gets tricky if someone is to debug why the policy they
are submitting is getting rejected. Maybe a sizeof check followed by a
debug printk would help.=20
Clearly even a sizeof is problematic in this case when keys[] is
variable which brings me to a slightly different topic:
One little proposal is to start adding versioning to some of the
important fields. I have done this for the netlink header so i could
figure if tc was broken. Dave is against this idea. His opinion is now
we will get a lot of idjots mod-ing the structures and  then bumping the
version numbers.=20
All the actions extensions actually have versioning fields.

Another related topic: tc SHOULD be able to probe configured kernel
options. It is a Good Thing to be able to do. Avoiding it as in this
patch is not the answer. I have some suggestions when i get time i will
speak with code. If someone wants this discussed we can continue on the
list.

> > @@ -229,11 +214,9 @@
> > =20
> >  	short			hoff;
> >  	__u32			hmask;
> > -#ifdef CONFIG_CLS_U32_PERF
> > +	struct tc_u32_key	keys[0];
> >  	unsigned long		rcnt;
> >  	unsigned long		rhit;
> > -#endif
> > -	struct tc_u32_key	keys[0];
> >  };
> > =20
> >  /* Flags */
>=20
> We cannot do this because keys holds key of variable length.

Yes - please change this.

> Solutions are, for example,
>  to allocate new TCA_U32_xxx for rcnt and rhit,
> or,=20
>  to rename TCA_U32_SEL to TCA_U32_OLS_SEL and allocate new value for=20
>  TCA_U32_SEL.


we could do this, but since we are already fscking the ABI it is not
valuable.

cheeers.
jamal
