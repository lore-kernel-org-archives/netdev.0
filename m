From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip_gre: lockless xmit
Date: Wed, 29 Sep 2010 20:43:14 +0200
Message-ID: <1285785794.2813.292.camel@edumazet-laptop>
References: <1285664747.2607.48.camel@edumazet-laptop>
	 <AANLkTinCz_0jHsMYW9_Wko78i9U20qefFbTYCQQQ-pz5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46809 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab0I2SnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 14:43:23 -0400
Received: by fxm4 with SMTP id 4so154921fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 11:43:22 -0700 (PDT)
In-Reply-To: <AANLkTinCz_0jHsMYW9_Wko78i9U20qefFbTYCQQQ-pz5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 10:33 -0700, Jesse Gross a =C3=A9c=
rit :

> The tx lock has another use here: to break local loops.  With this
> change, a misconfigured tunnel can bring down the machine with a stac=
k
> overflow.  There are clearly other ways to fix this that don't requir=
e
> a lock that restricts parallelism, such as a loop counter, but that's
> the way it is now.

Thats a very good point !

We could use a loop counter in the skb, but this use a bit of ram,
or percpu counters in tunnel drivers, to avoid a given level of
recursion.

/* this should be shared by all tunnels */
DEFINE_PER_CPU(tunnel_xmit_count);



tunnel_xmit()
{
if (__this_cpu_read(tunnel_xmit_count) >=3D LIMIT)
	goto tx_error;
__this_cpu_inc(tunnel_xmit_count);

=2E...

__IPTUNNEL_XMIT(tstats, &dev->stats);

__this_cpu_dec(tunnel_xmit_count),
return NETDEV_TX_OK;

}



