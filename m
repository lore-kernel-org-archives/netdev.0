From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Sat, 17 Apr 2010 10:38:25 -0700
Message-ID: <h2h65634d661004171038g75160e7avae118dfd1cb1441d@mail.gmail.com>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
	 <1271443994.16881.4249.camel@edumazet-laptop>
	 <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com>
	 <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:17919 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab0DQRia convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 13:38:30 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o3HHcSb7021942
	for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 19:38:28 +0200
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by kpbe17.cbf.corp.google.com with ESMTP id o3HHcQGg018768
	for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 10:38:27 -0700
Received: by pwj5 with SMTP id 5so2369794pwj.20
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 10:38:25 -0700 (PDT)
In-Reply-To: <1271520633.16881.4754.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> With attached patch, I reached
>
> Throughput 4465.13 MB/sec 16 procs
>
> RFS better than no RPS/RFS :)
>
> So, the old idea to make rxhash consistent (same value in both
> directions) is a win for some workloads (Consider connection tracking=
 /
> firewalling)
>
> port1 =3D ...
> port2 =3D ...
> addr1 =3D ...
> addr2 =3D ...
> if (addr1 > addr2)
> =A0 =A0 =A0 =A0exchange(addr1, addr2)
> if (port1 > port2)
> =A0 =A0 =A0 =A0exchange(port, port2)
>
> hash =3D jhash(addr1, addr2, (port1<<16)+port2, ...)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7abf959..6b757ff 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2280,8 +2280,10 @@ static int get_rps_cpu(struct net_device *dev,
> struct sk_buff *skb,
> =A0 =A0 =A0 =A0case IPPROTO_AH:
> =A0 =A0 =A0 =A0case IPPROTO_SCTP:
> =A0 =A0 =A0 =A0case IPPROTO_UDPLITE:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pskb_may_pull(skb, (ihl * 4) + 4))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ports =3D *((u32 *) (sk=
b->data + (ihl * 4)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pskb_may_pull(skb, (ihl * 4) + 4)) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 *_ports =3D (u16 *)=
(skb->data + (ihl * 4));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ports =3D _ports[0] ^ _=
ports[1];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0default:
>
That's cool!, but I still like the idea that this hash is treated as
an opaque value, getting the hash from the device to avoid the jhash
or cache misses on the packet can also be a win...  Maybe connection
tracking/firewall could use the skb->rxhash which provides the
consistency and also eliminates the need to do more jhashes.


>
>
