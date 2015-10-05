From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Mon, 05 Oct 2015 18:20:45 +0100
Message-ID: <8737xpxmdu.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
	<1444064074.9555.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Jason Baron <jbaron@akamai.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:34918 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751713AbbJERWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:22:14 -0400
In-Reply-To: <1444064074.9555.4.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 05 Oct 2015 09:54:34 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Mon, 2015-10-05 at 17:31 +0100, Rainer Weikusat wrote:
>
>>  	atomic_long_set(&u->inflight, 0);
>>  	INIT_LIST_HEAD(&u->link);
>> @@ -2135,8 +2139,16 @@ static unsigned int unix_poll(struct fil
>>  static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>>  				    poll_table *wait)
>>  {
>> -	struct sock *sk = sock->sk, *other;
>> -	unsigned int mask, writable;
>> +	struct sock *sk = sock->sk, *other, *pp;
>> +	struct unix_sock *u;
>> +	unsigned int mask, writable, dead;
>> +
>> +	u = unix_sk(sk);
>> +	pp = u->poll_peer;
>> +	if (pp) {
>> +		u->poll_peer = NULL;
>> +		sock_put(pp);
>> +	}
>
>
> This looks racy.
> Multiple threads could use poll() at the same time,
> and you would have too many sock_put()

That's one of the reasons why I wrote "might work": The use of a single
structure member without any locking for the sock_poll_wait suggests
that this is taken care of in some other way, as does the absence of any
comment about that in the 'public' LDDs ("Linux Device Drivers"),
however, I don't really know if this is true. If not, this simple idea
can't work.
