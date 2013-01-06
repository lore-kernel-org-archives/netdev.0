From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 3/3] tuntap: don't add to waitqueue when POLLERR
Date: Sun, 06 Jan 2013 12:43:40 +0800
Message-ID: <50E900FC.6050908@redhat.com>
References: <1357378446-19656-1-git-send-email-jasowang@redhat.com>  <1357378446-19656-4-git-send-email-jasowang@redhat.com> <1357414650.1678.4092.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755292Ab3AFEnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 23:43:49 -0500
In-Reply-To: <1357414650.1678.4092.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2013 03:37 AM, Eric Dumazet wrote:
> On Sat, 2013-01-05 at 17:34 +0800, Jason Wang wrote:
>> Currently, tun_chr_poll() returns POLLERR after waitqueue adding during device
>> unregistration. This would confuse some of its user such as vhost which assume
>> when POLLERR is returned, it wasn't added to the waitqueue. Fix this by
>> returning POLLERR before adding to waitqueue.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/tun.c |    5 +----
>>  1 files changed, 1 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index fbd106e..f9c0049 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -886,7 +886,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
>>  	struct sock *sk;
>>  	unsigned int mask = 0;
>>  
>> -	if (!tun)
>> +	if (!tun || tun->dev->reg_state != NETREG_REGISTERED)
>>  		return POLLERR;
>>  
>>  	sk = tfile->socket.sk;
>> @@ -903,9 +903,6 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
>>  	     sock_writeable(sk)))
>>  		mask |= POLLOUT | POLLWRNORM;
>>  
>> -	if (tun->dev->reg_state != NETREG_REGISTERED)
>> -		mask = POLLERR;
>> -
>>  	tun_put(tun);
>>  	return mask;
>>  }
> This patch is buggy.
>
> First, the caller assuming POLLERR means poll_wait() was not called is
> wrong.

True, looks like vhost need to check the poll->wqh before trying to
remove from waitqueue instead of this wrong assumption. And then we can
drop the whole tx polling state.
>
> Secondly, you add a ref leak.

Yes, will drop this patch.

Thanks.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
