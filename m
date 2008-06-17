From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: Killing sk->sk_callback_lock
Date: Tue, 17 Jun 2008 07:42:44 -0400
Message-ID: <4857A334.5020501@gmail.com>
References: <4856C12F020000C700039679@lucius.provo.novell.com> <20080616.185328.85842051.davem@davemloft.net> <4856FEC9.BA47.005A.0@novell.com> <20080616.215632.119969915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEE3AADFD024ADC99F45B2F4D"
Cc: herbert@gondor.apana.org.au, pmullaney@novell.com,
	chuck.lever@oracle.com, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:58628 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299AbYFQLny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 07:43:54 -0400
Received: by yw-out-2324.google.com with SMTP id 9so3368703ywe.1
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 04:43:51 -0700 (PDT)
In-Reply-To: <20080616.215632.119969915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEE3AADFD024ADC99F45B2F4D
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

>>> On Tue, Jun 17, 2008 at 12:56 AM, in message
<20080616.215632.119969915.davem@davemloft.net>, David Miller
<davem@davemloft.net> wrote:
> From: "Gregory Haskins" <ghaskins@novell.com>
> Date: Mon, 16 Jun 2008 22:01:13 -0600
>=20
>> This seemed odd to us, so we investigated further to see if an
>> improvement was lurking or whether this was expected.  We traced
>> back the source of each wakeup to be coming from 1) the wmem/nospace
>> code, and 2) from the rx-wakeup code from the softirq.  First the
>> softirq would process the tx-completions which would wake_up() the
>> wait-queue for NOSPACE signaling.  Since the client was waiting for
>> a packet on the same wait-queue, this was where the first wakeup
>> came from.  Then later the softirq finally pushed an actual packet
>> to the queue, and the client was once again re-awoken via the same
>> overloaded wait-queue.  This time it would successfully find a
>> packet and return to userspace.
>>
>> Since the client does not care about wmem/nospace in the UDP rx
>> path, yet the two events share a single wait-queue, the first wakeup
>> was completely wasted.  It just causes extra scheduling activity
>> that does not help in any way (and is quite expensive in the
>> grand-scheme of things).  Based on this lead, Pat devised a solution
>> which eliminates the extra wake-up() when there are no clients
>> waiting for that particular NOSPACE event.  With his patch applied,
>> we observed two things:
>=20
> Why is the application checking for receive packets even on the
> write-space wakeup?
>=20
> poll/select/epoll should be giving the correct event indication,
> therefore the application would know to not check for receive
> packets when a write-wakeup event occurs.
>=20
> Yes the wakeup is spurious and we should avoid it.  But this
> application is also buggy.

The application is blocked inside a system call (I forget which one=20
right now..probably recv()).  So the wakeup is not against a=20
poll/select.  Rather, the kernel is in=20
net/core/datagram.c::wait_for_packet() (blocked on skb->sk_sleep).

Since both the wmem code and the rx code use skb->sk_sleep to wake up=20
waiters, the wmem processing inadvertently kicks the client to go=20
through __skb_recv_datagram() one more time.  And since there aren't yet =

any packets in skb->sk_receive_queue, the client loops and once again=20
calls wait_for_packet().

So long story short:  This is entirely a kernel-space issue (unless you=20
believe the usage of that system-call itself is a bug?)

HTH

Regards,
-Greg






--------------enigEE3AADFD024ADC99F45B2F4D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIV6M0P5K2CMvXmqERAnNwAJ9HeDWLeUGIillYQ4He6QxxGGgMJgCffJJK
DL64Au4hwjmndOU5mbQT0l8=
=iGFr
-----END PGP SIGNATURE-----

--------------enigEE3AADFD024ADC99F45B2F4D--
