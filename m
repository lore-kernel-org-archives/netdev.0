From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Fri, 20 May 2011 12:01:02 -0700
Message-ID: <20110520120102.465d6a25@nehalam>
References: <20110513171729.247b126e@nehalam>
	<1305488809.3120.162.camel@edumazet-laptop>
	<1305490850.8178.57.camel@Joe-Laptop>
	<1305493826.3120.174.camel@edumazet-laptop>
	<20110516084644.483290f6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48397 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935099Ab1ETTBF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 15:01:05 -0400
In-Reply-To: <20110516084644.483290f6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 May 2011 08:46:44 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Sun, 15 May 2011 23:10:26 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le dimanche 15 mai 2011 =C3=A0 13:20 -0700, Joe Perches a =C3=A9cri=
t :
> > > On Sun, 2011-05-15 at 21:46 +0200, Eric Dumazet wrote:
> > > > Le vendredi 13 mai 2011 =C3=A0 17:17 -0700, Stephen Hemminger a=
 =C3=A9crit :
> > > > > There are some addresses in the assigned vendor block that do=
n't obey
> > > > > the locally assigned convention. These should be avoided by r=
andom_ether_addr
> > > > > assignment.
> > > > We call random_ether_addr() for some virtual devices, maybe we =
can add a
> > > > __random_ether_addr() helper for them and not avoid these OUI ?
> > >=20
> > > Unless it's speed critical, it's probably not worthwhile.
> > >=20
> >=20
> > Speed was not my concern, but getting idea of why avoiding pre-assi=
gned
> > OUI was a concern for them, if they dont hit a real Ethernet domain=
=2E
>=20
> My concern was that after some discussion with IEEE committee that ma=
ny
> virtual environments are using locally assigned addresses that get br=
idged
> onto real networks.
>=20
> That started me thinking that the current code should be more careful
> to avoid potential conflicts. My opinion is that this not worth worry=
ing
> about because the likelihood of conflict with any one of these old
> addresses is as about as the unlikely as two hosts choosing the same
> value. But I wanted to raise the issue for explicit discussion and fr=
ame
> it with what would be required to handle it.

I thought of one problem that the current code has related to udev.
If a virtual device chooses one of the pre-assigned OUI values then
udev will put in the persistent network device file.
This will cause the device to change name.

If you look at /lib/udev/rules.d/75-persistent-net-generator-rules
it has special case code for this.


# ignore KVM virtual interfaces
ENV{MATCHADDR}=3D=3D"52:54:00:*", GOTO=3D"persistent_net_generator_end"
# ignore VMWare virtual interfaces
ENV{MATCHADDR}=3D=3D"00:0c:29:*|00:50:56:*", GOTO=3D"persistent_net_gen=
erator_end"

# These vendors are known to violate the local MAC address assignment s=
cheme
# Interlan, DEC (UNIBUS or QBUS), Apollo, Cisco, Racal-Datacom
ENV{MATCHADDR}=3D=3D"02:07:01:*", GOTO=3D"globally_administered_whiteli=
st"
# 3Com
ENV{MATCHADDR}=3D=3D"02:60:60:*", GOTO=3D"globally_administered_whiteli=
st"
# 3Com IBM PC; Imagen; Valid; Cisco; Apple
ENV{MATCHADDR}=3D=3D"02:60:8c:*", GOTO=3D"globally_administered_whiteli=
st"
# Intel
ENV{MATCHADDR}=3D=3D"02:a0:c9:*", GOTO=3D"globally_administered_whiteli=
st"
# Olivetti
ENV{MATCHADDR}=3D=3D"02:aa:3c:*", GOTO=3D"globally_administered_whiteli=
st"
# CMC Masscomp; Silicon Graphics; Prime EXL
ENV{MATCHADDR}=3D=3D"02:cf:1f:*", GOTO=3D"globally_administered_whiteli=
st"
# Prominet Corporation Gigabit Ethernet Switch
ENV{MATCHADDR}=3D=3D"02:e0:3b:*", GOTO=3D"globally_administered_whiteli=
st"
# BTI (Bus-Tech, Inc.) IBM Mainframes
ENV{MATCHADDR}=3D=3D"02:e6:d3:*", GOTO=3D"globally_administered_whiteli=
st"
# Realtek
ENV{MATCHADDR}=3D=3D"52:54:00:*", GOTO=3D"globally_administered_whiteli=
st"
# Novell 2000
ENV{MATCHADDR}=3D=3D"52:54:4c:*", GOTO=3D"globally_administered_whiteli=
st"
# Realtec
ENV{MATCHADDR}=3D=3D"52:54:ab:*", GOTO=3D"globally_administered_whiteli=
st"
# Kingston Technologies
ENV{MATCHADDR}=3D=3D"e2:0c:0f:*", GOTO=3D"globally_administered_whiteli=
st"

# match interface dev_id
ATTR{dev_id}=3D=3D"?*", ENV{MATCHDEVID}=3D"$attr{dev_id}"

# do not use "locally administered" MAC address
ENV{MATCHADDR}=3D=3D"?[2367abef]:*", ENV{MATCHADDR}=3D""

# do not use empty address
ENV{MATCHADDR}=3D=3D"00:00:00:00:00:00", ENV{MATCHADDR}=3D""

LABEL=3D"globally_administered_whitelist"
