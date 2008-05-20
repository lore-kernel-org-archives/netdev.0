From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 18:14:15 -0700
Message-ID: <m1lk257p5k.fsf@frodo.ebiederm.org>
References: <bug-10737-10286@http.bugzilla.kernel.org/>
	<20080517141036.d8f3c768.akpm@linux-foundation.org>
	<482F88DE.8090508@trash.net>
	<20080517215641.acb94677.akpm@linux-foundation.org>
	<48301BE0.9040907@trash.net> <48302E09.8080701@trash.net>
	<48304BB5.7090805@trash.net> <1211183642.9966.6.camel@iris.sw.ru>
	<48321AC2.90500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@openvz.org>,
	Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	devzero@web.de, Robert Olsson <robert.olsson@its.uu.se>,
	Pavel Emelyanov <xemul@openvz.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58484 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571AbYETBU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 21:20:26 -0400
In-Reply-To: <48321AC2.90500@candelatech.com> (Ben Greear's message of "Mon,
	19 May 2008 17:26:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> Denis V. Lunev wrote:
>
>> could you consider this preliminary patch? It fixes the problem for me
>> and Pavel agrees with it.
>>
>> The problem is that module_get is called for each file opening while
>> module_put is called only when /proc inode is destroyed. So, lets put
>> module counter if we are dealing with already initialised inode.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


>> ------------------------------------------------------------------------
>>
>> diff --git a/fs/proc/inode.c b/fs/proc/inode.c
>> index 6f4e8dc..b08d100 100644
>> --- a/fs/proc/inode.c
>> +++ b/fs/proc/inode.c
>> @@ -425,7 +425,8 @@ struct inode *proc_get_inode(struct super_block *sb,
> unsigned int ino,
>>  			}
>>  		}
>>  		unlock_new_inode(inode);
>> -	}
>> +	} else
>> +	       module_put(de->owner);
>>  	return inode;
>>   out_ino:
>
> I just tested this and it seems to fix my problem (I applied this to 2.6.25
> kernel).

Looks good and it seems to follow the characterization.
proc_lookup -> proc_lookup_de -> proc_get_inode 

Will happen each time a dentry is created for a name/inode.
Which is much easier now with multiple instances in
proc.

It looks like this bug an old bug that has existed since

commit e9543659715602e3180f00a227bb6db34141ac41
Author: Kirill Korotaev <dev@sw.ru>
Date:   Sun Oct 30 15:02:26 2005 -0800

    [PATCH] proc: fix of error path in proc_get_inode()
    
    This patch fixes incorrect error path in proc_get_inode(), when module
    can't be get due to being unloaded.  When try_module_get() fails, this
    function puts de(!) and still returns inode with non-getted de.
    
    There are still unresolved known bugs in proc yet to be fixed:
    - proc_dir_entry tree is managed without any serialization
    - create_proc_entry() doesn't setup de->owner anyhow,
       so setting it later manually is inatomic.
    - looks like almost all modules do not care whether
       it's de->owner is set...
    
    Signed-Off-By: Denis Lunev <den@sw.ru>
    Signed-Off-By: Kirill Korotaev <dev@sw.ru>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

Eric
