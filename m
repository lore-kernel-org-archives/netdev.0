From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Tue, 4 Jan 2005 14:46:29 +0100
Message-ID: <20050104134629.GK26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <1104812028.1085.50.camel@jzny.localdomain> <20050104120333.GF26856@postel.suug.ch> <1104844753.1085.99.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104844753.1085.99.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104844753.1085.99.camel@jzny.localdomain> 2005-01-04 08:19
> On Tue, 2005-01-04 at 07:03, Thomas Graf wrote:
> >  change() (Optional)
> 
> My thinking is:
> It doesnt have to be simple 32 bit data.
> If i pass you a struct and tell you what length it is, then you as the
> classifier dont know need to know anything about it. You just store
> mystruct as data and datalen from the TLV. you then pass the datastruct
> to match() -  Of course the match() will have to know what that struct
> means.

That's exactly how it is, basically the logic is:

	if (ops->change) {
		err = ops->change(tp, data, datalen, m);
		if (err < 0)
			goto errout;
	} else if (datalen > 0) {
		if (mh->flags & TCF_EM_SIMPLE) {
			if (datalen != sizeof(u32))
				goto errout;
			m->data = *(u32 *) data;
		} else {
			void *v = kmalloc(datalen, GFP_KERNEL);
			if (v == NULL) {
				err = -ENOBUFS;
				goto errout;
			}
			memcpy(v, data, datalen);
			m->data = (unsigned long) v;
		}
	}
	m->datalen = datalen;

> >  destroy() (Optional)
> >    Called if provided, otheriwse m->data is freed in ematch api unless
> >    TCF_EM_SIMPLE is set.
> 
> Again using the above logic, destroy becomes just kfree(mystruct)

Right, that's exactly how it is

	if (m->ops->destroy)
		m->ops->destroy(tp, m);
	else if (!(m->hdr.flags & TCF_EM_SIMPLE) && m->data)
		kfree((void *) m->data);


> >  dump() (Optional)
> >    Called if provided, otherwise m->data is dumped onto the skb with
> >    m->datalen as L. Special handling again for TCF_EM_SIMPLE.
> 
> and dump becomes a matter of looking at datalen and encapsulating
> mystruct in a TLV without thinking about what the content is.

Absolutely true, you know about the code before you read it ;->

	if (m->ops->dump) {
		if (m->ops->dump(skb, m) < 0)
			goto rtattr_failure;
	} else if (m->hdr.flags & TCF_EM_SIMPLE) {
		u32 u = m->data;
		RTA_PUT_NOHDR(skb, sizeof(u32), &u);
	} else if (m->datalen > 0)
		RTA_PUT_NOHDR(skb, m->datalen, (void *) m->data);
