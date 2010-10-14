From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] SIW: Documentation (initial)
Date: Thu, 14 Oct 2010 15:57:03 -0700
Message-ID: <20101014155703.3d4b5d71.randy.dunlap@oracle.com>
References: <1286261747-5288-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1286261747-5288-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue,  5 Oct 2010 08:55:47 +0200 Bernard Metzler wrote:

> ---
>  Documentation/networking/siw.txt |   91 ++++++++++++++++++++++++++++++++++++++
>  1 files changed, 91 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/networking/siw.txt
> 
> diff --git a/Documentation/networking/siw.txt b/Documentation/networking/siw.txt
> new file mode 100644
> index 0000000..f051d8b
> --- /dev/null
> +++ b/Documentation/networking/siw.txt
> @@ -0,0 +1,91 @@
> +SoftiWARP: Software iWARP kernel driver module.
> +
> +General
> +-------
> +SoftiWARP (siw) implements the iWARP protocol suite (MPA/DDP/RDMAP,
> +IETF-RFC 5044/5041/5040) completely in software as a Linux kernel module.
> +siw runs on top of TCP kernel sockets and exports the Linux kernel ibvers
                                                                      ^^^^^^
Is that "ibverbs"?  (just checking)

> +RDMA interface. siw interfaces with the iwcm connection manager.
> +
> +
> +Transmit Path
> +-------------
> +If a send queue (SQ) work queue element gets posted, siw tries to send
> +it directly out of the application context. If the SQ was non-empty,
> +SQ processing is done asynchronously by a kernel worker thread. This
> +thread gets scheduled, if the TCP socket signals new write space to

drop the comma.

> +be available. If during send operation the socket send space get

                                                                becomes
(or "is")

> +exhausted, SQ processing is abandoned until new socket write space
> +becomes available.
> +
> +
> +Receive Path
> +------------
> +All application data is placed into target buffers within softirq
> +socket callback. Application notification is asynchronous.
> +
> +
> +User Interface
> +--------------
> +All fast path operations such as posting of work requests and
> +reaping of work completions currently involve a system call into
> +the siw module. Kernel/user-mapped send and receive as well as 

I didn't find the system call(s).  Are they new syscalls or just
(socket) reads/writes?  (I was probably looking for new syscalls.)

> +completion queues are not part of the current code. In
> +particular, mapped completion queues may improve performance,
> +since reaping completion queue entries as well as re-arming
> +the completion queue could be done more efficiently.
> +
> +
> +Memory Management
> +-----------------
> +siw currently uses kernels ib_umem_get() function to pin memory for later

                      the kernel's

> +use in data transfer operations. Transmit and receive memory is checked

                                                                are checked
(or change "and" to "or")

> +against correct access permissions only in the moment of access by the
> +network input path or before pushing it to the socket for transmission.
> +ib_umem_get() provides DMA mappings for the requested address space which
> +is not used by siw.
> +
> +
> +Module Parameters
> +-----------------
> +The following siw module parameters are recognized.
> +loopback_enabled:
> +	If set, siw attaches also to the looback device. Checked only
> +	during module insertion.
> +
> +mpa_crc_enabled:
> +	If set, the MPA CRC gets generated and checked both in tx and rx
> +	path. Without hardware support, setting this flag will severely
> +	hurt throughput. 
> +
> +zcopy_tx:
> +	If set, payload of non signalled work requests

	                   non-signalled

> +	(such as non signalled WRITE or SEND as well as all READ

	         non-signalled

> +	responses) are transferred using the TCP sockets

	                                         socket's

> +	sendpage interface. This parameter can be switched on and
> +	off dynamically (echo 1 >> /sys/module/siw/parameters/zcopy_tx
> +	for enablement, 0 for disabling). System load may benefits from

	                                                  benefit

> +	using 0copy data transmission. 0copy is not enabled if
> +	mpa_crc_enabled is set.
> +
> +
> +Compile Time Flags:
> +-DCHECK_DMA_CAPABILITIES
> +	Checks if the device siw wants to attach to provides
> +	DMA capabilities. While DMA capabilities are currently not
> +	needed (siw works on top of a kernel TCP socket), siw
> +	uses ib_umem_get() which performs a (not used) DMA address
> +	translation. Writing a siw private memory reservation and
> +	pinning routine would solve the issue.
> +
> +-DSIW_TX_FULLSEGS
> +	Experimental, not enabled by default. If set,
> +	siw tries not to overrun the socket (not sending until
> +	-EAGAIN retrun), but stops sending if the current segment

	        return),

> +	would not fit into the socket's estimated tx buffer. With that,
> +	wire FPDUs may get truncated by the TCP stack far less often.
> +	Since this feature manipulates the sock's SOCK_NOSPACE
> +	bit, it violates strict layering and is therefore considered
> +	proprietary.
> +	Since TCP is a byte stream protocol, no guarantee can be given
> +	if FPDU's are not fragmented.
> -- 


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
