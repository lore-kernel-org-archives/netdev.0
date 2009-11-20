From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
 and big packets in virtio_net
Date: Fri, 20 Nov 2009 08:08:52 -0800
Message-ID: <1258733332.4108.6.camel@localhost.localdomain>
References: <1258697745.7416.20.camel@localhost.localdomain>
	 <4B063509.10006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754127AbZKTQIy@vger.kernel.org>
In-Reply-To: <4B063509.10006@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-11-20 at 07:19 +0100, Eric Dumazet wrote:
> > +void virtio_free_pages(void *buf)
> > +{
> > +     struct page *page = (struct page *)buf;
> > +
> > +     while (page) {
> > +             __free_pages(page, 0);
> > +             page = (struct page *)page->private;
> > +     }
> > +}
> > +
> 
> Interesting use after free :)

Good catch. This code was run when virtio_net removal. I run many times
of remove virtio_net, and didn't hit any panic :(. Fixed it as below:

void virtio_free_pages(void *buf)
{
	struct page *page = (struct page *)buf;
	struct page *npage;

	while (page) {
		npage = page->private;
		__free_pages(page, 0);
		page = npage;
	}
}

Thanks
Shirley
