From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ECN + pfifo_fast borked? (Was Re: [Bloat] shaper team forming
 up)
Date: Tue, 15 Mar 2011 19:28:34 +0100
Message-ID: <1300213714.2927.37.camel@edumazet-laptop>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org>
	 <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	 <1300134277.2649.19.camel@edumazet-laptop>
	 <1300164166.2649.70.camel@edumazet-laptop>
	 <87ipvlosvz.fsf_-_@cruithne.co.teklibre.org>
	 <1300169749.2649.142.camel@edumazet-laptop>
	 <3D05C1F1-B75E-426B-8267-6DB5323A839D@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave =?ISO-8859-1?Q?T=E4ht?= <d@taht.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jonathan Morton <chromatix99@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61503 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758218Ab1COS2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 14:28:42 -0400
Received: by bwz15 with SMTP id 15so825708bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 11:28:40 -0700 (PDT)
In-Reply-To: <3D05C1F1-B75E-426B-8267-6DB5323A839D@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 mars 2011 =C3=A0 19:09 +0200, Jonathan Morton a =C3=A9crit =
:
> On 15 Mar, 2011, at 8:15 am, Eric Dumazet wrote:
>=20
> > band 0 : high priority packets (like now)
> > band 1 : (old band 1, ECN capable flows)
> > band 2 : (old band 1, no ECN flows)
> > band 3 : low priority packets (old band 2)
>=20
> This seems good to me.  It would provide a concrete (if minor) entice=
ment to turn ECN on.
>=20
> =20

Here is a patch to implement that, on top of net-next-2.6 git tree

qdisc pfifo_fast 0: dev eth1 root refcnt 2 bands 4 priomap  2 1 3 3 2 3=
 0 0 2 2 2 2 2 2 2 2
 Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20


diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c84b659..95ddf54 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -412,19 +412,39 @@ static struct Qdisc noqueue_qdisc =3D {
 };
=20
=20
-static const u8 prio2band[TC_PRIO_MAX + 1] =3D {
-	1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
+/* 4-band FIFO queue: old style, but should be a bit faster than
+   generic prio+fifo combination.
+ */
+
+enum {
+	BAND_HIGH_PRIO,
+	BAND_MEDIUM_ECN_PRIO,
+	BAND_MEDIUM_PRIO,
+	BAND_LOW_PRIO,
+
+	PFIFO_FAST_BANDS
 };
=20
-/* 3-band FIFO queue: old style, but should be a bit faster than
-   generic prio+fifo combination.
+/*
+ * We give a litle incent to ECN flows
  */
+static const u8 prio2band[TC_PRIO_MAX + 1] =3D {
+	[TC_PRIO_BESTEFFORT]	=3D BAND_MEDIUM_PRIO,
+	[TC_PRIO_FILLER]	=3D BAND_MEDIUM_ECN_PRIO,
+	[TC_PRIO_BULK]		=3D BAND_LOW_PRIO,
+	[TC_PRIO_BULK + 1]	=3D BAND_LOW_PRIO,
+	[TC_PRIO_INTERACTIVE_BULK] =3D BAND_MEDIUM_PRIO,
+	[TC_PRIO_INTERACTIVE_BULK + 1] =3D BAND_LOW_PRIO,
+	[TC_PRIO_INTERACTIVE]	=3D BAND_HIGH_PRIO,
+	[TC_PRIO_CONTROL]	=3D BAND_HIGH_PRIO,
+
+	[TC_PRIO_CONTROL+1 ... TC_PRIO_MAX] =3D BAND_MEDIUM_PRIO,
+};
=20
-#define PFIFO_FAST_BANDS 3
=20
 /*
  * Private data for a pfifo_fast scheduler containing:
- * 	- queues for the three band
+ * 	- queues for the four bands
  * 	- bitmap indicating which of the bands contain skbs
  */
 struct pfifo_fast_priv {
@@ -436,9 +456,13 @@ struct pfifo_fast_priv {
  * Convert a bitmap to the first band number where an skb is queued, w=
here:
  * 	bitmap=3D0 means there are no skbs on any band.
  * 	bitmap=3D1 means there is an skb on band 0.
- *	bitmap=3D7 means there are skbs on all 3 bands, etc.
+ * 	bitmap=3D2 means there is an skb on band 1.
+ *	bitmap=3D15 means there are skbs on all 4 bands.
  */
-static const int bitmap2band[] =3D {-1, 0, 1, 0, 2, 0, 1, 0};
+static const int bitmap2band[1 << PFIFO_FAST_BANDS] =3D {
+	-1, 0, 1, 0, 2, 0, 1, 0,
+	 3, 0, 1, 0, 2, 0, 1, 0
+};
=20
 static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *p=
riv,
 					     int band)


