From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v6 0/3] net: reserve ports for applications using fixed port numbers
Date: Thu, 4 Mar 2010 22:11:23 +0200
Message-ID: <201003042211.23460.opurdila@ixiacom.com>
References: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com> <4B8F6FF0.5000306@redhat.com> <m1vddbdhmo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nhorman@tuxdriver.com, eric.dumazet@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23892 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753202Ab0CDUL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 15:11:26 -0500
In-Reply-To: <m1vddbdhmo.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 March 2010 21:14:07 you wrote:
> Cong Wang <amwang@redhat.com> writes:
> > David Miller wrote:
> >> Eric B., could you look over the first two patches (which touch the
> >> sysctl core) and give some review and ACK/NACK?
> >
> > ping Eric W. Biederman ... :)
> 
> I have looked and it is not easy to tell by simple review if
> correctness has been maintained in the proc cleanup patch.
> Furthermore the code even after the cleanups still feels like code
> that is trying too hard to do too much.
> 
> 
> I think the example set by bitmap_parse_user in it's user interface is
> a good example to follow when constructing bitmap helper functions.
> Including having the actual parsing code should live in lib/bitmap.c
> 
> The users of bitmap_parse_user do something very nice.  They allocate
> a temporary bitmap.  Parse the userspace value into the temporary
> bitmap, and then move that new bitmap into the kernel data structures.
> For your large bitmap this seems like the idea way to handle it.  That
> guarantees no weird intermediate failure states, and really makes the
> the bitmap feel like a single value.
> 
> I would add the restriction that the values in the list of ranges
> always must be increasing, and in general restrict the set of accepted
> values as much as possible.  If we don't accept it now we don't have
> to worry about some userspace application relying on some unitended
> side effect a few years into the future.
> 

Eric, thanks for taking the time to go over it again. I now do share you 
opinion that we need to be more atomic. How about this simple approach:

1. Allocate new kernel buffer for the text and copy the whole userspace buffer 
into it.
2. Allocate temporary buffer for bitmap.
3. Parse the kernel text buffer into the temp bitmap.
4. Copy the temp bitmap into the final bitmap.

This is simple and clean but it has the disadvantage of potentially allocating 
a large chunk of memory, although even in the case that all ports are going to 
be set the temporary buffer will not go over 390K, which is now not an issue 
anymore for kmalloc, right?

> I think it is a serious bug that you clear the destination bitmap
> in the middle of parsing it.  That will either open or close all
> ports in the middle of parsing, and I can't see how that would
> ever be a good thing.
> 

Even when doing the copy from the temp bitmap you still have some inconsistent 
bitmap state while copying. 

We could solve by replacing the old buffer with the new one + RCU.



