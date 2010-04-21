From: Sasha Levin <sasha@comsleep.com>
Subject: [PATCH] ipv4: handle GARPs specially when updating neighbors
Date: Wed, 21 Apr 2010 01:02:02 -0700
Message-ID: <EF944FCCC928C64A875FE3EA1A41062C38FD52F406@P3PW5EX1MB02.EX1.SECURESERVER.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plex1out01.prod.phx3.secureserver.net ([72.167.180.17]:32869
	"HELO p3plex1out01.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752444Ab0DUICH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 04:02:07 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sasha Levin <sasha@comsleep.com>

We are currently testing IP fail-over on storage devices, and have obse=
rved an issue with the IP transfer from one device to another.

Assuming we have 2 storage devices A and B, and a server C which uses t=
he storage, the scenario is:

1. Device A sends an ARP request which server C sees =96 server C updat=
es it=92s ARP table with the MAC of device A.
2. Device A fails, Device B takes over the IP and sends out a GARP.
3. Even though device C sees the GARP, it ignores it and keeps trying t=
o communicate with device A until the entry is removed from its cache a=
nd a new ARP request is generated.

The code which causes this is located in arp_process@/net/ipv4/arp.c:

override =3D time_after(jiffies, n->updated + n->parms->locktime);

/* Broadcast replies and request packets
=A0=A0 do not assert neighbour reachability.
=A0*/
if (arp->ar_op !=3D htons(ARPOP_REPLY) ||
=A0=A0=A0 skb->pkt_type !=3D PACKET_HOST)
=A0=A0=A0=A0=A0=A0=A0 state =3D NUD_STALE;
neigh_update(n, sha, state, override ? NEIGH_UPDATE_F_OVERRIDE : 0);
neigh_release(n);

According to the code, this scenario happens because the kernel ignores=
 any ARP updates which happened in a short period after the previous AR=
P update. The reason which was stated in the comments is =A0=93If sever=
al different ARP replies follows back-to-back, use the FIRST one. It is=
 possible, if several proxy agents are active. Taking the first reply p=
revents arp trashing and chooses the fastest router.=94.

This, however, doesn=92t take into account GARPs which are not being se=
nt by ARP proxies anyway and just ignores them too =96 causing a loss o=
f communication for over a minute until the ARP cache refreshes.

Signed-off-by: Sasha Levin <sasha@comsleep.com>
---
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1a9dd66..caa2093 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -876,8 +876,11 @@ static int arp_process(struct sk_buff *skb)
 		   use the FIRST one. It is possible, if several proxy
 		   agents are active. Taking the first reply prevents
 		   arp trashing and chooses the fastest router.
+
+		   GARPs are always updating the cache since they can
+		   originate from different devices with the same IP.
 		 */
-		override =3D time_after(jiffies, n->updated + n->parms->locktime);
+		override =3D (sip =3D=3D tip) || time_after(jiffies, n->updated + n-=
>parms->locktime);
=20
 		/* Broadcast replies and request packets
 		   do not assert neighbour reachability.

