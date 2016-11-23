From: ebiederm@xmission.com (Eric W. Biederman)
Subject: random thoughts on optmizing network namespace exit.
Date: Wed, 23 Nov 2016 17:52:48 -0600
Message-ID: <87eg21ycrz.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Andrei Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45102 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933483AbcKWXz3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 18:55:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fundamentally if we want things to get better we have to remove
unnecessary serialization.  It is entirely too easy to sleep when
cleaning up a networking subsystem and create long hold times on
net_mutex for no particular reasons.

What probably makes sense to do is to add the concept of a
non-serialized pernet_operation.  And then work through the networking
stack converting all of the pernet_operations.  That should allow
network namespace exits to overlap while they clean up, and it should
allow the net_mutex to be dropped at the same point we drop rtnl_lock
in cleanup_net.

It might be a touch tricky during the transition period to take
advantage of an early drop of net_mutex, but that is where I would
start.

Once net_mutex is no longer used to serialize initialization/cleanup
methods for a network namespace.  We can look at other bottlenecks.

Eric
