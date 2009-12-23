From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Deadlock in IPv6 code while garbage collection on the rwlock
 protecting the routing tree.
Date: Wed, 23 Dec 2009 10:13:09 -0800
Message-ID: <20091223101309.08974d02@nehalam>
References: <4D35478224365146822AE9E3AD4A26660E89A49E@exchtewks3.starentnetworks.com>
	<20091222143638.37513a94@nehalam>
	<19250.22271.876068.511246@zeus.eng.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Akkipeddi, Srinivas" <sakkiped@starentnetworks.com>,
	<netdev@vger.kernel.org>
To: Dave Johnson <djohnson@starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47728 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756657AbZLWSNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 13:13:20 -0500
In-Reply-To: <19250.22271.876068.511246@zeus.eng.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Dec 2009 12:44:31 -0500
Dave Johnson <djohnson@starentnetworks.com> wrote:

> I don't think that would help.  You would still have a writer
> contained within a reader issue.  This would also likely involve quite
> a bit of copying given the amount of data the existing rwlock is
> protecting and how frequent write locks may be needed.

With RCU, you can safely acquire a spinlock inside rcu_read_lock
section.  The only issue is that the entry being modified might already
be in process of being deleted (ie. modifying a dead route).

Probably simpler to just get rid of rwlock entirely, go with a spinlock
for now.  Reader/writer locks are slower than spin locks and even if
lock is highly read contended, it is not held for long.

IPV6 routing table is using much simpler algorithms on the assumption
that IPV6 was going to solve the CIDR address explosion problem. That
assumption will probably not hold up, and having a trie (TRASH) version
of IPV6 routing table with RCU would be a good research project for
some graduate student.

-- 
