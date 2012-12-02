From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4] virtio-spec: virtio network device RFS support
Date: Mon, 03 Dec 2012 09:16:33 +1030
Message-ID: <87ip8kjcmu.fsf@rustcorp.com.au>
References: <20121122144645.GA28284@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121122144645.GA28284@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> Add RFS support to virtio network device.
> Add a new feature flag VIRTIO_NET_F_RFS for this feature, a new
> configuration field max_virtqueue_pairs to detect supported number of
> virtqueues as well as a new command VIRTIO_NET_CTRL_RFS to program
> packet steering for unidirectional protocols.

Hi Michael,

        Sorry for the delay, I took last week off.

> - rename multiqueue -> rfs this is what we support
> - Be more explicit about what driver should do.
> - Simplify layout making VQs functionality depend on feature.
> - Remove unused commands, only leave in programming # of queues

Thanks: this looks really nice now.  Comments are about the text, not
the ideas.

> + 2N+1: transmitqN.
> + 2N+
> +\change_unchanged
> +2:controlq
>  \begin_inset Foot
>  status open

Hmm, controlq after xmit queues... a nice improvement.

> +VIRTIO_NET_F_RFS(2) Device supports Receive Flow Steering.

I think readers would prefer numerical order to historical order here,
so perhaps move this up in the list.

> -layout Two configuration fields are currently defined.
> +layout 
> +\change_deleted 1986246365 1352743300
> +Two
> +\change_inserted 1986246365 1352743301
> +Four
> +\change_unchanged
> + configuration fields are currently defined.

two to four?  I only see three?  And you didn't update the structure to
match...

> + Following this, driver should not transmit new packets on virtqueues other
> + than transmitq0 and device will not steer new packets on virtqueues other
> + than receiveq0.

"Following this" is vague.  After the buffer is consumed by the device.

Should not is kind of meaningless.  Let's make it clear: the device will
not steer new packets to RxqN, nor read from TxqN.

You should probably put in a note about the RFS control in the Device
Initialization section, too, ie. if you have negotiated and want to use
more queues, you must initialize them then wait for the ack of the
CTRL_RFS cmd.

Note: the following hunks didn't apply, but I'm not sure why they're in
this anyway...

> @@ -6152,13 +6385,7 @@ Virtqueues 0:receiveq(port0).
>  status open
>  
>  \begin_layout Plain Layout
> -Ports 
> -\change_inserted 1986246365 1347188327
> -1
> -\change_deleted 1986246365 1347188327
> -2
> -\change_unchanged
> - onwards only if VIRTIO_CONSOLE_F_MULTIPORT is set
> +Ports 12 onwards only if VIRTIO_CONSOLE_F_MULTIPORT is set
>  \end_layout
>  
>  \end_inset
> @@ -6185,13 +6412,8 @@ VIRTIO_CONSOLE_F_SIZE
>  
>  \begin_layout Description
>  VIRTIO_CONSOLE_F_MULTIPORT(1) Device has support for multiple ports; configurati
> -on fields nr_ports and max_nr_ports are valid
> -\change_inserted 1986246365 1347188404
> -; if this bit is negotiated,
> -\change_deleted 1986246365 1347188406
> - and
> -\change_unchanged
> - control virtqueues will be used.
> +on fields nr_ports and max_nr_ports are valid; if this bit is negotiated,
> + and control virtqueues will be used.
>  \end_layout
>  
>  \end_deeper
> @@ -6260,8 +6482,7 @@ If the VIRTIO_CONSOLE_F_MULTIPORT feature is negotiated, the driver can
>   spawn multiple ports, not all of which may be attached to a console.
>   Some could be generic ports.
>   In this case, the control virtqueues are enabled and according to the max_nr_po
> -rts configuration-space value, an appropriate number of virtqueues are
> - created.
> +rts configuration-space value, an appropriate number of virtqueues are created.
>   A control message indicating the driver is ready is sent to the host.
>   The host can then send control messages for adding new ports to the device.
>   After creating and initializing each port, a VIRTIO_CONSOLE_PORT_READY
> @@ -6699,14 +6920,9 @@ The driver constructs an array of addresses of memory pages it has previously
>  \end_layout
>  
>  \begin_layout Enumerate
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
>  \end_layout
>  
>  \begin_layout Enumerate


Cheers,
Rusty.
