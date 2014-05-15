From: Kirill Tkhai <ktkhai@parallels.com>
Subject: Re: net: unix: Align send data_len up to PAGE_SIZE
Date: Thu, 15 May 2014 12:54:40 +0400
Message-ID: <1400144080.3782.23.camel@tkhai>
References: <1399906332.31472.1.camel@tkhai>
	 <20140514.151504.1740922429122469259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:37777 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbaEOIyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 04:54:44 -0400
In-Reply-To: <20140514.151504.1740922429122469259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D0=A1=D1=80, 14/05/2014 =D0=B2 15:15 -0400, David Miller =D0=BF=
=D0=B8=D1=88=D0=B5=D1=82:
> From: Kirill Tkhai <ktkhai@parallels.com>
> Date: Mon, 12 May 2014 18:52:12 +0400
>=20
> >  		data_len =3D min_t(size_t,
> >  				 len - SKB_MAX_ALLOC,
> >  				 MAX_SKB_FRAGS * PAGE_SIZE);
> > +		data_len =3D min_t(size_t,
> > +				 len,
> > +				 PAGE_ALIGN(data_len));
> > +	}
>=20
> When I see:
>=20
> 		x =3D min(y - N, z1);
> 		x =3D min(y, z2);
>=20
> I'm a bit suspicious.  Why are you not subtracting the constant
> factor out of the first variable in the second min() call?

Because, in the most cases (len - SKB_MAX_ALLOC) < PAGE_ALIGN(data_len)=
,
and the only payload of the patch is it tries to fix that :)
We use unused space of allocated page. For mem cache it's easier
to allocate

(len - PAGE_ALIGN(x)) than (len - x).


Here really should be=20

 		data_len =3D min_t(size_t,
 				 len - SKB_MAX_ALLOC,
 				 MAX_SKB_FRAGS * PAGE_SIZE);
+		data_len =3D PAGE_ALIGN(data_len));


I added the second min, because I was afraid somebody plays with
SKB_MAX_ALLOC size in debug purposes. Not sure now.

Ok, yes, simple PAGE_ALIGN is much better :)

+ data_len =3D PAGE_ALIGN(data_len));

And I assumed it's OK to allocate skbs with zero header size like this:

sock_alloc_send_pskb(sk, 0, data_len)

Please say, if it's wrong.

Thanks!
Kirill
