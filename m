From: "Nate Diller" <nate.diller@gmail.com>
Subject: Re: [PATCH -mm 4/10][RFC] aio: convert aio_complete to file_endio_t
Date: Tue, 16 Jan 2007 01:21:24 -0800
Message-ID: <5c49b0ed0701160121t7d65de92u74454f2debb86ea2@mail.gmail.com>
References: <20070116015450.9764.38389.patchbomb.py@nate-64.agami.com>
	 <200701152153.49260.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Nate Diller" <nate@agami.com>, "Andrew Morton" <akpm@osdl.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Benjamin LaHaise" <bcrl@kvack.org>,
	"Alexander Viro" <viro@zeniv.linux.org.uk>,
	"Suparna Bhattacharya" <suparna@in.ibm.com>,
	"Kenneth W Chen" <kenneth.w.chen@intel.com>,
	"David Brownell" <dbrownell@users.sourceforge.net>,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:65432 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbXAPJV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 04:21:26 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2328860nfa
        for <netdev@vger.kernel.org>; Tue, 16 Jan 2007 01:21:24 -0800 (PST)
To: "David Brownell" <david-b@pacbell.net>
In-Reply-To: <200701152153.49260.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/15/07, David Brownell <david-b@pacbell.net> wrote:
> On Monday 15 January 2007 5:54 pm, Nate Diller wrote:
> > --- a/drivers/usb/gadget/inode.c      2007-01-12 14:42:29.000000000 -0800
> > +++ b/drivers/usb/gadget/inode.c      2007-01-12 14:25:34.000000000 -0800
> > @@ -559,35 +559,32 @@ static int ep_aio_cancel(struct kiocb *i
> >       return value;
> >  }
> >
> > -static ssize_t ep_aio_read_retry(struct kiocb *iocb)
> > +static int ep_aio_read_retry(struct kiocb *iocb)
> >  {
> >       struct kiocb_priv       *priv = iocb->private;
> > -     ssize_t                 len, total;
> > -     int                     i;
> > +     ssize_t                 total;
> > +     int                     i, err = 0;
> >
> >       /* we "retry" to get the right mm context for this: */
> >
> >       /* copy stuff into user buffers */
> >       total = priv->actual;
> > -     len = 0;
> >       for (i=0; i < priv->nr_segs; i++) {
> >               ssize_t this = min((ssize_t)(priv->iv[i].iov_len), total);
> >
> >               if (copy_to_user(priv->iv[i].iov_base, priv->buf, this)) {
> > -                     if (len == 0)
> > -                             len = -EFAULT;
> > +                     err = -EFAULT;
>
> Discarding the capability to report partial success, e.g. that the first N
> bytes were properly transferred?  I don't see any virtue in that change.
> Quite the opposite in fact.
>
> I think you're also expecting that if N bytes were requested, that's always
> how many will be received.  That's not true for packetized I/O such as USB
> isochronous transfers ... where it's quite legit (and in some cases routine)
> for the other end to send packets that are shorter than the maximum allowed.
> Sending a zero length packet is not the same as sending no packet at all,
> for another example.

I will convert this (usb) code to use the standard completion path,
which you will notice *gained* the ability to properly report both an
error and a partial success as part of this patch.  In fact, fixing
this up was my intention when I wrote this patch, and the later patch
was a compromise intended to get this whole bundle out for review in a
timely manner :)

NATE
