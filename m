From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next 2/2] bnx2x: uses build_skb() in receive path
Date: Mon, 14 Nov 2011 17:36:45 +0100
Message-ID: <1321288605.2272.65.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AEC2@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	pstaszewski@itcare.pl, eilong@broadcom.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46029 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202Ab1KNQgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 11:36:51 -0500
Received: by bke11 with SMTP id 11so6073317bke.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 08:36:50 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEC2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 16:21 +0000, David Laight a =C3=A9crit=
 :
> > bnx2x uses following formula to compute its rx_buf_sz :
> >=20
> > dev->mtu + 2*L1_CACHE_BYTES + 14 + 8 + 8 + 2
> >=20
> > Then core network adds NET_SKB_PAD and SKB_DATA_ALIGN(sizeof(struct
> > skb_shared_info))
> >=20
> > Final allocated size for skb head on x86_64 (L1_CACHE_BYTES =3D 64,
> > MTU=3D1500) : 2112 bytes : SLUB/SLAB round this to 4096 bytes.
> >=20
> > Since skb truesize is then bigger than SK_MEM_QUANTUM, we have lot =
of
> > false sharing because of mem_reclaim in UDP stack.
> >=20
> > One possible way to half truesize is to reduce the need by 64 bytes
> > (2112 -> 2048 bytes)
>=20
> Would seem to be worth trying to reduce the size for systems
> where the L1 caches lines are 128 bytes - I think that includes
> some of the large ppc systems.
>=20
> If the alignment of the malloced memory can't be assumed/forced
> maybe one of the sub-structures could be dynamically placed
> before the data buffer?
>=20

What do you call sub-structure ?

Assuming you speak of skb_shared_info, moving at the start wont change
overall head size.

large ppc systems have 64Kb pages and SK_MEM_QUANTUM=3D64Kb, so it's le=
ss
a problem.

One other way would be to have a shinfo->nr_max_frags field, to reduce
max number of fragments, instead of assumin MAX_SKB_FRAGS, for 'legacy'
drivers.
