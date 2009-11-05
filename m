From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder	Cookie
Date: Thu, 05 Nov 2009 14:34:24 +0100
Message-ID: <4AF2D460.5010608@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AF0B0D2.4030905@gmail.com> <20091104214844.GA6714@linux.vnet.ibm.com> <4AF2C266.1010603@gmail.com> <4AF2C8E4.9020202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756544AbZKENeX@vger.kernel.org>
In-Reply-To: <4AF2C8E4.9020202@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson a =E9crit :
> William Allen Simpson wrote:
>> Yes.  Just shuffling the pointers without ever freeing anything.  So=
,
>> there's nothing for call_rcu() to do, and nothing else to synchroniz=
e
>> (only the pointers).  This assumes that after _unlock_ any CPU cache
>> with an old pointer->expires will hit the _lock_ code, and that will
>> update *both* ->expires and the other array elements concurrently?
>>
> Reiterating, I've not found Documentation showing that this code work=
s:
>=20
> +    unsigned long jiffy =3D jiffies;
> +
> +    if (unlikely(time_after(jiffy, tcp_secret_generating->expires)))=
 {
> +        spin_lock_bh(&tcp_secret_locker);
> +        if (!time_after(jiffy, tcp_secret_generating->expires)) {
> +            /* refreshed by another */
> +            spin_unlock_bh(&tcp_secret_locker);
> +            memcpy(&xvp->cookie_bakery[0],
> +                   &tcp_secret_generating->secrets[0],
> +                   sizeof(tcp_secret_generating->secrets));
> +        } else {
>=20
> How is it ensured that an old tcp_secret_generating or an old ->expir=
es,
> followed by a spin_lock, has updated both?
>=20
> And even when both are updated, then every word of the ->secrets arra=
y has
> also been updated in the local cache?
>=20
> Is this a property of spin_lock()?  Or spin_unlock()?

Yes, =20

$ vi +1121 Documentation/memory-barriers.txt

 (1) LOCK operation implication:

     Memory operations issued after the LOCK will be completed after th=
e LOCK
     operation has completed.

     Memory operations issued before the LOCK may be completed after th=
e LOCK
     operation has completed.

 (2) UNLOCK operation implication:

     Memory operations issued before the UNLOCK will be completed befor=
e the
     UNLOCK operation has completed.

     Memory operations issued after the UNLOCK may be completed before =
the
     UNLOCK operation has completed.
