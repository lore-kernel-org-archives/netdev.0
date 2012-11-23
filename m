From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCHv4] virtio-spec: virtio network device RFS support
Date: Fri, 23 Nov 2012 13:17:36 +0800
Message-ID: <50AF06F0.1030604@redhat.com>
References: <20121122144645.GA28284@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750778Ab2KWFOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 00:14:37 -0500
In-Reply-To: <20121122144645.GA28284@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2012 10:46 PM, Michael S. Tsirkin wrote:
> Add RFS support to virtio network device.
> Add a new feature flag VIRTIO_NET_F_RFS for this feature, a new
> configuration field max_virtqueue_pairs to detect supported number of
> virtqueues as well as a new command VIRTIO_NET_CTRL_RFS to program
> packet steering for unidirectional protocols.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>
> --
>
> Changes from v3:
> - rename multiqueue -> rfs this is what we support
> - Be more explicit about what driver should do.
> - Simplify layout making VQs functionality depend on feature.
> - Remove unused commands, only leave in programming # of queues
>
> Changes from v2:
> Address Jason's comments on v2:
> - Changed STEERING_HOST to STEERING_RX_FOLLOWS_TX:
>    this is both clearer and easier to support.
>    It does not look like we need a separate steering command
>    since host can just watch tx packets as they go.
> - Moved RX and TX steering sections near each other.
> - Add motivation for other changes in v2
>
> Changes from Jason's rfc:
> - reserved vq 3: this makes all rx vqs even and tx vqs odd, which
>    looks nicer to me.
> - documented packet steering, added a generalized steering programming
>    command. Current modes are single queue and host driven multiqueue,
>    but I envision support for guest driven multiqueue in the future.
> - make default vqs unused when in mq mode - this wastes some memory
>    but makes it more efficient to switch between modes as
>    we can avoid this causing packet reordering.
>
> Rusty, could you please take a look and comment soon?
> If this looks OK to everyone, we can proceed with finalizing the
> implementation. Would be nice to try and put it in 3.8.
>
> ---
>
> diff --git a/virtio-spec.lyx b/virtio-spec.lyx
> index d2f0da9..c1fa3e4 100644
> --- a/virtio-spec.lyx
> +++ b/virtio-spec.lyx
> @@ -59,6 +59,7 @@
>   \author -608949062 "Rusty Russell,,,"
>   \author -385801441 "Cornelia Huck" cornelia.huck@de.ibm.com
>   \author 1531152142 "Paolo Bonzini,,,"
> +\author 1986246365 "Michael S. Tsirkin"
>   \end_header
>   
>   \begin_body
> @@ -4170,9 +4171,42 @@ ID 1
>   \end_layout
>   
>   \begin_layout Description
> -Virtqueues 0:receiveq.
> - 1:transmitq.
> - 2:controlq
> +Virtqueues 0:receiveq
> +\change_inserted 1986246365 1352742829
> +0
> +\change_unchanged
> +.
> + 1:transmitq
> +\change_inserted 1986246365 1352742832
> +0
> +\change_deleted 1986246365 1352742947
> +.
> +
> +\change_inserted 1986246365 1352742952
> +.
> + ....
> + 2N
> +\begin_inset Foot
> +status open
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1352743187
> +N=0 if VIRTIO_NET_F_RFS is not negotiated, otherwise N is indicated by max_
> +\emph on
> +virtqueue_pairs control
> +\emph default
> + field.
> +
> +\end_layout
> +
> +\end_inset
> +
> +: receivqN.
> + 2N+1: transmitqN.
> + 2N+
> +\change_unchanged
> +2:controlq
>   \begin_inset Foot
>   status open
>   
> @@ -4343,6 +4377,16 @@ VIRTIO_NET_F_CTRL_VLAN
>   
>   \begin_layout Description
>   VIRTIO_NET_F_GUEST_ANNOUNCE(21) Guest can send gratuitous packets.
> +\change_inserted 1986246365 1352742767
> +
> +\end_layout
> +
> +\begin_layout Description
> +
> +\change_inserted 1986246365 1352742808
> +VIRTIO_NET_F_RFS(2) Device supports Receive Flow Steering.
> +\change_unchanged

should be 22
> +
>   \end_layout
>   
>   \end_deeper
> @@ -4355,11 +4399,44 @@ configuration
>   \begin_inset space ~
>   \end_inset
>   
> -layout Two configuration fields are currently defined.
> +layout
> +\change_deleted 1986246365 1352743300
> +Two
> +\change_inserted 1986246365 1352743301
> +Four
> +\change_unchanged
> + configuration fields are currently defined.
>    The mac address field always exists (though is only valid if VIRTIO_NET_F_MAC
>    is set), and the status field only exists if VIRTIO_NET_F_STATUS is set.
>    Two read-only bits are currently defined for the status field: VIRTIO_NET_S_LIN
>   K_UP and VIRTIO_NET_S_ANNOUNCE.
> +
> +\change_inserted 1986246365 1353595219
> + The following read-only field,
> +\emph on
> +max_virtqueue_pairs
> +\emph default
> + only exists if VIRTIO_NET_F_RFS is set.
> + This field specifies the maximum number of each of transmit and receive
> + virtqueues (receiveq0..receiveq
> +\emph on
> +N
> +\emph default
> + and transmitq0..transmitq
> +\emph on
> +N
> +\emph default
> + respectively;
> +\emph on
> +N
> +\emph default
> +=
> +\emph on
> +max_virtqueue_pairs
> +\emph default
> +) that can be configured once VIRTIO_NET_F_RFS is negotiated.
> +
> +\change_unchanged

So the virt queues used in single queue mode is still reserved in 
multiqueue mode, since when max_virtqueue_pairs in N, we finally get N+1 
virt queue pairs? And this looks conflict with the description in 
"Packet Receive Flow Steering":

"specifying the number of the last transmit and receive queue that is 
going to be used; thus out of transmitq0..transmitqn and 
receiveq0..receiveqn where n=virtqueue_pairs will be used."

In this description, looks like n+1 virtqueue pairs (include receiveq0 
and transmitq0) could be used in RFS mode.
>    
>   \begin_inset listings
>   inline false
> @@ -4410,7 +4487,24 @@ Device Initialization
>   
>   \begin_layout Enumerate
>   The initialization routine should identify the receive and transmission
> - virtqueues.
> + virtqueues
> +\change_inserted 1986246365 1352744077
> +, up to N+1 of each kind
> +\change_unchanged
> +.
> +
> +\change_inserted 1986246365 1352743942
> + If VIRTIO_NET_F_RFS feature bit is negotiated,
> +\emph on
> +N=max_virtqueue_pairs
> +\emph default
> +, otherwise identify
> +\emph on
> +N=0
> +\emph default
> +.
> +\change_unchanged
> +
>   \end_layout
>   
>   \begin_layout Enumerate
> @@ -4455,7 +4549,11 @@ status
>   \end_layout
>   
>   \begin_layout Enumerate
> -The receive virtqueue should be filled with receive buffers.
> +The receive virtqueue
> +\change_inserted 1986246365 1352743953
> +s
> +\change_unchanged
> + should be filled with receive buffers.
>    This is described in detail below in
>   \begin_inset Quotes eld
>   \end_inset
> @@ -4550,8 +4648,15 @@ Device Operation
>   \end_layout
>   
>   \begin_layout Standard
> -Packets are transmitted by placing them in the transmitq, and buffers for
> - incoming packets are placed in the receiveq.
> +Packets are transmitted by placing them in the transmitq
> +\change_inserted 1986246365 1353593685
> +0..transmitqN
> +\change_unchanged
> +, and buffers for incoming packets are placed in the receiveq
> +\change_inserted 1986246365 1353593692
> +0..receiveqN
> +\change_unchanged
> +.
>    In each case, the packet itself is preceeded by a header:
>   \end_layout
>   
> @@ -4861,6 +4966,17 @@ If VIRTIO_NET_F_MRG_RXBUF is negotiated, each buffer must be at least the
>   struct virtio_net_hdr
>   \family default
>   .
> +\change_inserted 1986246365 1353594518
> +
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1353594638
> +If VIRTIO_NET_F_RFS is negotiated, each of the receiveq0...receiveqN that will
> + be used should be populated with receive buffers.
> +\change_unchanged
> +
>   \end_layout
>   
>   \begin_layout Subsection*
> @@ -5293,8 +5409,125 @@ Sending VIRTIO_NET_CTRL_ANNOUNCE_ACK command through control vq.
>    
>   \end_layout
>   
> -\begin_layout Enumerate
> +\begin_layout Subsection*
> +
> +\change_inserted 1986246365 1353593879
> +Packet Receive Flow Steering
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1353594403
> +If the driver negotiates the VIRTIO_NET_F_RFS (depends on VIRTIO_NET_F_CTRL_VQ),
> + it can transmit outgoing packets on one of the multiple transmitq0..transmitqN
> + and ask the device to queue incoming packets into one the multiple receiveq0..rec
> +eiveqN depending on the packet flow.
> +\change_unchanged
> +
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1353594292
> +\begin_inset listings
> +inline false
> +status open
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594178
> +
> +struct virtio_net_ctrl_rfs {
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594212
> +
> +	u16 virtqueue_pairs;
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594172
> +
> +};
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594172
> +
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594263
> +
> +#define VIRTIO_NET_CTRL_RFC    1

RFS
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1353594273
> +
> + #define VIRTIO_NET_CTRL_RFS_VQ_PAIRS_SET        0
> +\end_layout
> +
> +\end_inset
> +
> +
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1353594884
> +RFS acceleration is disabled by default.
> + Driver enables RFS by executing the VIRTIO_NET_CTRL_RFS_VQ_PAIRS_SET command,
> + specifying the number of the last transmit and receive queue that is going
> + to be used; thus out of transmitq0..transmitqn and receiveq0..receiveqn where
> +
> +\emph on
> +n=virtqueue
> +\emph default
> +_pairs will be used.
> + All these virtqueues must have been pre-configured in advance.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1353595328
> +Programming of the receive flow classificator is implicit.
> + Transmitting a packet of a specific flow on transmitqX will cause incoming
> + packets for this flow to be steered to receiveqX.
> + For uni-directional protocols, or where no packets have been transmitted
> + yet, device will steer a packet to a random queue out of the specified
> + receiveq0..receiveqn.
> +\change_unchanged
> +
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1353595040
> +RFS acceleration is disabled by setting
> +\emph on
> +virtqueue_pairs = 0

Zero looks a little bit misleading, use 1 here is more clear since we 
would still use 1 queue pairs.
> +\emph default
> + (this is the default).
> + Following this, driver should not transmit new packets on virtqueues other
> + than transmitq0 and device will not steer new packets on virtqueues other
> + than receiveq0.
> +\change_unchanged
> +
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_deleted 1986246365 1353593873
>   .
> +
> +\change_unchanged
>    
>   \end_layout
>   
> @@ -6152,13 +6385,7 @@ Virtqueues 0:receiveq(port0).
>   status open
>   
>   \begin_layout Plain Layout
> -Ports
> -\change_inserted 1986246365 1347188327
> -1
> -\change_deleted 1986246365 1347188327
> -2
> -\change_unchanged
> - onwards only if VIRTIO_CONSOLE_F_MULTIPORT is set
> +Ports 12 onwards only if VIRTIO_CONSOLE_F_MULTIPORT is set

The changes here and follow looks unrelated.
>   \end_layout
>   
>   \end_inset
> @@ -6185,13 +6412,8 @@ VIRTIO_CONSOLE_F_SIZE
>   
>   \begin_layout Description
>   VIRTIO_CONSOLE_F_MULTIPORT(1) Device has support for multiple ports; configurati
> -on fields nr_ports and max_nr_ports are valid
> -\change_inserted 1986246365 1347188404
> -; if this bit is negotiated,
> -\change_deleted 1986246365 1347188406
> - and
> -\change_unchanged
> - control virtqueues will be used.
> +on fields nr_ports and max_nr_ports are valid; if this bit is negotiated,
> + and control virtqueues will be used.
>   \end_layout
>   
>   \end_deeper
> @@ -6260,8 +6482,7 @@ If the VIRTIO_CONSOLE_F_MULTIPORT feature is negotiated, the driver can
>    spawn multiple ports, not all of which may be attached to a console.
>    Some could be generic ports.
>    In this case, the control virtqueues are enabled and according to the max_nr_po
> -rts configuration-space value, an appropriate number of virtqueues are
> - created.
> +rts configuration-space value, an appropriate number of virtqueues are created.
>    A control message indicating the driver is ready is sent to the host.
>    The host can then send control messages for adding new ports to the device.
>    After creating and initializing each port, a VIRTIO_CONSOLE_PORT_READY
> @@ -6699,14 +6920,9 @@ The driver constructs an array of addresses of memory pages it has previously
>   \end_layout
>   
>   \begin_layout Enumerate
> -If the VIRTIO_BALLOON_F_MUST_TELL_HOST feature is
> -\change_inserted 1986246365 1347188540
> -negotiated
> -\change_deleted 1986246365 1347188542
> -set
> -\change_unchanged
> -, the guest may not use these requested pages until that descriptor in the
> - deflateq has been used by the device.
> +If the VIRTIO_BALLOON_F_MUST_TELL_HOST feature is negotiatedset, the guest
> + may not use these requested pages until that descriptor in the deflateq
> + has been used by the device.
>   \end_layout
>   
>   \begin_layout Enumerate
