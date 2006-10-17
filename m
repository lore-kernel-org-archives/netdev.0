From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 15:19:05 +0400
Message-ID: <20061017111905.GD19246@2ka.mipt.ru>
References: <20061016.135222.78711520.davem@davemloft.net> <019c01c6f186$99d0d6b0$0281a8c0@ebpc>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "'David Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:9160 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1423067AbWJQLTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 07:19:31 -0400
To: Eric Barton <eeb@bartonsoftware.com>
Content-Disposition: inline
In-Reply-To: <019c01c6f186$99d0d6b0$0281a8c0@ebpc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2006 at 01:53:02AM +0100, Eric Barton (eeb@bartonsoftware.com) wrote:
> > And these days we're trying to figure
> > out how to eliminate skbuff and skb_shared_info struct members
> > whereas you're adding 16-bytes of space on 64-bit platforms.
> 
> Do you think the general concept of a zero-copy completion callback is
> useful?

You can use existing skb destructor and appropriate reference counter is
already there. In your own destructor you need to call old one of
course, and it's type can be determined from the analysis of the headers
and skb itself (there are not so much destructor's types actually).
If that level of abstraction is not enough, it is possible to change
skb_release_data()/__kfree_skb() so that it would be possible in
skb->destructor() to determine if attached pages will be freed or not.

> If so, do you have any ideas about how to do it more economically?  It's 2
> pointers rather than 1 to avoid forcing an unnecessary packet boundary
> between successive zero-copy sends.  But I guess that might not be hugely
> significant since you're generally sending many pages when zero-copy is

Existing sendfile() implementation is synchronous, it does not require
async callback. It looks like lustre sets number of pages to be sent
asyncrhonously and report to user that everything is ok, and when
appropriate callback is invoked, it updates it's metadata? Fair enough,
it looks similar to VFS cache in case of usual write.

> needed for performance.  Also, (please correct me if I'm wrong) I didn't
> think this would push the allocation over to the next entry in
> 'malloc_sizes'.

skbs are allocated from own cache, and the smaller it is, the better.

>                 Cheers,
>                         Eric

-- 
	Evgeniy Polyakov
