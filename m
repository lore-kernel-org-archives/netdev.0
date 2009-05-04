From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 04 May 2009 09:08:00 +0200
Message-ID: <49FE9450.7010901@cosmosbay.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55626 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbZEDHIL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 03:08:11 -0400
In-Reply-To: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> This is an update of the receive packet steering patch (RPS) based on=
 received
> comments (thanks for all the comments).  Improvements are:
>=20
> 1) Removed config option for the feature.
> 2) Made scheduling of backlog NAPI devices between CPUs lockless and =
much
> simpler.
> 3) Added new softirq to do defer sending IPIs for coalescing.
> 4) Imported hash from simple_rx_hash.  Eliminates modulo operation to=
 convert
> hash to index.
> 5) If no cpu is found for packet steering, then netif_receive_skb pro=
cesses
> packet inline as before without queueing.  In paritcular if RPS is no=
t
> configured on a device the receive path is unchanged from current for
> NAPI devices (one additional conditional).
>=20

Thinking again about this Tom, I also think something might/should be d=
one
for the TX completion path. As spotted by earlier patches last weeks,
TX completion on TCP/UDP can do a lot of stuff, including wakeups (that
can be really expensive), and touching many socket cache lines.

Each cpu can call device transmit on its own, but TX completion path is=
 taken
by one cpu only, and this can use all this cpu cycles.

(It would make sense that skb freeing is done by the same cpu that did =
the alloc,
especially on NUMA setups)

As this TX completion path should use same hash than one selected for R=
X (as
done in your patch), maybe this is something you could add, if we know
current cpu is saturated by softirq handling.


One comment about simple_hashrnd check/initialization in get_rps_cpu()

+	if (unlikely(!simple_hashrnd_initialized)) {
+		get_random_bytes(&simple_hashrnd, 4);
+		simple_hashrnd_initialized =3D 1;
+	}
+

You could move it to rps_map_len/rps_map initialization in store_rps_cp=
us()
to save a few cycles per packet.

