From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 22:32:27 +0200
Message-ID: <1303331547.2690.37.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <201104202136.52568.casteyde.christian@free.fr>
	 <1303329300.2690.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Changli Gao <xiaosuo@gmail.com>
To: Christian Casteyde <casteyde.christian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47840 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab1DTUcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 16:32:32 -0400
Received: by wya21 with SMTP id 21so922615wya.19
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 13:32:31 -0700 (PDT)
In-Reply-To: <1303329300.2690.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 21:55 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le mercredi 20 avril 2011 =C3=A0 21:36 +0200, Christian Casteyde a =C3=
=A9crit :
>=20
> > I'm not sure it's the same problem anyway as I've said previously.
> > I append my config file used to build this kernel.
>=20
> This is not the same problem, and is a known false positive from skb
> reallocation. (skb_reserve() doesnt mark memory as initialized)=20
>=20
>=20

Please try following patch. It's a bit tricky, because network stack ha=
s
different functions to fill bytes in skb and change pointers/offsets in
it.

Alternative would be to change pskb_expand_head() to not copy zone
between skb->head and skb->data (might contain unitialized data)

Thanks


diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 79aafbb..3f2cba4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1252,6 +1252,7 @@ static inline int skb_tailroom(const struct sk_bu=
ff *skb)
  */
 static inline void skb_reserve(struct sk_buff *skb, int len)
 {
+	kmemcheck_mark_initialized(skb->data, len);
 	skb->data +=3D len;
 	skb->tail +=3D len;
 }


