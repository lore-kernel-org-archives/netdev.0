From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Tue, 12 Feb 2013 07:21:07 -0800 (PST)
Message-ID: <1675407061.963254.1360682467627.JavaMail.root@vmware.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
	<5118FEA9.2080201@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5118FEA9.2080201@redhat.com>
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

Hi Gerd,

> > +struct vsock_transport {
...
> Whoa.  This has grown *alot*.  Care to explain this please?  Patch
> creating a Documentation/virtual/vsock.txt would be cool.

Yes, it grew because of the notification stuff, which I'd forgotten
about until I removed the vmci header from the core code.  You are
free to use empty functions for these if they don't make any sense
for virtio.  The alternative is for us to move the entire body of
vsock_stream_recv/send into the transport, where we can hide the
notification stuff, but it seems like folks will just end up
duplicating a lot of code then.

> stream_has_data + stream_has_space + stream_rcvhiwat look like they
> are needed for buffer management.  Details please (especially for
> stream_rcvhiwat).

stream_has_data: Returns amount of data available (in bytes) in the
socket's receive buffer, or -1 if empty.

stream_has_space: Returns amount of space available (in bytes) in the
socket's send buffer, or -1 if full.

stream_rcvhiwat: The upper bound on the socket's receive buffer.
Which technically is the same as the value returned by
get_buffer_size(), so perhaps we could substitute that here and
drop this one.

> What is stream_is_active?

For the VMCI transport, it indicates if the underlying queuepair is
still around (i.e., make sure we haven't torn it down while sleeping
in a blocking send or receive).  Perhaps it's not the best name?

> What is *_allow?

It's very basic filtering.  We have specific addresses that we don't
allow, and we look for them in the allow() functions.  You can just
return true if you like.

> What are all those notify_* calls?

They're to do with signaling and flow-control.  Again, they might
not make any sense at all, but it's hard to know without having
written another transport :)

> Why do you need vsock_transport_{send,recv}_notify_data structs?
> Can't this live in vsock_sock->trans?

Those have to be setup on a per-call basis (per-thread), so it's
just easier to have them on the stack of the send/recv calls.  If
you think there's a better name, or a better way to allocate them,
I'm all ears.

Thanks!
- Andy
