From: David Miller <davem@davemloft.net>
Subject: Re: async network I/O, event channels, etc
Date: Wed, 26 Jul 2006 23:10:55 -0700 (PDT)
Message-ID: <20060726.231055.121220029.davem@davemloft.net>
References: <44C66FC9.3050402@redhat.com>
	<20060725.150122.49854414.davem@davemloft.net>
	<20060726062817.GA20636@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44729
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932518AbWG0GKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 02:10:36 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060726062817.GA20636@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 26 Jul 2006 10:28:17 +0400

> I have not created additional DMA memory allocation methods, like
> Ulrich described in his article, so I handle it inside NAIO which
> has some overhead (I posted get_user_pages() sclability graph some
> time ago).

I've been thinking about this aspect, and I think it's very
interesting.  Let's be clear what the ramifications of this
are first.

Using the terminology of Network Algorithmics, this is an
instance of Principle 2, "Shift computation in time".

Instead of using get_user_pages() at AIO setup, we instead map the
thing to userspace later when the user wants it.  Pinning pages is a
pain because both user and kernel refer to the buffer at the same
time.  We get more flexibility when the user has to map the thing
explicitly.

I want us to think about how a user might want to use this.  What
I anticipate is that users will want to organize a pool of AIO
buffers for themselves using this DMA interface.  So the events
they are truly interested in are of a finer granularity than you
might expect.  They want to know when pieces of a buffer are
available for reuse.

And here is the core dilemma.

If you make the event granularity too coarse, a larger AIO buffer
pool is necessary.  If you make the event granuliary too fine,
event processing begins to dominate, and costs too much.  This is
true even for something as light weight as kevent.
