From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Mon, 18 May 2009 19:35:59 -0700
Message-ID: <20090518193559.05295fe4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54442 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753249AbZESCgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:36:07 -0400
Received: from nehalam (pool-71-117-243-208.ptldor.fios.verizon.net [71.117.243.208])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id n4J2a5BB015328
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 19:36:07 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 18 May 2009 14:10:20 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 13339] New: rtable leak in ipv4/route.c


http://bugzilla.kernel.org/show_bug.cgi?id=13339

           Summary: rtable leak in ipv4/route.c
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.29
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: lav@yar.ru
        Regression: Yes


2.6.29 patch has introduced flexible route cache rebuilding. Unfortunately the
patch has at least one critical flaw, and another problem.

rt_intern_hash calculates rthi pointer, which is later used for new entry
insertion. The same loop calculates cand pointer which is used to clean the
list. If the pointers are the same, rtable leak occurs, as first the cand is
removed then the new entry is appended to it.

This leak leads to unregister_netdevice problem (usage count > 0).

Another problem of the patch is that it tries to insert the entries in certain
order, to facilitate counting of entries distinct by all but QoS parameters.
Unfortunately, referencing an existing rtable entry moves it to list beginning,
to speed up further lookups, so the carefully built order is destroyed.

For the first problem the simplest patch it to set rthi=0 when rthi==cand, but
it will also destroy the ordering.

-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
