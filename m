From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 01/21] scatterlist: Introduce sg_map helper functions
Date: Thu, 27 Apr 2017 08:53:38 +0200
Message-ID: <20170427065338.GA20677@lst.de>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com> <1493144468-22493-2-git-send-email-logang@deltatee.com> <20170426074416.GA7936@lst.de> <4736d44e-bbcf-5d59-a1a9-317d0f4da847@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org,
        linux-crypto@vger.kernel.org, linux-media@vger.kernel.org,
        dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
        linux-raid@vger.kernel.org, linux-mmc@vger.kernel.org,
        linux-nvdimm@lists.01.org, linux-scsi@vger.kernel.org,
        open-iscsi@googlegroups.com, megaraidlinux.pdl@broadcom.com,
        sparmaintainer@unisys.com, devel@driverdev.osuosl.org,
        target-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, dm-devel@redhat.com,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Jens Axboe <axboe@kernel.dk>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Ross Zwisler <ross.zwisler@linux.intel.com>,
To: Logan Gunthorpe <logang@deltatee.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4736d44e-bbcf-5d59-a1a9-317d0f4da847@deltatee.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 12:11:33PM -0600, Logan Gunthorpe wrote:
> Ok, well for starters I think you are mistaken about kmap being able to
> fail. I'm having a hard time finding many users of that function that
> bother to check for an error when calling it.

A quick audit of the arch code shows you're right - kmap can't fail
anywhere anymore.

> The main difficulty we
> have now is that neither of those functions are expected to fail and we
> need them to be able to in cases where the page doesn't map to system
> RAM. This patch series is trying to address it for users of scatterlist.
> I'm certainly open to other suggestions.

I think you'll need to follow the existing kmap semantics and never
fail the iomem version either.  Otherwise you'll have a special case
that's almost never used that has a different error path.

> There are a fair number of cases in the kernel that do something like:
> 
> if (something)
>     x = kmap(page);
> else
>     x = kmap_atomic(page);
> ...
> if (something)
>     kunmap(page)
> else
>     kunmap_atomic(x)
> 
> Which just seems cumbersome to me.

Passing a different flag based on something isn't really much better.

> In any case, if you can accept an sg_kmap and sg_kmap_atomic api just
> say so and I'll make the change. But I'll still need a flags variable
> for SG_MAP_MUST_NOT_FAIL to support legacy cases that have no fail path
> and both of those functions will need to be pretty nearly replicas of
> each other.

Again, wrong way.  Suddenly making things fail for your special case
that normally don't fail is a receipe for bugs.
