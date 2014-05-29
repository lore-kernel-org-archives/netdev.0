From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Thu, 29 May 2014 12:11:22 -0400
Message-ID: <CACP96tR8v=sujsGqFPefTw09X3WEud6-3KTX5j48ijX=hyyerw@mail.gmail.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	<alpine.LFD.2.11.1405290853530.1636@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:50371 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757839AbaE2QLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 12:11:24 -0400
Received: by mail-lb0-f175.google.com with SMTP id l4so316225lbv.20
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 09:11:22 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1405290853530.1636@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 2:34 AM, Julian Anastasov <ja@ssi.bg> wrote:

>         First improvment without adding fields to
> struct in_ifaddr would be (step 1):

< proposal to walk inet_addr_lst instead of ifa_list in 3 critical add/del
functions >

>         With additional pointer we can optimize
> __inet_insert_ifa and __inet_del_ifa: we will know
> how after finding ifa by walking inet_addr_lst to reach
> the primary ifa: with new pointer ifa_parent that
> points to our subnet. All secondaries for the subnet
> can be known with pointer to the first one: ifa_sec,
> because all secondaries are after all primaries:
  :
>
>         In fact ifa_sec and ifa_parent can be one field:
> ifa_pri_sec, ifa_link or another better name, used depending
> on IFA_F_SECONDARY.
>
>         So, step 2: add pointer in ifa

there would have to be some work done in addition/ deletion
code, to promote a track primary/secondary addresses..


>         Step 3: hash table for ifa_broadcast and
> struct hlist_node for ifa_has_brd (ifa_broadcast),
> ifa_hash_brd0 (first addr in subnet), ifa_hash_brd1 (last
> addr in subnet).
>
>         Any ideas?

Interesting proposal. But by itself, it might be a lot of code
change, with the real bottle-necks being elsewhere-

from what Eric and I observed, seems like the primary
time-suckers in these paths are check_lifetime() and fib_sync_up()-
both of these show at the top of the list for `perf top` and
from the quick hacks that Eric and I tried to get them out of the
way, give the most bang-for-the-buck?

I'm still not sure I understand *why* check_lifetime ends
up being expensive, though. For this particular test, all the
addresses are PERMANENT, so the to inet-addr_lst walking
loops should not be expensive at all- they should just bail
out quickly and continue. Eric's patch suggestst that this is due
to the chrun cause by doing  cancel_delayed_work +
queue_delayed_work from __inet_insert_ifa with a delay of 0?
If that's true, can this be safely skipped for PERMANENT addresses (i.e.
make delay infinite) with some careful adjustments on the delete
side to avoid the soft_lockup? Been meaning to play with that.

fib_sync_up() could also use a magnifying glass - was going to
look at this later.

And, of course, there's all the other config/control paths that
could use optimization - my tunnel experiment, and Jamal's
point about dumping ip addresses come to mind.

--Sowmini
