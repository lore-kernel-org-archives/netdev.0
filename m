From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Wed, 14 Oct 2015 22:54:38 -0400
Message-ID: <561F156E.9050905@akamai.com>
References: <cover.1443817522.git.jbaron@akamai.com>	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>	<5612B9A9.8050301@akamai.com>	<87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>	<561DCFA4.3010300@akamai.com> <87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:32957 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751098AbbJOCyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 22:54:41 -0400
In-Reply-To: <87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

....
> 
> X-Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> 

Hi,

So the patches I've posted and yours both use the idea of a relaying
the remote peer wakeup via callbacks that are internal to the net/unix,
such that we avoid exposing the remote peer wakeup to the external
poll()/select()/epoll(). They differ in when and how those callbacks
are registered/unregistered.

So I think your approach here will generally keep the peer wait wakeup
queue to its absolute minimum, by removing from that queue when
we set POLLOUT, however it requires taking the peer waitqueue lock on
every poll() call. So I think there are tradeoffs here vs. what I've
posted. So for example, if there are a lot of writers against one 'server'
socket, there is going to be a lot of lock contention with your approach
here. So I think the performance is going to depend on the workload that
is tested.

I don't have a specific workload that I am trying to solve here, but
since you introduced the waiting on the remote peer queue, perhaps you
can post numbers comparing the patches that have been posted for the
workload that this was developed for? I will send you the latest version
of what I have privately - so as not to overly spam the list.

Thanks,

-Jason
