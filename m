From: Alasdair G Kergon <agk@redhat.com>
Subject: Re: [2.6.23 PATCH 14/18] dm: netlink add to core
Date: Thu, 12 Jul 2007 22:18:20 +0100
Message-ID: <20070712211820.GK30047@agk.fab.redhat.com>
References: <20070711210159.GF24114@agk.fab.redhat.com>
	<20070711143423.36722a41.akpm@linux-foundation.org>
	<m1bqehfyp0.fsf@ebiederm.dsl.xmission.com>
	<20070712173410.GA2505@us.ibm.com>
	<m1wsx5e7lk.fsf@ebiederm.dsl.xmission.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Anderson <andmike@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Alasdair G Kergon <agk@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <m1wsx5e7lk.fsf@ebiederm.dsl.xmission.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 01:37:43PM -0600, Eric W. Biederman wrote:
> This of course assumes things are a good fit or the other pieces
> can be made to be a good fit.  Currently I don't see the what makes
> device mapper's events not fit the existing models, and I don't
> see it in the description for this patch why we need to invent
> something new.
 
The existing event protocol used by device-mapper is trivial.  It just
lets kernel device-mapper say to userspace 'Something happened on mapped
device X in which you might be interested: Check it out!'.  Userspace
then runs various checks to work out what happened and decide whether
any action should be taken.  Though simple, in practice this often
proves very inefficient.

We want to change the mechanism so device-mapper can pass an arbitrary
small payload to userspace to tell it exactly what happened immediately
so it no longer needs to waste time probing for things that could have
happened but kernel device-mapper knows didn't.

These netlink patches are the first attempt to put such a mechanism in
place for a few specific multipath conditions.  Sure, we *could*
shoe-horn this into extended dm ioctls but I see that as a last resort
if we can't make an existing mechanism do what we need.

Examples of events raised against device-mapper block devices to switch
to whichever new mechanism is chosen:
  - a new dm table has gone live (payload holds some basic info about
the new table)
  - the dm device name has just been changed (new name in payload)
  - a path in a multipath table has been marked as failed e.g. after
an I/O failure (payload says which path)
  - a failed path in a multipath table has been reenabled (payload says
which path)
  - a specific group of multipath paths has been bypassed (payload says
which group)
  - I/O is being directed to a different group of multipath paths
(payload says which group)
  - mirror recovery is complete
  - a mirror's log device has failed
  - a snapshot has been marked invalid (payload indicates reason)

Depending on the context, the events are caught by a userspace
device-mapper process (sometimes a long-lived daemon) - one that is
often locked in memory with preallocated buffers all set to process the
information and resolve the problem etc.

Alasdair
-- 
agk@redhat.com
