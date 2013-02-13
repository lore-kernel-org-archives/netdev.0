From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Wed, 13 Feb 2013 12:06:04 +0100
Message-ID: <511B739C.8000204@redhat.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
	<5118FEA9.2080201@redhat.com>
	<1675407061.963254.1360682467627.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1675407061.963254.1360682467627.JavaMail.root@vmware.com>
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

On 02/12/13 16:21, Andy King wrote:
> Hi Gerd,
> 
>>> +struct vsock_transport {
> ...
>> Whoa.  This has grown *alot*.  Care to explain this please?  Patch
>> creating a Documentation/virtual/vsock.txt would be cool.
> 
> Yes, it grew because of the notification stuff, which I'd forgotten
> about until I removed the vmci header from the core code.  You are
> free to use empty functions for these if they don't make any sense
> for virtio.

I've seen you have a notify_ops in the vmci bits.  Do you have different
notify ops depending on socket type or something?  Does it make sense to
move the notify ops ptr into "struct vsock_sock" maybe?

And can we make it optional please (i.e. allow the function pointers to
be NULL)?

> The alternative is for us to move the entire body of
> vsock_stream_recv/send into the transport, where we can hide the
> notification stuff, but it seems like folks will just end up
> duplicating a lot of code then.

Sounds not so good.  However, it is still not very clear what this
notification stuff is all about.  And it's not just notification, the
calls can return errors too.

Which problem you are trying to tackle with the notifications?

>> stream_has_data + stream_has_space + stream_rcvhiwat look like they
>> are needed for buffer management.  Details please (especially for
>> stream_rcvhiwat).
> 
> stream_has_data: Returns amount of data available (in bytes) in the
> socket's receive buffer, or -1 if empty.
> 
> stream_has_space: Returns amount of space available (in bytes) in the
> socket's send buffer, or -1 if full.

As one would expect from the names, good.

> stream_rcvhiwat: The upper bound on the socket's receive buffer.
> Which technically is the same as the value returned by
> get_buffer_size(), so perhaps we could substitute that here and
> drop this one.

Yes, please.

>> What is stream_is_active?
> 
> For the VMCI transport, it indicates if the underlying queuepair is
> still around (i.e., make sure we haven't torn it down while sleeping
> in a blocking send or receive).  Perhaps it's not the best name?

How you'd hit that?  Peer closing the socket while sleeping?  Other
thread closing the socket wile sleeping?  Both?

I think a state field in struct vsock_sock would be a better solution here.

>> What is *_allow?
> 
> It's very basic filtering.  We have specific addresses that we don't
> allow, and we look for them in the allow() functions.  You can just
> return true if you like.

Can we make those calls optional too please?

>> What are all those notify_* calls?
> 
> They're to do with signaling and flow-control.  Again, they might
> not make any sense at all, but it's hard to know without having
> written another transport :)

I don't see a immediate need for them in the virto transport, but it's
hard to say without knowing what exactly they are doing.

>> Why do you need vsock_transport_{send,recv}_notify_data structs?
>> Can't this live in vsock_sock->trans?
> 
> Those have to be setup on a per-call basis (per-thread), so it's
> just easier to have them on the stack of the send/recv calls.  If
> you think there's a better name, or a better way to allocate them,
> I'm all ears.

Hmm.  The struct content seems to be vmci-specific and it is in generic
code, which isn't that nice.

The notify_*_init could return a opaque pointer instead.  But then
you'll need a notify_*_free too.  And you can't place it on the stack
and thus have a allocation in the hot path, which I guess you are trying
to avoid in the first place.

No good idea offhand, but maybe that changes if the purpose of all those
notify_* calls is more clear.

cheers,
  Gerd
