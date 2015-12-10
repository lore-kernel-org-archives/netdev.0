From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2] r8169: Don't claim WoL works if LanWake flag is not
 set
Date: Thu, 10 Dec 2015 10:51:35 +0100
Message-ID: <20151210095135.GA21583@calimero.vinschen.de>
References: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
 <1449657826-4461-1-git-send-email-vinschen@redhat.com>
 <20151209224306.GA5082@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="yrj/dFKFPuw6o+aM"
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Corinna Vinschen <vinschen@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:56379 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbbLJJvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 04:51:39 -0500
Content-Disposition: inline
In-Reply-To: <20151209224306.GA5082@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Dec  9 23:43, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > This patch is supposed to fix this behaviour.  If LanWake is 0, the
> > function now returns 0.  Thus ethtool correctly reports "Wake-on: d".
>=20
> Can you turn it into a DMI controlled one (something like
> drivers/net/ethernet/marvell/skge.c use of dmi_check_system)

I could do this (after I could lay my hands on such a board, that is),
but I'm not convinced that this makes a lot of sense for two reasons.

> in order to
> avoid a global change of behavior ?

1.  There is no global change in behaviour.  The usual way to handle the
    WoL flags is to set the affected method flags and additionally set
    LanWake if any of the method flags is set.  The fact that the method
    flags don't enable WoL without also settting the LanWake flag is
    documented.

    __rtl8169_get_wol not reflecting this is a bug.  The code lazily
    assumes that checking the WoL method flags is sufficient while in
    fact it isn't.  __rtl8169_set_wol sets the LanWake flag accordingly,
    but that doesn't mean the driver may assume that the flags haven't
    been set differently.  I can easily hack the driver to set LanWake
    to 0 and ethtool would still happily report WoL is active.  That's
    plain wrong.

2. While we now know a single board which neglects to set the LanWake
   flag, that doesn't mean there aren't other boards out there doing the
   same.
  =20
   On top of that, the state of the NIC registers in terms of WoL are
   *not* board-specific.  They are regular NIC registers which are just
   set in a combination which the driver in it's current state evaluates
   wrongly.  It doesn't matter who and why the flags have been set that
   way.  The driver should reflect the actual state, and that requires
   to check for LanWake.

For those reasons I think that my fix is the right thing to do.

> Btw it's probably time to emit some warning during driver probe if wol
> bits are not consistent with LanWake.

That's a good idea.  I'll propose a followup patch with this addition.


Thanks,
Corinna

--yrj/dFKFPuw6o+aM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWaUsnAAoJEPU2Bp2uRE+gPGoP/16Jkq96YI2WoS/O0wi6BjRU
zcrIH4CdntJ6DvADhRWAPUjp7cO+T6+TEH1yAI/QPqWArd/DRCZBVElMm5vxdYOm
s2LWB48p/HZTyGZ2mnMvkKDra8RTSrhLEDGIptCSLH50q/6owmsAvmE8ZV1VHJ85
OEyjtASUEvgWFDRYjquJhOzAkzQ7jehAA/YhYvccleforndBMB4dY46n42Fv58B0
yLaFAoQLPP5O92WnDNTyWs5w0nLRJsGOOMlUERu4chCE0B20l5SNWR7EHw8NeThz
LasMvhOfs7zuOvE4rkN3AiZALPb2gfa8xGIQ/0ASKje9Nkd/P5YaemHF4X0vraGI
W/ZPFG15fr2cvzhR7GmZnFSvjavYQOcfpYUawV0ZRC//njhM23hjdDaXPCHPyW2I
PywpckRFiBP973PIWg+KcIeEd+YMghIdzqsxI+bzzZikTSWorswW6XMbmGNRvzKF
lCRPODq10SgCEd7snZ8hZyCwBNPw36Xpwavhfg53DfstXr0RFzb3Zm7il3Rpa6/3
IdDWk5/6Un2tD8EkhzG5kZJ9koN0cbySK+yFyD7q8r5nB/TfEjTbIC2n86yGjWJI
pRV3LdHopxulaKHIlAMvUNGVDv6KigroOk1R9SReAXOS7+aaAgwFPDX3qco2lH1G
VLvhA6tr6dzQAMXvf9kR
=gEwD
-----END PGP SIGNATURE-----

--yrj/dFKFPuw6o+aM--
