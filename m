From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers and big packets in virtio_net
Date: Wed, 25 Nov 2009 10:42:06 +1030
Message-ID: <200911251042.06368.rusty@rustcorp.com.au>
References: <1258697745.7416.20.camel@localhost.localdomain> <200911240854.24054.rusty@rustcorp.com.au> <20091124113754.GB2405@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hollis Blanchard <hollisb@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933338AbZKYAMF@vger.kernel.org>
In-Reply-To: <20091124113754.GB2405@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Nov 2009 10:07:54 pm Michael S. Tsirkin wrote:
> On Tue, Nov 24, 2009 at 08:54:23AM +1030, Rusty Russell wrote:
> > On Tue, 24 Nov 2009 02:37:01 am Shirley Ma wrote:
> > > > > +             skb = (struct sk_buff *)buf;
> > > > This cast is unnecessary, but a comment would be nice:
> > > 
> > > Without this cast there is a compile warning. 
> > 
> > Hi Shirley,
> > 
> >    Looks like buf is a void *, so no cast should be necessary.  But I could
> > be reading the patch wrong.
> > 
> > > > However, I question whether making it 16 byte is the right thing: the
> > > > ethernet header is 14 bytes long, so don't we want 8 bytes of padding?
> > > 
> > > Because in QEMU it requires 10 bytes header in a separately, so one page
> > > is used to share between virtio_net_hdr header which is 10 bytes head
> > > and rest of data. So I put 6 bytes offset here between two buffers. I
> > > didn't look at the reason why a seperate buf is used for virtio_net_hdr
> > > in QEMU.
> > 
> > It's a qemu bug.  It insists the header be an element in the scatterlist by
> > itself.  Unfortunately we have to accommodate it.
> 
> We do?  Let's just fix this?
> All we have to do is replace memcpy with proper iovec walk, correct?
> Something like the followng (untested) patch?  It's probably not too
> late to put this in the next qemu release...

You might want to implement a more generic helper which does:

	/* Return pointer into iovec if we can, otherwise copy into buf */
	void *pull_iovec(struct iovec *iov, int iovcnt, void *buf, size_t len)
	{
		unsigned int i;
		void *p;

		if (likely(iov_cnt && iov[0].iov_len >= len)) {
			/* Nice contiguous chunk. */
			void *p = iov[0].iov_base;
			iov[i].iov_base += len;
			iov[i].iov_len -= len;
			return p;
		}

		p = buf;
		for (i = 0; i < iov_cnt; i++) {
			size_t this_len = min(len, iov[i].iov_len);
			memcpy(p, iov[i].iov_base, this_len);
			len -= this_len;
			iov[i].iov_base += len;
			iov[i].iov_len -= len;
			if (len == 0)
				return buf;
		}
		/* BTW, we screwed your iovec. */
		return NULL;
	}

Then use it in all the virtio drivers...

Thanks!
Rusty.
