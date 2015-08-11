From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next v2] tcp: reduce cpu usage under tcp memory pressure
 when SO_SNDBUF is set
Date: Tue, 11 Aug 2015 13:59:17 -0400
Message-ID: <55CA37F5.8090108@akamai.com>
References: <20150811143846.672A92039@prod-mail-relay10.akamai.com>	 <1439304576.1084.24.camel@edumazet-glaptop2.roam.corp.google.com>	 <55CA0EC2.9030306@akamai.com> <1439309530.1084.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-179.deploy.static.akamaitechnologies.com ([23.79.238.179]:42981
	"EHLO prod-mail-xrelay05.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751661AbbHKR7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 13:59:19 -0400
In-Reply-To: <1439309530.1084.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/11/2015 12:12 PM, Eric Dumazet wrote:
> On Tue, 2015-08-11 at 11:03 -0400, Jason Baron wrote:
> 
>>
>> Yes, so the test case I'm using to test against is somewhat contrived.
>> In that I am simply allocating around 40,000 sockets that are idle to
>> create a 'permanent' memory pressure in the background. Then, I have
>> just 1 flow that sets SO_SNDBUF, which results in the: poll(), write() loop.
>>
>> That said, we encountered this issue initially where we had 10,000+
>> flows and whenever the system would get into memory pressure, we would
>> see all the cpus spin at 100%.
>>
>> So the testcase I wrote, was just a simplistic version for testing. But
>> I am going to try and test against the more realistic workload where
>> this issue was initially observed.
>>
> 
> Note that I am still trying to understand why we need to increase socket
> structure, for something which is inherently a problem of sharing memory
> with an unknown (potentially big) number of sockets.
> 

I was trying to mirror the wakeups when SO_SNDBUF is not set, where we
continue to trigger on 1/3 of the buffer being available, as the
sk->sndbuf is shrunk. And I saw this value as dynamic depending on
number of sockets and read/write buffer usage. So that's where I was
coming from with it.

Also, at least with the .config I have the tcp_sock structure didn't
increase in size (although struct sock did go up by 8 and not 4).

> I suggested to use a flag (one bit).
> 
> If set, then we should fallback to tcp_wmem[0] (each socket has 4096
> bytes, so that we can avoid starvation)
> 
> 
> 

Ok, I will test this approach.

Thanks,

-Jason
