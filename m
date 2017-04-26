From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: [PATCH v2 01/21] scatterlist: Introduce sg_map helper functions
Date: Wed, 26 Apr 2017 09:44:16 +0200
Message-ID: <20170426074416.GA7936@lst.de>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com> <1493144468-22493-2-git-send-email-logang@deltatee.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
	"Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Ross Zwisler <ross.zwisler-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Stephen Bates <s
To: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Return-path: <open-iscsi+bncBDUNBGN3R4KRBUM7QHEAKGQEGIOHSPI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <1493144468-22493-2-git-send-email-logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 12:20:48PM -0600, Logan Gunthorpe wrote:
> This patch introduces functions which kmap the pages inside an sgl.
> These functions replace a common pattern of kmap(sg_page(sg)) that is
> used in more than 50 places within the kernel.
>=20
> The motivation for this work is to eventually safely support sgls that
> contain io memory. In order for that to work, any access to the contents
> of an iomem SGL will need to be done with iomemcpy or hit some warning.
> (The exact details of how this will work have yet to be worked out.)

I think we'll at least need a draft of those to make sense of these
patches.  Otherwise they just look very clumsy.

> + *   Use this function to map a page in the scatterlist at the specified
> + *   offset. sg->offset is already added for you. Note: the semantics of
> + *   this function are that it may fail. Thus, its output should be chec=
ked
> + *   with IS_ERR and PTR_ERR. Otherwise, a pointer to the specified offs=
et
> + *   in the mapped page is returned.
> + *
> + *   Flags can be any of:
> + *	* SG_KMAP		- Use kmap to create the mapping
> + *	* SG_KMAP_ATOMIC	- Use kmap_atomic to map the page atommically.
> + *				  Thus, the rules of that function apply: the
> + *				  cpu may not sleep until it is unmaped.
> + *	* SG_MAP_MUST_NOT_FAIL	- Indicate that sg_map must not fail.
> + *				  If it does, it will issue a BUG_ON instead.
> + *				  This is intended for legacy code only, it
> + *				  is not to be used in new code.

I'm sorry but this API is just a trainwreck.  Right now we have the
nice little kmap_atomic API, which never fails and has a very nice
calling convention where we just pass back the return address, but does
not support sleeping inside the critical section.

And kmap, wh=D1=96ch may fail and requires the original page to be passed
back.  Anything that mixes these two concepts up is simply a non-starter.

--=20
You received this message because you are subscribed to the Google Groups "=
open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
