From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 10:06:01 +0200
Message-ID: <BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	<1305704885.2983.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:43446 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab1ERIGC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 04:06:02 -0400
Received: by pvg12 with SMTP id 12so596555pvg.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 01:06:01 -0700 (PDT)
In-Reply-To: <1305704885.2983.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 18 mai 2011 =E0 09:01 +0200, Jacek Luczak a =E9crit :
>> During the sctp_close() call, we do not use rcu primitives to
>> destroy the address list attached to the endpoint. =A0At the same
>> time, we do the removal of addresses from this list before
>> attempting to remove the socket from the port hash
>>
>> As a result, it is possible for another process to find the socket
>> in the port hash that is in the process of being closed. =A0It then
>> proceeds to traverse the address list to find the conflict, only
>> to have that address list suddenly disappear without rcu() critical
>> section.
>>
>> This can result in a kernel crash with general protection fault or
>> kernel NULL pointer dereference.
>>
>> Fix issue by closing address list removal inside RCU critical
>> section.
>>
>> Signed-off-by: Jacek Luczak <luczak.jacek@gmail.com>
>> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>>
>> ---
>> =A0bind_addr.c | =A0 12 ++++++++++--
>> =A01 file changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
>> index faf71d1..19d1329 100644
>> --- a/net/sctp/bind_addr.c
>> +++ b/net/sctp/bind_addr.c
>> @@ -155,8 +155,16 @@ static void sctp_bind_addr_clean(struct sctp_bi=
nd_addr *bp)
>> =A0/* Dispose of an SCTP_bind_addr structure =A0*/
>> =A0void sctp_bind_addr_free(struct sctp_bind_addr *bp)
>> =A0{
>> - =A0 =A0 =A0 /* Empty the bind address list. */
>> - =A0 =A0 =A0 sctp_bind_addr_clean(bp);
>> + =A0 =A0 =A0 struct sctp_sockaddr_entry *addr;
>> +
>> + =A0 =A0 =A0 /* Empty the bind address list inside RCU section. */
>> + =A0 =A0 =A0 rcu_read_lock();
>> + =A0 =A0 =A0 list_for_each_entry_rcu(addr, &bp->address_list, list)=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_rcu(&addr->list);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_rcu(&addr->rcu, sctp_local_addr_f=
ree);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SCTP_DBG_OBJCNT_DEC(addr);
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 rcu_read_unlock();
>>
>
> Sorry this looks odd.
>
> If you're removing items from this list, you must be a writer here, w=
ith
> exclusive access. So rcu_read_lock()/rcu_read_unlock() is not necessa=
ry.

I could agree to some extend ... but strict RCU section IMO is needed h=
ere.
I can check this if the issue exists.

> Therefore, I guess following code is better :
>
> list_for_each_entry(addr, &bp->address_list, list) {
> =A0 =A0 =A0 =A0list_del_rcu(&addr->list);
> =A0 =A0 =A0 =A0call_rcu(&addr->rcu, sctp_local_addr_free);
> =A0 =A0 =A0 =A0SCTP_DBG_OBJCNT_DEC(addr);
> }
>
> Then, why dont you fix sctp_bind_addr_clean() instead ?
>
> if 'struct sctp_sockaddr_entry' is recu protected, then all frees sho=
uld
> be protected as well.

The _clean() as claimed by Vlad is called many times from various place=
s
in code and this could give a overhead. I guess Vlad would need to comm=
ent.

-Jacek
