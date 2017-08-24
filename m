From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 3/3 v7] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Thu, 24 Aug 2017 16:45:30 -0600
Message-ID: <0a82b4c5349c3201c58a13f90b5ea758@codeaurora.org>
References: <1503355019-12236-1-git-send-email-subashab@codeaurora.org>
 <1503355019-12236-4-git-send-email-subashab@codeaurora.org>
 <20170824.121559.882635807428126397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@aculab.com, marcel@holtmann.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43822 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753495AbdHXWpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:45:31 -0400
In-Reply-To: <20170824.121559.882635807428126397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +
>> +CFLAGS_rmnet.o := -I$(src)
> 
> You do not need this CFLAGS rule, the local include files are included
> using "" double quotes so it uses the local directory always.

Hi David

I'll remove this.

>> +static void rmnet_free_later(struct work_struct *work)
>> +{
>> +	struct rmnet_free_work *fwork;
>> +
>> +	fwork = container_of(work, struct rmnet_free_work, work);
>> +
>> +	rtnl_lock();
>> +	rmnet_delink(fwork->rmnet_dev, NULL);
>> +	rtnl_unlock();
>> +
>> +	kfree(fwork);
>> +}
> 
> This is racy and doesn't work properly.
> 
> When you schedule this work, the RTNL mutex is dropped.  Meanwhile
> another request can come in the associate this device.
> 
> Your work function will still run and erroneously unlink the object.
> 
> Furthermore, during this time that the RTNL mutex is dropped, people
> will see the unassociated device in the lists.
> 
> You have to atomically remove the object from all possible locations
> which provide external visibility of that object, before the RTNL
> mutex is dropped.
> 
> So you can defer the freeing, but you cannot defer the unlink
> operation.

I had incorrectly assumed earlier that the check in rtnl_newlink for
NLM_F_EXCL would guard against the scenario of re-associating a
device which was unlinked.

> 
> You probably need to move to RCU as well in order for all of this to
> work properly since scans of the lists occur in the data path which
> is completely asynchronous and not protected by the RTNL mutex.

I'll remove all the rtnl locks and checks and switch to rcu and post
an update.
