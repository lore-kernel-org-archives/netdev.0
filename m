From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
	available to userspace
Date: Thu, 12 Jun 2008 10:07:10 +0100
Message-ID: <20080612090710.GA6307@gerrit.erg.abdn.ac.uk>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806081421.25688.tomasz@grobelny.oswiecenia.net> <20080610114908.GA25798@gerrit.erg.abdn.ac.uk> <200806111943.42390.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:42638 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752724AbYFLJHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 05:07:41 -0400
Content-Disposition: inline
In-Reply-To: <200806111943.42390.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > But there are also areas where the rate of change is relatively low or
| > even absent: Documentation/ABI/README for instance mentions 4 different
| > levels of stability (stable/testing/obsolete/removed), the most entries
| > are under `testing'.
| >
| This one should probably be marked as testing too. And probably be moved to 
| stable with time (when it proves useful for applications).
| 
In the test tree there are two levels of testing:

 * any subtrees tree are open for writing experimental patches,
   for refinement, and for patches that may be rewritten later;

 * the test tree itself is for later consideration in mainline and therefore
   is more conservative. The main reason for keeping the patches in that tree
   is to extend the phase of patch review, to filter out bugs that may still
   lurk somewhere, so that regressions are minimised when submitting.


| > why not implement a sysctl (which is also mirrored in
| > /proc/sys) that contains all available/implemented qpolicies as a
| > space-separated string, such as
| >
| > 	cat /proc/sys/net/ipv4/tcp_available_congestion_control ?
| >
| Could be /proc/sys. I just had an impression that sysctls are for setting 
| certain variables used in kernel. But as far as I understand it the 
| difference is highly subjective and I'm ok with both /proc and /proc/sys. 
Yes that is not immediately obvious, there are far more sysctls with write
permissions than informative/read-only sysctls:
 * read-only:   7 entries with  `find /proc/sys/net/ -perm  444` 
 * write:     486 entries with  `find /proc/sys/net/ -perm /222`


| Would be nice to have more opinions (Arnaldo? others?) whether we should 
| favour one over other.
Agree with this call. 


| But if the application wants information about implemented parameters there is 
| currently no way to get it. It can try to send() packet and check return 
| value (which is quite a hack to be honest). It will work if the parameter is 
| not implemented at all. But what happens when you try to set priority for a 
| packet and use "simple" qpolicy? AFAIR nothing - you get no information 
| whatsoever that this parameter will not be used inside qpolicy.
| 
| And that's why we need information about parameters in /proc or /proc/sys.
| 
Sorry I can't see here why we need information about parameters. When
introducing a new socket option there is a convention of how to use it.

For sockopts, the type of the argument is listed for each option type.

With qpolicies, there is one more indirection, since there is no
immediate return value. But even for this kind of socket option there
exist similar cases, for instance in the manpage of ipv6(7)
 * IPV6_RECVERR (boolean) sets delivery of error messages which return a "struct
   sock_extended_err" via cmsg(3) when MSG_ERRQUEUE is set in recvmsg(2)
 * IPV6_PKTINFO (boolean) sets the delivery of IPV6_PKTINFO control messages,
   and this one has an associated constraint - works only on SOCK_DGRAM/SOCK_RAW


| > If we agree on using unique strings to identify qpolicies then we can
| > keep the runtime discovery much simpler. I think a manpage would be more
| > helpful here, since the runtime discovery of parameters is not
| > immediately obvious.
| >
| Manpage of what? Documentation is certainly needed but before writing one we 
| need to have a basic implementation we agree upon.
| -- 
There is indeed a misunderstanding.

We have already an implementation we agreed upon:
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=87cf8b3ce96397f934775617ba24eb1ff404747a

With a manpage I mean to document 
 * how the two currently available qpolicies ("simple" and "prio") are enabled;
 * which additional constraints they have (e.g. how they interpret tx_qlen);
 * information specific to a policy (e.g. that higher priority values in the
   "prio" policy mean a higher priority, comparable to SO_PRIORITY in socket(7));
 * which ancillary data the policies require (the procfs parameters)
   - simple: no ancillary parameters
   - prio:   u32 priority value, passed as DCCP_SCM_PRIORITY via cmsg(3),
             using a level of SOL_DCCP and a length of CMSG_LEN(sizeof(uint32_t));
 * ... probably I have missed something here

With that kind of documentation, I think, we would not need runtime discovery
of parameters.
