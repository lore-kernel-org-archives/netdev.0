From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next] bonding: use rtnl_deref in
 bond_change_rx_flags()
Date: Wed, 16 Jul 2014 11:34:11 +0200
Message-ID: <20140716093411.GB12030@mikrodark.usersys.redhat.com>
References: <1405495467-16187-1-git-send-email-vfalico@gmail.com>
 <1405501548.10255.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:58064 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaGPJhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 05:37:10 -0400
Received: by mail-wi0-f178.google.com with SMTP id hi2so966796wib.5
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 02:37:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405501548.10255.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2014 at 11:05:48AM +0200, Eric Dumazet wrote:
>On Wed, 2014-07-16 at 09:24 +0200, Veaceslav Falico wrote:
>> As it's always called with RTNL held, via dev_set_allmulti/promiscuity.
>>
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index d643807..2998710 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -498,7 +498,7 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
>>  	int err = 0;
>>
>>  	if (bond_uses_primary(bond)) {
>> -		struct slave *curr_active = bond_deref_active_protected(bond);
>> +		struct slave *curr_active = rtnl_dereference(bond->curr_active_slave);
>>
>>  		/* write lock already acquired */
>
>This seems dubious to me. What really protects curr_active_slave being
>modified ?

That's indeed all messed up, also I assume you've meant "c_a_s variable
changes its value" but not "the slave's internal parts are modified".

>
>Considering the presence of the previous comment, I assumed the sync
>point was the write lock. Not rtnl.

Good point, this comment should be removed. I'll send v2 if we'll agree
with this one removed.

>
>If write lock is never held without rtnl, then maybe the write lock is
>useless, I don't know.

The c_a_s is set under rtnl, i.e. we can't have another slave there while
we hold the rtnl.

However, quite a few functions (alb usually) uses the c_a_s write lock to
assure that the *current* slave isn't modified again (like - by re-entering
this function) or in parallel with some another function, or even changing
the current slave to which c_a_s points.

i.e. rtnl prevents changing the slave to which c_a_s points, while the
spinlock protects the interiors of the slave from changing, and the slave
itself.

So, the write lock isn't exactly useless currently, however it should go
away.

Yes, I know it's a mess. :(

>
>But after your patch its not really consistent and we increase
>confusion.
>
>>  		if (curr_active)
>> @@ -524,7 +524,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
>>  	int err = 0;
>>
>>  	if (bond_uses_primary(bond)) {
>> -		struct slave *curr_active = bond_deref_active_protected(bond);
>> +		struct slave *curr_active = rtnl_dereference(bond->curr_active_slave);
>>
>>  		/* write lock already acquired */
>>  		if (curr_active)
>
>
