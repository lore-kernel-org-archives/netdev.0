From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Network/block layer race.
Date: Fri, 28 Mar 2008 12:20:36 +0300
Message-ID: <20080328092036.GA11924@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jens Axboe <axboe@kernel.dk>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36380 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754292AbYC1JRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:17:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

There is a race between ->sendpage() and block layer, when the latter
can override the page while it is queued in hardware, qdisk or tcp
queue. Although page's reference counter is handled correctly, and page
will not be freed until fully transferred, block layer can reuse it,
since it assumes that after ->sendpage() returns, page is no longer
used. It is invalid assumption, but there is no way currently to
determine when page is no longer used by network except invoke a
callback during skb freeing.

Block layer pages do not use page->lru.next, at least in kernel afaics,
which is a kmem_cache pointer, so some users, who do know, what they are
doing, can set it up to private data structure and replace skb
destructor with own callback, which in turn will invoke sock_wfree()
when needed (transmit only is interesing), so there will not be any
changes in skb structure, maybe some extension of the sock (a single
pointer to private callback or reuse sk_user_data, which is only used by
rpc code, and export of the sock_wfree() function.

I do not know if we have to fix sendfile()/splice() since everyone is
used to have that race, but some other out-of-tree network storage
projects (like distributed storage) would greatly benefit from it.

So far it is a request for comments and idea has to be better tested if
accepted, so the question is: will such a hack be accepted?

Thanks.

-- 
	Evgeniy Polyakov
