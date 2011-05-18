From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 17:02:40 +0800
Message-ID: <4DD38B30.9090601@cn.fujitsu.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>	 <1305704885.2983.4.camel@edumazet-laptop>	 <BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com> <1305707358.2983.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63020 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755814Ab1ERJDF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 05:03:05 -0400
In-Reply-To: <1305707358.2983.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Le mercredi 18 mai 2011 =C3=A0 10:06 +0200, Jacek Luczak a =C3=A9crit=
 :
>> 2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
>>> If you're removing items from this list, you must be a writer here,=
 with
>>> exclusive access. So rcu_read_lock()/rcu_read_unlock() is not neces=
sary.
>> I could agree to some extend ... but strict RCU section IMO is neede=
d here.
>> I can check this if the issue exists.
>>
> I can tell you for sure rcu_read_lock() is not needed here. Its only
> showing confusion from code's author.
>
> Please read Documentation/RCU/listRCU.txt for concise explanations,
> line 117.
>
>
>>> Therefore, I guess following code is better :
>>>
>>> list_for_each_entry(addr, &bp->address_list, list) {
>>>        list_del_rcu(&addr->list);
>>>        call_rcu(&addr->rcu, sctp_local_addr_free);
>>>        SCTP_DBG_OBJCNT_DEC(addr);
>>> }
>>>
>>> Then, why dont you fix sctp_bind_addr_clean() instead ?
>>>
>>> if 'struct sctp_sockaddr_entry' is recu protected, then all frees s=
hould
>>> be protected as well.
>> The _clean() as claimed by Vlad is called many times from various pl=
aces
>> in code and this could give a overhead. I guess Vlad would need to c=
omment.
> I guess a full review of this code is needed. You'll have to prove
> sctp_bind_addr_clean() is always called after one RCU grace period if
> you want to leave it as is.
>
> You cant get RCU for free, some rules must be followed or you risk
> crashes.
>

fix the race between sctp_bind_addr_free() and sctp_bind_addr_conflict(=
), maybe you just
need to remove the socket from the port hash before empty the bind addr=
ess list.
some thing like this, not test.

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index c8cc24e..924d846 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -268,12 +268,13 @@ static void sctp_endpoint_destroy(struct sctp_end=
point *ep)
=20
 	/* Cleanup. */
 	sctp_inq_free(&ep->base.inqueue);
-	sctp_bind_addr_free(&ep->base.bind_addr);
=20
 	/* Remove and free the port */
 	if (sctp_sk(ep->base.sk)->bind_hash)
 		sctp_put_port(ep->base.sk);
=20
+	sctp_bind_addr_free(&ep->base.bind_addr);
+
 	/* Give up our hold on the sock. */
 	if (ep->base.sk)
 		sock_put(ep->base.sk);


