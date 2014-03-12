From: Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [mac80211_hwsim] BUG: unable to handle kernel paging request at
 ce1db404
Date: Wed, 12 Mar 2014 18:34:46 +0100
Message-ID: <20140312173446.GD2983@piware.de>
References: <20140305125703.GA7193@localhost>
 <20140305132317.GB10880@localhost>
 <20140308121138.GA8359@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3siQDZowHQqNOShm"
Cc: Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140308121138.GA8359@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3siQDZowHQqNOShm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Fengguang Wu [2014-03-08 20:11 +0800]:
> [    4.429993] mac80211_hwsim: ieee80211_register_hw failed (-2)
> [...]
> [    4.431924]  [<c12377de>] get_device+0xf/0x17
> [    4.431924]  [<c123a165>] driver_detach+0x38/0x8f
> [    4.431924]  [<c1239433>] bus_remove_driver+0x53/0x66
> [    4.431924]  [<c123a535>] driver_unregister+0x38/0x3d
> [    4.431924]  [<c123b3aa>] platform_driver_unregister+0xb/0xd
> [    4.431924]  [<c1c4ac9f>] init_mac80211_hwsim+0x3a5/0x3b6


So that first message is from
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers=
/net/wireless/mac80211_hwsim.c?id=3D9ea927748#n2428

At this point we registered the platform driver and the class, and it
should have created two devices (at least for the default radios=3D2).
What's odd is that I don't see this printk in your kernel log:

  mac80211_hwsim: Initializing radio %d

If for some reasons "radio" is 0, it would not show this and not
initialize data->dev, but then you shouldn't get to
ieee80211_register_hw() either as it's in the same loop. So that's a
bit of a mystery to me.

On failure, above ieee80211_register_hw() jumps to the cleanup:

| failed_hw:
| 	device_unregister(data->dev);
| failed_drvdata:
| 	ieee80211_free_hw(hw);
| failed:
| 	mac80211_hwsim_free();
| failed_unregister_driver:
| 	driver_unregister(&mac80211_hwsim_driver);
| 	return err;
| }


The mac80211_hwsim_free() function again calls
device_unregister(data->dev) for a list (not sure which, I'm not
certain how to interpret

  list_for_each_entry_safe(data, tmpdata, &tmplist, list)

) Could that be the double free causing the memory corruption?

If you are in a position to do quick builds and tests, does the crash
go away with this?

 		printk(KERN_DEBUG "mac80211_hwsim: device_bind_driver failed (%d)\n",
 		       err);
- 		goto failed_hw;
+ 		goto failed_drvdata;
 	}

(I'm not claiming that this is correct, just taking a stab at
understanding what happens) If not, does it go away with changing the
goto to failed_unregister_driver()?

Thanks,

Martin
--=20
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)

--3siQDZowHQqNOShm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJTIJq2AAoJENFO8V2v4RNHA/8P/0BtuaxdqeAdJtkjKXXuSKCT
WZNcimLWbKr0jf7miXzhRaMonkBo9iBnYwCGytu9ELKWUkvFfdu6SHM9GOGKmy9o
B92qHFbHNy1wAeGo0Oblay9gVhmDU2+PgNySlKFW5u24DDd3Ym2sYpcsl3PI+BfP
cOA1tQYEGOEYdoSEAt92Rf2sP8FQoH/YwHAE/y1exE7wEgToXmdbdLDcI3nHY571
SVtw6le28BSlXnOYUPxiTWpVSe/9GDnjU3wxQfelVEAmzlzCtUDDXYBnaCxgU/Tc
LV1z76K3nDbfyFwfecurxOwKFG8+Em7v6b9CeN+MZP3A9xstu2zDQ8LNbGoHR2vp
ba1XYdsMsu+jHl63BwClgfwN4AWg7MvK5675u1ePXmHU2KIbB0Uj93m95ydYRQ0D
f5bYLXQjMleoOwPk/X2ostgI8DxYrq8wQpUYGHTfY+dGjsHTyddZ5TemrMxNnM3s
Sf12e1bsmFCBQeu6ZA2TdIt/Vg6O97tnuZ62x3yWWW7ti94rgvogMqbtJD9+vFKi
Cy5FsU8yO6pmWpwVUkFq2o9C/IIW0IrOhVq8JQdBV34MzvXXhDf8KsEX8Zy74Hox
92cbLAOgE06rSv2Iz7MaSsZHc1JPjfvG4Nx+plmjEmmj1Ebp7I+6gla4Q+9EtxwV
FS9gf4rf8R6G0oieWJ2Z
=uieF
-----END PGP SIGNATURE-----

--3siQDZowHQqNOShm--
