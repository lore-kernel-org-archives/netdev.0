From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCHv2] virtio-spec: virtio network device multiqueue support
Date: Wed, 05 Sep 2012 11:34:15 +0800
Message-ID: <5046C837.7040609@redhat.com>
References: <20120903115526.GA3815@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120903115526.GA3815@redhat.com>
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

On 09/03/2012 07:55 PM, Michael S. Tsirkin wrote:
> At Jason's request, I am trying to help finalize the spec for
> the new multiqueue feature.
>
> Changes from Jason's rfc:
> - reserved vq 3: this makes all rx vqs even and tx vqs odd, which
>    looks nicer to me.
> - documented packet steering, added a generalized steering programming
>    command. Current modes are single queue and host driven multiqueue,
>    but I envision support for guest driven multiqueue in the future.

For host driven, more thought in the long term. Maybe we could add more 
policy to choose the rxq such as hashing, round-robin and cpuid.
> - make default vqs unused when in mq mode - this wastes some memory
>    but makes it more efficient to switch between modes as
>    we can avoid this causing packet reordering.

Not sure whether or not this can really helps. Depending on the host 
scheduler, we may always see a disorder when we do the switching.
> Rusty, could you please take a look and comment?
> If this looks OK to everyone, we can proceed with finalizing the
> implementation.  This patch is against
> eb9fc84d0d3c46438aaab190e2401a9e5409a052 in virtio-spec git tree.
>
> -->
>
> virtio-spec: virtio network device multiqueue support
>
> Add multiqueue support to virtio network device.
> Add a new feature flag VIRTIO_NET_F_MULTIQUEUE for this feature, a new
> configuration field max_virtqueue_pairs to detect supported number of
> virtqueues as well as a new command VIRTIO_NET_CTRL_STEERING to program
> packet steering.
>
> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
>
> --
>
> diff --git a/virtio-spec.lyx b/virtio-spec.lyx
> index 7a073f4..583debc 100644
> --- a/virtio-spec.lyx
> +++ b/virtio-spec.lyx
> @@ -58,6 +58,7 @@
>   \html_be_strict false
>   \author -608949062 "Rusty Russell,,,"
>   \author 1531152142 "Paolo Bonzini,,,"
> +\author 1986246365 "Michael S. Tsirkin"
>   \end_header
>
>   \begin_body
> @@ -3896,6 +3897,37 @@ Only if VIRTIO_NET_F_CTRL_VQ set
>   \end_inset
>
>
> +\change_inserted 1986246365 1346663522
> + 3: reserved
> +\end_layout
> +
> +\begin_layout Description
> +
> +\change_inserted 1986246365 1346663550
> +4: receiveq1.
> + 5: transmitq1.
> + 6: receiveq2.
> + 7.
> + transmitq2.
> + ...
> + 2N+2:receivqN, 2N+3:transmitqN
> +\begin_inset Foot
> +status open
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346663558
> +Only if VIRTIO_NET_F_CTRL_VQ set.
> + N is indicated by max_virtqueue_pairs field.
> +\change_unchanged
> +
> +\end_layout
> +
> +\end_inset
> +
> +
> +\change_unchanged
> +
>   \end_layout
>
>   \begin_layout Description
> @@ -4056,6 +4088,17 @@ VIRTIO_NET_F_CTRL_VLAN
>
>   \begin_layout Description
>   VIRTIO_NET_F_GUEST_ANNOUNCE(21) Guest can send gratuitous packets.
> +\change_inserted 1986246365 1346617842
> +
> +\end_layout
> +
> +\begin_layout Description
> +
> +\change_inserted 1986246365 1346618103
> +VIRTIO_NET_F_MULTIQUEUE(22) Device has multiple receive and transmission
> + queues.
> +\change_unchanged
> +
>   \end_layout
>
>   \end_deeper
> @@ -4068,11 +4111,45 @@ configuration
>   \begin_inset space ~
>   \end_inset
>
> -layout Two configuration fields are currently defined.
> +layout
> +\change_deleted 1986246365 1346671560
> +Two
> +\change_inserted 1986246365 1346671647
> +Six
> +\change_unchanged
> + configuration fields are currently defined.
>    The mac address field always exists (though is only valid if VIRTIO_NET_F_MAC
>    is set), and the status field only exists if VIRTIO_NET_F_STATUS is set.
>    Two read-only bits are currently defined for the status field: VIRTIO_NET_S_LIN
>   K_UP and VIRTIO_NET_S_ANNOUNCE.
> +
> +\change_inserted 1986246365 1346672138
> + The following four read-only fields only exists if VIRTIO_NET_F_MULTIQUEUE
> + is set.
> + The max_virtqueue_pairs field specifies the maximum number of each of transmit
> + and receive virtqueues that can used for multiqueue operation.

s/can/can be/
> + The following read-only fields:
> +\emph on
> +current_steering_rule
> +\emph default
> +,
> +\emph on
> +reserved
> +\emph default
> + and
> +\emph on
> +current_steering_param
> +\emph default
> + store the last successful VIRTIO_NET_CTRL_STEERING
> +\begin_inset CommandInset ref
> +LatexCommand ref
> +reference "sub:Transmit-Packet-Steering"
> +
> +\end_inset
> +
> + command executed by driver, for debugging.
> +
> +\change_unchanged
>
>   \begin_inset listings
>   inline false
> @@ -4105,6 +4182,40 @@ struct virtio_net_config {
>   \begin_layout Plain Layout
>
>       u16 status;
> +\change_inserted 1986246365 1346671221
> +
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346671532
> +
> +    u16 max_virtqueue_pairs;
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346671531
> +
> +    u8 current_steering_rule;
> +\change_unchanged
> +
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346671499
> +
> +    u8 reserved;
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346671530
> +
> +    u16 current_steering_param;
> +\change_unchanged
> +
>   \end_layout
>
>   \begin_layout Plain Layout
> @@ -4151,6 +4262,18 @@ physical
>   \begin_layout Enumerate
>   If the VIRTIO_NET_F_CTRL_VQ feature bit is negotiated, identify the control
>    virtqueue.
> +\change_inserted 1986246365 1346618052
> +
> +\end_layout
> +
> +\begin_layout Enumerate
> +
> +\change_inserted 1986246365 1346618175
> +If VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, identify the receive
> + and transmission queues that are going to be used in multiqueue mode.
> + Only queues that are going to be used need to be initialized.
> +\change_unchanged
> +
>   \end_layout
>
>   \begin_layout Enumerate
> @@ -4168,7 +4291,11 @@ status
>   \end_layout
>
>   \begin_layout Enumerate
> -The receive virtqueue should be filled with receive buffers.
> +The receive virtqueue
> +\change_inserted 1986246365 1346618180
> +(s)
> +\change_unchanged
> + should be filled with receive buffers.
>    This is described in detail below in
>   \begin_inset Quotes eld
>   \end_inset
> @@ -4516,6 +4643,201 @@ Note that the header will be two bytes longer for the VIRTIO_NET_F_MRG_RXBUF
>   \end_layout
>
>   \begin_layout Subsection*
> +
> +\change_inserted 1986246365 1346670975
> +\begin_inset CommandInset label
> +LatexCommand label
> +name "sub:Transmit-Packet-Steering"
> +
> +\end_inset
> +
> +Transmit Packet Steering
> +\end_layout
> +

Since this needs control vq, move this after the section of control vq?
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346670592
> +When VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, guest can use any
> + of multiple configured transmit queues to transmit a given packet.
> + To avoid packet reordering by device (which gnerally leads to performance
> + degradation) driver should attempt to utilize the same transmit virtqueue
> + for all packets of a given transmit flow.
> + For bi-directional protocols (in practice, TCP), a given network connection
> + can utilize both transmit and receive queues.
> + For best performance, packets from a single connection should utilize the
> + paired transmit and receive queues from the same virtqueue pair; for example
> + both transmitqN and receiveqN.
> + This rule makes it possible to optimize processing on the device side,
> + but this is not a hard requirement: devices should function correctly even
> + when this rule is not followed.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346670727
> +Driver selects an active steering rule using VIRTIO_NET_CTRL_STEERING command
> + (this controls both which virtqueue is selected for a given packet for
> + receive and notifies the device which virtqueues are about to be used for
> + transmit).
> +\end_layout
> +
> +\begin_layout Standard
> +

Not sure it's suitable to define the policy in the spec ( and even a not 
hard requirement ). An alternative is to just define some tools such as 
the queue number negotiation mechanism like modern card and just let the 
driver to choose the policy, this can give both flexibility and space 
for the future evolution of the device. E.g. we may have a guest 
controlled flow director in the future, we can have a seperate command 
to enable/disable it and a separate feature bits.
> +\change_inserted 1986246365 1346670594
> +This command accepts a single out argument in the following format:
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346670594
> +\begin_inset listings
> +inline false
> +status open
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346670594
> +
> +#define VIRTIO_NET_CTRL_STEERING       4
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346670594
> +
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346670594
> +
> +struct virtio_net_ctrl_steering {
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346671425
> +
> +	u8 current_steering_rule;
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346670594
> +
> +    u8 reserved;
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346671485
> +
> +	u16 current_steering_param;
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346670594
> +
> +};
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346670594
> +
> +#define VIRTIO_NET_CTRL_STEERING_SINGLE       0
> +\end_layout
> +
> +\begin_layout Plain Layout
> +
> +\change_inserted 1986246365 1346670594
> +
> +#define VIRTIO_NET_CTRL_STEERING_HOST  1
> +\end_layout
> +
> +\end_inset
> +
> +
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346671803
> +The field
> +\emph on
> +rule
> +\emph default
> + specifies the function used to select transmit virtqueue for a given packet;
> + the field
> +\emph on
> +param
> +\emph default
> + makes it possible to pass an extra parameter if appropriate.
> + When
> +\emph on
> +rule
> +\emph default
> + is set to VIRTIO_NET_CTRL_STEERING_SINGLE all packets are steered to the
> + default virtqueue transmitq (1); param is unused; this is the default.
> + When
> +\emph on
> +rule
> +\emph default
> + is set to VIRTIO_NET_CTRL_STEERING_HOST packets are steered by driver to
> + the first (
> +\emph on
> +param
> +\emph default
> ++1) multiqueue virtqueues transmitq1...transmitqN; the default transmitq is
> + unused.

It's driver that select the transmitq, does the device need to know 
about the transmit steering used in driver? defining the those 
transmission steering commands for the deivce looks useless. Maybe we'd 
better rename the subsection to "Packet Steering" and focus on the 
receive part?

> + Driver must have configured all these (
> +\emph on
> +param
> +\emph default
> ++1) virtqueues beforehand.
> + For best performance, driver should detects flow to virtqueue pair mapping
> + on receive and selects the transmit virtqueue from the same virtqueue pair.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346670762
> +Supported steering rules can be added and removed in the future.
> + Driver should probe for supported rules by checking ack values of the command.
> +\end_layout
> +

What's the advantages of using this over feature bits?
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346671315
> +When steering rule is modified, some packets can still be outstanding in
> + one or more of the virtqueues.
> + For transmit, device is recommended to complete processing of the transmit
> + queue(s) utilized by the original steering before processing any packets
> + delivered by the modified steering rule.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346671412
> +For debugging, current steering rule can also be read from the configuration
> + space.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346670762
> +See also receive steering description
> +\begin_inset CommandInset ref
> +LatexCommand ref
> +reference "sub:Receive-Packet-Steering"
> +
> +\end_inset
> +
> +.
> +\end_layout
> +
> +\begin_layout Subsection*
>   Packet Transmission Interrupt
>   \end_layout
>
> @@ -4988,8 +5310,24 @@ status open
>   The Guest needs to check VIRTIO_NET_S_ANNOUNCE bit in status field when
>    it notices the changes of device configuration.
>    The command VIRTIO_NET_CTRL_ANNOUNCE_ACK is used to indicate that driver
> - has recevied the notification and device would clear the VIRTIO_NET_S_ANNOUNCE
> - bit in the status filed after it received this command.
> + has rece
> +\change_inserted 1986246365 1346663932
> +i
> +\change_unchanged
> +v
> +\change_deleted 1986246365 1346663934
> +i
> +\change_unchanged
> +ed the notification and device would clear the VIRTIO_NET_S_ANNOUNCE bit
> + in the status fi
> +\change_inserted 1986246365 1346663942
> +e
> +\change_unchanged
> +l
> +\change_deleted 1986246365 1346663943
> +e
> +\change_unchanged
> +d after it received this command.
>   \end_layout
>
>   \begin_layout Standard
> @@ -5004,10 +5342,101 @@ Sending the gratuitous packets or marking there are pending gratuitous packets
>   \begin_layout Enumerate
>   Sending VIRTIO_NET_CTRL_ANNOUNCE_ACK command through control vq.
>
> +\change_deleted 1986246365 1346662247
> +
>   \end_layout
>
> -\begin_layout Enumerate
> +\begin_layout Subsection*
> +
> +\change_inserted 1986246365 1346670357
> +\begin_inset CommandInset label
> +LatexCommand label
> +name "sub:Receive-Packet-Steering"
> +
> +\end_inset
> +
> +Receive Packet Steering
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346671046
> +When VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, device can use any
> + of multiple configured receive queues to pass a given packet to driver.
> + Driver controls which virtqueue is selected in practice by configuring
> + packet steering rule using VIRTIO_NET_CTRL_STEERING command, as described
> + above
> +\begin_inset CommandInset ref
> +LatexCommand ref
> +reference "sub:Transmit-Packet-Steering"
> +
> +\end_inset
> +
>   .
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346671818
> +The field
> +\emph on
> +rule
> +\emph default
> + specifies the function used to select receive virtqueue for a given packet;
> + the field
> +\emph on
> +param
> +\emph default
> + makes it possible to pass an extra parameter if appropriate.
> + When
> +\emph on
> +rule
> +\emph default
> + is set to VIRTIO_NET_CTRL_STEERING_SINGLE all packets are steered to the
> + default virtqueue receveq (0); param is unused; this is the default.

A question here is whether or not we need to do the seamless switching 
between mq modes and sq modes. If we expect it happens rare, we could 
afforad some disordering by dropping this and just do the switching by 
resetting the device and negotiating the MULTIQUEUE bit or not on 
demand. This can simplify the implemention.
> + When
> +\emph on
> +rule
> +\emph default
> + is set to VIRTIO_NET_CTRL_STEERING_HOST packets are steered by host using
> + a device-specific steering function to the first (
> +\emph on
> +param
> +\emph default
> ++1) multiqueue virtqueues receiveq1...receiveqN; the default receiveq is unused.
> + Driver must have configured all these (
> +\emph on
> +param
> +\emph default
> ++1) virtqueues beforehand.
> + For best performance, driver is expected to detect flow to virtqueue pair
> + mapping on receive and select the transmit virtqueue from the same virtqueue
> + pair.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346669564
> +Supported steering rules can be added and removed in the future.
> + Driver should probe for supported rules by checking ack values of the command.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_inserted 1986246365 1346671151
> +When steering rule is modified, some packets can still be outstanding in
> + one or more of the virtqueues.
> + For receive, driver is recommended to complete processing of the receive
> + queue(s) utilized by the original steering before processing any packets
> + delivered by the modified steering rule.
> +\end_layout
> +
> +\begin_layout Standard
> +
> +\change_deleted 1986246365 1346664095
> +.
> +
> +\change_unchanged
>
>   \end_layout
>
