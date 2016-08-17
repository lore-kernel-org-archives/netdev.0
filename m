From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 01/13] net: sched: allow qdiscs to handle locking
Date: Wed, 17 Aug 2016 15:49:19 -0700
Message-ID: <57B4E9EF.5070400@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193338.27032.71493.stgit@john-Precision-Tower-5810>
 <1471473180.29842.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36585 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbcHQWtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 18:49:33 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so190113pfg.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 15:49:32 -0700 (PDT)
In-Reply-To: <1471473180.29842.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 03:33 PM, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 12:33 -0700, John Fastabend wrote:
>> This patch adds a flag for queueing disciplines to indicate the stack
>> does not need to use the qdisc lock to protect operations. This can
>> be used to build lockless scheduling algorithms and improving
>> performance.
>>
>> The flag is checked in the tx path and the qdisc lock is only taken
>> if it is not set. For now use a conditional if statement. Later we
>> could be more aggressive if it proves worthwhile and use a static key
>> or wrap this in a likely().
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  include/net/pkt_sched.h   |    4 +++-
>>  include/net/sch_generic.h |    1 +
>>  net/core/dev.c            |   32 ++++++++++++++++++++++++++++----
>>  net/sched/sch_generic.c   |   26 ++++++++++++++++----------
>>  4 files changed, 48 insertions(+), 15 deletions(-)
>>
>> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
>> index 7caa99b..69540c6 100644
>> --- a/include/net/pkt_sched.h
>> +++ b/include/net/pkt_sched.h
>> @@ -107,8 +107,10 @@ void __qdisc_run(struct Qdisc *q);
>>  
>>  static inline void qdisc_run(struct Qdisc *q)
>>  {
>> -	if (qdisc_run_begin(q))
>> +	if (qdisc_run_begin(q)) {
>>  		__qdisc_run(q);
>> +		qdisc_run_end(q);
>> +	}
>>  }
> 
> 
> Looks like you could have a separate patch, removing qdisc_run_end()
> call done in __qdisc_run(q) ?
> 
> Then the 'allow qdiscs to handle locking'
> 
> 

Agreed that would clean this up a bit. Will do for next rev.
