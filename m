From: Howard Chu <hyc@symas.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 11:25:02 -0800
Message-ID: <45EDC00E.8020805@symas.com>
References: <45EBFD13.1060106@symas.com>	<200703051528.02564.dada1@cosmosbay.com> <45ED32CA.5080709@symas.com> <45EDB708.1010103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from highlandsun.propagation.net ([66.221.212.168]:2077 "EHLO
	highlandsun.propagation.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933148AbXCFTaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 14:30:46 -0500
In-Reply-To: <45EDB708.1010103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>> This is probably not something that happens in real world deployments. 
>> I But it's not 60,000 concurrent connections, it's 60,000 within a 2 
>> minute span.
> 
> Sounds like a case of Doctor! Doctor! It hurts when I do this.

I guess. In the cases where it matters, we use LDAP over Unix Domain 
Sockets instead of TCP. Smarter clients that do connection pooling would 
help too, but the fact that this even came to our attention is because 
not all clients out there are smart enough.

Since we have an alternative that works, I'm not really worried about 
it. I just thought it was worthwhile to raise the question.

>> I'm not saying this is a high priority problem, I only encountered it 
>> in a test scenario where I was deliberately trying to max out the server.
>>
>>>> Ideally the 2MSL parameter would be dynamically adjusted based on the
>>>> route to the destination and the weights associated with those routes.
>>>> In the simplest case, connections between machines on the same subnet
>>>> (i.e., no router hops involved) should have a much smaller default 
>>>> value
>>>> than connections that traverse any routers. I'd settle for a two-level
>>>> setting - with no router hops, use the small value; with any router 
>>>> hops
>>>> use the large value.
> 
> With transparant bridging, nobody knows how long the datagram may be out 
> there.  Admittedly, the chances of a datagram living for a full two 
> minutes these days is probably nil, but just being in the same IP subnet 
> doesn't really mean anything when it comes to physical locality.

Bridging isn't necessarily a problem though. The 2MSL timeout is 
designed to prevent problems from delayed packets that got sent through 
multiple paths. In a bridging setup you don't allow multiple paths, 
that's what STP is designed to prevent. If you want to configure a 
network that allows multiple paths, you need to use a router, not a bridge.

> SPECweb benchmarking has had to deal with the issue of attempted 
> TIME_WAIT reuse going back to 1997.  It deals with it by not relying on 
> the client's configured local/anonymous/ephemeral port number range and 
> instead making explicit bind() calls in the (more or less) entire unpriv 
> port range (actually it may just be from 5000 to 65535 but still)

That still doesn't solve the problem, it only ~doubles the available 
port range. That means it takes 0.6 seconds to trigger the problem 
instead of only 0.3 seconds...

> Now, if it weren't necessary to fully randomize the ISNs, the chances of 
> a successful transition from TIME_WAIT to ESTABLISHED might be greater, 
> but going back to the good old days of more or less purly clock driven 
> ISN's isn't likely.

In an environment where connections are opened and closed very quickly 
with only a small amount of data carried per connection, it might make 
sense to remember the last sequence number used on a port and use that 
as the floor of the next randomly generated ISN. Monotonically 
increasing sequence numbers aren't a security risk if there's still a 
randomly determined gap from one connection to the next. But I don't 
think it's necessary to consider this at the moment.
-- 
   -- Howard Chu
   Chief Architect, Symas Corp.  http://www.symas.com
   Director, Highland Sun        http://highlandsun.com/hyc
   Chief Architect, OpenLDAP     http://www.openldap.org/project/
