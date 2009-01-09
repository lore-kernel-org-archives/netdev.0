From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 23:09:46 +0100
Message-ID: <20090109220946.GA4787@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <4967C95E.3070602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1344 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754048AbZAIWNO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 17:13:14 -0500
Content-Disposition: inline
In-Reply-To: <4967C95E.3070602@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 11:02:06PM +0100, Eric Dumazet wrote:
> Willy Tarreau a =E9crit :
> > On Fri, Jan 09, 2009 at 09:51:17PM +0100, Eric Dumazet wrote:
> > (...)
> >>> Also, in your second mail, you're saying that your change
> >>> might return more data than requested by the user. I can't
> >>> find why, could you please explain to me, as I'm still quite
> >>> ignorant in this area ?
> >> Well, I just tested various user programs and indeed got this
> >> strange result :
> >>
> >> Here I call splice() with len=3D1000 (0x3e8), and you can see
> >> it gives a result of 1460 at the second call.
> >=20
> > huh, not nice indeed!
> >=20
> > While looking at the code to see how this could be possible, I
> > came across this minor thing (unrelated IMHO) :
> >=20
> > 	if (__skb_splice_bits(skb, &offset, &tlen, &spd))
> > 		goto done;
> >>>>>>> 	else if (!tlen)    <<<<<<
> > 		goto done;
> >=20
> > 	/*
> > 	 * now see if we have a frag_list to map
> > 	 */
> > 	if (skb_shinfo(skb)->frag_list) {
> > 		struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
> >=20
> > 		for (; list && tlen; list =3D list->next) {
> > 			if (__skb_splice_bits(list, &offset, &tlen, &spd))
> > 				break;
> > 		}
> > 	}
> >=20
> >     done:
> >=20
> > Above on the enlighted line, we'd better remove the else and leave =
a plain
> > "if (!tlen)". Otherwise, when the first call to __skb_splice_bits()=
 zeroes
> > tlen, we still enter the if and evaluate the for condition for noth=
ing. But
> > let's leave that for later.
> >=20
> >> I suspect a bug in splice code, that my patch just exposed.
> >=20
> > I've checked in skb_splice_bits() and below and can't see how we ca=
n move
> > more than the requested len.
> >=20
> > However, with your change, I don't clearly see how we break out of
> > the loop in tcp_read_sock(). Maybe we first read 1000 then loop aga=
in
> > and read remaining data ? I suspect that we should at least exit wh=
en
> > ((struct tcp_splice_state *)desc->arg.data)->len =3D 0.
> >=20
> > At least that's something easy to add just before or after !desc->c=
ount
> > for a test.
> >=20
>=20
> I believe the bug is in tcp_splice_data_recv()

yes, see my other mail.

> I am going to test a new patch, but here is the thing I found:
>=20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index bd6ff90..fbbddf4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -523,7 +523,7 @@ static int tcp_splice_data_recv(read_descriptor_t=
 *rd_desc, struct sk_buff *skb,
>  {
>         struct tcp_splice_state *tss =3D rd_desc->arg.data;
>=20
> -       return skb_splice_bits(skb, offset, tss->pipe, tss->len, tss-=
>flags);
> +       return skb_splice_bits(skb, offset, tss->pipe, len, tss->flag=
s);
>  }

it will not work, len is always 1000 in your case, for every call,
as I had in my logs :

kernel :

tcp_splice_data_recv: skb=3Ded3d3480 offset=3D0 len=3D1460 tss->pipe=3D=
ed1cbc00 tss->len=3D1000 tss->flags=3D3
tcp_sendpage: going through do_tcp_sendpages
tcp_splice_data_recv: skb=3Ded3d3480 offset=3D1000 len=3D460 tss->pipe=3D=
ed1cbc00 tss->len=3D1000 tss->flags=3D3
tcp_splice_data_recv: skb=3Ded3d3540 offset=3D0 len=3D1460 tss->pipe=3D=
ed1cbc00 tss->len=3D1000 tss->flags=3D3
tcp_sendpage: going through do_tcp_sendpages
tcp_sendpage: going through do_tcp_sendpages
tcp_splice_data_recv: skb=3Ded3d3540 offset=3D1000 len=3D460 tss->pipe=3D=
ed1cbc00 tss->len=3D1000 tss->flags=3D3
tcp_splice_data_recv: skb=3Ded3d3600 offset=3D0 len=3D1176 tss->pipe=3D=
ed1cbc00 tss->len=3D1000 tss->flags=3D3
tcp_sendpage: going through do_tcp_sendpages
tcp_sendpage: going through do_tcp_sendpages
tcp_splice_data_recv: skb=3Ded3d3600 offset=3D1000 len=3D176 tss->pipe=3D=
ed1cbc00 tss->len=3D1000 tss->flags=3D3
tcp_sendpage: going through do_tcp_sendpages

program :

accept(3, 0, NULL)                      =3D 4
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) =3D 5
connect(5, {sa_family=3DAF_INET, sin_port=3Dhtons(4001), sin_addr=3Dine=
t_addr("10.0.3.1")}, 16) =3D 0
fcntl64(4, F_SETFL, O_RDONLY|O_NONBLOCK) =3D 0
fcntl64(5, F_SETFL, O_RDONLY|O_NONBLOCK) =3D 0
pipe([6, 7])                            =3D 0
select(6, [5], [], NULL, NULL)          =3D 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 1000
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x3e8, 0x3)      =3D 1000
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 1460
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x5b4, 0x3)      =3D 1460
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 1460
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x5b4, 0x3)      =3D 1460
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 176
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0xb0, 0x3)       =3D 176
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D -1 EAGAIN (Resource tempora=
rily unavailable)
close(5)                                =3D 0
close(4)                                =3D 0
exit_group(0)                           =3D ?


Now with the fix :

accept(3, 0, NULL)                      =3D 4
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) =3D 5
connect(5, {sa_family=3DAF_INET, sin_port=3Dhtons(4001), sin_addr=3Dine=
t_addr("10.0.3.1")}, 16) =3D 0
fcntl64(4, F_SETFL, O_RDONLY|O_NONBLOCK) =3D 0
fcntl64(5, F_SETFL, O_RDONLY|O_NONBLOCK) =3D 0
pipe([6, 7])                            =3D 0
select(6, [5], [], NULL, NULL)          =3D 1 (in [5])
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 1000
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x3e8, 0x3)      =3D 1000
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 1000
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x3e8, 0x3)      =3D 1000
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 1000
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x3e8, 0x3)      =3D 1000
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 1000
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x3e8, 0x3)      =3D 1000
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D 96
select(6, [5], [4], NULL, NULL)         =3D 2 (in [5], out [4])
splice(0x6, 0, 0x4, 0, 0x60, 0x3)       =3D 96
splice(0x5, 0, 0x7, 0, 0x3e8, 0x3)      =3D -1 EAGAIN (Resource tempora=
rily unavailable)
close(5)                                =3D 0
close(4)                                =3D 0
exit_group(0)                           =3D ?


Regards,
Willy

