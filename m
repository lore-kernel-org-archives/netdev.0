From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] bonding: get netdev_rx_handler_unregister out of locks
Date: Tue, 2 Apr 2013 17:45:14 +0200
Message-ID: <20130402154514.GA29115@redhat.com>
References: <1364915716-4857-1-git-send-email-vfalico@redhat.com>
 <1364916362.5113.167.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932750Ab3DBPqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:46:24 -0400
Content-Disposition: inline
In-Reply-To: <1364916362.5113.167.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 02, 2013 at 08:26:02AM -0700, Eric Dumazet wrote:
>On Tue, 2013-04-02 at 17:15 +0200, Veaceslav Falico wrote:
>> Now that netdev_rx_handler_unregister contains synchronize_net(), we need
>> to call it outside of bond->lock, cause it might sleep. Also, remove the
>> already unneded synchronize_net().
>>
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>> ---
>>  drivers/net/bonding/bond_main.c |    3 +--
>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 11a8cb3..78c9e2d 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1975,12 +1975,11 @@ static int __bond_release_one(struct net_device *bond_dev,
>>  		return -EINVAL;
>>  	}
>>
>> +	write_unlock_bh(&bond->lock);
>>  	/* unregister rx_handler early so bond_handle_frame wouldn't be called
>>  	 * for this slave anymore.
>>  	 */
>>  	netdev_rx_handler_unregister(slave_dev);
>> -	write_unlock_bh(&bond->lock);
>> -	synchronize_net();
>>  	write_lock_bh(&bond->lock);
>>
>>  	if (!all && !bond->params.fail_over_mac) {
>
>Good catch, thanks !
>
>Acked-by: Eric Dumazet <edumazet@google.com>
>
>I'll send a net-next patch to remove the synchronize_net() from bridge
>code as well.

Nice, when I've checked it not to be under other locks I've somehow missed
the part where the bridge calls synchronize_net() right after it.

Thank you!

>
>
>
