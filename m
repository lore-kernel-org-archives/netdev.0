From: Bill Fink <billfink@mindspring.com>
Subject: Re: specifying scopid's for link-local IPv6 addrs
Date: Tue, 24 Jul 2007 03:01:15 -0400
Message-ID: <20070724030115.3208229d.billfink@mindspring.com>
References: <46A4FAFF.8010809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:32781 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753265AbXGXHBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 03:01:21 -0400
In-Reply-To: <46A4FAFF.8010809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Jul 2007, Rick Jones wrote:

> Folks -
> 
> People running netperf have reported that they have trouble with IPv6 under 
> Linux.  Specifically, wereas the use of link-local IPv6 addresses "just works" 
> in netperf under a number of "other OSes" they do not under Linux.  I'm 
> ass-u-me-ing 2.6 here, but not sure exactly which ones - I've seen it on a 
> 2.6.18-based RHEL5.
> 
> Some poking about and conversation has suggested that one has to set a 
> sin6_scope_id in the sockaddr_in6.  This needs to be an index of one of the 
> interfaces in the system, which I presume means walking some additional structures.
> 
> Is this a requirement which might be expected to remain in the future, or is it 
> something which might just go away?  That will have an effect on netperf future 
> development.
> 
> thanks,
> 
> rick jones

Rick,

I don't see any way around this.  For example, on one of my test
systems, I have the following link local routes:

chance% netstat -A inet6 -rn | grep fe80::/64
fe80::/64                                   ::                                      U     256    0        0 eth0
fe80::/64                                   ::                                      U     256    0        0 eth2
fe80::/64                                   ::                                      U     256    0        0 eth3
fe80::/64                                   ::                                      U     256    0        0 eth4
fe80::/64                                   ::                                      U     256    0        0 eth5
fe80::/64                                   ::                                      U     256    0        0 eth6

So if I want to run a link local test to fe80::202:b3ff:fed4:cd1,
the system has no way to choose which is the correct interface to
use for the test, and will give an error if the interface isn't
specified.  Here's an example of this with nuttcp:

chance% nuttcp -P5100 fe80::202:b3ff:fed4:cd1
nuttcp-t: Info: attempting to switch to deprecated "classic" mode
nuttcp-t: Info: will use less reliable transmitter side statistics
nuttcp-t: v5.5.5: Error: connect: Invalid argument
errno=22

You must explicitly specify the desired interface.  For example,
on my test system, the correct interface is eth6 which is interface 8
(lo eth0 eth1 eth2 ... eth5 eth6).  Here is an example nuttcp test
specifying interface 8:

chance% nuttcp -P5100 fe80::202:b3ff:fed4:cd1%8
 1178.5809 MB /  10.02 sec =  986.2728 Mbps 12 %TX 15 %RX

nuttcp uses getaddrinfo() which parses the "%<ifindex>" field,
and then copies the sin6_scope_id from the res structure to the
server's sockaddr_in6 structure before initiating the connect().

						-Bill
