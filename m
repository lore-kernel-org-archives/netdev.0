From: Tilman Schmidt <tilman@imap.cc>
Subject: capi.c calls receive_buf with interrupts disabled (was: N_PPP_SYNC
 ldisc BUG: sleeping function called from invalid context)
Date: Thu, 01 Oct 2009 01:15:56 +0200
Message-ID: <4AC3E6AC.3000107@imap.cc>
References: <4AC37032.4030901@imap.cc> <20090930174704.796b24b9@lxorguk.ukuu.org.uk> <4AC3A986.4080808@imap.cc> <4AC3C9B8.9080003@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig831036D3AE567DAC56CD0071"
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@linux.intel.com>,
	Michael Buesch <mb@bu3sch.de>,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754804AbZI3XQP@vger.kernel.org>
In-Reply-To: <4AC3C9B8.9080003@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig831036D3AE567DAC56CD0071
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Jarek Poplawski schrieb:
> Tilman Schmidt wrote, On 09/30/2009 08:55 PM:
[...]
>> - ppp_sync_receive() was called, as the LD's receive_buf method,
>>   via handle_recv_skb() [drivers/isdn/capi/capi.c line 504, inlined]
>>   from handle_minor_recv() [drivers/isdn/capi/capi.c line 519]
>>
>> - handle_minor_recv() was called from capi_recv_message()
>>   [drivers/isdn/capi/capi.c line 656]
>>
>> - capi_recv_message() was called, as the CAPI application's
>>   recv_message method, from recv_handler()
>>   [drivers/isdn/capi/kcapi.c line 268]
>>
>> - recv_handler() is never called directly. It's only scheduled
>>   via the work queue ap->recv_work from capi_ctr_handle_message()
>>   [drivers/isdn/capi/kcapi.c line 349]
>>
>> Even if we don't trust the backtraces, there's not much room for
>> another activation path. So for all I know, the expectation of the
>> tty logic should have been met. The call was indeed processed from
>> a work queue.
>>
>> Why then does mutex_lock() complain?
>=20
> Hmm... capi_recv_message() calls handle_minor_recv() under
> spin_lock_irqsave(), doesn't it?

Well spotted. Indeed it does. That explains it, of course.

The spinlock in question was added by:

commit 053b47ff249b9e0a634dae807f81465205e7c228
Author: Michael Buesch <mb@bu3sch.de>
Date:   Mon Feb 12 00:53:26 2007 -0800

    [PATCH] Workaround CAPI subsystem locking issue
   =20
    I think the following patch should go into the kernel, until the ISDN=
/CAPI
    guys create the real fix for this issue.
    =20
    The issue is a concurrency issue with some internal CAPI data structu=
re
    which can crash the kernel.

    On my FritzCard DSL with the AVM driver it crashes about once a day w=
ithout
    this workaround patch.  With this workaround patch it's rock-stable (=
at
    least on UP, but I don't see why this shouldn't work on SMP as well. =
 But
    maybe I'm missing something.)
   =20
    This workaround is kind of a sledgehammer which inserts a global lock=
 to
    wrap around all the critical sections.  Of course, this is a scalabil=
ity
    issue, if you have many ISDN/CAPI cards.  But it prevents a crash.  S=
o I
    vote for this fix to get merged, until people come up with a better
    solution.  Better have a stable kernel that's less scalable, than a
    crashing and useless kernel.
   =20
So let's cc the author of that patch, and also the good people on the
isdn4linux developer mailing list ...

Any ideas for a fix?

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig831036D3AE567DAC56CD0071
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFKw+a5Q3+did9BuFsRAgdnAJ9fsDRWMcSwSvDsXMP+fB+NE4IEbgCglp13
+br1K4wCe4N0IlhE2Piz7xs=
=fp3R
-----END PGP SIGNATURE-----

--------------enig831036D3AE567DAC56CD0071--
