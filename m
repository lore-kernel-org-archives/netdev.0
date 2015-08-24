From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2: Behavioural Bug?
Date: Mon, 24 Aug 2015 22:17:48 +0300
Message-ID: <20150824191748.GA28975@angus-think.lan>
References: <CAA5aLPjmomaEv28==0wxtwNeRUguXimJqyWCEFNt0jrOkZ9O7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33022 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbbHXTUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 15:20:38 -0400
Received: by wijp15 with SMTP id p15so87208820wij.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 12:20:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA5aLPjmomaEv28==0wxtwNeRUguXimJqyWCEFNt0jrOkZ9O7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 02:00:29PM +0530, Akshat Kakkar wrote:
> When I am trying to delete a single tc filter (i.e. specifying its
> handle), it is deleting all the
> filters with the same priority/preference. i.e. it is ignoring the
> handle specified.
> 
> But, When I am doing similar activity in hashtable 800: it is deleting only the
> specified filter, i.e. it is behaving as expected.
> 
> I am unable to comprehend the reason for this difference in behaviour.
> 
> Infact, in kernel 2.6.32 all is working as expected. However, in
> kernel 3.1 and 4.1 it is having the behaviour as mentioned above.
> 
> For example, following set of commands  create a hashtable 15: and add
> 2 filters to it.
> 
> tc filter add dev eth0 parent 1:0 prio 5 handle 15: protocol ip u32 divisor 256
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:2 u32
> ht 15:2: match ip src 10.0.0.2 flowid 1:10
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
> ht 15:2: match ip src 10.0.0.3 flowid 1:10
> 
> Now following command DELETES ALL THE FILTERS, though it should only
> delete FILTER 15:2:3 !
> tc filter del dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
> 
> O/p of tc filter show eth0 is this case is blank. As all filters are deleted.
> 
> 
> However, similar commands when executed for hashtable 800: is deleting
> only the specified filter
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 800:0:2 u32
> ht 800:0: match ip src 10.0.0.2 flowid 1:10
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 800:0:3 u32
> ht 800:0: match ip src 10.0.0.3 flowid 1:10
> 
> tc filter del dev eth0 protocol ip parent 1: prio 5 handle 800:0:2 u32
> 
> Above mentioned command only deletes single filter.
> O/p of tc filter show eth0 is 2nd case is
> 
> filter parent 1: protocol ip pref 5 u32
> filter parent 1: protocol ip pref 5 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 5 u32 fh 800::3 order 3 key ht 800
> bkt 0 flowid 1:10
>   match 0a000003/ffffffff at 12
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

Thats what I got using this script where I copied your commands:

----------------------------------
#!/bin/bash

DEV=dummy0

ip link del $DEV 2> /dev/null

ip link add dev $DEV type dummy

tc qdisc add dev $DEV root handle 1: htb

tc filter add dev $DEV parent 1:0 prio 5 handle 15: protocol ip u32 divisor 256
tc filter add dev $DEV protocol ip parent 1: prio 5 handle 15:2:2 u32 ht 15:2: match ip src 10.0.0.2 flowid 1:10
tc filter add dev $DEV protocol ip parent 1: prio 5 handle 15:2:3 u32 ht 15:2: match ip src 10.0.0.3 flowid 1:10

tc filter del dev $DEV protocol ip parent 1: prio 5 handle 15:2:3 u32

tc filter show dev $DEV
# ---------------------------------

Result is:

filter parent 1: protocol ip pref 5 u32 
filter parent 1: protocol ip pref 5 u32 fh 15: ht divisor 256 
filter parent 1: protocol ip pref 5 u32 fh 15:2:2 order 2 key ht 15 bkt 2 flowid 1:10 
  match 0a000002/ffffffff at 12
filter parent 1: protocol ip pref 5 u32 fh 800: ht divisor 1 

Some additional info:

# tc -V
tc utility, iproute2-ss150413

# uname -a
Linux angus-think 4.0.4-2-ARCH #1 SMP PREEMPT Fri May 22 03:05:23 UTC 2015 x86_64 GNU/Linux

Regards,
Vadim Kochan
