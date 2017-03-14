From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH 08/29] drivers, md: convert mddev.active from atomic_t
 to refcount_t
Date: Tue, 14 Mar 2017 07:58:59 -0700
Message-ID: <1489503539.3214.17.camel@HansenPartnership.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-9-git-send-email-elena.reshetova@intel.com>
 <87lgs8ukfq.fsf@concordia.ellerman.id.au>
 <2236FBA76BA1254E88B949DDB74E612B41C588E8@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "peterz@infradead.org" <peterz@infradead.org>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
 "linux1394-devel@lists.sourceforge.net"
 <linux1394-devel@lists.sourceforge.net>,
 "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 "linux-serial@vger.kernel.org" <linux-serial@vger.kernel.org>,
 "fcoe-devel@open-fcoe.org" <fcoe-devel@open-fcoe.org>,
 "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
 "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 Kees Cook <keescook@chromium.org>,
 "linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
 "linux-bcache@vger.kernel.org" <linux-bcache@vger.kerne
To: "Reshetova, Elena" <elena.reshetova@intel.com>, Michael Ellerman
 <mpe@ellerman.id.au>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B41C588E8@IRSMSX102.ger.corp.intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, 2017-03-14 at 12:29 +0000, Reshetova, Elena wrote:
> > Elena Reshetova <elena.reshetova@intel.com> writes:
> > 
> > > refcount_t type and corresponding API should be
> > > used instead of atomic_t when the variable is used as
> > > a reference counter. This allows to avoid accidental
> > > refcounter overflows that might lead to use-after-free
> > > situations.
> > > 
> > > Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> > > Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> > > Signed-off-by: Kees Cook <keescook@chromium.org>
> > > Signed-off-by: David Windsor <dwindsor@gmail.com>
> > > ---
> > >  drivers/md/md.c | 6 +++---
> > >  drivers/md/md.h | 3 ++-
> > >  2 files changed, 5 insertions(+), 4 deletions(-)
> > 
> > When booting linux-next (specifically 5be4921c9958ec) I'm seeing
> > the
> > backtrace below. I suspect this patch is just exposing an existing
> > issue?
> 
> Yes, we have actually been following this issue in the another
> thread. 
> It looks like the object is re-used somehow, but I can't quite
> understand how just by reading the code. 
> This was what I put into the previous thread:
> 
> "The log below indicates that you are using your refcounter in a bit
> weird way in mddev_find(). 
> However, I can't find the place (just by reading the code) where you
> would increment refcounter from zero (vs. setting it to one).
> It looks like you either iterate over existing nodes (and increment
> their counters, which should be >= 1 at the time of increment) or
> create a new node, but then mddev_init() sets the counter to 1. "
> 
> If you can help to understand what is going on with the object
> creation/destruction, would be appreciated!
> 
> Also Shaohua Li stopped this patch coming from his tree since the 
> issue was caught at that time, so we are not going to merge this 
> until we figure it out. 

Asking on the correct list (dm-devel) would have got you the easy
answer:  The refcount behind mddev->active is a genuine atomic.  It has
refcount properties but only if the array fails to initialise (in that
case, final put kills it).  Once it's added to the system as a gendisk,
it cannot be freed until md_free().  Thus its ->active count can go to
zero (when it becomes inactive; usually because of an unmount). On a
simple allocation regardless of outcome, the last executed statement in
md_alloc is mddev_put(): that destroys the device if we didn't manage
to create it or returns 0 and adds an inactive device to the system
which the user can get with mddev_find().

James
