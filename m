From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 30 Jan 2015 14:39:45 +0100
Message-ID: <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	eyalpe-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422537297.21689.15.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 29 January 2015 at 14:14, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
> On Thu, 2015-01-29 at 12:48 +0100, Michal Kazior wrote:
>> Hi,
>>
>> I'm not subscribed to netdev list and I can't find the message-id so=
 I
>> can't reply directly to the original thread `BW regression after "tc=
p:
>> refine TSO autosizing"`.
>>
>> I've noticed a big TCP performance drop with ath10k
>> (drivers/net/wireless/ath/ath10k) on 3.19-rc5. Instead of 500mbps I
>> get 250mbps in my testbed.
>>
>> After bisecting I ended up at `tcp: refine TSO autosizing`. Revertin=
g
>> `tcp: refine TSO autosizing` and `tcp: Do not apply TSO segment limi=
t
>> to non-TSO packets` (for conflict free reverts) fixes the problem.
[...]
>> Any hints/ideas?
>>
>
> Hi Michal
>
> This patch restored original TSQ behavior, because the 1ms worth of d=
ata
> per flow had totally destroyed TSQ intent.
>
> vi +630 Documentation/networking/ip-sysctl.txt
[...]
> With this change and the stretch ack fixes, I got 37Gbps of throughpu=
t
> on a single flow, on a 40Gbit NIC (mlx4)
>
> If a driver needs to buffer more than tcp_limit_output_bytes=3D131072=
 to
> get line rate, I suggest that you either :
>
> 1) tweak tcp_limit_output_bytes, but its not practical from a driver.

I've briefly tried playing with this knob to no avail unfortunately. I
tried 256K, 1M - it didn't improve TCP performance. When I tried to
make it smaller (e.g. 16K) the traffic dropped even more so it does
have an effect. It seems there's some other limiting factor in this
case.


> 2) change the driver, knowing what are its exact requirements, by
> removing a fraction of skb->truesize at ndo_start_xmit() time as in :
>
> if ((skb->destructor =3D=3D sock_wfree ||
>      skb->restuctor =3D=3D tcp_wfree) &&
>     skb->sk) {
>     u32 fraction =3D skb->truesize / 2;
>
>     skb->truesize -=3D fraction;
>     atomic_sub(fraction, &skb->sk->sk_wmem_alloc);
> }

tcp_wfree isn't exported so I went and just did a quick hack and used
`if (skb->sk)` as the condition. Didn't help with TCP.

I wonder if this TSO patch is the single thing to blame. Maybe it's
just the trigger and something else is broken? I've been seeing some
UDP performance inconsistencies in 3.19 (I don't recall seeing these
in 3.18) - but maybe my perception is failing on me.

Anyway, thanks for the tips so far.


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
