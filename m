From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: BUG in xennet_make_frags with paged skb data
Date: Fri, 07 Nov 2014 12:08:19 +0100
Message-ID: <545CA823.2080307@canonical.com>
References: <20141106214940.GD44162@ubuntu-hedt> <545CA27F.4070400@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="bCvbWEJMulW7EirtrJbTqmj5j1SVXs2Fc"
To: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <545CA27F.4070400@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bCvbWEJMulW7EirtrJbTqmj5j1SVXs2Fc
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07.11.2014 11:44, David Vrabel wrote:
> On 06/11/14 21:49, Seth Forshee wrote:
>> We've had several reports of hitting the following BUG_ON in
>> xennet_make_frags with 3.2 and 3.13 kernels (I'm currently awaiting
>> results of testing with 3.17):
>>
>>         /* Grant backend access to each skb fragment page. */
>>         for (i =3D 0; i < frags; i++) {
>>                 skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
>>                 struct page *page =3D skb_frag_page(frag);
>>
>>                 len =3D skb_frag_size(frag);
>>                 offset =3D frag->page_offset;
>>
>>                 /* Data must not cross a page boundary. */
>>                 BUG_ON(len + offset > PAGE_SIZE<<compound_order(page))=
;
>>
>> When this happens the page in question is a "middle" page in a compoun=
d
>> page (i.e. it's a tail page but not the last tail page), and the data =
is
>> fully contained within the compound page. The data does however cross
>> the hardware page boundary, and since compound_order evaluates to 0 fo=
r
>> tail pages the check fails.
>>
>> In going over this I've been unable to determine whether the BUG_ON in=

>> xennet_make_frags is incorrect or the paged skb data is wrong. I can't=

>> find that it's documented anywhere, and the networking code itself is =
a
>> bit ambiguous when it comes to compound pages. On the one hand
>> __skb_fill_page_desc specifically handles adding tail pages as paged
>> data, but on the other hand skb_copy_bits kmaps frag->page.p which cou=
ld
>> fail with data that extends into another page.
>=20
> netfront will safely handle this case so you can remove this BUG_ON()
> (and the one later on).  But it would be better to find out were these
> funny-looking skbs are coming from and (if necessary) fixing the bug th=
ere.

Right, in fact it does ignore pages from the start of a compound page in =
case
the offset is big enough. So there is no difference between that case and=
 the
one where the page pointer from the frag is adjusted the way it was obser=
ved.

It really boils down to the question what the real rules for the frags ar=
e. If
it is "only" that data may not cross the boundary of a hw or compound pag=
e this
leaves room for interpretation. The odd skb does not violate that but a c=
heck
for conformance would become a lot more complex. And netfront is not the =
only
place that expects the frag page to be pointing to the compound head (the=
re is
igb for example, though it does only a warn_on upon failing).

On the other hand the __skb_fill_page_desc is written in a way that seems=
 to
assume the frag page pointer may be pointing to a tail page. So before "b=
laming"
one piece of code or the other we need an authoritative answer to what we=
 are
supposed to expect.

-Stefan
>=20
> David
>=20



--bCvbWEJMulW7EirtrJbTqmj5j1SVXs2Fc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUXKgjAAoJEOhnXe7L7s6jv00P/1h8nZmWti/L+ueiOit/Uv/u
2sBrwRi96T+9pi9dEFuDZruPCOqWEBcRjQnkdmL0Id0PwjjLwNd+pKfQuOgpGDmp
9GA1yO+yxFikHEgILlmPcvdEwAvMnRhm5BuBtthYuuJ+eWcKQfWJXswVB+769Vy+
hTYp01pqWay7XP5LMntzz7ZtShC3exOXs5nX1R/BmkxDWlm0WxlI/ALCmNCfuvpx
RkA3wfVHqC/azyzOiuyI+82MAx/0dah2kJddKbvwUr7oC3JYrCt+asOg19nB7RML
5505YPdp79SRB5vZa/bMS8QWh8x+xA5iVcTdbJxGGKix9Ms+OHk1KYC+qqKwm/yS
VdjQ5MJlp5woGDGtl04ExyOw1NXaqaMidExGktq7rl528wtn05tvn3PT6W7LdpwM
fook6Qs56Z6F+EVi1ZTY03d4aqp5NKhb5bFaKBsDJCtz+NpOSYxwa0BQZICYnKXy
ZXj8gN0s7dd9FfxGq+AVd5JKaXT18MxpIPW+pIw83ZL2QblH02L4imf9Lo5BkV7Z
0luMQMN3rsXNqINrbOa/JTrEyJwn0V2D4UwOrdJrsqN6Q1mx3Sqaa2QhVNYbBAtb
CdY8SyicB3sD8UaVlHqTB1jb2F6klst5ZTftxyDC9GT/088Zjb5AEqyeCUpItuI+
590GautyGVnF60sEHMK4
=VJCZ
-----END PGP SIGNATURE-----

--bCvbWEJMulW7EirtrJbTqmj5j1SVXs2Fc--
