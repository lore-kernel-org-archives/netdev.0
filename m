From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 05/12] IB/cm: Share listening CM IDs
Date: Thu, 21 May 2015 11:54:13 -0600
Message-ID: <20150521175413.GB6771@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-6-git-send-email-haggaie@mellanox.com>
 <20150519183545.GH18675@obsidianresearch.com>
 <20150519223502.GA26324@obsidianresearch.com>
 <555D927F.7060801@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:44526 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702AbbEURyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 13:54:16 -0400
Content-Disposition: inline
In-Reply-To: <555D927F.7060801@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 11:08:31AM +0300, Haggai Eran wrote:
> > The more I look at this, the more I think it is sketchy. Don't try and
> > merge sharecount and refcount together,

> I'm not sure what you mean here. The way I was thinking about it was
> that sharecount = num of rdma_cm_ids sharing this listener, while
> refcount = num of active internal uses of this ID (work items, timers,
> etc.) Do you want refcount to also include the sharecount?

If you hold on to the pointer, then you increment the refcount. The
refcount is the 'number of holders of the pointer'. Basic invariant.

When the pointer left the lock region for the lockup, the ref must be
incremented.

What you had was functionally correct because the sharecount was
implying a refcount, but it doesn't follow the standard kernel
refcounting pattern.

> > after cm_find_listen is called
> > you have to increment the refcount before dropping cm.lock.
> > 
> > Decrement the refcount when destroying a shared listen.
> You mean to decrement event if listen_sharecount > 0, and the id isn't
> destroyed, right? The code already calls cm_deref_id when
> listen_sharecount = 0 of course.

Yes, because cm_destroy_id is the ref'd pair to cm_listen, after it
returns the caller must give up their pointer.

Jason
