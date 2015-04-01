From: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and cap_sa(), for sa-check
Date: Tue, 31 Mar 2015 20:51:13 -0400
Message-ID: <20150401005113.GA15327@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com> <55157B43.6060507@profitbricks.com> <1427732191.21101.201.camel@redhat.com> <55197CDB.3040105@profitbricks.com> <1427734923.21101.227.camel@redhat.com> <20150331231202.GA20094@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <mata
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150331231202.GA20094-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2015 at 05:12:02PM -0600, Jason Gunthorpe wrote:
> On Mon, Mar 30, 2015 at 01:02:03PM -0400, Doug Ledford wrote:
> 
> > If we use something like this, then the above is all you need.  Then
> > every place in the code that checks for something like has_sa or cap_sa
> > can be replaced with rdma_ib_mgmt. 
> 
> I don't want to see this slide back into some ill defined feature
> test.
> 
> We need to clearly define exactly what these tests are checking, and I
> think, since we have so much code sharing, the checks should be narrow
> in scope, not just an entire standard.

Somewhat agree.

> 
> I think the basic family of checks Michael identified seemed like
> a reasonable start.
> 
> Going forward we want to NAK stuff like this:
> 
>   if (rdma_ib_mgmt() || rdma_opa_mgmt())
>   if (has_sa() || has_opa_foobar())

I'm confused.

Is the idea that you would NAK has_sa but be in favor of has_ib_sa?

I think cap_opa_mad is reasonable.  And this confuses me why has_opa_foobar
would be NAKed.

I believe it is reasonable to flag OPA MAD support as a feature set through a
single bit.  From this the MAD stack can know if OPA MAD base/class versions
are allowed (or treated differently from future IB versions) and if it should
processing OPA SM Class DR MADs differently.  I don't want devices to be
required to supply a list of MAD Base/Class Versions they support.

> 
> That indicates we need a new micro feature test.

The million dollar question is how micro we should go.

More specifically which feature sets can be appropriately communicated with a
single bit vs not.

For example, the MAD size is more generally (and perhaps better) communicated
via an actual mad_size attribute rather than as part of the OPA MAD feature
set.

Another example is the question of is it appropriate to wrap up the single READ
SGL entry support within the "is iwarp" flag?

https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23611.html

Right now there is implicit information being gleaned from the "is iwarp" flag.
That is that an iWarp device is limited to only 1 READ SGL entry.  As this is
the only device type which has this limitation _and_ that number is "well
known" it works.  Even if not the best solution.

The task at hand is to clean up implicit information passing like this while
not getting mired down in our own refactoring.

> 
> A big problem here is people working on the core may not know the
> intricate details of all the families. This will only get worse when
> proprietary tech like OPA gets added. Documenting requirements via a
> narrow feature test gives a much higher chance that core stuff will be
> right via review.

Agreed as long as we get the width right.

> 
> > But, like I said, this is an all or nothing change, it isn't
> > something we can ease into.
> 
> Well, we ease into it by introducing the micro tests and then wiping
> the legacy ones, followed by changing how the driver/core communicates
> the port and device feature set, ideally to a bitset like you've
> described.

I think this does need to be eased into.  We seem to agree that the feature
flags we have now are not granular and/or explicit enough.  So lets start
cleaning up some of these tests and see how it goes.

Ira

> 
> Michael has tackled the core code, another series could work on the
> drivers..
> 
> Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
