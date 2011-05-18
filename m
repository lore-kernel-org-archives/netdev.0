From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 14:47:15 +0200
Message-ID: <BANLkTinQAy+jq_VUwky2rxchomuN3avPQg@mail.gmail.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	<1305704885.2983.4.camel@edumazet-laptop>
	<BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
	<1305707358.2983.14.camel@edumazet-laptop>
	<4DD38B30.9090601@cn.fujitsu.com>
	<4DD3BC8F.9050802@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:62390 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933098Ab1ERMrP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 08:47:15 -0400
Received: by pvg12 with SMTP id 12so686499pvg.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 05:47:15 -0700 (PDT)
In-Reply-To: <4DD3BC8F.9050802@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18 Vladislav Yasevich <vladislav.yasevich@hp.com>:
> On 05/18/2011 05:02 AM, Wei Yongjun wrote:
>
>> fix the race between sctp_bind_addr_free() and sctp_bind_addr_confli=
ct(), maybe you just
>> need to remove the socket from the port hash before empty the bind a=
ddress list.
>> some thing like this, not test.
>>
>> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
>> index c8cc24e..924d846 100644
>> --- a/net/sctp/endpointola.c
>> +++ b/net/sctp/endpointola.c
>> @@ -268,12 +268,13 @@ static void sctp_endpoint_destroy(struct sctp_=
endpoint *ep)
>>
>> =A0 =A0 =A0 /* Cleanup. */
>> =A0 =A0 =A0 sctp_inq_free(&ep->base.inqueue);
>> - =A0 =A0 sctp_bind_addr_free(&ep->base.bind_addr);
>>
>> =A0 =A0 =A0 /* Remove and free the port */
>> =A0 =A0 =A0 if (sctp_sk(ep->base.sk)->bind_hash)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sctp_put_port(ep->base.sk);
>>
>> + =A0 =A0 sctp_bind_addr_free(&ep->base.bind_addr);
>> +
>> =A0 =A0 =A0 /* Give up our hold on the sock. */
>> =A0 =A0 =A0 if (ep->base.sk)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_put(ep->base.sk);
>>
>>
>
> I am not sure that this will guarantee avoidance of this crash, even =
though it is the right
> thing to do in general.
>
> We simply make the race condition much smaller and much harder to hit=
=2E =A0Potentially, one
> cpu may be doing lookup of the socket while the other is doing the de=
stroy. =A0If the lookup cpu
> finds the socket just as this code removes the socket from the hash, =
we still have this potential
> race condition.
>
> I agree with Eric, rcu_read_lock() is not strictly necessary, as what=
 we are really after is call_rcu()
> based destruction. =A0We need to delay memory destruction for the rcu=
 grace period.
>
> Thinking a little more about how bind_addr_clean() is used, it would =
probably benefit from getting
> converted to call_rcu(). =A0That function is used as local clean-up i=
n case of malloc failure; however,
> that doesn't preclude a potential race. =A0The fact that we do not ha=
ve this race simply points out that
> we don't have any kind of parallel lookup that can hit it (and the co=
de confirms it). =A0This doesn't
> mean that we wouldn't have it in the future.
>

OK then, at the end what Eric suggested is IMO valid:

diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index faf71d1..0025d90 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -144,10 +144,9 @@ static void sctp_bind_addr_clean(struct sctp_bind_=
addr *bp)
        struct list_head *pos, *temp;

        /* Empty the bind address list. */
-       list_for_each_safe(pos, temp, &bp->address_list) {
-               addr =3D list_entry(pos, struct sctp_sockaddr_entry, li=
st);
-               list_del(pos);
-               kfree(addr);
+       list_for_each_entry(pos, &bp->address_list, list) {
+               list_del_rcu(&pos->list);
+               call_rcu(&pos->rcu, sctp_local_addr_free);
                SCTP_DBG_OBJCNT_DEC(addr);
        }
 }


I will test this. Should be safe, avoid race not only in that case and
it consistent.

-Jacek
