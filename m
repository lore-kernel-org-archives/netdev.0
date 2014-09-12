From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix div by zero while enslaving and transmitting
Date: Fri, 12 Sep 2014 16:55:55 +0200
Message-ID: <5413097B.9080802@redhat.com>
References: <1410524556-27128-1-git-send-email-nikolay@redhat.com>	 <1410527381.7106.81.camel@edumazet-glaptop2.roam.corp.google.com>	 <5412F4D5.3070101@redhat.com> <5412F643.10007@redhat.com> <1410533152.7106.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbaILO4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 10:56:13 -0400
In-Reply-To: <1410533152.7106.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 04:45 PM, Eric Dumazet wrote:
> On Fri, 2014-09-12 at 15:33 +0200, Nikolay Aleksandrov wrote:
> 
>> One more thing, netdev_master_upper_dev_link_private() which is called
>> after the increment uses list_add_rcu() (i.e. rcu_assign_pointer) to insert
>> the slave, so there's a barrier there to ensure this is visible before the
>> slave is linked.
> 
> You missed my point.
> 
> You fixed the writer side, without adding barriers on the read side.
> 
> Without looking at the code, just reading your patch, I spot a problem.
> 
> Following code is fundamentally broken :
> 
> rcu_read_lock();
> 
> if (bond->list) {
>     x = y % bond->slave;  // bug : cpu could fetch bond->slave before  bond->list
> 
> rcu_read_unlock();
> 
> 
Ah yes, you're absolutely correct.
Then get the value of slave_cnt in a local variable using ACCESS_ONCE() + a
check for != 0 would be a better solution than adding a read barrier, what
do you think ?
Since it's not a problem to see slave_cnt > 0 when there're no slaves, but
the other way around is problematic.

> Because it needs a read barrier, since the writer does after your patch:
> 
> 	update bond->slave
> 	smp_wmb();
> 	update bond->list
> 
> I repeat : adding few rcu_read_lock() / rcu_read_unlock() /
> rcu_assign_pointer() calls is not enough to guarantee code is not
> broken.
> 
Yes, I see now.

Thanks,
 Nik
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
