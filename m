From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 08:42:33 -0400
Message-ID: <49C23DB9.6000905@novell.com>
References: <49C16D7C.3080003@novell.com>	<20090318.180355.228447835.davem@davemloft.net>	<49C1C09E.8050405@novell.com> <20090318.223806.123468340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig36EBAC2DDE86F664ACE742C4"
Cc: vernux@us.ibm.com, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	pmullaney@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090318.223806.123468340.davem@davemloft.net>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig36EBAC2DDE86F664ACE742C4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Gregory Haskins <ghaskins@novell.com>
> Date: Wed, 18 Mar 2009 23:48:46 -0400
>
>  =20
>> To see this in action, try taking a moderately large smp system
>> (8-way+) and scaling the number of flows.
>>    =20
>
> I can maintain line-rate over 10GB with a 64-cpu box.
Oh man, I am jealous of that 64-way :)

How many simultaneous flows?  What hardware?  What qdisc and other
config do you use?  MTU?  I cannot replicate such results on 10GB even
with much smaller cpu counts.

On my test rig here, I have a 10GB link connected by crossover between
two 8-core boxes.  Running one unidirectional TCP flow is typically
toping out at ~5.5Gb/s on 2.6.29-rc8.  Granted we are using MTU=3D1500,
which in of itself is part of the upper limit.  However, that result in
of itself isn't a problem, per se.  What is a problem is the aggregate
bandwidth drops with scaling the number of flows.  I would like to
understand how to make this better, if possible, and perhaps I can learn
something from your setup.
>   It's not
> a problem.
>  =20

To clarify terms, we are not saying "the stack performs inadequately".=20
What we are saying here is that analysis of our workloads and of the
current stack indicates that we are io-bound, and that this particular
locking architecture in the qdisc subsystem is the apparent top gating
factor from going faster.  Therefore we are really saying "how can we
make it even better"?  This is not a bad question to ask in general,
would you agree?

To vet our findings, we built that prototype I mentioned in the last
mail where we substituted the single queue and queue_lock with a
per-cpu, lockless queue.  This meant each cpu could submit work
independent of the others with substantially reduced contention.  More
importantly, it eliminated the property of scaling the RFO pressure on a
single cache-lne for the queue-lock.  When we did this, we got
significant increases in aggregate throughput (somewhere on the order of
6%-25% depending on workload,  but this was last summer so I am a little
hazy on the exact numbers).

So you had said something to the effect of "Contention isn't implicitly
a bad thing".   I agree to a point.  At least so much as contention
cannot always be avoided.  Ultimately we only have one resource in this
equation:  the phy-link in question.  So naturally multiple flows
targeted for that link will contend for it.

But the important thing to note here is that there are different kinds
of contention.  And contention against spinlocks *is* generally bad, for
multiple reasons.  It not only affects the cores under contention, but
it affects all cores that exist in the same coherency domain.  IMO it
should be avoided whenever possible.

So I am not saying our per-cpu solution is the answer.  But what I am
saying is that we found that an architecture that doesnt piggy back all
flows into a single spinlock does have the potential to unleash even
more Linux-networking fury :)

I haven't really been following the latest developments in netdev, but
if I understand correctly part of what we are talking about here would
be addressed by the new MQ stuff?  And if I also understand that
correctly, support for MQ is dependent on the hardware beneath it?  If
so, I wonder if we could apply some of the ideas I presented earlier for
making "soft MQ" with a lockless-queue per flow or something like that?=20
Thoughts?

-Greg



--------------enig36EBAC2DDE86F664ACE742C4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknCPbkACgkQlOSOBdgZUxlrJwCeLNasxUz01bw9POxOCZjl3B7J
6SAAnRcKhI9jZSz8f2MiAO1DXf9uFKXR
=bA95
-----END PGP SIGNATURE-----

--------------enig36EBAC2DDE86F664ACE742C4--
