From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/2] fix generic netlink locking issue(s)
Date: Wed, 21 Aug 2013 16:08:01 +0200
Message-ID: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:59330 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab3HUOIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 10:08:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's another attempt at fixing the genetlink locking issue,
hopefully better tested this time. Sorry about the mess the 
previous version caused.

I really didn't find a way to "simply" add locking, no matter
which way I turn genetlink is special because it would then use
the same locks "inside" and "outside" the generic netlink family;
"inside" because I'm trying to protect the otherwise unlocked
dump call, and "outside" because it itself is a generic netlink
family so needs to protect things there.

As a result, I've turned to RCU and (hopefully) made it safe.
The unregistration can get fairly expensive with all the calls
to synchronize_rcu(), but I don't see any better way, and it's
hopefully really rare.

The only place that now uses RCU is ctrl_dumpfamily(), but it'd
be possible to use it in other places. I didn't want to do it
in this patch, but I also don't see any candidates where that 
would really make sense. 

The first patch should obviously go into 3.11, I'll let you 
decide about the second. This one might actually be easier to
backport than the original one, but it'd still have to be done
carefully.

johannes
