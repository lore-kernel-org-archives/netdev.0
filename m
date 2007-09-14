From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless vs. network namespaces
Date: Fri, 14 Sep 2007 19:59:10 +0200
Message-ID: <1189792750.3974.43.camel@johannes.berg>
References: <1189763513.3974.26.camel@johannes.berg>
	 <m1bqc52ria.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LUeu4DbIFWxcX+UnPzRY"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m1bqc52ria.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-LUeu4DbIFWxcX+UnPzRY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-09-14 at 09:31 -0600, Eric W. Biederman wrote:

> > Now that the network namespace work is in net-2.6.24, I'm wondering how
> > wireless will be handling this. Is there any benefit at all to a
> > wireless device supporting network namespaces?
>=20
> Good question.  Network namespaces are designed as a general tool
> so if we can support network namespaces in the wireless stack without
> killing ourselves there should be value in it.

Right.

> > Should we, for now, set the new NETIF_F_NETNS_LOCAL flag for all
> > mac80211 devices?
> >
> > If we do want to support moving, then we'll have to make cfg80211
> > (preferably, though mac80211 might be easier at first) migrate *all*
> > virtual interfaces associated with the same wiphy because otherwise
> > we'll get into trouble when moving one virtual interface and then
> > somebody in the other namespace changes its operating channel.
>=20
> Ok.  This appears at least to be an atomicity issue and possibly more.

Yeah, good point, it'd have to move them all at once.

> I don't currently understand the way the wireless interfaces interact
> well enough to make a judgement call.
>=20
> There are two basic usage models I can currently think of.
> 1) Super chroot.  Where a group of processes has distinct mount,
>    network, uts, ipc, and pid namespaces.  So in this case on the
>    inside we will only see processes that only belong to our own
>    network namespace.  So in this scenario you get whatever the person
>    who sets up the environment gives you.
>=20
>    If one of the network devices only allows access to a subset of
>    the wireless networking  (say just sending packets but not
>    controlling the radio aspects) I can see and advantage in only
>    having that device in the restricted network namespace.

Right now, there's no way to disallow that, but yes, I can see value in
it as well.

> 2) Advanced routing.  Where someone is doing some weird thing like=20
>    testing sending packets and receiving them on the same machine.

Not sure I see a point in that with wireless.

> Currently creation of a network namespace requires CAP_SYS_ADMIN
> and for device movement we only require CAP_NET_ADMIN.  So these are
> all privileged operations.  So the scenario you are concerned about
> may just be a "don't do that then".

Ok. Sounds good to me. All the radio config requires CAP_SYS_ADMIN as
well.

> If this doesn't give you enough information to make the call can
> you describe for me how the separation of wireless network interfaces
> work?

Well, basically what we have is one physical device that sends/receives
packets. We have multiple options then:
 * some hardware (no drivers at this time) support multiple virtual
   devices to associate to multiple different access points, each has a
   different MAC address too
 * more importantly, if you have an access point you can put any group
   of associated stations into a sort of VLAN based on which encryption
   keys they use for multicast traffic. Each of these VLANs shows up as
   a local device as well.
 * Then there's some things like having a monitor interface that sees
   all traffic etc. but that's not too interesting.
 * You could have an AP along with a WDS device to enable bridging
   between multiple APs over wireless, not really interesting either in
   this context

I can mainly see the first and the second points having value in
separation. With the first, pending drivers that have multi-MAC address
support you could give each namespace one device that can associate to
some different AP [1]. And then you could have VLANs on an AP where each
VLAN "ends" in a different namespace.

johannes

[1] though actually, right now, they couldn't associate to the same AP
without having weird bugs in mac80211... I have plans to fix this
though.

--=-LUeu4DbIFWxcX+UnPzRY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG6svu/ETPhpq3jKURAoS1AKCNdbUClxwdxWBfLd+cBBnZcbp82ACeOn5c
WK9u8DPMi2/4/xhFz756Ewc=
=HTZ3
-----END PGP SIGNATURE-----

--=-LUeu4DbIFWxcX+UnPzRY--
