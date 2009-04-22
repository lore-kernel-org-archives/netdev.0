From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: e100 shutdown breaks e100 probing when using kexec
Date: Wed, 22 Apr 2009 15:32:43 -0300
Message-ID: <20090422183242.GH4691@vespa.holoscopio.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hUH5gZbnpyIv7Mn4"
To: e1000-devel@lists.sourceforge.net, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.18.203]:57116 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbZDVScu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 14:32:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hUH5gZbnpyIv7Mn4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello, folks.

As seen recently, I've sent a bugfix for the e100 shutdown in the same
lines as the patches proposed by RWJ to e1000, e1000e and some other
network devices.

I would like to get some light about the need to disable wake when
suspending if there is no WOL support, if most, if not all, resume and
probe code already do it. If it is really needed, perhaps, an utility
helper function could be written and most drivers migrated to it.

But another issue is that, in some particular cases, although the device
was put in D3 state with wake enabled, I could get it back working even
when using kexec. In particular, when the system resumes, it can get it
back working anyway. So there should be something we could do while
probing to wake up these devices. This would allow people running old
systems to kexec into new ones. If there's little or no drawback in the
approach, I think added robustness for probing a PCI device is a plus
anyway.

So, I will tell what I've done while looking for the problem so there is
some hidden hint in there. If I am in a wild-goose chase here or there's
no use or interest in something like this, please tell me so and I'll
stop bothering you all. :-)

Since the PCI code already sets the power state to D0 and disable wake
before calling probe function, there was no use doing the following in
probe.

        pci_set_power_state(pdev, PCI_D0);
        pci_enable_wake(pdev, 0, 0);

I've tested it and it did not work.

Doing pci_restore_state, which should not work at all, in probe, seemed
to work, but perhaps it was because of some of the other reasons below.
Don't trust this information. It's stupid anyway.

Most configurations with earlier releases like 2.6.29 did work. I had
problems when some commits were introduced that I've found out while
bisecting. In particular, one patch changing how uevent_helper is called
and configuring the helper to empty did activate the bug in earlier
releases.

kobject: don't block for each kobject_uevent
[ upstream commit: f520360d93cdc37de5d972dac4bf3bdef6a7f6a7 ]

This commit is the one that seemed to start it all. It has already been
reverted in v2.6.30-rc2, AFAIK.

CONFIG_UEVENT_HELPER_PATH=""

This configuration also had an effect. With that, I could hit the bug
with releases earlier than v2.6.29. This all with a minimal, almost
allnoconfig. When adding some things, like initramfs or other drivers,
the probe went well and the device at least registered.

I thought this could be related to some delay or some race condition.
I've used some msleep or udelay (this is UP) in the probe, but with no
success.

I've also noticed my e100 device is after a bridge. Since I didn't know
much about PCI PM, I thought this could be related, but could find
nothing about it.

Any thoughts on that?

Best Regards,
Cascardo.

--hUH5gZbnpyIv7Mn4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAknvYsoACgkQyTpryRcqtS0JUQCeOFKLy70vjZzbpwFPmd2DGW8T
bIsAn3b5hiLS7ZyrSWjD+URRi0vGIRbm
=8gEP
-----END PGP SIGNATURE-----

--hUH5gZbnpyIv7Mn4--
