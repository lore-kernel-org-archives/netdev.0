From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Fri, 23 Aug 2013 10:05:10 -0700
Message-ID: <CALnjE+qnDQazprpm2Y8iiQ8USuY7J3LX1GooYp4xN2JZ5FW9+Q@mail.gmail.com>
References: <1377206736-18357-1-git-send-email-pshelar@nicira.com>
	<1377242432.14021.2.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:41034 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755078Ab3HWRFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 13:05:11 -0400
Received: by mail-qa0-f47.google.com with SMTP id o19so116100qap.20
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 10:05:11 -0700 (PDT)
In-Reply-To: <1377242432.14021.2.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 12:20 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
>> @@ -572,15 +594,29 @@ static int genl_family_rcv_msg(struct
>> genl_family *family,
>>                 return -EPERM;
>>
>>         if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
>> -               struct netlink_dump_control c = {
>> -                       .dump = ops->dumpit,
>> -                       .done = ops->done,
>> -               };
>> +               struct netlink_dump_control c;
>> +               int rc;
>>
>>                 if (ops->dumpit == NULL)
>>                         return -EOPNOTSUPP;
>>
>> -               return netlink_dump_start(net->genl_sock, skb, nlh,
>> &c);
>> +               memset(&c, 0, sizeof(c));
>> +               if (!family->parallel_ops) {
>> +                       genl_unlock();
>> +                       c.data = ops;
>> +                       c.dump = genl_lock_dumpit;
>> +                       if (ops->done)
>> +                               c.done = genl_lock_done;
>> +               } else {
>> +                       c.dump = ops->dumpit;
>> +                       c.done = ops->done;
>> +               }
>> +
>> +               rc = netlink_dump_start(net->genl_sock, skb, nlh, &c);
>> +               if (!family->parallel_ops)
>> +                       genl_lock();
>> +               return rc;
>> +
>
> I think this piece would be easier to read if you call
> netlink_dump_start() separately in the two branches. If you also move
> the "c" variable into the branches then you can keep initializing it
> with an explicit initializer which would also be more readable IMHO.
>
ok, I will update patch.

> Either way, this seems fine. I still think that not assigning cb_mutex
> wasn't the smartest idea, but I'll reply over in the other thread.
