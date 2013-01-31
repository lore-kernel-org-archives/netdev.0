From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Thu, 31 Jan 2013 14:06:30 -0800 (PST)
Message-ID: <140410652.5634760.1359669990735.JavaMail.root@vmware.com>
References: <51066E32.2000209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <51066E32.2000209@redhat.com>
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

Thanks so much for taking a look and apologies for the delay!

> > +config VMWARE_VSOCK
> > +	tristate "Virtual Socket protocol"
> > +	depends on VMWARE_VMCI
> 
> I guess this is temporary?  Cover letter says *mostly* separated ...

Yes, right now everything is still munged into one driver.

> > +vmw_vsock-y += af_vsock.o vmci_transport.o vmci_transport_notify.o
> > \
> > +	vmci_transport_notify_qstate.o vsock_addr.o
> 
> Likewise, I expect with the final version vmci_transport is a
> separate module (or moves into the vmci driver), correct?

When you say final, do you mean something that we have to do before
acceptance into mainline or something we can refine over time?  I'm
rather hoping for the latter: it'd be nice to come to an agreement
about whether VM Sockets is the right way to go, and actually get
this in, before we go to the trouble of splitting this out, only to
find that nobody actually implements their own transport ;)

> > +	switch (cmd) {
> > +	case IOCTL_VMCI_SOCKETS_VERSION:
> > +		version = VMCI_SOCKETS_MAKE_VERSION(parts);
> > +		if (put_user(version, p) != 0)
> > +			retval = -EFAULT;
> > +		break;
> 
> Still needed?

Cut.

> > +	case IOCTL_VMCI_SOCKETS_GET_AF_VALUE:
> > +		if (put_user(AF_VSOCK, p) != 0)
> > +			retval = -EFAULT;
> > +
> > +		break;
> 
> That can go away, with the upstream merge vsock will get a fixed
> AF_VSOCK.

Cut.

> > +	case IOCTL_VMCI_SOCKETS_GET_LOCAL_CID:
> > +		if (put_user(vmci_get_context_id(), p) != 0)
> > +			retval = -EFAULT;
> 
> What is this?

A CID, or "context ID" is how we identify a VM.  It's also in
the address structure (svm_cid).  If you look at vm_sockets.h,
you'll see that we have definitions for various endpoints (the
host, anonymous and so forth).  It's sometimes useful for VMs
to be able to query their own ID, for example, to be able to
pass it out-of-band via INET to a peer.  So we'd like to keep
this, although I guess it should be transport-defined, i.e.,
we should ask the transport for this value.

> > +	err = vmci_transport_register(&transport);
> > +	if (err) {
> > +		pr_err("Cannot register with VMCI device\n");
> > +		goto err_misc_deregister;
> > +	}
> 
> Hmm?  There should be a vsock_(un)register_transport which the vmci
> transport code can call (and likewise virtio transport some day).

Yes, it's still totally topsy-turvy.  But see comment about coming
to an agreement :)

> > +	struct {
> > +		/* For DGRAMs. */
> > +		struct vmci_handle dg_handle;
> 
> Yep, should be a pointer where transports can hook in their private
> data.

I'm fixing this.

> > +struct vsock_transport {
> > +	void (*init)(struct vsock_sock *, struct vsock_sock *);
> > +	void (*destruct)(struct vsock_sock *);
> > +	void (*release)(struct vsock_sock *);
> > +	int (*connect)(struct vsock_sock *);
> > +	int (*bind_dgram)(struct vsock_sock *, struct sockaddr_vm *);
> > +	int (*send_dgram)(struct vsock_sock *, struct sockaddr_vm *,
> > +			  struct iovec *, size_t len);
> > +	ssize_t (*recv_stream)(struct vsock_sock *, struct iovec *,
> > +			       size_t len, int flags);
> > +	ssize_t (*send_stream)(struct vsock_sock *, struct iovec *,
> > +			       size_t len);
> > +	s64 (*stream_has_data)(struct vsock_sock *);
> > +	s64 (*stream_has_space)(struct vsock_sock *);
> > +	int (*send_shutdown)(struct sock *sk, int mode);
> > +	void (*unregister)(void);
> > +};
> 
> So that is the interface transports have to implement.  Looks
> reasonable to me.  Some documentation would be nice, although
> most of it is self-explaining.
>
> Where is recv_dgram?

The transport just enqueues sk_buffs in the socket's buffer, so the
core socket code can just pull them off.  So there's no explicit
recv_dgram.

> Also why bind_dgram?  I guess binding stream sockets doesn't make
> sense for the vsock family?

Ah, for our transport, there's nothing special involved in binding a
STREAM, everything is handled by the core socket code.  So I didn't
add a transport callback.  This is something we can add when it
becomes necessary, if that's okay?

> I'd make the naming a bit more consistent, some stream callbacks are
> prefixed and some postfixed with "stream".

Fixed.

> I'd also name send_shutdown just shutdown (same name the system call
> has).

Fixed.

> What does unregister?

That's topsy-turvy unregistration, it drops the transport.  It will go
away eventually.

I'll send out a patch soon addressing the (easy) issues above.

Thanks!
- Andy
