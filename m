From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Thu, 15 May 2014 14:14:00 +0200
Message-ID: <5374AF88.2070608@canonical.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com> <1400143605.1006.1.camel@kazak.uk.xensource.com> <20140515110410.GD1117@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="x723IHkWpHrDgjrvnPhI0FP12DtHpwvpB"
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	xen-devel@lists.xenproject.org, netdev <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39037 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbaEOMOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 08:14:05 -0400
In-Reply-To: <20140515110410.GD1117@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--x723IHkWpHrDgjrvnPhI0FP12DtHpwvpB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 15.05.2014 13:04, Wei Liu wrote:
> On Thu, May 15, 2014 at 09:46:45AM +0100, Ian Campbell wrote:
>> On Wed, 2014-05-14 at 20:49 +0100, Zoltan Kiss wrote:
>>> On 13/05/14 19:21, Stefan Bader wrote:
>>>> We had reports about this message being seen on EC2 for a while but =
finally a
>>>> reporter did notice some details about the guests and was able to pr=
ovide a
>>>> simple way to reproduce[1].
>>>>
>>>> For my local experiments I use a Xen-4.2.2 based host (though I woul=
d say the
>>>> host versions are not important). The host has one NIC which is used=
 as the
>>>> outgoing port of a Linux based (not openvswitch) bridge. And the PV =
guests use
>>>> that bridge. I set the mtu to 9001 (which was seen on affected insta=
nce types)
>>>> and also inside the guests. As described in the report one guests ru=
ns
>>>> redis-server and the other nodejs through two scripts (for me I had =
to do the
>>>> two sub.js calls in separate shells). After a bit the error messages=
 appear on
>>>> the guest running the redis-server.
>>>>
>>>> I added some debug printk's to show a bit more detail about the skb =
and got the
>>>> following (<length>@<offset (after masking off complete pages)>):
>>>>
>>>> [ 698.108119] xen_netfront: xennet: skb rides the rocket: 19 slots
>>>> [ 698.108134] header 1490@238 -> 1 slots
>>>> [ 698.108139] frag #0 1614@2164 -> + 1 pages
>>>> [ 698.108143] frag #1 3038@1296 -> + 2 pages
>>>> [ 698.108147] frag #2 6076@1852 -> + 2 pages
>>>> [ 698.108151] frag #3 6076@292 -> + 2 pages
>>>> [ 698.108156] frag #4 6076@2828 -> + 3 pages
>>>> [ 698.108160] frag #5 3038@1268 -> + 2 pages
>>>> [ 698.108164] frag #6 2272@1824 -> + 1 pages
>>>> [ 698.108168] frag #7 3804@0 -> + 1 pages
>>>> [ 698.108172] frag #8 6076@264 -> + 2 pages
>>>> [ 698.108177] frag #9 3946@2800 -> + 2 pages
>>>> [ 698.108180] frags adding 18 slots
>>>>
>>>> Since I am not deeply familiar with the networking code, I wonder ab=
out two things:
>>>> - is there something that should limit the skb data length from all =
frags
>>>>    to stay below the 64K which the definition of MAX_SKB_FRAGS hints=
?
>>> I think netfront should be able to handle 64K packets at most.
>>
>> Ah, maybe this relates to this fix from Wei?
>>
>=20
> Yes, below patch limits SKB size to 64KB.  However the problem here is
> not SKB exceeding 64KB. The said SKB is acutally 43KB in size. The
> problem is that guest kernel is  using compound page so a frag which ca=
n
> be fit into one 4K page spans two 4K pages.  The fix seems to be
> coalescing SKB in frontend, but it will degrade performance.
>=20
> Wei.
>=20
Reading more of the code I would agree. The definition of MAX_SKB_FRAGS (=
at
least now with compound pages) cannot be used in any way to derive the nu=
mber of
4k slots a transfer will require.

Zoltan already commented on worst cases. Not sure it would get as bad as =
that or
"just" 16*4k frags all in the middle of compound pages. That would then e=
nd in
around 33 or 34 slots, depending on the header.

Zoltan wrote:
> I think the worst case scenario is when every frag and the linear buffe=
r contains 2 bytes,
> which are overlapping a page boundary (that's (17+1)*2=3D36 so far), pl=
us 15 of
them have a 4k
> page in the middle of them, so, a 1+4096+1 byte buffer can span over 3 =
page.
> That's 51 individual pages.

I cannot claim to really know what to expect worst case. Somewhat I was t=
hinking
of a
worst case of (16+1)*2, which would be inconvenient enough.

So without knowing exactly how to do it, but as Ian said it sounds best t=
o come
up with some sort of exception coalescing in cases the slot count goes ov=
er 18
and we know the data size is below 64K.

-Stefan



--x723IHkWpHrDgjrvnPhI0FP12DtHpwvpB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTdK+IAAoJEOhnXe7L7s6j2AwP/i7ZH1U+JkBvrYqk2HqTapYV
RjByc5k2fz+rbcUivzO5yArO4UFQ2qZ5S3dAoA8GrOhciKxGGAWzibx+65AzmsqV
4iCGjaFLe3OVkXV29rxbeYbjcuYzRyQqI0JW/gDVJeLThuICa7iGUdUk8Lk9/hNu
kFTDkK5mqvJJR9CygMYS78zLK6Na6N+7ZC0GzVFTMaagzKkKzDQ0Dho4gliLPkZh
Zc6rQxWLBb8o+4avqLJtyY1Tfh09vTrojiDHnlMTNsrjE5nkfo31ZHhUANBpZTJ9
mm+FrpMT9JxKxld9X06kofYUy5dWq0pkB0SubWJ6pIGDkAl0GR0ZLNh2oZwaIec2
m+7W8qzrmpWonUayiQBOI1NYJcBuNXvY7zzliABQuOl5XxGxKP6uukxpnITHj//w
3+WBOCngjgQNpMS6Nc7AT9Zfnjc8TI+3HhekOVHmhBC5mPXhyv8PIvHXq1KGC/XZ
CCGCzHkfgYDkSnM238hXkSz8/1KOtPn/Zn4vkfLQOEU7wekWba/Ncf12KLJtsDuf
IILC004xssM3iBPjH019tneGEK90FFsgwaukINRW+rfQiyU/4CsimK/K39E6v9c6
I6TQ7ZiBevUB7UZLUjK7t3g798AOgn3RWa/QK2kVR6DMy7OdgvzYhnLK5GFN4zqr
8FdniLX9eHIKjBU/zW6K
=q0E6
-----END PGP SIGNATURE-----

--x723IHkWpHrDgjrvnPhI0FP12DtHpwvpB--
