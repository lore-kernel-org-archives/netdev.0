From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 17/18] vhost: don't bother copying iovecs in
 handle_rx(), kill memcpy_toiovecend()
Date: Tue, 3 Feb 2015 22:13:11 +0000
Message-ID: <20150203221311.GD29656@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <1422863977-17668-17-git-send-email-viro@ZenIV.linux.org.uk>
 <20150203100412.GA4896@redhat.com>
 <20150203152154.GA9072@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41239 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbbBCWNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 17:13:15 -0500
Content-Disposition: inline
In-Reply-To: <20150203152154.GA9072@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2015 at 04:21:54PM +0100, Michael S. Tsirkin wrote:
> > Hmm having second thoughts here.
> > Will this modify the iov in vq->iov?
> > If yes, how will recvmsg fill it?
> 
> OK that was just me misunderstanding what the
> function does. As it doesn't modify the iovec itself,
> I think there's no issue, my ack stands.

That, BTW, was the point of switching ->sendmsg() and ->recvmsg() to
iov_iter primitives - not only do memcpy_toiovec() et.al. change the
iovec, the way it's done was protocol-dependent, up to and including
the things like "have sent 60 caller-supplied bytes, iovec modified
with only 6 bytes consumed".  What's worse, on TCP sendmsg we usually
left iovec unchanged, but sometimes it got drained.  Granted, that
happened only after setsockopt() playing caller with TCP_REPAIR (i.e.
checkpoint/restart stuff), but...
