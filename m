From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Question: AF-Independence of ECN (was [PATCH 0/4] inet6: minor
	cleanups)
Date: Wed, 22 Jul 2009 22:17:31 +0200
Message-ID: <20090722201731.GA8877@gerrit.erg.abdn.ac.uk>
References: <1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk> <20090721.125745.210846096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60244 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751865AbZGVURm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 16:17:42 -0400
Content-Disposition: inline
In-Reply-To: <20090721.125745.210846096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for reviewing the patches.

| > Patch #4: Finds that RT_TOS() redefines IPTOS_TOS().
| 
| This macro probably exists so that if the ipv4 route cache entry TOS
| representation changes compared to IPTOS_TOS(), we would simply have
| to change the definition of this macro.
| 
| Just because they happen to be the same now is no reason to kill off
| this macro I think.
| 
| I'm not applying this either.
| 
These patches are a byproduct of studying the code. I think it is better to
post the question I am trying to resolve, before discussing any more patches.
I hope that there will be some input and/or discussion.

The problem is that
 * IPv4 TOS and IPv6 Traffic Class have identical semantics
   - the DiffServ bits 0..5 due to RFC 2474,
   - the 'CU'/ECN bits 6,7  due to RFC 3168.
 * in the code this is currently handled AF-dependent:
   - as inet_sk's    "tos"    field,
   - as ipv6_pinfo's "tclass" field.
 
There are already three existing Linux transport protocols affected by
the AF-dependence of ECN:
 * TCPv4 supports ECN, but TCPv6 currently does not;
 * SCTP achieves ECN support for v4 and v6 only with difficulties:
   - it uses a function pointer 'ecn_capable', which calls wrappers around
   - INET_ECN_xmit (sctp_v4_ecn_capable)
   - modification of inet6_sk(sk)->tclass (sctp_v6_ecn_capable)
 * DCCP ECN is not supported yet, but a working patch set exists.

So the whole point is: to achieve AF-independent ECN/DiffServ support, 
I was using an ugly hack to work around the existing AF-dependence:

  #define IP6_ECN_flow_xmit(sk, label) do {                               \
  -       if (INET_ECN_is_capable(inet6_sk(sk)->tclass))                  \
  -               (label) |= htonl(INET_ECN_ECT_0 << 20);                 \
  +       IP6_ECN_flow_init(label);                                       \
  +       (label) |= htonl((inet_sk(sk)->tos & INET_ECN_MASK) << 20);     \
       } while (0)
  
Realising that 
 * this is so ugly that I don't want to submit it (it has been the reason for
   several patches sitting idly for a couple of months), and 
 * finding that other transport protocols are facing a similar situation,

I am interested in solving the problem so that 
 (a) the DCCP code becomes usable and 
 (b) other transport protocols might benefit from a more generic solution.

My question:
 * is there support for an AF-independent use of ECN/DiffServ field?
 * what needs to be considered other than a good understanding of the code:
   - are there possible breakages,
   - legacy code or,
   - anything else that would prevent this?

Gerrit
