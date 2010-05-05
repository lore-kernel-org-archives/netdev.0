From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Wed, 05 May 2010 20:53:18 +0200
Message-ID: <1273085598.2367.233.camel@edumazet-laptop>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Bhaskar Dutta <bhaskie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:48221 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab0EESxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 14:53:24 -0400
Received: by bwz25 with SMTP id 25so3215866bwz.28
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 11:53:22 -0700 (PDT)
In-Reply-To: <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 mai 2010 =C3=A0 23:33 +0530, Bhaskar Dutta a =C3=A9crit =
:

> Hi,
>=20
> TSO, GSO and SG are already turned off.
> rx/tx checksumming is on, but that shouldn't matter, right?
>=20
> # ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off
>=20
> The bad packets are very small in size, most have no data at all (<30=
0 bytes).
>=20
> After adding some logs to kernel 2.6.31-12, it seems that
> tcp_v4_md5_hash_skb (function that calculates the md5 hash) is
> (might?) getting corrupt.
>=20
> The tcp4_pseudohdr (bp =3D &hp->md5_blk.ip4) structure's saddr, daddr
> and len fields get modified to different values towards the end of th=
e
> tcp_v4_md5_hash_skb function whenever there is a checksum error.
>=20
> The tcp4_pseudohdr (bp) is within the tcp_md5sig_pool (hp), which is
> filled up by tcp_get_md5sig_pool (which calls per_cpu_ptr).
>=20
> Using a local copy of the tcp4_pseudohdr in the same function
> tcp_v4_md5_hash_skb (copied all fields from the original
> tcp4_pseudohdr within the tcp_md5sig_pool) and calculating the md5
> checksum with the local  tcp4_pseudohdr seems to solve the issue
> (don't see bad packets for a hours in load tests, and without the
> change I can see them instantaneously in the load tests).
>=20
> I am still unable to figure out how this is happening. Please let me
> know if you have any pointers.

I am not familiar with this code, but I suspect same per_cpu data can b=
e
used at both time by a sender (process context) and by a receiver
(softirq context).

To trigger this, you need at least two active md5 sockets.

tcp_get_md5sig_pool() should probably disable bh to make sure current
cpu wont be preempted by softirq processing


Something like :

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fb5c66b..e232123 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1221,12 +1221,15 @@ struct tcp_md5sig_pool          *tcp_get_md5sig=
_pool(void)
 	struct tcp_md5sig_pool *ret =3D __tcp_get_md5sig_pool(cpu);
 	if (!ret)
 		put_cpu();
+	else
+		local_bh_disable();
 	return ret;
 }
=20
 static inline void             tcp_put_md5sig_pool(void)
 {
 	__tcp_put_md5sig_pool();
+	local_bh_enable();
 	put_cpu();
 }


