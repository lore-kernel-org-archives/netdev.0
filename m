From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net 1/2] mlxsw: spectrum: Fix refcount bug on span entries
Date: Fri, 11 Nov 2016 14:15:52 +0100
Message-ID: <20161111131552.GC1873@nanopsycho.orion>
References: <1478859642-2918-1-git-send-email-jiri@resnulli.us>
 <1478859642-2918-2-git-send-email-jiri@resnulli.us>
 <20161111124928.dbxqswx6akatsjrt@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        arkadis@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34945 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755999AbcKKNPz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 08:15:55 -0500
Received: by mail-wm0-f65.google.com with SMTP id a20so9428956wme.2
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 05:15:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161111124928.dbxqswx6akatsjrt@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 11, 2016 at 01:49:28PM CET, idosch@idosch.org wrote:
>On Fri, Nov 11, 2016 at 11:20:41AM +0100, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>> 
>> When binding port to a newly created span entry, its refcount is set 0
>> even though it has a bound port. That leeds to unexpected behaviour when
>
>s/leeds/leads/
>
>> the user tries to delete that port from the span entry.
>> 
>> Change the binding process to increase the refcount of the bound entry
>> even if the entry is newly created, and add warning on the process of
>> removing bound port from entry when its refcount is 0.
>> 
>> Fixes: 763b4b70afcd3 ("mlxsw: spectrum: Add support in matchall mirror TC offloading")
>
>You only need the first 12 characters.
>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 11 ++++++-----
>>  1 file changed, 6 insertions(+), 5 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
>> index 1ec0a4c..d75c1ff 100644
>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
>> @@ -269,17 +269,18 @@ static struct mlxsw_sp_span_entry
>>  	struct mlxsw_sp_span_entry *span_entry;
>>  
>>  	span_entry = mlxsw_sp_span_entry_find(port);
>> -	if (span_entry) {
>> -		span_entry->ref_count++;
>> -		return span_entry;
>> -	}
>> +	if (!span_entry)
>> +		span_entry = mlxsw_sp_span_entry_create(port);
>>  
>> -	return mlxsw_sp_span_entry_create(port);
>> +	span_entry->ref_count++;
>
>mlxsw_sp_span_entry_create() can return NULL. You can look at
>mlxsw_sp_fib_entry_get() for reference.

Right, missed that. Will fix. Thanks.
