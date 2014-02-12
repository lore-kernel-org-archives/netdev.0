From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net 1/3] kref: add kref_sub_return
Date: Wed, 12 Feb 2014 10:37:57 -0800
Message-ID: <20140212183757.GA27840@kroah.com>
References: <1392222846-26699-1-git-send-email-mst@redhat.com>
	<1392222846-26699-2-git-send-email-mst@redhat.com>
	<20140212165630.GA22991@kroah.com>
	<20140212173524.GA26860@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, Joern Engel <joern@logfs.org>,
	Anatol Pomozov <anatol.pomozov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com,
	davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140212173524.GA26860@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 07:35:24PM +0200, Michael S. Tsirkin wrote:
> On Wed, Feb 12, 2014 at 08:56:30AM -0800, Greg Kroah-Hartman wrote:
> > On Wed, Feb 12, 2014 at 06:38:21PM +0200, Michael S. Tsirkin wrote:
> > > It is sometimes useful to get the value of the reference count after
> > > decrement.
> > > For example, vhost wants to execute some periodic cleanup operations
> > > once number of references drops below a specific value, before it
> > > reaches zero (for efficiency).
> > 
> > You should never care about what the value of the kref is, if you are
> > using it correctly :)
> > 
> > So I really don't want to add this function, as I'm sure people will use
> > it incorrectly.  You should only care if the reference drops to 0, if
> > not, then your usage doesn't really fit into the "kref" model, and so,
> > just use an atomic variable.
> 
> This happens when you have code that keeps
> reference itself implicitly or explicitly.
> 
> 	foo(struct kref *k, int bar) {
> 
> 	sub = kref_sub(k)
> 
> 	if (sub == 1)
> 		FOO(k, bar) /* Here I am the only one
> 			       with a reference */

Why do you care if you are the only one with a reference?

If you do, then just don't grab that reference and do the work in the
cleanup callback :)

> 	}
> 
> 	kref_get(k)
> 	foo(k, bar);
> 	....
> 	kref_put(k)
> 
> Why not do FOO in destructor you ask?
> Absolutely but this will be called much later.
> 
> Maybe you will reconsider if I document this
> as the only legal use?

No one reads documentation :(

> > I really want to know why it matters for "efficiency" that you know this
> > number.  How does that help anything, as the number could then go up
> > later on, and the work you did at a "lower" number is obsolete, right?
> > 
> > thanks,
> > 
> > greg k-h
> 
> The issue is that if number dropped to 1, this means
> we must do the cleanup work since there are
> no outstanding buffers, (last user is ourselves)
> if we do not cleanup,
> guest will hang waiting for us.

This doesn't make sense, nor does it sound like a use for a kref (or you
are using it wrong.)

> But it never drops to 0 since we have our own reference
> in the device.

Then don't do that.

> If it goes up again this means we didn't have
> to do cleanup, but an alternative is doing
> it all the time and that is slow.

Then just cleanup when it hits 0, like the rest of the world does.

> Yes I can rework vhost to open-code this kref use, it's
> no big deal.
> Alternatively since most of the use does match kref
> model, maybe __kref_sub_return with disclaimers
> that you must know what you are doing?

No, no one reads documentation, sorry.  Either fix your use of kref
(i.e. don't care about the count), or do something else, as you don't
want a kref, but rather, an atomic count of what is going on and "1"
means something "special" to you.

sorry,

greg k-h
