From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] natsemi: make cable length magic configurable
Date: Mon, 16 Jul 2012 14:26:21 +0200
Message-ID: <1342441581.4165.235.camel@amber.site>
References: <201111241443.59191.jdelvare@suse.de>
	 <1322162739.2784.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tim Hockin <thockin@hockin.org>,
	Olaf Kirch <okir@suse.de>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55458 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375Ab2GPM0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 08:26:42 -0400
In-Reply-To: <1322162739.2784.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Thanks for you fast reply and sorry for my very slow one.

Le jeudi 24 novembre 2011 =C3=A0 19:25 +0000, Ben Hutchings a =C3=A9cri=
t :
> On Thu, 2011-11-24 at 14:43 +0100, Jean Delvare wrote:
> > From: Olaf Kirch <okir@suse.de>
> >=20
> > We had a customer report concerning problems with a Natsemi DP83815=
-D
> > and long cables. With 100m cables, the network would be essentially=
 dead,
> > not a single packet would get through either way. We had to apply t=
he
> > patch below to make it work.
> >=20
> > The patch adds a module parameter named "no_cable_magic" that does
> > two things:
> >=20
> >  -	Unconditionally set the DSPCFG register to the
> > 	fixed value. Without this change, the chip apparently
> > 	never completes autonegotiation in the tested configuration.
> >=20
> > 	This has been an unconditional assignment for a long time,
> > 	until this was changed in 2.6.11 (there's an interesting
> > 	explanation in the ChangeLog, subject is
> > 	"[PATCH] natsemi long cable fix", bk commit is
> > 	5871b81bf2b5cf188deab0d414dce104fcb69ca6, git commit in
> > 	tglx/history tree is c0d51c67f9c398279a95c5a7df387f2d9a586c98.
> >=20
> >  -	Skip the bit banging in {,un}do_cable_magic. It seems that
> > 	if we write the DSPCFG register as above, a rev D chip will report
> > 	all cables as "short cables", which do_cable_magic detects, and
> > 	trying to be helpful it will "fix" the attenuation coefficient.
> >=20
> > I admit the use of a module parameter is ugly, but I didn't find a =
sane
> > way to fix this - especially since the magic registers we're changi=
ng
> > are undocumented.
> [...]
>=20
> This could be implemented as an ethtool 'private flag'.  However, the
> ethtool utility currently does not provide an interface to them.
> Perhaps you could implement both the private flag and the module
> parameter for now, and then drop the module parameter some time after
> the utility has been updated.

I see that you updated the ethtool utility meanwhile, thanks for doing
that.

> You would need to:
> 1. Number the flags starting from 0.  Well, that was easy.
> 2. Implement {get,set}_priv_flags() operations to access all flags as
>    a bitmask.
> 3. Expose the flag names as string set ETH_SS_PRIV_FLAGS accessed by
>    get_sset_count() and get_strings() operations.

I was looking for an example, but there doesn't seem to be any driver
implementing private flags at the moment?

I am also unsure if a private flag is a suitable solution to the proble=
m
at hand. I am a little worried about the timing, as the non-default
value can't be set before the network device is available, I'm afraid
the network initialization scripts may kick in before one has a chance
to set the flag with ethtool. I suppose this could be problematic, but
then again I don't know much about network device drivers, I don't even
know for sure when method .ndo_open is called...

=46urthermore I don't quite get why we can't just go with the module
parameter. As I understand it, this is a crappy driver for crappy, rare
hardware. The driver already has a module parameter to work around a
hardware bug (dspcfg_workaround), I don't quite see why adding a second
one would be a problem. At least it is consistent.

Thanks,
--=20
Jean Delvare
Suse L3
