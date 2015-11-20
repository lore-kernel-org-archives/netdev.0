From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue (w/ Fixes:)
Date: Fri, 20 Nov 2015 16:21:24 +0000
Message-ID: <87lh9sfxq3.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
	<87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<877flp34fl.fsf@doppelsaurus.mobileactivedefense.com>
	<87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
	<876111wpza.fsf@doppelsaurus.mobileactivedefense.com>
	<87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<87d1v57dif.fsf@doppelsaurus.mobileactivedefense.com>
	<564F4458.8050309@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Howells <dhowells@redhat.com>,
	Paul Moore <paul@paul-moore.com>, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com,
	netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:46832 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbbKTQVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:21:55 -0500
In-Reply-To: <564F4458.8050309@akamai.com> (Jason Baron's message of "Fri, 20
	Nov 2015 11:03:36 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Baron <jbaron@akamai.com> writes:
> On 11/19/2015 06:52 PM, Rainer Weikusat wrote:
>
> [...]
>
>> @@ -1590,21 +1718,35 @@ restart:
>>  			goto out_unlock;
>>  	}
>>  
>> -	if (unix_peer(other) != sk && unix_recvq_full(other)) {
>> -		if (!timeo) {
>> +	if (unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {
>> +		if (timeo) {
>> +			timeo = unix_wait_for_peer(other, timeo);
>> +
>> +			err = sock_intr_errno(timeo);
>> +			if (signal_pending(current))
>> +				goto out_free;
>> +
>> +			goto restart;
>> +		}
>> +
>> +		if (unix_peer(sk) != other ||
>> +		    unix_dgram_peer_wake_me(sk, other)) {
>>  			err = -EAGAIN;
>>  			goto out_unlock;
>>  		}
>
> Hi,
>
> So here we are calling unix_dgram_peer_wake_me() without the sk lock the first time
> through - right?

Yes. And this is obviously wrong. I spend most of the 'evening time'
(some people would call that 'night time') with testing this and didn't
get to read through it again yet. Thank you for pointing this out. I'll
send an updated patch shortly.
