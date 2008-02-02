From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Sat, 2 Feb 2008 20:21:09 +0100
Message-ID: <20080202192109.GA2730@ami.dom.local>
References: <20080127232018.GA2856@ami.dom.local> <Pine.LNX.4.58.0801290139450.3181@u.domain.uli> <20080129084915.GA1624@ff.dom.local> <20080129091030.GB1624@ff.dom.local> <20080129095245.GA2570@ff.dom.local> <Pine.LNX.4.58.0802021224460.3483@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:38934 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732AbYBBTQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 14:16:23 -0500
Received: by ug-out-1314.google.com with SMTP id z38so929170ugc.16
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2008 11:16:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0802021224460.3483@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 02, 2008 at 12:56:08PM +0200, Julian Anastasov wrote:
> 
> 	Hello,

Hi!

> On Tue, 29 Jan 2008, Jarek Poplawski wrote:
> 
> > ...On the other hand, I wonder how bad would be switching these two
> > to avoid this error? After all "replace" with this "add or change"
> > meaning looks quite permissive, and after all it was used before with
> > no such errors, so, even if correct, it could still break some
> > scripts...
> 
> 	Agreed, what could break are scripts that add 2 equal 
> alternative routes and checking for errors.

BTW, I would be glad if you could use this in some patch (unless you
have no time - then let me know)...

> BTW, I tried to add
> more information and that is what I have finally:
> 
> http://www.ssi.bg/~ja/fib.txt

Great! But, I hope more people will know about this if you send it as
a patch with a new thread. BTW#2: I've thought it maybe needs a bit of
cosmetcs like more uniform TOS or tos and "." or no "." after
paragraphs, or more consistent wrapping, but then I've exagerated with
this for sure. Anyway, below are some suggestions, but feel free to
skip them all!

Thanks,
Jarek P.


--- fib.txt.orig	2008-02-02 15:44:09.000000000 +0100
+++ fib.txt	2008-02-02 18:57:56.000000000 +0100
@@ -1,42 +1,55 @@
 
 		FIB - Forwarding Information Base
 
-- Routes are organized in routing tables
+- Routes are organized in routing tables.
+
 - For "fib_hash" algorithm routing tables have 33 zones (for prefix
-lengths 0..32), routing lookup walks them from 32 to 0 to find a
-node containing all routing information
-- Zones are implemented as hash tables where nodes are hashed by
-key (prefix=network) because there can be lots of prefixes in a zone.
+lengths 0..32), routing lookup walks them from 32 to 0 to find a node
+containing all routing information.
+
+- Zones are implemented as hash tables where nodes are hashed by key
+(prefix = network) because there can be lots of prefixes in a zone.
+
 - Nodes can be stored with other methods, eg. trie, where nodes are
-searched (we hope faster) by prefix and length, no zones are used
-in this case
-- Nodes have a list of aliases (tos+type+scope+fib_info ptr) sorted by
-decreasing TOS because TOS=0 must be a last hit when looking for route,
-TOS 0 matches packet with any TOS. type is unicast, local, prohibit, etc.
-scope is host, link, etc. Additionally, aliases with same TOS are
-sorted by fib_info priority (ascending).
-- fib_info is a structure containing protocol (kernel, boot, zebra, etc),
-prefsrc, priority (metric), metrics, nexthop(s). Fallback routes have
-higher value for priority, they are used if more priority routes
-disappear or their nexthops are dead.
-- fib_info structures are organized in 2 global hash tables, one
-keyed by prefsrc and another by nexthop_count+protocol+prefsrc+priority
-- fib_info is a shared structure, different aliases can point to same
-fib_info, even aliases from different prefixes, from different routing
-tables. By this way if fib_info contains multipath route then many
-aliases share same route path scheduling context.
-- Nexthop contains gateway, output device, scope and weight. Weight
+searched (we hope faster) by prefix and length; no zones are used in
+this case.
+
+- Nodes have a list of aliases (tos + type + scope + fib_info ptr)
+sorted by decreasing tos because tos = 0 must be the last hit when
+looking for a route (tos = 0 matches packet with any tos); type is:
+unicast, local, prohibit, etc.; scope is: host, link, etc.
+Additionally, aliases with the same tos are sorted by fib_info
+priority (ascending).
+
+- fib_info is a structure containing: protocol (kernel, boot, zebra,
+etc.), prefsrc, priority (metric), metrics, nexthop(s). Fallback
+routes have higher value for priority; they are used if routes with
+more priority disappear or their nexthops are dead.
+
+- fib_info structures are organized in 2 global hash tables, one keyed
+by prefsrc, and another by: nexthop_count + protocol + prefsrc +
+priority.
+
+- fib_info structure is shared: different aliases can point at the
+same fib_info, even aliases with different prefixes or from different
+routing tables. This way if fib_info contains multipath route, then
+many aliases share the same route path scheduling context.
+
+- Nexthop contains: gateway, output device, scope and weight; weight
 is used for path scheduling where nexthops have relative priority
-compared to other nexthops in multipath route.
-- There can be many aliases with same tos, there can be alternative
-routes (aliases) with same tos and priority (metric) but only one alias
-with particular tos, type, scope and fib_info can exist to avoid duplicate
-alternative routes.
-- The operation to replace route includes replacing of alias. The alias
-in node (table -> prefix/len) is matched by tos and fib_info priority and
-they can not be changed. The parameters that are changed are type, scope
-and fib_info (except priority).
-- The 'ip' tool maps route operations to NLM_F_* flags as follows: 
+compared to other nexthops in a multipath route.
+
+- There can be many alternative routes (aliases) with the same tos and
+priority (metric), but only one alias can exist with particular: tos,
+type, scope and fib_info - to avoid duplicate alternative routes.
+
+- The operation to replace a route includes replacing an alias. The
+alias in a node (table -> prefix/len) is matched by tos and fib_info
+priority, and they cannot be changed. The parameters that are
+changed are: type, scope and fib_info (except priority).
+
+- The 'ip' tool maps route operations to NLM_F_* flags as follows:
+
 	- ip route add		-> NLM_F_CREATE | NLM_F_EXCL
 		- add unique route
 	- ip route change	-> NLM_F_REPLACE
@@ -49,30 +62,33 @@ and fib_info (except priority).
 		- create new alternative route as last
 	- ip route test		-> NLM_F_EXCL
 		- check if route exists
-- By default, 'ip route add' adds no more than one route for particular
-prefix/len, tos and fib_info priority. This is guaranteed by the
-NLM_F_EXCL flag. Extension to this rule is the support for alternative
-routes where 'ip route prepend' and 'ip route append' which avoid the
-NLM_F_EXCL flag and allow many routes for prefix/len, tos and
-fib_info priority to be added. Still, there should be no more than one
-alternative route with same prefix/len, tos and all remaining fib_info
-parameters.
+
+- By default, 'ip route add' adds no more than one route for
+particular prefix/len, tos and fib_info priority. This is guaranteed
+by the NLM_F_EXCL flag. An extension to this rule is support for
+alternative routes with 'ip route prepend' and 'ip route append' which
+avoid the NLM_F_EXCL flag and allow many routes for prefix/len, tos
+and fib_info priority to be added. Still, there should be no more than
+one alternative route with the same prefix/len, tos and all remaining
+fib_info parameters.
+
 - As for the 'route' tool, it works just like 'ip route prepend' which
 allows alternative routes to be created.
+
 - Additionally, the IP stack can automatically add local or broadcast
-'proto kernel' routes when IP address is added and unicast subnet route
-when primary IP address for subnet is added. The routes are created in
-the 'ip route append' way in local or main table.
+'proto kernel' routes when IP address is added, and unicast subnet
+route when primary IP address for a subnet is added. The routes are
+created in the 'ip route append' way in local or main table.
 
-FIB tree:
+- FIB tree:
 
 * routing table
-	* node (prefix/len)
-		* alias (tos, type, scope)
-			-> fib_info (priority, protocol, prefsrc, metrics)
-				* nexthop (gateway, outdev, scope, weight)
-
-- one or many routing tables with fast access to multiple nodes, each
-node has list with aliases with unique parameters sorted by decreasing tos
-and increasing priority.
+  * node (prefix/len)
+    * alias (tos, type, scope)
+      -> fib_info (priority, protocol, prefsrc, metrics)
+         * nexthop (gateway, outdev, scope, weight)
+
+- One or more routing tables can exist with fast access to multiple
+nodes; each node has a list of aliases with unique parameters sorted
+by decreasing tos and increasing priority.
 
