From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sun, 27 Jan 2008 11:49:06 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0801271127490.8409@u.domain.uli>
References: <bug-9816-10286@http.bugzilla.kernel.org/>
 <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com>
 <20080125192026.e667f396.akpm@linux-foundation.org>
 <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com>
 <20080126114036.GA2624@ami.dom.local> <20080126141010.GC2624@ami.dom.local>
 <jeve5gd5mz.fsf@sykes.suse.de> <20080126151934.GA2969@ami.dom.local>
 <20080127011126.GA3408@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andreas Schwab <schwab@suse.de>,
	Joonwoo Park <joonwpark81@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:36375 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752275AbYA0Jsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2008 04:48:42 -0500
In-Reply-To: <20080127011126.GA3408@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 27 Jan 2008, Jarek Poplawski wrote:

> But comment#3 is "ambiguous"... It looks like you don't want to show
> us too much... So, apparently you change the route, but it seems this
> route exists; you have this:
>   10.0.0.0/8 dev eth0  scope link 
> but probably also something like this:
>   default via 192.168.1.1 dev eth0 src 10.204.0.116

	On replace the problem arises when same fib_info (priority, 
protocol, prefsrc, metrics, nexthops) is used in another route or routing 
table. In such cases single copy of structure is used with reference 
counter, all routes share pointer to such fib_info structure which
saves memory when we have many routes using same gateway, for example.

> So, I doubt there is any "real" change attempted here. It looks more
> like a question if program should allow for changing the form of route
> entries even if they mean the same, and if this should be reported as
> error at all? But maybe I miss something...

	No, simply the last change in 2.6.24 is wrong to assume 
duplication is evident in fib_info reference counter. And such check
is only on ip route replace/change. I'm appending brief FIB information
for your reference:

FIB - Forwarding Information Base

- Routes are organized in routing tables
- For "fib_hash" algorithm routing tables have 33 zones (for prefix
lengths 0..32), routing lookup walks them from 32 to 0 to find a
node containing all routing information
- Zones are implemented as hash tables where nodes are hashed by
key (prefix=network) because there can be lots of prefixes in a zone.
- Nodes can be stored with other methods, eg. trie, where nodes are
searched (we hope faster) by prefix and length, no zones are used
in this case
- Nodes have a list of aliases (tos+type+scope+fib_info ptr) sorted by
decreasing TOS because TOS=0 must be a last hit when looking for route.
type is unicast, local, prohibit, etc. scope is host, link, etc.
- fib_info is a structure containing protocol (kernel, boot, zebra, etc),
prefsrc, priority (metric), metrics, nexthop(s). Fallback routes have
higher value for priority, they are used if more priority routes
disappear or their nexthops are dead.
- fib_info structures are organized in 2 global hash tables, one
keyed by prefsrc and another by nexthop_count+protocol+prefsrc+priority
- fib_info is a shared structure, different aliases can point to same
fib_info, even aliases from different prefixes, from different routing
tables. By this way if fib_info contains multipath route then many
aliases share same route path scheduling context.
- Nexthop contains gateway, output device, scope and weight. Weight
is used for path scheduling where nexthops have relative priority
compared to other nexthops in multipath route.
- There can be many aliases with same tos, there can be alternative
routes (aliases) with same tos and priority (metric) but only one alias
with particular tos, type, scope and fib_info can exist to avoid duplicate
alternative routes.
- The operation to replace route includes replacing of alias. The alias
in node (table -> prefix/len) is matched by tos and fib_info priority and
they can not be changed. The parameters that are changed are type, scope
and fib_info (except priority).

* routing table
	* node (prefix/len)
		* alias (tos, type, scope)
			-> fib_info (priority, protocol, prefsrc, metrics)
				* nexthop (gateway, outdev, scope, weight)

read '*' for 'many' and '->' for 'counted reference'

Regards

--
Julian Anastasov <ja@ssi.bg>
