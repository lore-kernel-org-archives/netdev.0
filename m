From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq@rere.qmqm.pl>
Subject: Re: [PATCH 08/11] netlink: implement memory mapped sendmsg()
Date: Thu, 8 Sep 2011 20:08:23 +0200
Message-ID: <20110908180823.GA12536@rere.qmqm.pl>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
 <1315070771-18576-9-git-send-email-kaber@trash.net>
 <20110904161822.GA8176@rere.qmqm.pl>
 <4E678C18.1010306@trash.net>
 <20110907200319.GA29545@rere.qmqm.pl>
 <4E688BD5.5030909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E688BD5.5030909@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 08, 2011 at 11:33:09AM +0200, Patrick McHardy wrote:
> Am 07.09.2011 22:03, schrieb Micha=B3 Miros=B3aw:
> > On Wed, Sep 07, 2011 at 05:22:00PM +0200, Patrick McHardy wrote:
> >> On 04.09.2011 18:18, Micha=B3 Miros=B3aw wrote:
> >>> On Sat, Sep 03, 2011 at 07:26:08PM +0200, kaber@trash.net wrote:
> >>>> From: Patrick McHardy <kaber@trash.net>
> >>>>
> >>>> Add support for memory mapped sendmsg() to netlink. Userspace qu=
eued to
> >>>> be processed frames into the TX ring and invokes sendmsg with
> >>>> msg.iov.iov_base =3D NULL to trigger processing of all pending m=
essages.
> >>>>
> >>>> Since the kernel usually performs full message validation before=
 beginning
> >>>> processing, userspace must be prevented from modifying the messa=
ge
> >>>> contents while the kernel is processing them. In order to do so,=
 the
> >>>> frames contents are copied to an allocated skb in case the the r=
ing is
> >>>> mapped more than once or the file descriptor is shared (f.i. thr=
ough
> >>>> AF_UNIX file descriptor passing).
> >>>>
> >>>> Otherwise an skb without a data area is allocated, the data poin=
ter set
> >>>> to point to the data area of the ring frame and the skb is proce=
ssed.
> >>>> Once the skb is freed, the destructor releases the frame back to=
 userspace
> >>>> by setting the status to NL_MMAP_STATUS_UNUSED.
> >>>
> >>> Is this protected from threads? Like: one thread waits on sendmsg=
() and
> >>> another (same process) changes the buffer.
> >> Yes, if the ring is mapped multiple times (or the file descriptor
> >> is changed), the contents are copied to an allocated skb.
> >=20
> > I mean:
> >=20
> > [1] mmap()
> > [1] fill buffers
> > [1] pthread_create() [creates: 2]
> > [1] sendmsg() starts
> > [2] modify buffers
> > [1] sendmsg() returns
> >=20
> > So: no multiple mmaps, and no touching of the fd. I haven't dug int=
o
> > filesystem layer to see if threads affect file->f_count, but there
> > sure are no multiple mappings here.
> If CLONE_VM is given to clone(), the mapping is visible in both
> threads and thus we have multiple mappings (vma_ops->open() is
> invoked through clone()). Without CLONE_VM, the second thread
> can't access the ring unless it mmap()s it itself, in case we'd
> also have multiple mappings.

I made a quick look into kernel/fork.c, and it looks to me that if CLON=
E_VM
is set, then vma->open() is actually avoided --- it's called via dup_mm=
()
and dup_mmap() only if CLONE_VM is not there and the VMA needs to be co=
pied.

Best Regards,
Micha=B3 Miros=B3aw
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
