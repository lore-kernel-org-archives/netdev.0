From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: error handling for dev_mc_sync (__dev_addr_add)
Date: Tue, 09 Jun 2009 16:43:26 +0200
Message-ID: <1244558606.4672.25.camel@johannes.local>
References: <1244556667.4672.18.camel@johannes.local>
	 <4A2E7376.4080407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-DS7B8XMvZJ+cOIceFxZ7"
Cc: netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:42411 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbZFIOn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 10:43:59 -0400
In-Reply-To: <4A2E7376.4080407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DS7B8XMvZJ+cOIceFxZ7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-06-09 at 16:36 +0200, Patrick McHardy wrote:
> Johannes Berg wrote:
> > I can't seem to figure out how to handle errors from dev_mc_sync(). I
> > can see why it fails, looking at __dev_addr_add(), because memory
> > allocations can fail. However, it seems that __dev_addr_sync() will the=
n
> > leave the netdev in a state where some addresses were added, but others
> > were not. And ndo_set_multicast_list() cannot even return an error code=
.
> >=20
> > So how am I supposed to handle the error? Isn't it possible that
> > dev_mc_unsync() will then cause trouble because it removes something
> > that wasn't actually added? OTOH, there always is da->synced, but then
> > __dev_addr_sync() confuses me -- why does it not increment da->da_users=
?
>=20
> It does:
>=20
> 	if (!da->da_synced) {
> 		err =3D __dev_addr_add(to, to_count,
> 				     da->da_addr, da->da_addrlen, 0);
> 		if (err < 0)
> 			break;
> 		da->da_synced =3D 1;
> 		da->da_users++;
>=20
> The problem on errors is that it can't determine which addresses
> were added in this run, and which were previously. So it can't undo
> just the actions of the last run. A generation count for da_synced
> could be used to fix that, but it would need to be bigger than the
> currently used u8.

Hmm, ok, but in the da_synced case why is da_users not incremented? I
don't claim to understand any of this code though :)

> But that wouldn't fix the fundamental problem that almost no callers
> of dev_mc_add checks for errors, so even if you abort and clean up
> properly, the higher layers will take it as success and not retry.

True. Well, dev_mc_add() isn't exactly called a lot.

> > Basically what I need is the patch below to maintain a multicast list,
> > but I'm wondering if it's all correct that way and what error handling =
I
> > need and am currently lacking if I ignore the return value of
> > dev_mc_sync().
>=20
> Adding proper error handling looks like a bigger task. First we
> need all the callers of multicast address manipulation functions
> to actually check the return value and perform some kind of
> recovery on failure - which might not be possible in all cases,
> I'm not sure (IPv6).=20

Right.

> Then we need to be able to propagate errors
> from ->set_multicast_list() and abort address list changes when
> synchronization fails - which is not particulary complicated, but
> requires touching a lot of drivers.

I think you're overstating? Regular drivers should need to be changed,
would they, except for adding changing 'return' to 'return 0;' and
adding a 'return 0;' at the end which is a quite simple spatch I'd
think.

Not that I want to do that now, I'm just confused by the semantics here,
and the lack of error handling. Additionally, I'm worried if that might
be causing the occasional 'multicast leaked' messages I was seeing, but
I doubt it.

johannes

--=-DS7B8XMvZJ+cOIceFxZ7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKLnULAAoJEODzc/N7+Qma4SQP/0Xy9sun9RPEOlG394LFLJTj
hPkxv+HusmCm450K726Orz0I4nW5YQPtgCkqg0ViiVoRcObbRKG7yyhAfQQcJTjr
hM5+omY/yBSb0J9Qlu4MLgYu8b2gbUySrKOVub56f2AXBx9yDKzVx4v6ZeyQFElN
7aX+LMTBnWSI+d4qNzrjx4K4p+UWlK3s2QFXYrPoR/LerhabufjNVEQ8exsJhS01
j+CN13LxZAf1BZqOP2qhRxepdMVsTWJRyBsHMxSmVQbAH/kv+ZoW2FeRSJr7GXGR
9/avjkrtEkmY/HBXra3ZUBtIYKbQaa3o03uwTsp0+XEgxA4qnKer5waF9XCxCRcY
g9QKpHJ5SBLuNvCKxmJgGIs4vVr+pIkKUgncOArxN72QJUk3xxZQF2Sx2S4mMKgc
qqiNrHddFz98id5e07GHp1s4vHSRkDHjEBqSpHnrMyCAZ2lLSFQlCss2o2wVhUpN
f8T9DpaDw2p1d0ZTXtNhYHZ6l8TwkiVVS+eOLEuu9y6XGdNMErKrgch8kHPL+H/k
mGPvGkEY9mLy+dof2aVu8lVb4XMVxsmkiLEtA4AwkR43AT7+Fjp8UHfTcpj92Oko
EISK1w+w4+AoLsG34VZcMyTGlp0jrSJCJJaXMIVx70yzWowyyAnHXK5nVPaBj3ty
sQCPYgr/GTeYHUn2yd8N
=pylk
-----END PGP SIGNATURE-----

--=-DS7B8XMvZJ+cOIceFxZ7--

