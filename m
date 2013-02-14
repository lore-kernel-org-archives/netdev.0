From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Wed, 13 Feb 2013 19:20:23 -0800 (PST)
Message-ID: <1218897172.1425846.1360812023655.JavaMail.root@vmware.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
	<5118FEA9.2080201@redhat.com>
	<1675407061.963254.1360682467627.JavaMail.root@vmware.com>
	<511B739C.8000204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <511B739C.8000204@redhat.com>
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

> I've seen you have a notify_ops in the vmci bits.  Do you have different
> notify ops depending on socket type or something?  Does it make sense to
> move the notify ops ptr into "struct vsock_sock" maybe?

The notify stuff only applies to STREAMs.  However, we have two different
notify impls, one for legacy ESX and one for newer, and we figure out at
runtime which protocol we're using with the hypervisor and set the
callbacks appropriately.  The difference between the two is that the
newer one is much smarter and knows not to signal (the peer) quite so much,
i.e., it has some basic but sensible flow-control, which improves
performance quite a bit.  Again, that might not make any sense at all
for virtio.  Do you need to signal when you enqueue to a ring?  And is
there coalescing?  Dunno...

> And can we make it optional please (i.e. allow the function pointers to
> be NULL)?

They were originally allowed to be NULL, but I changed it in the last
round of patches while moving them into the transport, since I disliked
the NULL checks so much.  I can put them back, but that's a bigger
change, and I'm not sure we want to push large patches to Dave right
now :)

> Which problem you are trying to tackle with the notifications?

It's to do with signaling the peer, or more appropriately, trying to
avoid signaling the peer when possible.  The naive impl. is to signal
every time we enqueue or dequeue data (into our VMCI queuepairs).
But signaling is slow, since it involves a world exit, so we prefer
not to.  Which means we need to keep track of rate of flow and figure
out when we should and should not, and that's what all the notification
stuff does.  It's...ugly...

> > For the VMCI transport, it indicates if the underlying queuepair is
> > still around (i.e., make sure we haven't torn it down while sleeping
> > in a blocking send or receive).  Perhaps it's not the best name?
> 
> How you'd hit that?  Peer closing the socket while sleeping?  Other
> thread closing the socket wile sleeping?  Both?
> 
> I think a state field in struct vsock_sock would be a better solution here.

Hrm, lemme think about this one.

> 
> >> What is *_allow?
> > 
> > It's very basic filtering.  We have specific addresses that we don't
> > allow, and we look for them in the allow() functions.  You can just
> > return true if you like.
> 
> Can we make those calls optional too please?

Sure.

> The notify_*_init could return a opaque pointer instead.  But then
> you'll need a notify_*_free too.  And you can't place it on the stack
> and thus have a allocation in the hot path, which I guess you are trying
> to avoid in the first place.

Avoiding allocation is good, but at the same time, I wonder if it's not
a big deal compared with the time spent copying out of the buffers, in
which case it won't matter.  So maybe we can do this.

Thanks!
- Andy
