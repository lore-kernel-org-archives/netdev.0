From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH net-next 3/3] vxlan: allow multiple VXLANs with same VNI
 for IPv6 link-local addresses
Date: Wed, 15 Mar 2017 15:29:29 +0100
Message-ID: <1542ef1a-4bc2-d142-1910-0583c3c543a6@universe-factory.net>
References: <cover.1489184335.git.mschiffer@universe-factory.net>
 <5c74248483272110d0ca249b80b943b0ceb0b610.1489184335.git.mschiffer@universe-factory.net>
 <20170314162815.7aae9e94@griffin>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="3A0G9WHNefdjwO6mRbf880AUgG7NP8WTI"
Cc: davem@davemloft.net, hannes@stressinduktion.org, pshelar@ovn.org,
        aduyck@mirantis.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314162815.7aae9e94@griffin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3A0G9WHNefdjwO6mRbf880AUgG7NP8WTI
Content-Type: multipart/mixed; boundary="V8PLdBuoDoaebTm16EogSmNd7MeWmarRS";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer@universe-factory.net>
To: Jiri Benc <jbenc@redhat.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org, pshelar@ovn.org,
 aduyck@mirantis.com, roopa@cumulusnetworks.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-ID: <1542ef1a-4bc2-d142-1910-0583c3c543a6@universe-factory.net>
Subject: Re: [PATCH net-next 3/3] vxlan: allow multiple VXLANs with same VNI
 for IPv6 link-local addresses
References: <cover.1489184335.git.mschiffer@universe-factory.net>
 <5c74248483272110d0ca249b80b943b0ceb0b610.1489184335.git.mschiffer@universe-factory.net>
 <20170314162815.7aae9e94@griffin>
In-Reply-To: <20170314162815.7aae9e94@griffin>

--V8PLdBuoDoaebTm16EogSmNd7MeWmarRS
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/14/2017 04:28 PM, Jiri Benc wrote:
> On Fri, 10 Mar 2017 23:39:44 +0100, Matthias Schiffer wrote:
>> @@ -233,17 +234,30 @@ static struct vxlan_dev *vxlan_vs_find_vni(struc=
t vxlan_sock *vs, __be32 vni)
>>  		vni =3D 0;
>> =20
>>  	hlist_for_each_entry_rcu(vxlan, vni_head(vs, vni), hlist) {
>> -		if (vxlan->default_dst.remote_vni =3D=3D vni)
>> -			return vxlan;
>> +		if (vxlan->default_dst.remote_vni !=3D vni)
>> +			continue;
>> +
>> +		if (IS_ENABLED(CONFIG_IPV6)) {
>> +			const struct vxlan_config *cfg =3D &vxlan->cfg;
>> +
>> +			if (cfg->remote_ifindex !=3D 0 &&
>> +			    cfg->remote_ifindex !=3D ifindex &&
>> +			    cfg->saddr.sa.sa_family =3D=3D AF_INET6 &&
>> +			    (ipv6_addr_type(&cfg->saddr.sin6.sin6_addr) &
>> +			     IPV6_ADDR_LINKLOCAL))
>=20
> Calculating this (especially ipv6_addr_type) on every received packet
> looks unnecessarily expensive. Just store the fact the the local
> address is link-local in a flag during config. And compare the flag
> first before considering remote_ifindex.
>=20
> This is especially important for lwtunnels which can have anything in
> the saddr and remote_ifindex, yet those fields are ignored and the
> vni 0 entry has to be returned. It also means that the link-local flag
> must not be set for lwtunnels.
>=20
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +		if (conf->remote_ifindex !=3D tmp->cfg.remote_ifindex &&
>> +		    conf->saddr.sa.sa_family =3D=3D AF_INET6 &&
>> +		    tmp->cfg.saddr.sa.sa_family =3D=3D AF_INET6 &&
>> +		    (ipv6_addr_type(&conf->saddr.sin6.sin6_addr) &
>> +		     IPV6_ADDR_LINKLOCAL) &&
>> +		    (ipv6_addr_type(&tmp->cfg.saddr.sin6.sin6_addr) &
>> +		     IPV6_ADDR_LINKLOCAL))
>> +			continue;
>> +#endif
>=20
> In patch 1, you're checking for either source and destination address
> being link-local, while here you're consider only those that have both
> addresses link-local.
>=20
> Wouldn't it be better to plainly reject configuration that has one
> address link-local but not the other one?

While ensuring that the destination address is link-local iff the source
address is would also be an option, it didn't seem too useful as the
destination address will be a multicast address anyways in "normal" VXLAN=

configurations. If we really want to check this, I guess the valid
combinations are:

source link-local - destination link-local UC
source link-local - destination link-local MC
source global/... - destination global/... UC
source global/... - destination any MC

Does this make sense?


>=20
>  Jiri

Thanks for your comments, I'll send a v2 soon.

Matthias





--V8PLdBuoDoaebTm16EogSmNd7MeWmarRS--

--3A0G9WHNefdjwO6mRbf880AUgG7NP8WTI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEZmTnvaa2aYgexS51Fu8/ZMsgHZwFAljJT8oACgkQFu8/ZMsg
HZyMEhAAzBRnKYNDUhubbaeaxITSfIjDrNwQPfHpgyFK7IRccr3WCtCHb4xFEil2
ScPSlbggr1iRzSCeR/AN0SzBQ0KGnvWbaT8PcmAwbqIFmClFXmdpqzoEgTuHrE6X
wO/JT5E2Nkiq41JlQ58SVRafMTb5qvGPxUQrLLUwQEcZ/2i48MHBv9JB1MQVkdP0
OC7zr8r+KBaHDFcHGpGJ09B5GTOyobaG9jlIsgkXF7mV3RxL7ECADKAh6UnYhCOq
nRu0UDF9eBXQWFM9meS7Al40i/EEkrv1dAKw70nO4z0bOfkL2tapBKEmusHvpZ6m
uvw1IbAJBkJcArwUowtttNMzLrsay6wPGtqvgCI0H/c76QQ80+zwS4FaZcbnB2Q+
8gkQ7tSfM5DvDfARqEc/0hzfGAjcwsXBqC5rFOLAih6DKnCUWcD6lsrFdv8mIs3t
kdccAVf7Lb2SXjK7hIatXkjzyqWh3mZxhafhffEfAIWys5s2Fon+KLDwYP+ZHnO7
cvhQEIBBDjG8/87zZyIw2qRka60EWbfOFhCTgt36sdQS+ZXSCUreERNJRNVf6uyV
vtsPH2m2jGobxDjqQ3WwaNRWemI7YTGuAdbFK25EhGD115YU+Qg9oOlJ8fUo8cGT
ZZtg7yzu3yo8pbQTsnPab1oD8yj8ysBFtkf1Wpor2Idf0ORbEYk=
=EQRF
-----END PGP SIGNATURE-----

--3A0G9WHNefdjwO6mRbf880AUgG7NP8WTI--
