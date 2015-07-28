From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 14/16] net: Add sk_bind_dev_if to task_struct
Date: Tue, 28 Jul 2015 10:11:13 -0600
Message-ID: <55B7A9A1.6010704@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com> <1438021869-49186-15-git-send-email-dsa@cumulusnetworks.com> <CALCETrWbvbRK5rE3O-1AO9WSFxvWnbYMyYNu953SmiaEU1Q0XQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gospo@cumulusnetworks.com,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ingo Molnar <mingo@kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	jtoppins@cumulusnetworks.com,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	svaidya@brocade.com, hadi@mojatatu.com,
	nikolay@cumulusnetworks.com, roopa@cumulusnetworks.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33777 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbbG1QLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 12:11:15 -0400
Received: by pdbnt7 with SMTP id nt7so72992836pdb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:11:15 -0700 (PDT)
In-Reply-To: <CALCETrWbvbRK5rE3O-1AO9WSFxvWnbYMyYNu953SmiaEU1Q0XQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/15 9:25 AM, Andy Lutomirski wrote:
> On Jul 27, 2015 11:33 AM, "David Ahern" <dsa@cumulusnetworks.com> wrote:
>>
>> Allow tasks to have a default device index for binding sockets. If set
>> the value is passed to all AF_INET/AF_INET6 sockets when they are created.
>>
>
> This is not intended to be a review of the concept.  I haven't thought
> about whether the concept is a good idea, broken by design, or
> whatever.  FWIW, if this were added to the kernel and didn't require
> excessive privilege, I'd probably use it.  (I still don't really
> understand why binding to a device requires privilege in the first
> place, but, again, I haven't thought about it very much.)

The intent here is to restrict a task to only sending and receiving 
packets from a single network device. The device can be single ethernet 
interface, a stacked device (e.g, bond) or in our case a VRF device 
which restricts a task to interfaces (and hence network paths) 
associated with the VRF.

>
>> +#ifdef CONFIG_NET
>> +       case PR_SET_SK_BIND_DEV_IF:
>> +       {
>> +               struct net_device *dev;
>> +               int idx = (int) arg2;
>> +
>> +               if (!capable(CAP_NET_ADMIN))
>> +                       return -EPERM;
>> +
>
> Can you either use ns_capable or add a comment as to why not?

will do.

>
> Also, please return -EINVAL if unused args are nonzero.

ok.

>
>> +               if (idx) {
>> +                       dev = dev_get_by_index(me->nsproxy->net_ns, idx);
>> +                       if (!dev)
>> +                               return -EINVAL;
>> +                       dev_put(dev);
>> +               }
>> +               me->sk_bind_dev_if = idx;
>> +               break;
>> +       }
>> +       case PR_GET_SK_BIND_DEV_IF:
>> +       {
>> +               struct task_struct *tsk;
>> +               int sk_bind_dev_if = -EINVAL;
>> +
>> +               rcu_read_lock();
>> +               tsk = find_task_by_vpid(arg2);
>> +               if (tsk)
>> +                       sk_bind_dev_if = tsk->sk_bind_dev_if;
>
> Why do you support different tasks here?  Could this use proc instead?

In this case we want to allow a separate process to determine if a task 
is restricted to a device.

>
> The same -EINVAL issue applies.
>
> Also, I think you need to hook setns and unshare to do something
> reasonable when the task is bound to a device.

ack on both.

Thanks for the review,
David
