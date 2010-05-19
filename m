From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: any change in socket systemcall or packet_mmap regarding
 multiqueue nic?
Date: Wed, 19 May 2010 14:28:05 +0200
Message-ID: <1274272085.2766.18.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC786@MILEXCH2.ds.jdsu.net>
	 <1274243074.2485.28.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC946@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45245 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab0ESM2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 08:28:08 -0400
Received: by wwb22 with SMTP id 22so533836wwb.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 05:28:07 -0700 (PDT)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC946@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 mai 2010 =C3=A0 03:36 -0700, Jon Zhou a =C3=A9crit :
>=20
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Sent: Wednesday, May 19, 2010 12:25 PM
> To: Jon Zhou
> Cc: netdev@vger.kernel.org
> Subject: Re: any change in socket systemcall or packet_mmap regarding=
 multiqueue nic?
>=20
> Le mardi 18 mai 2010 =C3=A0 19:55 -0700, Jon Zhou a =C3=A9crit :
> > hi
> > the multiqueue networking can utilize multi-core to process packets=
 from multiqueue nic,
> > but any change in related userspace application part, such as socke=
t system call, packet_mmap? these userspace API can also utilize multic=
ore to process packets from kernel?
> > otherwise they have to read data in serialization
> >=20
>=20
> Thats a bit general question. Works are in progress.
>=20
> So far, you can use a new condition in filters to match a given queue
> index for incoming packets. A sniffer could setup N different sockets=
 to
> receive data from N NIC queues.
>=20
> jon->is it something like "ioctl(fd,SOL_SOCKET,queue_id...),could you=
 tell the keyword?

keyword is BPF (used in libpcap) and SKF_AD_QUEUE instruction

Kernel part is ready :

commit d19742fb1c68e6db83b76e06dea5a374c99e104f
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Tue Oct 20 01:06:22 2009 -0700

    filter: Add SKF_AD_QUEUE instruction
   =20
    It can help being able to filter packets on their queue_mapping.
   =20
    If filter performance is not good, we could add a "numqueue" field
    in struct packet_type, so that netif_nit_deliver() and other
functions
    can directly ignore packets with not expected queue number.
   =20
    Lets experiment this simple filter extension first.
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 909193e..bb3b435 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -124,7 +124,8 @@ struct sock_fprog   /* Required for
SO_ATTACH_FILTER. */
 #define SKF_AD_NLATTR  12
 #define SKF_AD_NLATTR_NEST     16
 #define SKF_AD_MARK    20
-#define SKF_AD_MAX     24
+#define SKF_AD_QUEUE   24
+#define SKF_AD_MAX     28
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
=20
diff --git a/net/core/filter.c b/net/core/filter.c
index e3987e1..08db7b9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -306,6 +306,9 @@ load_b:
                case SKF_AD_MARK:
                        A =3D skb->mark;
                        continue;
+               case SKF_AD_QUEUE:
+                       A =3D skb->queue_mapping;
+                       continue;
                case SKF_AD_NLATTR: {
                        struct nlattr *nla;
=20



