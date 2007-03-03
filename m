From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [patch] at76_usb wireless driver
Date: Sat, 03 Mar 2007 17:23:57 +0100
Message-ID: <1172939037.4966.97.camel@johannes.berg>
References: <20070110145724.GA4171@bogon.ms20.nix>
	 <20070223221230.GA9965@bogon.ms20.nix>
	 <20070303150029.GA19940@bogon.ms20.nix>
	 <1172934588.4966.46.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-h8P2bWm32yEpGQkx8npm"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Guido Guenther <agx-wGvLLbajjwFAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1172934588.4966.46.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-h8P2bWm32yEpGQkx8npm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Looks pretty good, a few more comments.

KEVENT_* constants and functions are really really confusing when the
"kevent" subsystem is being discussed on netdev all the time. They're
also quite meaningless, please rename them to something like
AT76_DEVEVENT_* or whatever. While at that, the kevent() function really
could use splitting up into sub-functions, it's a pretty large mess.

The same about constant names goes for PM_* constants since linux/pm.h
defines a whole bunch of PM_* constants too (I initially thought you
were using those and was really confused what the driver does!)

Having a whole bunch of module parameters that only set initial settings
for things you later configure with iwconfig seems pretty useless but if
you really think that they're absolutely required I don't care too much.

PRIV_IOCTL_SET_MONITOR_MODE is wrong as far as I can tell, there's
"iwconfig ... mode monitor" which you should use instead. (Btw, why are
the priv ioctls spaced so strangely??)

There doesn't seem to be a need to include rtnetlink.h, what made you
think you'd need rtnl_lock()?
"putting this inside rtnl_lock() - rtnl_unlock() hangs modprobe" is
pretty obvious -- register_netdev does rtnl_lock()! And don't use
unregister_netdevice(), use unregister_netdev().

Your init_new_device() function can return an error but those errors are
not always checked, maybe a printk would be appropriate. Also,
generally, subfunctions are allowed to return errors directly, i.e.
instead of returning -1 return -ENODEV from there and just hand it up
from the caller.

at76c503_do_probe could use splitting into two functions, the two huge
parts of the if, if only to unindent the whole code a bit and get it to
adhere to 80 chars/line instead of 99.

"Use our own dbg macro" but mabye use dev_dbg?
Same for err() (which I didn't even know existed..) how about dev_err()?

static u8 snapsig/rfc1042sig/bc_addr/off_addr/hw_rates/channel_frequency
etc etc etc don't belong into a header file.



Some other (mostly style) issues:
 * kernel code prefers a space before the brace in
   "struct at76c503_command{" et al.
 * both your header and code files contain lots of trailing whitespace
 * kernel code prefers no space between function names and the opening
   parenthesis
 * use compare_ether_addr() instead of memcmp (look for ETH_ALEN, lots
   of places)
 * all the PROC =3D=3D=3D=3D=3D stuff looks pretty strange to my eyes but h=
ey
   that's just me I guess :)
 * why does at76c503_get_fw_info take such a huge number of parameters?
   Couldn't you pass in a struct at76c503 * and have that filled?
 * struct reg_domain should be tab-indented.
 * don't use typedefs for structs
 * attribute packed on members of a struct is pretty weird
 * the various frame definitions like struct ieee802_11_beacon_data are
   useless, the same stuff is in struct ieee80211_mgmt (at least on
   wireless dev kernel, that might not be true on other kernels?)
 * hex2str wants proper indentation
 * get_hw_config has weird indentation
 * wait_completion sounds far too generic (wait_for_completion in
   completion.h!)



Hey, I need to go but that probably gives you a lot to review...

johannes

--=-h8P2bWm32yEpGQkx8npm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF6aEc/ETPhpq3jKURAgumAJ9tJXWNIqJJPsIVTicd5nbxD8M2CQCfW/Sy
uX/o0j5eQziCrdB/EfY5VZc=
=65sJ
-----END PGP SIGNATURE-----

--=-h8P2bWm32yEpGQkx8npm--
