From: Howard Chu <hyc@symas.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 01:22:18 -0800
Message-ID: <45ED32CA.5080709@symas.com>
References: <45EBFD13.1060106@symas.com> <200703051528.02564.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from highlandsun.propagation.net ([66.221.212.168]:1238 "EHLO
	highlandsun.propagation.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933185AbXCFKAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 05:00:39 -0500
In-Reply-To: <200703051528.02564.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Monday 05 March 2007 12:20, Howard Chu wrote:
>> Why is the Maximum Segment Lifetime a global parameter? Surely the
>> maximum possible lifetime of a particular TCP segment depends on the
>> actual connection. At the very least, it would be useful to be able to
>> set it on a per-interface basis. E.g., in the case of the loopback
>> interface, it would be useful to be able to set it to a very small
>> duration.
> 
> Hi Howard
> 
> I think you should address these questions on netdev instead of linux-kernel.

OK, I just subscribed to netdev...

>> As I note in this draft
>> http://www.ietf.org/internet-drafts/draft-chu-ldap-ldapi-00.txt
>> when doing a connection soak test of OpenLDAP using clients connected
>> through localhost, the entire port range is exhausted in well under a
>> second, at which point the test stalls until a port comes out of
>> TIME_WAIT state so the next connection can be opened.
>>
>> These days it's not uncommon for an OpenLDAP slapd server to handle tens
>> of thousands of connections per second in real use (e.g., at Google, or
>> at various telcos). While the LDAP server is fast enough to saturate
>> even 10gbit ethernet using contemporary CPUs, we have to resort to
>> multiple virtual interfaces just to make sure we have enough port
>> numbers available.

> I dont uderstand... doesnt slapd server listen for connections on a given 
> port, like http ? Or is it doing connections like a ftp server ?

No, you're right, it listens on a single port. There is a standard port 
(389) though of course you can use any port you want.
> 
> Of course, if you want to open more than 60.000 concurrent connections, using 
> 127.0.0.1 address, you might have a problem...

This is probably not something that happens in real world deployments. I 
But it's not 60,000 concurrent connections, it's 60,000 within a 2 
minute span.

I'm not saying this is a high priority problem, I only encountered it in 
a test scenario where I was deliberately trying to max out the server.

>> Ideally the 2MSL parameter would be dynamically adjusted based on the
>> route to the destination and the weights associated with those routes.
>> In the simplest case, connections between machines on the same subnet
>> (i.e., no router hops involved) should have a much smaller default value
>> than connections that traverse any routers. I'd settle for a two-level
>> setting - with no router hops, use the small value; with any router hops
>> use the large value.
> 
> Well, is it really a MSL problem ?

> I did a small test (linux-2.6.21-rc1) and was able to get 1.000.000 
> connections on localhost on my dual proc machine in one minute, without an 
> error.

It's a combination of 2MSL and /proc/sys/net/ipv4/ip_local_port_range - 
on my system the default port range is 32768-61000. That means if I use 
up 28232 ports in less than 2MSL then everything stops. netstat will 
show that all the available port numbers are in TIME_WAIT state. And 
this is particularly bad because while waiting for the timeout, I can't 
initiate any new outbound connections of any kind at all - telnet, ssh, 
whatever, you have to wait for at least one port to free up. 
(Interesting denial of service there....)

Granted, I was running my test on 2.6.18, perhaps 2.6.21 behaves 
differently.

-- 
   -- Howard Chu
   Chief Architect, Symas Corp.  http://www.symas.com
   Director, Highland Sun        http://highlandsun.com/hyc
   Chief Architect, OpenLDAP     http://www.openldap.org/project/
