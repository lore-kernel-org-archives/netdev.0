From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Does the ordering of the fib_table_dump or /proc/net/fib_trie matter?
Date: Tue, 06 Jan 2015 12:30:06 -0800
Message-ID: <54AC45CE.80800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "miller >> David Miller" <davem@davemloft.net>,
	stephen@networkplumber.org, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:44059 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbbAFUaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 15:30:08 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so279888pac.11
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 12:30:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am considering reversing the order of any non-lookup traversal of the
fib_trie so that it starts at the last node and works it's way up toward
the first node.  This would make it so that all walks using the parent
pointer all go in the same direction.

The problem right now is that leaf_walk_rcu and a couple of other
iterators traverse the trie in one direction grabbing the next child
(child++) of the parent, while fib_table_lookup is traversing the list
grabbing a previous child (child & (child - 1)) of the parent.  It makes
things a bit ugly for RCU as we have to have the node fully populated
before we can start updating the parent pointers on the children.

I want to have them both moving in the same direction so the
fib_table_lookup would remain the same, but the leaf_walk_rcu and others
would walk from the last child to the first (child--) and as a result
when I assemble a tnode in inflate or halve I would be able to populate
children from 0 to ((1 << tn->bits) - 1) without having to worry about
any iterators walking into uninitialized memory.

The question I have is if that would screw up any user-space apps.  I
know ip route can dump the list via "ip route show".  I'm just wondering
if there would be any problem with default being the last entry instead
of the first entry?

- Alex
