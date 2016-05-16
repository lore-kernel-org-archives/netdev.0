From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] ixgbe: take online CPU number as MQ max
 limit when alloc_etherdev_mq()
Date: Mon, 16 May 2016 10:14:04 -0700
Message-ID: <5739FFDC.80908@gmail.com>
References: <1463118995-31763-1-git-send-email-ethan.zhao@oracle.com>
 <CAKgT0UeiEW21E7A9fnt_BUCppopns-E2w1WbwF-8A6sCZkJ8rQ@mail.gmail.com>
 <573937A7.9010405@oracle.com>
 <CAKgT0UfJqu5sa7U4HKLFk0h3NjqavaAY0xfsahZ32MvnePFHdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	Ethan Zhao <ethan.kernel@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	ethan zhao <ethan.zhao@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UfJqu5sa7U4HKLFk0h3NjqavaAY0xfsahZ32MvnePFHdg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...]

>>> ixgbe_main.c.  All you are doing with this patch is denying the user
>>> choice with this change as they then are not allowed to set more
>>
>>   Yes, it is purposed to deny configuration that doesn't benefit.
> 
> Doesn't benefit who?  It is obvious you don't understand how DCB is
> meant to work since you are assuming the queues are throw-away.
> Anyone who makes use of the ability to prioritize their traffic would
> likely have a different opinion.


+1 this is actually needed so that when DCB is turned on we can
see both prioritize between tcs (DCB feature) but also do not
see a performance degradation with just a single TC transmitting.

If we break this (and its happened occasionally) we end up with
bug reports so its clear to me folks care about it.

> 
>>> queues.  Even if they find your decision was wrong for their
>>> configuration.
>>>
>>> - Alex
>>>
>>  Thanks,
>>  Ethan
> 
> Your response clearly points out you don't understand DCB.  I suggest
> you take another look at how things are actually being configured.  I
> believe what you will find is that the current implementation is
> basing things on the number of online CPUs already based on the
> ring_feature[RING_F_RSS].limit value.  All that is happening is that
> you are getting that value multiplied by the number of TCs and the RSS
> value is reduced if the result is greater than 64 based on the maximum
> number of queues.
> 
> With your code on an 8 core system you go from being able to perform
> RSS over 8 queues to only being able to perform RSS over 1 queue when
> you enable DCB.  There was a bug a long time ago where this actually
> didn't provide any gain because the interrupt allocation was binding
> all 8 RSS queues to a single q_vector, but that has long since been
> fixed and what you should be seeing is that RSS will spread traffic
> across either 8 or 16 queues when DCB is enabled in either 8 or 4 TC
> mode.
> 
> My advice would be to use a netperf TCP_CRR test and watch what queues
> and what interrupts traffic is being delivered to.  Then if you have
> DCB enabled on both ends you might try changing the priority of your
> netperf session and watch what happens when you switch between TCs.
> What you should find is that you will shift between groups of queues
> and as you do so you should not have any active queues overlapping
> unless you have less interrupts than CPUs.
> 

Yep.

Thanks,
John

> - Alex
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> 
