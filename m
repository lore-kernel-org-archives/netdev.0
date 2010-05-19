From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: any change in socket systemcall or packet_mmap regarding
 multiqueue nic?
Date: Wed, 19 May 2010 06:24:34 +0200
Message-ID: <1274243074.2485.28.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC786@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39901 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab0ESEYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 00:24:38 -0400
Received: by wyg36 with SMTP id 36so130428wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 21:24:37 -0700 (PDT)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC786@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 mai 2010 =C3=A0 19:55 -0700, Jon Zhou a =C3=A9crit :
> hi
> the multiqueue networking can utilize multi-core to process packets f=
rom multiqueue nic,
> but any change in related userspace application part, such as socket =
system call, packet_mmap? these userspace API can also utilize multicor=
e to process packets from kernel?
> otherwise they have to read data in serialization
>=20

Thats a bit general question. Works are in progress.

So far, you can use a new condition in filters to match a given queue
index for incoming packets. A sniffer could setup N different sockets t=
o
receive data from N NIC queues.

=46or tcp flows, nothing is needed, since all packets of a given flow
should use same queue.

However the current tx queue selection is based on sk->sk_hash value, a
linux side computed value, and this differs from the rx queue selection
done by the NIC firmware. So tx packets use a different queue than rx
packets for a given tcp flow. This means this is suboptimal: tcp_ack()
can run on a different cpu than TX completion handler.

TX completion handler touches the cloned skb that TCP used to transmit
buffer. Its freeing touches the dataref atomic counter in packet.

This should be addressed somehow.


