From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFC]  net/ipv{4,6} UDP-Lite: code sharing between udp.c and udplite.c
Date: Thu, 22 Jun 2006 08:20:04 +0100
Message-ID: <200606220820.05056@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50631 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751767AbWFVHUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 03:20:16 -0400
Received: from gerrit (gerrit.erg.abdn.ac.uk [139.133.204.176])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id k5M7K6uS025953
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 08:20:06 +0100 (BST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I would greatly value comments on a suggestion made earlier by Yoshifuji
regarding sharing code between udp.c and udplite.c which I am pursuing. 

I reduced diffs between ipv4/udp{,lite}.c to the minimum possible and
performed a line-by-line comparison between udp.c and udplite.c.

Result: out of 45 functions which re-appear from udp.c in udplite.c,
        * 26 can be derived without human thinking at all (sed/perl)
        * 10 require trivial interaction (sockopt/header names)
        *  8 require genuine modifications (in control flow and algorithm)
        *  1 function is missing in udplite.c (no equivalent of udp_check())


Problem: The UDP code (and in particular the replicated functions) operate 
         on the following globally visible symbols:
    
         EXPORT_SYMBOL(udp_hash);        /* would be udplite_hash       */
         EXPORT_SYMBOL(udp_hash_lock);   /* would be udplite_hash_lock  */ 
         EXPORT_SYMBOL(udp_port_rover);  /* would be udplite_port_rover */
    
        This would lead to clashes if udp.c/udplite.c use the same names.

          
Suggestion: #include code from udp.c in a much-reduced udplite.c, after
        re-defining symbols, so that the top of udplite.c looks like e.g.

          #include <linux/udplite.h>
          #define   udp_hash        udplite_hash        
          #define   udp_port_rover  udplite_port_rover
          #include "udp.c"          /* include the source code */


Inputs: The benefits are a much deflated patch, code reuse, increased
        clarity (only the diffs are visible). This comes at the cost
        of introducing a few #ifdefs in udp.c (otherwise no changes).
        However, I am not sure whether such an approach would find 
        acceptance and therefore I am asking for input. As currently the
        porting to ipv6/udplite.c is under way, I would like to take any
        suggestions on board which can reduce dependencies and inflated
        code.
        
Many thanks in advance,
--Gerrit 


NB: Details of the code analysis can be found on 
 http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/udplite-comparison.html
and the diff-minimized variant of ipv4/udplite.c is in the latest tarball,
 http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/files/udplite_linux.tar.gz
(any future patches will have the linelengths cut to 80 chars).
