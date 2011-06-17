From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH 14/14] SIWv2: Documentation: siw.txt
Date: Fri, 17 Jun 2011 16:17:04 +0200
Message-ID: <OF6DBD2DA8.BC0FBA45-ONC12578B2.004E3BEE-C12578B2.004E780E@ch.ibm.com>
References: <20110616091044.217d0524.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110616091044.217d0524.rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Randy,

many thanks, i'll change accordingly.
and sorry for the typo - 'isynchronous' is just 'synchronous'
typed in vi and doing the insert command twice ;)

thanks,
Bernard.


Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org> wrote on 06/16/2011 06:10:44 PM:

> On Thu, 16 Jun 2011 14:42:54 +0200 Bernard Metzler wrote:
>
> > ---
> >  Documentation/networking/siw.txt |  156
> ++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 156 insertions(+), 0 deletions(-)
> >  create mode 100644 Documentation/networking/siw.txt
> >
> > diff --git a/Documentation/networking/siw.txt
> b/Documentation/networking/siw.txt
> > new file mode 100644
> > index 0000000..805e21b
> > --- /dev/null
> > +++ b/Documentation/networking/siw.txt
> > @@ -0,0 +1,156 @@
> > +SoftiWARP: Software iWARP kernel driver module.
> > +
> > +General
> > +-------
> > +SoftiWARP (siw) implements the iWARP protocol suite (MPA/DDP/RDMAP,
> > +IETF-RFC 5044/5041/5040) completely in software as a Linux kernel
module.
> > +siw runs on top of TCP kernel sockets and exports the Linux kernel
ibverbs
> > +RDMA interface. siw interfaces with the iwcm connection manager.
> > +
> > +
> > +Transmit Path
> > +-------------
> > +If a send queue (SQ) work queue element gets posted, siw tries to send
> > +it directly out of the application context. If the SQ was non-empty,
> > +SQ processing is done asynchronously by a kernel worker thread. This
> > +thread gets scheduled if the TCP socket signals new write space to
>
> s/gets/is/
>
> > +be available. If during send operation the socket send space becomes
> > +exhausted, SQ processing is abandoned until new socket write space
> > +becomes available.
> > +
> > +
> > +Receive Path
> > +------------
> > +All application data is placed into target buffers within softirq
> > +socket callback. Application notification is asynchronous.
> > +
> > +
> > +User Interface
> > +--------------
> > +All user space fast path operations such as posting of work requests
and
> > +reaping of work completions currently involve a isynchronous call into
>
> If you really mean "isynchronous", then it should be:  an isynchronous
call
>
> but what is isynchronous?
>
> > +the siw kernel module via ib_uverbs interface. Kernel/user-mapped send
> > +and receive as well as completion queues are not part of the current
code.
> > +In particular, mapped completion queues may improve performance,
> > +since reaping completion queue entries as well as re-arming
> > +the completion queue could be done more efficiently.
> > +
> > +
> > +Kernel Client Support
> > +---------------------
> > +To guarantee non-blocking fast path operations, for kernel clients
> > +all work queue elements (send/receive/shared-receive queue) are
> > +pre-allocated during connection resource setup.
> > +
> > +
> > +Memory Management
> > +-----------------
> > +siw currently uses the ib_umem_get() function of the ib_core module
> > +to pin memory for later use in data transfer operations. Transmit
> > +and receive memory are checked against correct access permissions only
> > +in the moment of access by the network input path or before pushing it
>
>    at the moment
>
> > +to the TCP socket for transmission.
> > +ib_umem_get() provides DMA mappings for the requested address space
which
> > +are not used by siw.
> > +
> > +
> > +Module Parameters
> > +-----------------
> > +The following siw module parameters are recognized.
> > +
> > +loopback_enabled:
> > +   If set, siw attaches also to the looback device. Checked only
> > +   during module insertion.
> > +
> > +mpa_crc_required:
> > +   If set, the MPA CRC gets generated and checked both in tx and rx
>
> s/gets/is/
>
> > +   path. Without hardware support, setting this flag will severely
> > +   hurt throughput. Default setting is 0 (off).
> > +
> > +mpa_crc_strict:
> > +   If set, MPA CRC will not be enabled, even if peer requests
> > +   it. If the peer requests CRC generation, the connection setup
> > +   will be aborted. Default setting is 1 (on).
> > +
> > +zcopy_tx:
> > +   If set, payload of non-signalled work requests
>
>            payloads ... are transferred
>
> > +   (such as non-signalled WRITE or SEND as well as all READ
> > +   responses) are transferred using the TCP sockets
> > +   sendpage interface. This parameter can be switched on and
> > +   off dynamically (echo 1 >> /sys/module/siw/parameters/zcopy_tx
> > +   for enablement, 0 for disabling). System load may benefits from
>
>                                                  may benefit
>
> > +   using 0copy data transmission. 0copy is not enabled if
>
> "0copy" is fugly (IMO).
>
> > +   mpa_crc_enabled is set. Default setting is 1 (on).
> > +
> > +tcp_nodelay:
> > +   If set, on the TCP socket the TCP_NODELAY option is set.
> > +   Default setting is 1 (on).
> > +
> > +iface_list:
> > +   Comma separated list of interfaces siw should attach to.
>
>    Comma-separated
>
> > +   If no list is given, siw attaches to all available devices.
> > +   If a list is given, siw skips those devices not listed.
> > +   Currently, the list is restricted to 12 entries. If needed,
> > +   the 'SIW_MAX_IF' #define in siw_main.c can be adaped.
>
>                                                  adapted.  ?  (or
modified)
>
> > +   This parameter might be usefull to skip devices which are
>
>                            useful
>
> > +   attached to a real RNIC device. Default setting is an empty list.
> > +
> > +
> > +Compile Time Flags:
> > +-------------------
> > +-DCHECK_DMA_CAPABILITIES
> > +   Checks if the device siw wants to attach to provides
> > +   DMA capabilities. While DMA capabilities are currently not
> > +   needed (siw works on top of a kernel TCP socket), siw
> > +   uses ib_umem_get() which performs a (not used) DMA address
> > +   translation. Writing a siw private memory reservation and
> > +   pinning routine would solve the issue.
> > +
> > +-DSIW_TX_FULLSEGS
> > +   Experimental, not enabled by default. If set,
> > +   siw tries not to overrun the socket (not sending until
> > +   -EAGAIN return), but stops sending if the current segment
> > +   would not fit into the socket's estimated tx buffer. With that,
> > +   wire FPDUs may get truncated by the TCP stack far less often.
> > +   Since this feature manipulates the sock's SOCK_NOSPACE
> > +   bit, it violates strict layering and is therefore considered
> > +   proprietary.
> > +   Since TCP is a byte stream protocol, no guarantee can be given
> > +   if FPDU's are not fragmented.
>
> or      FPDUs
>
> > +
> > +
> > +Debugging SIW:
> > +--------------
> > +The siw_debug.h file defines a 'dprint' macro which is used to debug
> > +siw at runtime. Verbosity of debugging is controlled at compile time
> > +via setting the 'DPRINT_MASK' to a or'd list of know value as defined
>
>                                  to an or'd list of known value
>
>
> > +in siw_debug.h, e.g. '#define DPRINT_MASK (DBG_ON|DBG_CM)' to debug
> > +errors and connection management. Defining DPRINT_MASK to '0' avoids
> > +to compile any runtime debugging code.
>
>    compiling any
>
> > +
> > +To track siw's useage of its objects (connection endpoints, tcp
sockets,
>
>                   usage
>
> > +protection domains, queue pairs, shared receive queues, completion
queues,
> > +memory registrations, work queue elements),
the /sys/class/infiniband/siw*
> > +directory contains siw interface specific objects, which can be read
to
> > +gather simple statistics:
> > +
> > +/sys/class/infiniband/siw*/stats:
> > +   Summary of allocated WQE's, PD's, QP's, CQ's, SRQ's, MR's, CEP's.
>
> All of those single quote/apostrophe marks are not needed.
>
> > +   WQE statistics are not gathered if 'DPRINT_MASK' is set to '0'
> > +   (see above).
> > +
> > +/sys/class/infiniband/siw*/qp:
> > +   Summary of allocated queue pairs. If queue pairs are allocated,
> > +   after reading 'qp' a more detailed status of all queue pairs has
> > +   been printed to the kernel syslog and can be retrieved via
> > +   'dmesg' command.
> > +
> > +/sys/class/infiniband/siw*/cep:
> > +   Summary of allocated connection end points. If connection endpoints
> > +   are allocated, after reading 'cep' a more detailed status of all
> > +   CEP's is printed to the kernel syslog and can be retrieved via
>
> ditto
>
> > +   'dmesg' command.
> > +
> > +Using the sysfs to gather siw's object allocations is considered a
> > +tentative aid during further driver development and should disappear
> > +in a stable version of siw.
> > --
>
>
> HTH.
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code
***

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
