From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] NBD: Move from a global spinlock to one lock per NBD device
Date: Tue, 5 Feb 2013 11:22:48 -0500
Message-ID: <20130205162248.GG20842@kvack.org>
References: <1359993343.18869.14.camel@eboracum.office.bytemark.co.uk> <CAPshTCir48mTze-pEayg5TDxcH0Tyi4=NoH-FBhnM4rgrxekfQ@mail.gmail.com> <1360080867.18869.30.camel@eboracum.office.bytemark.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul.Clements@steeleye.com, jaxboe@fusionio.com,
	netdev@vger.kernel.org, hkchu@google.com, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Nicholas Thomas <nick@bytemark.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:58455 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753984Ab3BEQWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 11:22:49 -0500
Content-Disposition: inline
In-Reply-To: <1360080867.18869.30.camel@eboracum.office.bytemark.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2013 at 04:14:27PM +0000, Nicholas Thomas wrote:
> This patch is entirely based on a submission by Jerry Chu, incorporating
> suggestions from Eric Dumazet. Modern, faster NICs make the original comment
> on why a single lock is preferable incorrect; moving to one lock per NBD
> device removes a performance bottleneck.
> 
> Original patch: http://permalink.gmane.org/gmane.linux.network/207233
...
> +static spinlock_t *nbd_locks __read_mostly;
...

This is about the worst way to split up a lock possible.  Most (all?) of the 
spinlocks across nbd devices are on the same cacheline, so performance will 
be limited by the rate of cacheline bounces for the lock.  It would be far 
better to embed the spinlock in the data structures that it will be 
protecting to avoid this expensive false-sharing.

		-ben
