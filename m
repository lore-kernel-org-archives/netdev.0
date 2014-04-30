From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 01/15] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Wed, 30 Apr 2014 15:25:31 -0700
Message-ID: <5361785B.6000604@gmail.com>
References: <20140430163250.9021.21199.stgit@nitbit.x32>  <20140430163504.9021.12828.stgit@nitbit.x32> <1398877228.29914.177.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:61547 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933552AbaD3WZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 18:25:47 -0400
Received: by mail-ob0-f174.google.com with SMTP id gq1so2782545obb.5
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 15:25:46 -0700 (PDT)
In-Reply-To: <1398877228.29914.177.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2014 10:00 AM, Eric Dumazet wrote:
> On Wed, 2014-04-30 at 09:35 -0700, John Fastabend wrote:
>
>>   static inline struct Qdisc *qdisc_root(const struct Qdisc *qdisc)
>>   {
>> -	return qdisc->dev_queue->qdisc;
>> +	struct Qdisc *q = rcu_dereference(qdisc->dev_queue->qdisc);
>> +
>> +	return q;
>>   }
>>
>
> Hmm... I am pretty sure this can be called without rcu_read_lock()
>
> rcu_dereference_rtnl() would be more appropriate here I think.
>
>

It looks like it except for qdisc_watchdog() which needs an
rcu_read_lock() if I'm not mistaken/

static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
{
	struct qdisc_watchdog *wd = container_of(timer, struct 		
						 qdisc_watchdog,
						 timer);

	rcu_read_lock();
	qdisc_unthrottled(wd->qdisc);
	__netif_schedule(qdisc_root(wd->qdisc));
	rcu_read_unlock();

	return HRTIMER_NORESTART;
}


-- 
John Fastabend         Intel Corporation
