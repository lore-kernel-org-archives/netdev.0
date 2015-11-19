From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue (w/ Fixes:)
Date: Thu, 19 Nov 2015 23:48:45 +0000
Message-ID: <87h9kh7dpe.fsf@doppelsaurus.mobileactivedefense.com>
References: <87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
	<876111wpza.fsf@doppelsaurus.mobileactivedefense.com>
	<87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151117.151421.249423864481324472.davem@davemloft.net>
	<87d1v85mtx.fsf@doppelsaurus.mobileactivedefense.com>
	<878u5w5lcr.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jbaron@akamai.com,
	dvyukov@google.com, syzkaller@googlegroups.com, mkubecek@suse.cz,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, hannes@stressinduktion.org,
	dhowells@redhat.com, paul@paul-moore.com, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com, netdev@vger.kernel.org,
	kcc@google.com, glider@google.com, andreyknvl@google.com,
	sasha.levin@oracle.com, jln@google.com, keescook@google.com,
	minipli@googlemail.com
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878u5w5lcr.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Tue, 17 Nov 2015 22:09:40 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rweikusat@mobileactivedefense.com> writes:
> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
>
> [...]
>
>> The basic options would be
>>
>> 	- return EAGAIN even if sending became possible (Jason's most
>>           recent suggestions)
>>
>> 	- retry sending a limited number of times, eg, once, before
>>           returning EAGAIN, on the grounds that this is nicer to the
>>           application and that redoing all the stuff up to the _lock in
>>           dgram_sendmsg can possibly/ likely be avoided
>
> A third option:

A fourth and even one that's reasonably simple to implement: In case
other became ready during the checks, drop other lock, do a double-lock
sk, other, set a flag variable indicating this and restart the procedure
after the unix_state_lock_other[*], using the value of the flag to lock/
unlock sk as needed. Should other still be ready to receive data,
execution can then continue with the 'queue it' code as the other lock
was held all the time this time. Combined with a few unlikely
annotations in place where they're IMHO appropriate, this is speed-wise
comparable to the stock kernel.
