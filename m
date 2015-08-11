From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: reduce cpu usage under tcp memory
 pressure when SO_SNDBUF is set
Date: Tue, 11 Aug 2015 09:12:10 -0700
Message-ID: <1439309530.1084.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150811143846.672A92039@prod-mail-relay10.akamai.com>
	 <1439304576.1084.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55CA0EC2.9030306@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35578 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965299AbbHKQMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 12:12:12 -0400
Received: by pacgr6 with SMTP id gr6so53817443pac.2
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 09:12:11 -0700 (PDT)
In-Reply-To: <55CA0EC2.9030306@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-11 at 11:03 -0400, Jason Baron wrote:

> 
> Yes, so the test case I'm using to test against is somewhat contrived.
> In that I am simply allocating around 40,000 sockets that are idle to
> create a 'permanent' memory pressure in the background. Then, I have
> just 1 flow that sets SO_SNDBUF, which results in the: poll(), write() loop.
> 
> That said, we encountered this issue initially where we had 10,000+
> flows and whenever the system would get into memory pressure, we would
> see all the cpus spin at 100%.
> 
> So the testcase I wrote, was just a simplistic version for testing. But
> I am going to try and test against the more realistic workload where
> this issue was initially observed.
> 

Note that I am still trying to understand why we need to increase socket
structure, for something which is inherently a problem of sharing memory
with an unknown (potentially big) number of sockets.

I suggested to use a flag (one bit).

If set, then we should fallback to tcp_wmem[0] (each socket has 4096
bytes, so that we can avoid starvation)
