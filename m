From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] struct file cleanup : the very large file_ra_state is
 now allocated only on demand.
Date: Wed, 17 Aug 2005 19:43:15 -0700 (PDT)
Message-ID: <20050817.194315.111196480.davem@davemloft.net>
References: <20050817215357.GU3996@wotan.suse.de>
	<4303D90E.2030103@cosmosbay.com>
	<20050818010524.GW3996@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, bcrl@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932105AbVHRCnf@vger.kernel.org>
To: ak@suse.de
In-Reply-To: <20050818010524.GW3996@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 18 Aug 2005 03:05:25 +0200

> I would just set the ra pointer to a single global structure if the
> allocation fails. Then you can avoid all the other checks. It will
> slow down things and trash some state, but not fail and nobody
> should expect good performance after out of memory anyways. The only
> check still needed would be on freeing.

I would think twice about that due to repeatability concerns.  Yes, we
should care less when memory is so low, but if we can avoid this kind
of scenerio easily we should.

Having said that, I would like to recommend looking into a scheme
where the path leading to the filp allocation states whether the
read-ahead bits are needed or not.  This has two benefits:

1) Repeatability, and error signalling at the correct place
   should the memory allocation fail.

2) We can avoid the pointer dereference overhead.  The read-ahead
   state is always at (filp + 1).  Macro'ized or static inline
   function'ized interfaces for this access can make it look
   clean and perhaps even implement debugging of the case where
   we try to get at the read-ahead state for a non-read-ahead
   filp.

I do really think that would be a better approach.  A quick glance
shows that it should be easy to propagate the "need_read_ahead"
state, just by passing a boolean to get_unused_fd() via
sock_map_fd().
