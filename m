From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sun, 10 Aug 2008 09:54:46 -0500
Message-ID: <1218380086.3418.21.camel@localhost.localdomain>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>
	 <aday73jxdfs.fsf@cisco.com>	<200807311752.00911.divy@chelsio.com>
	 <200808071145.03848.divy@chelsio.com>
	 <489C8BEB.8060001@opengridcomputing.com>	<489CC58D.4010606@pobox.com>
	 <adazlnlzc60.fsf@cisco.com> <20080810101935.5c8e8e9a@lxorguk.ukuu.org.uk>
	 <489EE3DC.9060202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Roland Dreier <rdreier@cisco.com>,
	Steve Wise <swise@opengridcomputing.com>, davem@davemloft.net,
	Divy Le Ray <divy@chelsio.com>, Karen Xie <kxie@chelsio.com>,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from accolon.hansenpartnership.com ([76.243.235.52]:53644 "EHLO
	accolon.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751511AbYHJOyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 10:54:55 -0400
In-Reply-To: <489EE3DC.9060202@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-08-10 at 08:49 -0400, Jeff Garzik wrote:
> Alan Cox wrote:
> >>  - It doesn't work in theory, because the suggestion (I guess) is that
> >>    the iSCSI HBA has its own MAC and IP and behaves like a separate
> > 
> > The iSCSI HBA is its own system - that is the root of the problem.
> 
> Indeed.
> 
> Just like with TOE, from the net stack's point of view, an iSCSI HBA is 
> essentially a wholly asynchronous remote system [with a really fast 
> communication bus like PCI Express].
> 
> As such, the task becomes updating the net stack such that 
> formerly-private resources are now shared with an independent, external 
> system...  with all the complexity, additional failure modes, and 
> additional security complications that come along with that.

What's wrong with making it configurable identically to current software
iSCSI?  i.e. plumb the thing into the current iscsi transport class so
that we use the standard daemon for creating and binding sessions?
Then, only once the session is bound do you let your iSCSI TOE stack
take over.

That way the connection appears to the network as completely normal,
because it has an open socket associated with it; and, since the
transport class has done the connection login, it even looks like a
normal iSCSI connection to the usual tools.  iSCSI would manage
connection and authentication, so your TOE stack can be simply around
the block acceleration piece (i.e. you'd need to get the iscsi daemon to
do relogin and things).

I would assume net will require some indicator that the opened
connection has been subsumed, so it knows not to try to manage it, but
other than that I don't see it will need any alteration.  The usual
tools, like netfilter could even use this information to know the limits
of their management.

If this model works, we can use it for TOE acceleration of individual
applications (rather than the entire TCP stack) on an as needed basis.

This is like the port stealing proposal, but since the iSCSI daemon is
responsible for maintaining the session, the port isn't completely
stolen, just switched to accelerator mode when doing the iSCSI offload.

James


