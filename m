From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 11:40:47 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7241@saturn3.aculab.com>
References: <519B38EC.90401@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <zhmurov@yandex-team.ru>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>
To: "Roman Gushchin" <klamm@yandex-team.ru>,
	"Dipankar Sarma" <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54424 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753892Ab3EUKly convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 06:41:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30531-01 for <netdev@vger.kernel.org>;
 Tue, 21 May 2013 11:41:49 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <519B38EC.90401@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Some network functions (udp4_lib_lookup2(), for instance) use the
> hlist_nulls_for_each_entry_rcu macro in a way that assumes restarting
> of a loop. In this case, it is strictly necessary to reread the head->first
> value from the memory before each scan.
> Without additional hints, gcc caches this value in a register. In this case,
> if a cached node is moved to another chain during the scan, we can loop
> forever getting wrong nulls values and restarting the loop uninterruptedly.

Hmmm.... if either inet_ehashfn() or next_pseudo_random32() is
called gcc must reread it anyway.
I'm surprised gcc is generating separate code for all the conditional
loop endings. So why is it caching head->first.
The 'list empty' might be short-circuited - but that would only
be relevant after a rescan.
I suspect something else is going on.

I'd also have thought that this code needs to scan the entire
hash list. If things are moved under its feet this won't happen.
If it can end up on a different list (because a node got moved)
it is also possible for a later node to move it back.
In that case it would end up on the correct list
...
> -#define hlist_nulls_first_rcu(head) \
> -	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
> +#define hlist_nulls_first_rcu(head)			\
> +	(*((struct hlist_nulls_node __rcu __force **)	\
> +	   &((volatile typeof(*head) *)head)->first))

I'd have thought it would be better to change hlist_nulls_first_rcu().

	David
