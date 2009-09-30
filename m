From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: N_PPP_SYNC ldisc BUG: sleeping function called from invalid context
Date: Wed, 30 Sep 2009 20:55:02 +0200
Message-ID: <4AC3A986.4080808@imap.cc>
References: <4AC37032.4030901@imap.cc> <20090930174704.796b24b9@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA3335ECF50EFE6405BD5CA9B"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755073AbZI3SzO@vger.kernel.org>
In-Reply-To: <20090930174704.796b24b9@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA3335ECF50EFE6405BD5CA9B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Alan Cox schrieb:
>>  [<c026d39b>] tty_unthrottle+0x10/0x38
>>  [<f8dcc31f>] ppp_sync_receive+0x168/0x170 [ppp_synctty]
>>  [<f8fbb9ce>] handle_minor_recv+0x187/0x1cd [capi]
>>  [<f8fbc19b>] capi_recv_message+0x1d9/0x24e [capi]
>=20
> Really need to see the rest of the call trace to be sure

There wasn't more than what I posted. I had six of them, they looked all
identical, and all of them ended after the kernel_thread_helper line.=20

>> Turns out the ppp_sync_receive() function (drivers/net/ppp_synctty.c
>> line 385ff.) has a comment in front stating:
>>
>> /*
>>  * This can now be called from hard interrupt level as well
>>  * as soft interrupt level or mainline.
>>  */
>=20
> Which is wrong. The flip_buffer_push -> rx processing path should never=

> be called from IRQ context and that was fixed for various drivers that
> mis-set tty->low_latency, as well as in the PPP rework. The PPP case is=

> actually unrelated in many was.

Might be worth correcting that text then before is misleads someone.

>> Opinions?
>=20
> See how we got into that code direct from an IRQ path. The expectation =
of
> the tty logic is that it gets processed from work queues either
> specifically in driver or via tty_flip_buffer_push when tty->low_latenc=
y
> =3D 0

I'm at a loss here. According to all the backtraces:

- ppp_sync_receive() was called, as the LD's receive_buf method,
  via handle_recv_skb() [drivers/isdn/capi/capi.c line 504, inlined]
  from handle_minor_recv() [drivers/isdn/capi/capi.c line 519]

- handle_minor_recv() was called from capi_recv_message()
  [drivers/isdn/capi/capi.c line 656]

- capi_recv_message() was called, as the CAPI application's
  recv_message method, from recv_handler()
  [drivers/isdn/capi/kcapi.c line 268]

- recv_handler() is never called directly. It's only scheduled
  via the work queue ap->recv_work from capi_ctr_handle_message()
  [drivers/isdn/capi/kcapi.c line 349]

Even if we don't trust the backtraces, there's not much room for
another activation path. So for all I know, the expectation of the
tty logic should have been met. The call was indeed processed from
a work queue.

Why then does mutex_lock() complain?

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigA3335ECF50EFE6405BD5CA9B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFKw6mQQ3+did9BuFsRApFeAJ9apVzjEfFwEt/LveHNjgRRzVRRJwCfYTYZ
aUOMUTram+AzNGpHpuWSGhA=
=+U3c
-----END PGP SIGNATURE-----

--------------enigA3335ECF50EFE6405BD5CA9B--
