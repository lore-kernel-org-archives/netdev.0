From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: NOHZ: local_softirq_pending 08
Date: Wed, 21 Oct 2009 20:46:40 +0200
Message-ID: <4ADF5710.4030505@imap.cc>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local> <4AD76184.6030900@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5AFD4289CAEBB63DCDBBFEB4"
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	hidave.darkstar@gmail.com, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, linux-wireless@vger.kernel.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org, paulus@samba.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932065AbZJUSqv@vger.kernel.org>
In-Reply-To: <4AD76184.6030900@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5AFD4289CAEBB63DCDBBFEB4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 15.10.2009 19:53 Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 10/15/2009 01:40 PM:
>=20
>> On 12-10-2009 13:25, Tilman Schmidt wrote:

>>> I have encountered the message in the subject during a test of
>>> the Gigaset CAPI driver, and would like to determine whether
>>> it's a bug in the driver, a bug somewhere else, or no bug at
>>> all. The test scenario was PPP over ISDN with pppd+capiplugin.
>>> In an alternative scenario, also PPP over ISDN but with
>>> smpppd+capidrv, the message did not occur.

I'm sorry, I had confused the two cases. The message occurs in
the smpppd+capidrv scenario, not with pppd+capiplugin.

>>> Johannes' answer pointed me to the netif_rx() function.
>>> The Gigaset driver itself doesn't call that function at all.
>>> In the scenario where I saw the message, it was the SYNC_PPP
>>> line discipline that did.

This analysis was therefore wrong. It would be the netif_rx()
call towards the end of isdn_ppp_push_higher() in
drivers/isdn/i4l/isdn_ppp.c L1177.

>> Anyway, I agree with Michael Buesch there is no reason to waste time
>> for tracking all netif_rx vs netif_rx_ni uses, and it seems we could
>> avoid it by using the "proper" version of raise_softirq_irqoff() in
>> __napi_schedule(). Could anybody try if I'm not wrong?
>>
>>  net/core/dev.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 28b0b9e..7fc4009 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2728,7 +2728,7 @@ void __napi_schedule(struct napi_struct *n)
>> =20
>>  	local_irq_save(flags);
>>  	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list)=
;
>> -	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
>> +	raise_softirq_irqoff(NET_RX_SOFTIRQ);
>>  	local_irq_restore(flags);
>>  }
>>  EXPORT_SYMBOL(__napi_schedule);

I have tested your patch and I can confirm that it fixes the messages.
I have not noticed any ill effects.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig5AFD4289CAEBB63DCDBBFEB4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFK31cZQ3+did9BuFsRAlWeAJ93rbAD2D/9sgXqn7IkoKQndzDfEQCeMlEL
Z4A+PxVoA1bD0gc2OvUqD/k=
=yorf
-----END PGP SIGNATURE-----

--------------enig5AFD4289CAEBB63DCDBBFEB4--
