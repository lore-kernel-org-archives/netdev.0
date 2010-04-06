From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] rfs: Receive Flow Steering
Date: Tue, 6 Apr 2010 07:25:56 -0700
Message-ID: <v2n65634d661004060725paf401b5bg1ee692caef565d33@mail.gmail.com>
References: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
	 <1270559096.2081.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:22160 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab0DFO0B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 10:26:01 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [10.3.21.1])
	by smtp-out.google.com with ESMTP id o36EPww6026969
	for <netdev@vger.kernel.org>; Tue, 6 Apr 2010 07:25:59 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by hpaq1.eem.corp.google.com with ESMTP id o36EPuCi014316
	for <netdev@vger.kernel.org>; Tue, 6 Apr 2010 16:25:57 +0200
Received: by pwj9 with SMTP id 9so1150267pwj.5
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 07:25:56 -0700 (PDT)
In-Reply-To: <1270559096.2081.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Running on a preprod machine here, seems fine.
>
> Some questions :
>
> 1) The need to add "rps_flow_entries=3Dxxx" at boot time is problemat=
ic.
> =A0 Maybe we can allow it being dynamic (and use vmalloc() instead of
> alloc_large_system_hash())
>
Okay, could be a sysctl with vmalloc.

> 2) inet_rps_save_rxhash(sk, skb->rxhash);
>
> =A0 =A0 =A0 =A0It should have a check to make sure some part of the s=
tack doesnt feed
> many different rxhash for a given socket (Make sure we dont pollute f=
low
> table with pseudo random values)
>
If packets for a connection are always received on the same device, is
it reasonable to assume the rxhash is constant for that connection?

I suppose it's possible that packets for a same sockets are being
constantly received on two different devices that are giving different
rxhashes.  This would already be bad in that OOO is probably happening
anyway.  I don't know if thrashing the sock_flow_table is going to
aggravate this scenario much.

Are there any other degenerative cases you're worried about?

> 3) UDP connected sockets dont benefit of RFS currently
> =A0 (Not sure many apps use connected UDP sockets, I do have some of =
them
> in house)
>
Makes sense to support that.

> I am trying following code for IPV4 only :
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 7af756d..5c2d37a 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1216,6 +1216,7 @@ int udp_disconnect(struct sock *sk, int flags)
> =A0 =A0 =A0 =A0sk->sk_state =3D TCP_CLOSE;
> =A0 =A0 =A0 =A0inet->inet_daddr =3D 0;
> =A0 =A0 =A0 =A0inet->inet_dport =3D 0;
> + =A0 =A0 =A0 inet_rps_save_rxhash(sk, 0);
> =A0 =A0 =A0 =A0sk->sk_bound_dev_if =3D 0;
> =A0 =A0 =A0 =A0if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_reset_saddr(sk);
> @@ -1257,8 +1258,12 @@ EXPORT_SYMBOL(udp_lib_unhash);
>
> =A0static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *sk=
b)
> =A0{
> - =A0 =A0 =A0 int rc =3D sock_queue_rcv_skb(sk, skb);
> + =A0 =A0 =A0 int rc;
> +
> + =A0 =A0 =A0 if (inet_sk(sk)->inet_daddr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_rps_save_rxhash(sk, skb->rxhash);
>
> + =A0 =A0 =A0 rc =3D sock_queue_rcv_skb(sk, skb);
> =A0 =A0 =A0 =A0if (rc < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int is_udplite =3D IS_UDPLITE(sk);
>
>
>
>
