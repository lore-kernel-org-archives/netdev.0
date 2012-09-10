From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Mon, 10 Sep 2012 11:42:25 +0930
Message-ID: <878vcifwxi.fsf@rustcorp.com.au>
References: <20120909130308.GA3471@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, rick.jones2@hp.com, levinsasha928@gmail.com,
	Tom Herbert <therbert@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120909130308.GA3471@redhat.com>
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

OK, I read the spec (pasted below for easy of reading), but I'm still
confused over how this will work.

I thought normal net drivers have the hardware provide an rxhash for
each packet, and we map that to CPU to queue the packet on[1].  We hope
that the receiving process migrates to that CPU, so xmit queue
matches.

For virtio this would mean a new per-packet rxhash value, right?

Why are we doing something different?  What am I missing?

Thanks,
Rusty.
[1] Everything I Know About Networking I Learned From LWN:
    https://lwn.net/Articles/362339/

---
Transmit Packet Steering

When VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, guest can use any of multiple configured transmit queues to transmit a given packet. To avoid packet reordering by device (which generally leads to performance degradation) driver should attempt to utilize the same transmit virtqueue for all packets of a given transmit flow. For bi-directional protocols (in practice, TCP), a given network connection can utilize both transmit and receive queues. For best performance, packets from a single connection should utilize the paired transmit and receive queues from the same virtqueue pair; for example both transmitqN and receiveqN. This rule makes it possible to optimize processing on the device side, but this is not a hard requirement: devices should function correctly even when this rule is 
 not followed.

Driver selects an active steering rule using VIRTIO_NET_CTRL_STEERING command (this controls both which virtqueue is selected for a given packet for receive and notifies the device which virtqueues are about to be used for transmit).

This command accepts a single out argument in the following format:

#define VIRTIO_NET_CTRL_STEERING               4

The field rule specifies the function used to select transmit virtqueue for a given packet; the field param makes it possible to pass an extra parameter if appropriate. When rule is set to VIRTIO_NET_CTRL_STEERING_SINGLE (this is the default) all packets are steered to the default virtqueue transmitq (1); param is unused; this is the default. With any other rule, When rule is set to VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX packets are steered by driver to the first N=(param+1) multiqueue virtqueues transmitq1...transmitqN; the default transmitq is unused. Driver must have configured all these (param+1) virtqueues beforehand.

Supported steering rules can be added and removed in the future. Driver should check that the request to change the steering rule was successful by checking ack values of the command. As selecting a specific steering is an optimization feature, drivers should avoid hard failure and fall back on using a supported steering rule if this command fails. The default steering rule is VIRTIO_NET_CTRL_STEERING_SINGLE. It will not be removed.

When the steering rule is modified, some packets can still be outstanding in one or more of the transmit virtqueues. Since drivers might choose to modify the current steering rule at a high rate (e.g. adaptively in response to changes in the workload) to avoid reordering packets, device is recommended to complete processing of the transmit queue(s) utilized by the original steering before processing any packets delivered by the modified steering rule.

For debugging, the current steering rule can also be read from the configuration space.

Receive Packet Steering

When VIRTIO_NET_F_MULTIQUEUE feature bit is negotiated, device can use any of multiple configured receive queues to pass a given packet to driver. Driver controls which virtqueue is selected in practice by configuring packet steering rule using VIRTIO_NET_CTRL_STEERING command, as described above[sub:Transmit-Packet-Steering].

The field rule specifies the function used to select receive virtqueue for a given packet; the field param makes it possible to pass an extra parameter if appropriate. When rule is set to VIRTIO_NET_CTRL_STEERING_SINGLE all packets are steered to the default virtqueue receiveq (0); param is unused; this is the default. When rule is set to VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX packets are steered by host to the first N=(param+1) multiqueue virtqueues receiveq1...receiveqN; the default receiveq is unused. Driver must have configured all these (param+1) virtqueues beforehand. For best performance for bi-directional flows (such as TCP) device should detect the flow to virtqueue pair mapping on transmit and select the receive virtqueue from the same virtqueue pair. For uni-directional flows, o
 r when this mapping information is missing, a device-specific steering function is used.

Supported steering rules can be added and removed in the future. Driver should probe for supported rules by checking ack values of the command.

When the steering rule is modified, some packets can still be outstanding in one or more of the virtqueues. Device is not required to wait for these packets to be consumed before delivering packets using the new streering rule. Drivers modifying the steering rule at a high rate (e.g. adaptively in response to changes in the workload) are recommended to complete processing of the receive queue(s) utilized by the original steering before processing any packets delivered by the modified steering rule.
