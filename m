From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() page recycling
Date: Sun, 04 Dec 2011 19:27:18 +0100
Message-ID: <4EDBBB86.8050406@gmail.com>
References: <1323018317.2762.143.camel@edumazet-laptop> <1323019253.1785.7.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:44173 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932Ab1LDS1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:27:14 -0500
Received: by wgbds13 with SMTP id ds13so5157783wgb.1
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 10:27:13 -0800 (PST)
In-Reply-To: <1323019253.1785.7.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/12/2011 18:20, Joe Perches a =C3=A9crit :
> On Sun, 2011-12-04 at 18:05 +0100, Eric Dumazet wrote:
>> If our TCP_PAGE(sk) is not shared (page_count() =3D=3D 1), we can se=
t page
>> offset to 0.
> []
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> []
>> @@ -1009,7 +1009,12 @@ new_segment:
>>   				int merge =3D 0;
>>   				int i =3D skb_shinfo(skb)->nr_frags;
>>   				struct page *page =3D TCP_PAGE(sk);
>> -				int off =3D TCP_OFF(sk);
>> +				int off;
>> +
>> +				if (page&&  page_count(page) =3D=3D 1)
>> +					TCP_OFF(sk) =3D 0;
>> +
>> +				off =3D TCP_OFF(sk);
>
> This might be clearer and take one less indirection as
>
> 				if (page&&  page_count(page) =3D=3D 1) {
> 					TCP_OFF(sk) =3D 0;
> 					off =3D 0;
> 				} else {
> 					off =3D 0;
> 				}
>
> or maybe
>
> 				if (page&&  page_count(page) =3D=3D 1)
> 					off =3D TCP_OFF(sk) =3D 0;
> 				else
> 					off =3D 0;

Well, those two fragments don't look equivalent to the original one, un=
less TCP_OFF(sk) happens to=20
be 0 before the test. But if this is true, then the whole thing seems u=
seless. Do I miss something?

=46or as far as I understand, the following should be equivalent to Eri=
c's original, but I don't=20
consider it better than the original.

  				if (page&&  page_count(page) =3D=3D 1)
  					off =3D TCP_OFF(sk) =3D 0;
  				else
  					off =3D TCP_OFF(sk);

	Nicolas.
