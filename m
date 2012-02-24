From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH net-next v2] extend taskstats API to support networking
 accounts
Date: Fri, 24 Feb 2012 11:15:45 +0800
Message-ID: <4F4700E1.3010407@gmail.com>
References: <4F45F73F.3000708@gmail.com>  <20120223.033434.1801978370536071654.davem@davemloft.net>  <4F46F941.1020401@gmail.com> <1330052710.2511.37.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33344 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab2BXDPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 22:15:55 -0500
Received: by iacb35 with SMTP id b35so2441299iac.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 19:15:55 -0800 (PST)
In-Reply-To: <1330052710.2511.37.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B402=E6=9C=8824=E6=97=A5 11:05, Ben Hutchings =E5=86=
=99=E9=81=93:
> On Fri, 2012-02-24 at 10:43 +0800, Li Yu wrote:
>> This patch adds L7 traffic accounting in taskstats API, so
>> the iotop like applications can receive these statistics data.
>> In fact, I also have an iotop patch for this change.
>>
>> It ignores any protocol header overhead, so results of this
>> patch should be saw as the applications-aware data statistics
>> instead of traffic statistics on wire.
>>
>> The changes of v2 are:
>>
>> 1. Move up accounting source code, so they are not protocol-aware no=
w.
>> 2. Skipping interrupt context accounting.
> [...]
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -1735,6 +1735,18 @@ static inline int skb_copy_to_page(struct soc=
k
>> *sk, char __user *from,
>>    	return 0;
>>    }
>>
>> +static inline void task_net_accounting_rx(unsigned int len)
>> +{
>> +	if (!in_irq()&&  len>  0)
>> +		current->rx_bytes +=3D len;
>> +}
>> +
>> +static inline void task_net_accounting_tx(unsigned int len)
>> +{
>> +	if (!in_irq()&&  len>  0)
>> +		current->tx_bytes +=3D len;
>> +}
> [...]
>
> These are only called from system calls, so why are you checking for =
IRQ
> context?
>

Some caller are exported symbols or in exported symbols path, so
I think that we'd best that do not assume that such symbols only
work at process context, it may be used by some kernel modules in
softirq context.

However, faint, the 'len' should be signed int type.


>> @@ -558,7 +559,10 @@ static inline int __sock_sendmsg_nosec(struct k=
iocb
>> *iocb, struct socket *sock,
>>    	si->msg =3D msg;
>>    	si->size =3D size;
>>
>> -	return sock->ops->sendmsg(iocb, sock, msg, size);
>> +	ret =3D sock->ops->sendmsg(iocb, sock, msg, size);
>> +	task_net_accounting_tx(ret);
>> +
>> +	return ret;
>>    }
> [...]
>
> So what happens to the totals when sendmsg() returns an error?
>
> It seems to me that the parameter type for the accounting functions
> should be ssize_t.
>

En, I think that "int" is enough here at least, the return type of=20
__sock_sendmsg_nosec() also is int ...

Thanks

Yu

> Ben.
>
