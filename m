From: Olivier Brunel <jjk@jjacky.com>
Subject: Re: Bug w/ (policy) routing
Date: Sun, 1 Jan 2017 20:52:38 +0100
Message-ID: <20170101205238.426803f4@jjacky.com>
References: <20161231000006.17677918@jjacky.com>
        <3575dc1f-d536-20d2-24b9-a1e95a5c795b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 23-29-69-116.static.gorillaservers.com ([23.29.69.116]:53685
        "EHLO mail.jjacky.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S932229AbdAATx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 14:53:59 -0500
In-Reply-To: <3575dc1f-d536-20d2-24b9-a1e95a5c795b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Dec 2016 13:15:44 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 12/30/16 4:00 PM, Olivier Brunel wrote:
> > Hi,
> > 
> > (Please cc me as I'm not subscribed to the list, thanks.)
> > 
> > I'm trying to set things up using some policy routing, and having
> > some weird issues I can't really explain. It looks to me like there
> > might be a bug somewhere...
> > 
> > This is done under Arch Linux 64bits, iproute2 4.9.0 (`ip -V` says
> > ip utility, iproute2-ss161212), kernel 4.8.13
> > 
> > Basically here's what I could reduce it to:
> > - create a new network namespace, create a pair of veth devices:
> > one in there, one sent back to the original namespace
> > - I'm giving them IPs 10.4.0.1 (original namespace) & 10.4.0.2 (new
> > namespace)
> > - in that new namespace, I'm trying to add a route to 10.4.0.1, but
> >   inside a new table. I also want a default route via 10.4.0.1 on
> > the table main. It seems to work, only not really...
> > 
> > It's not very easy to describe so hopefully this will make things
> > clearer:
> > 
> > $ sudo unshare -n sh  
> 
> The main and local fib tables start merged into a single fib_table
> instance.
> 
> > sh-4.4# ip rule add table 50 prio 50
> > sh-4.4# ip link add test type veth peer name test2
> > sh-4.4# ip addr add 10.4.0.2 dev test
> > sh-4.4# ip link set dev test up
> > sh-4.4# ip link set netns 1 dev test2
> > # back in original namespace, we add 10.4.0.1 to test2 and bring it
> > up
> > 
> > sh-4.4# ip route add 10.4.0.1 dev test table 50
> > sh-4.4# ip route add default via 10.4.0.1 dev test
> > sh-4.4# ip route flush cache
> > sh-4.4# ip rule
> > 0:	from all lookup local 
> > 50:	from all lookup 50 
> > 32766:	from all lookup main 
> > 32767:	from all lookup default 
> > sh-4.4# ip route show table 50
> > 10.4.0.1 dev test scope link 
> > sh-4.4# ip route get 10.4.0.1
> > 10.4.0.1 via 10.4.0.1 dev test table local src 10.4.0.2 
> >     cache 
> > # !?? why isn't table 50 used as, I believe, it should. And why  
> 
> The default rule set has the local table at priority 0 so all lookups
> hit that table first:
> 
> # ip ru ls
> 0:	from all lookup local
> 32766:	from all lookup main
> 32767:	from all lookup default
> 
> For some reason it hits a match doing the lookup in the merged
> local/main fib_table for this ip route get.
> 
> > does adding a rule "fixes" it :
> > 
> > sh-4.4# ip rule add prio 55555  
> 
> Adding this rule causes the local and main tables to be split into
> actual separate fib tables. Doing so causes the lookup in the local
> table to fail, so the lookup continues to the next rule -- which is
> your prio 50 table 50 rule.
> 
> I did not look into why the earlier rule addition did not cause the
> unmerge to happen -- it should have.

Thanks, (I feel like) I understand what's happening now.


> > sh-4.4# ip route get 10.4.0.1
> > 10.4.0.1 dev test table 50 src 10.4.0.2 
> >     cache 
> > # deleting the new rule makes no difference. It could even have been
> > done right after adding it. It's like it just triggered something
> > (reload, cache flushed, ...)
> > As seen I did flush cached routes as mentionned in the man page, I
> > don't know of anything else that would need done to "refresh"
> > things?
> > 
> > Any ideas as to why this is happening? Should this work as I expect
> > it, or is there anything I'm doing wrong?  
> 
> For your purposes now this should fix the problem for you:
> 
> ip ru del from all lookup local
> ip ru add prio 32765 from all lookup local

Indeed, if I first delete the rule for lookup local and recreate it
w/ higher prio than my "lookup 50", then no more issue.

Thanks a lot!
