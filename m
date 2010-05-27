From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: boot crash in arp_error_report() (Re: [GIT] Networking)
Date: Thu, 27 May 2010 21:47:17 +0200
Message-ID: <1274989637.2446.1.camel@edumazet-laptop>
References: <20100525.165945.39198480.davem@davemloft.net>
	 <20100527190652.GA20303@elte.hu>
	 <alpine.LFD.2.00.1005271213091.3689@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1005271213091.3689@i5.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 27 mai 2010 =C3=A0 12:27 -0700, Linus Torvalds a =C3=A9crit :
>=20
> On Thu, 27 May 2010, Ingo Molnar wrote:
> >=20
> > FYI, this boot crash in arp_error_report() started triggering in -t=
ip testing:
> >=20
> > [  113.285384] BUG: unable to handle kernel paging request at 6b6b6=
b87
>=20
> That's the POISON_FREE signature, with an offset of 28 (0x1c).
>=20
> And it looks like the whole function got captured in the Code: sequen=
ce.=20
> It looks like this:
>=20
>    0:	55                   	push   %ebp
>    1:	89 e5                	mov    %esp,%ebp
>    3:	53                   	push   %ebx
>    4:	0f 1f 44 00 00       	nopl   0x0(%eax,%eax,1)
>    9:	89 d3                	mov    %edx,%ebx
>    b:	89 d0                	mov    %edx,%eax
>    d:	e8 fa fb ff ff       	call   0xfffffc0c		# skb_dst()
>   12:	85 c0                	test   %eax,%eax		# dst
>   14:	74 12                	je     0x28
>   16:	8b 40 40             	mov    0x40(%eax),%eax		# dst->ops
>   19:	85 c0                	test   %eax,%eax
>   1b:	74 0b                	je     0x28
>   1d:*	8b 50 1c             	mov    0x1c(%eax),%edx     <-- trapping =
instruction
>   20:	85 d2                	test   %edx,%edx
>   22:	74 04                	je     0x28
>   24:	89 d8                	mov    %ebx,%eax
>   26:	ff d2                	call   *%edx			# dst->ops->link_failure()
>   28:	89 d8                	mov    %ebx,%eax
>   2a:	e8 9b 50 fa ff       	call   0xfffa50ca		# skb_free()
>   2f:	5b                   	pop    %ebx
>   30:	5d                   	pop    %ebp
>   31:	c3                   	ret   =20
>=20
> Where most of it is "dst_link_failure()" being inlined (that last "ca=
llq"=20
> is the call to kfree_skb().
>=20
> Looks like 'dst' points to free'd memory, so when we load a pointer f=
rom=20
> it (the dst->ops) field, we get 0x6b6b6b6b, and then when we try to l=
oad
> dst->ops->link_failure it oopses.
>=20
> tl;dr: that
>=20
> 	struct dst_entry *dst =3D skb_dst(skb);
>=20
> in dst_link_failure seems to result in a stale skb.
>=20
> 		Linus
> --

I am looking at this bug report, as I am probably at fault, please give
me one or two hour ;)

Thanks
