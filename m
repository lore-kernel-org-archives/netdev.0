From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] meta ematch
Date: Thu, 13 Jan 2005 19:54:29 +0100
Message-ID: <41E6C3E5.2020908@trash.net>
References: <20050105110048.GO26856@postel.suug.ch> <1104931991.1117.152.camel@jzny.localdomain> <20050105144514.GQ26856@postel.suug.ch> <1105019225.2312.7.camel@jzny.localdomain> <20050106194102.GW26856@postel.suug.ch> <1105105511.1046.77.camel@jzny.localdomain> <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain> <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain> <20050113174111.GP26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050113174111.GP26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>Found some cycles today and wrote the meta ematch. It tried to
>find a good compromise between speed and power.
>
>So far I added the following matching possibilies:
> - random
> - load average (0,1,2)
> - dev (numeric and string)
> - indev (numeric and string)
> - realdev (numeric and string)
> - skb priority
> - ... protocol
> - ... security
> - ... pkttype (to easly match on multicast/broadcast)
> - ... pktlen
> - ... datalen
> - ... maclen
> - netfilter mark
> - ... cache
> - ... conntrack info
> - ... debug variable
> - tc index
> - ... verdict
> - ... classid
> - routing classid
> - .... iif
>
>Yet to come are more routing and socket attributes such as queue
>sizes, backlog sizes, neighbour attribute of the route found, ...
>
>It is also possible to compare two kernel meta values, e.g
>realdev equals dev.
>
>Numeric matches may be modified via shift and mask operators
>to for example only consider a part of nfmark.
>
>Binary matches may have a shift modifier to only consider
>a certain amount of the data, e.g. "eth1" with shift 1 would
>end up with "eth". I added this because I wanted something
>like eth% but didn't want to implement expensive string
>operations.
>  
>
Looks great. I have a few doubts about about the set of chosen values
though. Things like nf_debug and nf_cache were never meant to be
userspace-visible. What about backwards compatibility if we want to
remove it, or some other more meaningful value where just returning 0
wouldn't be the same ?

A couple of minor things:

- var_dev sets dst->value to dev->name, meta_var_destroy will try to
  free dev->name.

- meta_int_change only uses 32 bit, but dst->value is unsigned long
  (64 bit on 64-bit arches). nfmark for example is unsigned long, so
  you should also use *(unsigned long *).

- for the same reason meta_int_compare should return long not int

>If its not obvious, random and loadavg are intended for
>load balancing purposes, i.e.
>  
>
I have my doubts about the usefullness of load balancing traffic based
on CPU load, but I guess it doesn't hurt.

Regards
Patrick
