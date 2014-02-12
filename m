From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 1/3] kref: add kref_sub_return
Date: Wed, 12 Feb 2014 19:35:24 +0200
Message-ID: <20140212173524.GA26860@redhat.com>
References: <1392222846-26699-1-git-send-email-mst@redhat.com>
 <1392222846-26699-2-git-send-email-mst@redhat.com>
 <20140212165630.GA22991@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        virtio-dev@lists.oasis-open.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        davem@davemloft.net, qinchuanyu@huawei.com,
        Joern Engel <joern@logfs.org>,
        Anatol Pomozov <anatol.pomozov@gmail.com>,
        Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <virtio-dev-return-378-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
Content-Disposition: inline
In-Reply-To: <20140212165630.GA22991@kroah.com>
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 08:56:30AM -0800, Greg Kroah-Hartman wrote:
> On Wed, Feb 12, 2014 at 06:38:21PM +0200, Michael S. Tsirkin wrote:
> > It is sometimes useful to get the value of the reference count after
> > decrement.
> > For example, vhost wants to execute some periodic cleanup operations
> > once number of references drops below a specific value, before it
> > reaches zero (for efficiency).
> 
> You should never care about what the value of the kref is, if you are
> using it correctly :)
> 
> So I really don't want to add this function, as I'm sure people will use
> it incorrectly.  You should only care if the reference drops to 0, if
> not, then your usage doesn't really fit into the "kref" model, and so,
> just use an atomic variable.

This happens when you have code that keeps
reference itself implicitly or explicitly.

	foo(struct kref *k, int bar) {

	sub = kref_sub(k)

	if (sub == 1)
		FOO(k, bar) /* Here I am the only one
			       with a reference */

	}

	kref_get(k)
	foo(k, bar);
	....
	kref_put(k)

Why not do FOO in destructor you ask?
Absolutely but this will be called much later.

Maybe you will reconsider if I document this
as the only legal use?

> 
> I really want to know why it matters for "efficiency" that you know this
> number.  How does that help anything, as the number could then go up
> later on, and the work you did at a "lower" number is obsolete, right?
> 
> thanks,
> 
> greg k-h

The issue is that if number dropped to 1, this means
we must do the cleanup work since there are
no outstanding buffers, (last user is ourselves)
if we do not cleanup,
guest will hang waiting for us.

But it never drops to 0 since we have our own reference
in the device.
If it goes up again this means we didn't have
to do cleanup, but an alternative is doing
it all the time and that is slow.

Yes I can rework vhost to open-code this kref use, it's
no big deal.
Alternatively since most of the use does match kref
model, maybe __kref_sub_return with disclaimers
that you must know what you are doing?
Please let me know.

Thanks!

-- 
MST
