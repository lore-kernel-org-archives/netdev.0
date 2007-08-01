From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: specifying scopid's for link-local IPv6 addrs
Date: Wed, 01 Aug 2007 10:25:28 -0400
Message-ID: <46B097D8.5060002@hp.com>
References: <46A4FAFF.8010809@hp.com> <20070724030115.3208229d.billfink@mindspring.com> <46A63327.6010705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:55652 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754890AbXHAOZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 10:25:45 -0400
In-Reply-To: <46A63327.6010705@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>> Rick,
>>
>> I don't see any way around this.  For example, on one of my test
>> systems, I have the following link local routes:
>>
>> chance% netstat -A inet6 -rn | grep fe80::/64
>> fe80::/64                                  
>> ::                                      U     256    0        0 eth0
>> fe80::/64                                  
>> ::                                      U     256    0        0 eth2
>> fe80::/64                                  
>> ::                                      U     256    0        0 eth3
>> fe80::/64                                  
>> ::                                      U     256    0        0 eth4
>> fe80::/64                                  
>> ::                                      U     256    0        0 eth5
>> fe80::/64                                  
>> ::                                      U     256    0        0 eth6
>>
>> So if I want to run a link local test to fe80::202:b3ff:fed4:cd1,
>> the system has no way to choose which is the correct interface to
>> use for the test, and will give an error if the interface isn't
>> specified. 
> 
> Yeah, I was wondering about that.  I'm not sure if the attempts on
> "those other OSes" happened to involve multiple interfaces or not.

Yes, there have been attempts.   BSD has a concept of default interface.
The default interface is used when the user did not specify the interface/
scope_id.

Other OSs do different things.  For example, Tru64 (to pick on a dead system)
would try to find the right interface base on the preferences you could
set up.

But, in the end the whole thing is really utterly broken since no-one has
truly implemented scoped address architecture for link-local addresses.
The concept of the link is so closely tied to the 'interface' that I don't
know anyone who has separated the two.


>  Even
> so, it "feels" unpleasant for an application to deal with and I wonder
> if there is a way for a stack to deal with it on the application's
> behalf.  I guess that might involve some sort of layer violation between
> neightbor discovery and routing (typing while I think about things I
> know little about...)
> 
> Is there RFC chapter and verse I might read about routing with multiple
> link-local's on a system?

See RFC 4007 for the concepts.  

> 
>> You must explicitly specify the desired interface.  For example,
>> on my test system, the correct interface is eth6 which is interface 8
>> (lo eth0 eth1 eth2 ... eth5 eth6).  Here is an example nuttcp test
>> specifying interface 8:
>>
>> chance% nuttcp -P5100 fe80::202:b3ff:fed4:cd1%8
>>  1178.5809 MB /  10.02 sec =  986.2728 Mbps 12 %TX 15 %RX
>>
>> nuttcp uses getaddrinfo() which parses the "%<ifindex>" field,
>> and then copies the sin6_scope_id from the res structure to the
>> server's sockaddr_in6 structure before initiating the connect().
> 
> OK, I'll give that a quick try with netperf:
> 
> [root@hpcpc106 ~]# netperf -H 192.168.2.107 -c -C -i 30,3 -- -s 1M -S 1M
> -m 64K -H fe80::207:43ff:fe05:9d%2
> TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to
> fe80::207:43ff:fe05:9d%2 (fe80::207:43ff:fe05:9d) port 0 AF_INET6 :
> +/-2.5% @ 99% conf.
> 
> Cool - it establishes the data connection just fine.
> 
> 
> To further demonstrate my ignorance :)  is that %n suffix something one
> might expect in most/all getaddrinfo()'s or is that unique to the one in
> Linux?

This is becoming more generic.  I believe HP-UX supports it (if the don't
you should kick them :).

-vlad
