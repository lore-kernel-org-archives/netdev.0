From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH/RFC] synchronize_rcu(): high latency on idle system
Date: Mon, 14 Jan 2008 09:19:00 -0800
Message-ID: <20080114091900.3a857024@deepthought>
References: <20080112012626.GI28570@kvack.org>
	<200801121935.58286.ak@suse.de>
	<20080112175226.7d8f9dbc@deepthought>
	<200801131634.17677.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kerne@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48824 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752248AbYANRVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 12:21:37 -0500
In-Reply-To: <200801131634.17677.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Jan 2008 16:34:17 +0100
Andi Kleen <ak@suse.de> wrote:

> 
> > I think it should be in netdev_unregister_kobject().  But that would
> > only get rid of one of the two calls to synchronize_rcu() in the unregister_netdev.
> 
> Would be already an improvement.
> 
> > The other synchronize_rcu() is for qdisc's and not sure if that one can
> > be removed?
> 
> The standard way to remove such calls is to set a "deleted" flag in the object,
> then check and ignore such objects in the reader and finally remove the object with
> call_rcu
> 
> I have not checked if that is really feasible for qdiscs.
> 
> -Andi

Actually, the synchronize_rcu() is now acting a barrier between two sections
in the current unregister process. It can't be removed.

But, an alternative unregister_and_free_netdev() could be created that uses
call_rcu.  Basically:

void unregistr_and_free_netdev() {
    do stuff before barrier...
    setup rcu callback
    call_rcu();
}

static void netdev_after_rcu() {
    rtnl_lock();
    do stuff after barier
    rtnl_unlock();
    free_netdev
}

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
