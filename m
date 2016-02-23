From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Invalid sk_policy[] access (was Re: Recent spontaneous reboots on
 multiple machines)
Date: Tue, 23 Feb 2016 07:12:44 -0500
Message-ID: <20160223121244.GI28756@oracle.com>
References: <alpine.LRH.2.20.1601061716510.27880@math.ut.ee>
 <alpine.LRH.2.20.1601061722190.27880@math.ut.ee>
 <20160107174105.GD23579@oracle.com>
 <alpine.LRH.2.20.1601072133480.29795@math.ut.ee>
 <20160107201445.GF23579@oracle.com>
 <20160108172022.GA3398@oracle.com>
 <alpine.LRH.2.20.1602051103140.5582@math.ut.ee>
 <20160214105131.GD20715@oracle.com>
 <alpine.LRH.2.20.1602150751180.29662@math.ut.ee>
 <20160222010201.GB23053@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sparclinux@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19992 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbcBWMMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 07:12:55 -0500
Content-Disposition: inline
In-Reply-To: <20160222010201.GB23053@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I figured out what's the root-cause of my panics.

In my case, for the stack shown in 
 http://marc.info/?l=linux-sparc&m=145610295109214&w=2
(which also has all the details about the issue),

tcp_make_synack has been called with attach_req set to true
so it sets up the skb->sk via:

        if (attach_req) {
                skb_set_owner_w(skb, req_to_sk(req));
        } else { /* .. */

Now, req is a struct inet_request_sock, and we are casting this
as a struct sock, to later get the ->sk_policy[1] in the xfrm
code. Consider the sizes of these structures between 32 and 64 bits:

  sizeof             32-bit        64-bit
-------------------------------------------
request_sock          256           312
inet_request_sock     272           328
sock                  688          1216

And offsetof sk_policy[1] is 256 on the 32-bit v440, whereas
it is 520 on my 64-bit T5. 

Thus on the v440, the sk_policy[1] is pointing at somewhere
in the middle of stuff set up by tcp_openreq_init() (the ireq
flags initialization).

Even on the 64-bit arch, trying to do req_to_sk(req) and accessing
fields beyond the sock_common, e.g., between offset 312 and 328 
may not give you the fields you are looking for? 

so how is this supposed to work? (Evidently it worked for Meelis
before, but I dont know if that was before or after  commit
9e17f8a475).

--Sowmini
