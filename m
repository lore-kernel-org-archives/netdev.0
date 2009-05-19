From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] sch_teql: should not dereference skb after ndo_start_xmit
Date: Tue, 19 May 2009 03:34:03 +0200
Message-ID: <4A120C8B.80108@cosmosbay.com>
References: <4A11391D.8060503@cosmosbay.com> <20090518.151256.217066131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jussi.kivilinna@mbnet.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37751 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbZESBeR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 21:34:17 -0400
In-Reply-To: <20090518.151256.217066131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 18 May 2009 12:31:57 +0200
>=20
>> [PATCH] sch_teql: should not dereference skb after ndo_start_xmit()
>>
>> It is illegal to dereference a skb after a successful ndo_start_xmit=
()
>> call. We must store skb length in a local variable instead.
>>
>> Bug was introduced in 2.6.27 by commit 0abf77e55a2459aa9905be4b226e4=
729d5b4f0cb
>> (net_sched: Add accessor function for packet length for qdiscs)
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Applied and queued up for -stable, thanks!

Looking again at teql_master_xmit(), I wonder if there is another
problem in it.

    int subq =3D skb_get_queue_mapping(skb);

But as a matter of fact, following code assumes subq is 0

struct netdev_queue *slave_txq =3D netdev_get_tx_queue(slave, 0);
=2E..
if (__netif_subqueue_stopped(slave, subq) ||
=2E..

Either we should set subq to 0, or call dev_pick_tx() to better
take into account multi queue slaves ?

(As teqlN has one queue, I assume original dev_queue_xmit() will
set skb queue_mapping to 0 before entering teql_master_xmit(), but
maybe other paths could call teql_master_xmit() not through dev_queue_x=
mit() ?

Oh well, time for sleeping a bit...

