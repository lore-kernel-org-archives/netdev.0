From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net_sched: sch_sfq: fix allot handling
Date: Thu, 16 Dec 2010 14:08:52 +0100
Message-ID: <1292504932.2883.110.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>
	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net>
	 <1292432120.3427.366.camel@edumazet-laptop>  <4D08F4F4.3050501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64903 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab0LPNI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 08:08:57 -0500
Received: by wyb28 with SMTP id 28so2473128wyb.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 05:08:56 -0800 (PST)
In-Reply-To: <4D08F4F4.3050501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 18:03 +0100, Patrick McHardy a=
 =C3=A9crit :
> On 15.12.2010 17:55, Eric Dumazet wrote:

> > I was thinking in allowing more packets per SFQ (but keep the 126 a=
ctive
> > flows limit), what do you think ?
>=20
> I keep forgetting why this limit exists, let me try to figure
> it out once more :)

I took a look, and found we already are at max, unless we change
sfq_index type (from u8 to u16)

SFQ_SLOTS is 128  (not really exist, but this is the number of slots)
SFQ_DEPTH is 128 (max depth for one slot)
Constraints are :
 SFQ_SLOTS < 256
 SFQ_DEPTH < 256
 SFQ_SLOTS + SFQ_DEPTH < 256, because of the dep[] array.

We could avoid the "struct sk_buff_head" structure with its un-needed
spinlock, and eventually group data for a given slot in a structure to
reduce number of cache lines we touch...

struct sfq_slot {
	struct sk_buff *first;
	struct sk_buff *last;
	u8 qlen;
	sfq_index next; /* dequeue chain */
	u16 hash;
	short allot;
	/* 16bit hole */
};

This would save 768 bytes on x86_64 (and much more if LOCKDEP is used)



