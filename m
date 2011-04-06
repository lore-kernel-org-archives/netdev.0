From: David Miller <davem@davemloft.net>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 06 Apr 2011 13:02:39 -0700 (PDT)
Message-ID: <20110406.130239.232756965.davem@davemloft.net>
References: <BANLkTikZfp_GLyNRufAzqv3Yeb5d12BPDA@mail.gmail.com>
	<20110406.121208.189703414.davem@davemloft.net>
	<20110406195719.GE14697@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@gmail.com, fedora-kernel-list@redhat.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752323Ab1DFUDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:03:16 -0400
In-Reply-To: <20110406195719.GE14697@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 6 Apr 2011 16:57:19 -0300

> Something like ftrace code changing when the user inserts the first
> rule?
> 
> People wanting top performance disable it in the build, but thos wanting
> to stick to vendor provided kernels don't have that choice :)

Using ftrace-like stubs would be an interesting idea, and I highly encourage
people to work on something like that.

However I want to reiterate that I think that real rules are installed
in Jesse's case, and once he removes those the majority of the
overhead will disappear.  The FC14 workstation I'm using right now, on
which I've made no modifications to the installer's netfilter settings,
has the following rules:

--------------------
[root@ilbolle davem]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            state RELATED,ESTABLISHED 
ACCEPT     icmp --  anywhere             anywhere            
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     tcp  --  anywhere             anywhere            state NEW tcp dpt:ssh 
ACCEPT     udp  --  anywhere             anywhere            state NEW udp dpt:ipp 
ACCEPT     udp  --  anywhere             224.0.0.251         state NEW udp dpt:mdns 
ACCEPT     tcp  --  anywhere             anywhere            state NEW tcp dpt:ipp 
ACCEPT     udp  --  anywhere             anywhere            state NEW udp dpt:ipp 
REJECT     all  --  anywhere             anywhere            reject-with icmp-host-prohibited 

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         
REJECT     all  --  anywhere             anywhere            reject-with icmp-host-prohibited 

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
[root@ilbolle davem]# 
--------------------

I suspect Jesse has something similar on his test box.

When no rules are loaded, all the stubs make happen is a function call
plus a list_empty() check.  Nothing more.  I really can't see that, all
by itself, obliterating routing performance.

In fact I've done udp flood tests, as recently as a month ago, with just
NETFILTER=y and no rules installed, and the impact was minimal.

And that was on sparc64 where function calls are expensive :)

