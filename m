From: Bob Gilligan <gilligan@aristanetworks.com>
Subject: No netlink notification for user-initiated NUD state change
Date: Tue, 26 Nov 2013 18:28:07 -0800
Message-ID: <529558B7.5000506@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:47516 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab3K0C2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 21:28:09 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so9421341pbc.10
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 18:28:09 -0800 (PST)
Received: from Administrators-MacBook-Pro-3.local ([162.210.130.4])
        by mx.google.com with ESMTPSA id gw10sm46093525pbd.13.2013.11.26.18.28.08
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 18:28:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -- The neighbour code sends up an RTM_NEWNEIGH netlink notification
if the NUD state of a neighbour cache entry is changed by a timer (e.g.
from REACHABLE to STALE), even if the lladdr of the entry has not changed.

But a user-initiated change to the the NUD state of a neighbour cache
entry that does not change the lladdr (e.g. via "ip -4 neigh change ...
nud ...") does not trigger a netlink notification.

I'm wondering if that is intended behavior?  Is there any reason not to
send a netlink notification in this case?  The situation we've seen
where it would be nice to have these notifications is if a user changes
an existing resolved entry to PERMANENT.

This one-line change to neigh_update() would trigger netlink
notifications on all user-initiated state changes:

Index: linux-3.12.1/net/core/neighbour.c
===================================================================
--- linux-3.12.1.orig/net/core/neighbour.c
+++ linux-3.12.1/net/core/neighbour.c
@@ -1161,6 +1161,7 @@ int neigh_update(struct neighbour *neigh

neigh->parms->reachable_time :
                                                 0)));
                neigh->nud_state = new;
+               notify = 1;
        }

        if (lladdr != neigh->ha) {



I'd be happy to submit a properly formatted patch if there's agreement
that this is an issue.

Bob.
