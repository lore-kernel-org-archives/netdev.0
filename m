From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Thu, 5 Feb 2015 08:21:25 +0100
Message-ID: <20150205072125.GY13046@secunet.com>
References: <54CF3348.40207@huawei.com>
 <20150203092845.GT13046@secunet.com>
 <54D0A8DB.4010106@huawei.com>
 <20150203120140.GU13046@secunet.com>
 <54D17D1A.3020706@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: shengyong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45895 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbbBEHV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 02:21:29 -0500
Content-Disposition: inline
In-Reply-To: <54D17D1A.3020706@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2015 at 09:59:54AM +0800, shengyong wrote:
> 
> Sorry, the later. I test it on 3.10-stable. It can fix this problem. So maybe this is a bug?

Yes, it's a bug.

> And the 3 approaches (different flags are used: RTF_LOCAL, IFF_LOOPBACK and RTF_CACHE) in
> these mails can fix the expire of local address. I'm confused about these flags:
> * RTF_LOCAL: the entries of local address, like address binded to the native NIC
> * RTF_CACHE: all cached entries
> * IFF_LOOPBACK: this is a device-related flag, which has the same meaning as RTF_LOCAL
> 
> Am I right? If so, I think RTF_LOCAL is appropriate, because we just want entries of local
> addresses to be not expired and we don't care other entries (I think if they get expired,
> a neigh discovery could find them back).

It is not the address that expires, it is the learned PMTU value that
expires. If we delete an uncached route, nothing will bring it back
unless you readd it manually.

We need to ensure that all routes that can learn something what
expires are cached. This means that we clone the inserted route
when it is used for the first time. The learned values are stored
at this cloned route. If the learned value expires, the clone is
deleted. The original route remains in the fib tree and can be
still looked up.

The problem is, that we currently don't cache/clone host routes.
So if a host route learns something that expires, the original
route is removed from the fib tree and we loose connectivity
to that host. We don't cache host routes because some of them
(the local ones) are automatically added with metric 0.
If we try to cache such a route, the clone will be identical
to the original route and we fail to insert it to the fib tree.

So we need to adjust the caching to all routes that actually can
learn something and leave out only those that can not.

I'll send a patchset that should fix this at the beginning of the
next week.
