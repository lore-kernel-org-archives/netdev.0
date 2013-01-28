From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Mon, 28 Jan 2013 13:25:22 +0100
Message-ID: <51066E32.2000209@redhat.com>
References: <1359135470-30677-1-git-send-email-acking@vmware.com> <1359135470-30677-2-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pv-drivers@vmware.com,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: acking@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895Ab3A1MZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 07:25:29 -0500
In-Reply-To: <1359135470-30677-2-git-send-email-acking@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hi,

> diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
> new file mode 100644
> index 0000000..95e2568
> --- /dev/null
> +++ b/net/vmw_vsock/Kconfig
> @@ -0,0 +1,14 @@
> +#
> +# Vsock protocol
> +#
> +
> +config VMWARE_VSOCK
> +	tristate "Virtual Socket protocol"
> +	depends on VMWARE_VMCI

I guess this is temporary?  Cover letter says *mostly* separated ...

> +vmw_vsock-y += af_vsock.o vmci_transport.o vmci_transport_notify.o \
> +	vmci_transport_notify_qstate.o vsock_addr.o

Likewise, I expect with the final version vmci_transport is a separate
module (or moves into the vmci driver), correct?

> +static long vsock_dev_do_ioctl(struct file *filp,
> +			       unsigned int cmd, void __user *ptr)
> +{
> +	static const u16 parts[4] = VSOCK_DRIVER_VERSION_PARTS;
> +	u32 __user *p = ptr;
> +	int retval = 0;
> +	u32 version;
> +
> +	switch (cmd) {
> +	case IOCTL_VMCI_SOCKETS_VERSION:
> +		version = VMCI_SOCKETS_MAKE_VERSION(parts);
> +		if (put_user(version, p) != 0)
> +			retval = -EFAULT;
> +		break;

Still needed?

> +	case IOCTL_VMCI_SOCKETS_GET_AF_VALUE:
> +		if (put_user(AF_VSOCK, p) != 0)
> +			retval = -EFAULT;
> +
> +		break;

That can go away, with the upstream merge vsock will get a fixed AF_VSOCK.

> +	case IOCTL_VMCI_SOCKETS_GET_LOCAL_CID:
> +		if (put_user(vmci_get_context_id(), p) != 0)
> +			retval = -EFAULT;

What is this?

> +static int __init vsock_init(void)
> +{
> +	int err;
> +
> +	vsock_init_tables();
> +
> +	err = misc_register(&vsock_device);
> +	if (err) {
> +		pr_err("Failed to register misc device\n");
> +		return -ENOENT;
> +	}
> +
> +	err = vmci_transport_register(&transport);
> +	if (err) {
> +		pr_err("Cannot register with VMCI device\n");
> +		goto err_misc_deregister;
> +	}

Hmm?  There should be a vsock_(un)register_transport which the vmci
transport code can call (and likewise virtio transport some day).

> +struct vsock_sock {
> +	/* sk must be the first member. */
> +	struct sock sk;
> +	struct sockaddr_vm local_addr;
> +	struct sockaddr_vm remote_addr;

> +	/* The rest is transport-specific: this is the stuff we need to pull
> +	 * out to make it work with something other than VMCI.
> +	 */
> +	struct {
> +		/* For DGRAMs. */
> +		struct vmci_handle dg_handle;

Yep, should be a pointer where transports can hook in their private data.

> +/**** TRANSPORT ****/
> +
> +struct vsock_transport {
> +	void (*init)(struct vsock_sock *, struct vsock_sock *);
> +	void (*destruct)(struct vsock_sock *);
> +	void (*release)(struct vsock_sock *);
> +	int (*connect)(struct vsock_sock *);
> +	int (*bind_dgram)(struct vsock_sock *, struct sockaddr_vm *);
> +	int (*send_dgram)(struct vsock_sock *, struct sockaddr_vm *,
> +			  struct iovec *, size_t len);
> +	ssize_t (*recv_stream)(struct vsock_sock *, struct iovec *,
> +			       size_t len, int flags);
> +	ssize_t (*send_stream)(struct vsock_sock *, struct iovec *,
> +			       size_t len);
> +	s64 (*stream_has_data)(struct vsock_sock *);
> +	s64 (*stream_has_space)(struct vsock_sock *);
> +	int (*send_shutdown)(struct sock *sk, int mode);
> +	void (*unregister)(void);
> +};

So that is the interface transports have to implement.  Looks reasonable
to me.  Some documentation would be nice, although most of it is
self-explaining.

Where is recv_dgram?

Also why bind_dgram?  I guess binding stream sockets doesn't make sense
for the vsock family?

I'd make the naming a bit more consistent, some stream callbacks are
prefixed and some postfixed with "stream".

I'd also name send_shutdown just shutdown (same name the system call has).

What does unregister?

cheers,
  Gerd
