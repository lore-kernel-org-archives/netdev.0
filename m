From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 08:13:30 +0100
Message-ID: <49C9D99A.2040900@cosmosbay.com>
References: <49C380A6.4000904@cosmosbay.com> <20090324.234354.43714160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53660 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbZCYHNl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:13:41 -0400
In-Reply-To: <20090324.234354.43714160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 20 Mar 2009 12:40:22 +0100
>=20
>> I believe we can release dst in dev_queue_xmit(), while cpu cache is
>> hot, since caller of dev_queue_xmit() had to hold a reference on dst
>> right before. This reduce work to be done by softirq handler, and
>> decrease cache misses.
>>
>=20
> This will break various packet schedulers and classifiers.
>=20
> Heck sch_sfq.c even uses skb->dst as part of it's flow hash
> function :-)

Well, as one of the hash perturbator, for other protocols than
IPV4 & IPV6...

        default:
                h =3D (unsigned long)skb->dst ^ skb->protocol;
                h2 =3D (unsigned long)skb->sk;
        }

        return sfq_fold_hash(q, h, h2);

But teql indeed mandates dst in __teql_resolve()=20

Darn...

This dst freeing should be done very late then, in the NIC driver itsel=
f, just
before giving skb to hardware, or right before in dev_hard_start_xmit()

If done in dev_hard_start_xmit(), skb could be requeued (because of NET=
DEV_TX_BUSY).
Then if requeued, maybe at this time, dst being NULL is not a problem ?

Thanks a lot David

