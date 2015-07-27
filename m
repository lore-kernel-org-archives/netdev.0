From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: increase in time to delete an interface with 4.x kernels
Date: Mon, 27 Jul 2015 10:36:26 -0700
Message-ID: <55B66C1A.4000804@redhat.com>
References: <55B6612C.7050506@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237AbbG0RyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 13:54:25 -0400
In-Reply-To: <55B6612C.7050506@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2015 09:49 AM, David Ahern wrote:
> Hi Alex:
>
> I believe you did the recent overhaul to the fib implementation. I am
> seeing dramatically higher times to delete an interface with an ipv4
> address in 4.2-rc3. perf-top points to update_suffix:
>
>     PerfTop:   15834 irqs/sec  kernel:97.3%  exact:  0.0% [4000Hz
> cpu-clock],  (all, 4 CPUs)
> -------------------------------------------------------------------------------------------
>
>
>      74.69%  [kernel]       [k] update_suffix
>       2.38%  [kernel]       [k] fib_table_flush
>       2.20%  [kernel]       [k] fib6_walk_continue
>       2.03%  [kernel]       [k] fib6_ifdown
>       1.31%  [kernel]       [k] fib6_age
>
>
> I have a simple script to create and assign an ipv4 address to 10k dummy
> interfaces:
>
> l=0
> for (( j = 1; j <= 40; j += 1))
> do
>      for (( k = 1 ; k <= 250  ; k += 1 ))
>      do
>          l=$((l + 1))
>          ip link add dev dummy${l} type dummy
>            ip addr add  72.$j.$k.1/24 dev dummy${l}
>            ifconfig dummy${l} up
>      done
> done
>
>
> and a counter script to delete them all:
>
> k=$(ip link show | grep dummy | wc -l)
> for (( j = 1; j <= k; j += 1))
> do
>      ip link del dev dummy${j}
> done
>

Okay so looking over what this script does it looks like it really 
exposes the worst case scenerio for update_suffix.  You have a monstrous 
tnode that is 15 bits ins size.  That is roughly 32K entries, and 
unfortunately the suffix is 8 bits long with a position of 7.

The result is that for every removal the code is scanning 16K entries in 
order to relevel things after an entry is removed.

Let me try a couple of quick things and I should have a patch for you in 
the next couple of hours.

Thanks.

- Alex
