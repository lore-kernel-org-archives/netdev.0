From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: about latencies
Date: Fri, 24 Apr 2009 07:11:01 +0200
Message-ID: <49F149E5.1010304@cosmosbay.com>
References: <49F0E579.5030200@cosmosbay.com>	<alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com>	<49F0F49A.1050609@cosmosbay.com> <20090423.170408.228280954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse.brandeburg@intel.com, cl@linux-foundation.org,
	netdev@vger.kernel.org, mchan@broadcom.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60437 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbZDXFLz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 01:11:55 -0400
In-Reply-To: <20090423.170408.228280954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 24 Apr 2009 01:07:06 +0200
>=20
>> Brandeburg, Jesse a =E9crit :
>>> On Thu, 23 Apr 2009, Eric Dumazet wrote:
>>>> We could improve this.
>>>>
>>>> 1) dst_release at xmit time, should save a cache line ping-pong on=
 general case
>>>> 2) sock_wfree() in advance, done at transmit time (generally the t=
hread/cpu doing the send)
>>> how much does the effect socket accounting?  will the app then fill=
 the=20
>>> hardware tx ring all the time because there is no application throt=
tling=20
>>> due to delayed kfree?
>> tx ring is limited to 256 or 512 or 1024 elements, but yes this migh=
t
>> defeat udp mem accounting on sending side, unless using qdiscs...
>=20
> I'm pretty sure you really can't do this.  It's been suggested
> countless times in the past.
>=20
> The whole point of the socket send buffer limits is to eliminate
> the situation where one socket essentially hogs the TX queue of
> the device.


Yes agreed !

Without splitting sk_sleep and enlarging _again_ "struct sock",
cannot we make sock_def_write_space() smarter ? Avoiding scheduling
as the plague Your Honor :)

Dont we have a bit saying there is a sleeping writer ?

We dirty sk_callback_lock, and read "sk_wmem_alloc" and "sk_sndbuf",
we could first test a flag.



Actual function is : (not a patch, just as reference for convenience)

static void sock_def_write_space(struct sock *sk)
{
        read_lock(&sk->sk_callback_lock);

        /* Do not wake up a writer until he can make "significant"
         * progress.  --DaveM
         */
        if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) =
{
                if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
                        wake_up_interruptible_sync_poll(sk->sk_sleep, P=
OLLOUT |
                                                POLLWRNORM | POLLWRBAND=
);

                /* Should agree with poll, otherwise some programs brea=
k */
                if (sock_writeable(sk))
                        sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
        }

        read_unlock(&sk->sk_callback_lock);
}

Thank you

