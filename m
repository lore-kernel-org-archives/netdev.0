From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 08:17:48 -0500
Message-ID: <4908627C.6030001@acm.org>
References: <20081008.114527.189056050.davem@davemloft.net>
 <49077918.4050706@cosmosbay.com>	<490795FB.2000201@cosmosbay.com>
 <20081028.220536.183082966.davem@davemloft.net>
 <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:53710 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbYJ2OSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 10:18:30 -0400
Received: from wf-rch.minyard.local ([96.226.138.225])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0K9I001204XPKLW1@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 29 Oct 2008 08:17:50 -0500 (CDT)
In-reply-to: <49082718.2030201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe there is a race in this patch:

+	sk_for_each_rcu(sk, node, &hslot->head) {
+		/*
+		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
+		 * We must check this item was not moved to another chain
+		 */
+		if (udp_hashfn(net, sk->sk_hash) != hash)
+			goto begin;
 		score = compute_score(sk, net, hnum, saddr, sport, daddr, dport, dif);
 		if (score > badness) {
 			result = sk;
 			badness = score;
 		}
 	}

If the socket is moved from one list to another list in-between the time 
the hash is calculated and the next field is accessed, and the socket 
has moved to the end of the new list, the traversal will not complete 
properly on the list it should have, since the socket will be on the end 
of the new list and there's not a way to tell it's on a new list and 
restart the list traversal.  I think that this can be solved by 
pre-fetching the "next" field (with proper barriers) before checking the 
hash.

I also might be nice to have a way to avoid recomputing the score the 
second time, perhaps using a sequence number of some type.

-corey
