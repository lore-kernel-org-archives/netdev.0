From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] [ver3 PATCH 0/6] Implement multiqueue virtio-net
Date: Sun, 13 Nov 2011 13:40:49 +0200
Message-ID: <20111113114048.GE15322@redhat.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
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

On Fri, Nov 11, 2011 at 06:32:23PM +0530, Krishna Kumar wrote:
> This patch series resurrects the earlier multiple TX/RX queues
> functionality for virtio_net, and addresses the issues pointed
> out.

Some general questions/issues with the approach this patchset takes:
1. Lack of host-guest synchronization for flow hash.
   On the host side, things will scale if the same vhost thread
   handles both transmit and receive for a specific flow.
   Further, things will scale
   if packets from distinct guest queues get routed to
   distict queues on the NIC and tap devices in the host.
   It seems that to achieve both, host and guest
   need to pass  the flow hash information to each other.
   Ben Hutchings suggested effectively pushing the guest's
   RFS socket map out to the host.  Any thoughts on this?
2. Reduced batching/increased number of exits.
   It's easy to see that the amount of work per VQ
   is reduced with this patch. Thus it's easy to imagine
   that under some workloads, where we previously had
   X packets per VM exit/interrupt, we'll now have X/N with N
   the number of virtqueues. Since both a VM exit and an interrupt
   are expensive operations, one wonders whether this can
   lead to performance regressions.
   It seems that to reduce the chance of such, some adaptive
   strategy would work better. But how would we ensure
   packets aren't reordered then? Any thoughts?
3. Lack of userspace resource control.
   A vhost-net device already uses quite a lot of resources.
   This patch seems to make the problem worse. At the moment,
   management can to some level control that by using a file
   descriptor per virtio device. So using a file descriptor
   per VQ has an advantage of limiting the amount of resources
   qemu can consume.  In April, Jason posted a qemu patch that supported
   a multiqueue guest by using existing vhost interfaces, by opening
   multiple devices, one per queue.
   It seems that this can be improved upon, if we allow e.g. sharing
   of memory maps between file descriptors.
   This might also make adaptive queueing strategies possible.
   Would it be possible to do this instead?

>  It also includes an API to share irq's, f.e.  amongst the
> TX vqs. 
> I plan to run TCP/UDP STREAM and RR tests for local->host and
> local->remote, and send the results in the next couple of days.

Please do. Small message throughput would be especially interesting.

> patch #1: Introduce VIRTIO_NET_F_MULTIQUEUE
> patch #2: Move 'num_queues' to virtqueue
> patch #3: virtio_net driver changes
> patch #4: vhost_net changes
> patch #5: Implement find_vqs_irq()
> patch #6: Convert virtio_net driver to use find_vqs_irq()
> 
> 
> 		Changes from rev2:
> Michael:
> -------
> 1. Added functions to handle setting RX/TX/CTRL vq's.
> 2. num_queue_pairs instead of numtxqs.
> 3. Experimental support for fewer irq's in find_vqs.
> 
> Rusty:
> ------
> 4. Cleaned up some existing "while (1)".
> 5. rvq/svq and rx_sg/tx_sg changed to vq and sg respectively.
> 6. Cleaned up some "#if 1" code.
> 
> 
> Issue when using patch5:
> -------------------------
> 
> The new API is designed to minimize code duplication.  E.g.
> vp_find_vqs() is implemented as:
> 
> static int vp_find_vqs(...)
> {
> 	return vp_find_vqs_irq(vdev, nvqs, vqs, callbacks, names, NULL);
> }
> 
> In my testing, when multiple tx/rx is used with multiple netperf
> sessions, all the device tx queues stops a few thousand times and
> subsequently woken up by skb_xmit_done.  But after some 40K-50K
> iterations of stop/wake, some of the txq's stop and no wake
> interrupt comes. (modprobe -r followed by modprobe solves this, so
> it is not a system hang).  At the time of the hang (#txqs=#rxqs=4):
> 
> # egrep "CPU|virtio0" /proc/interrupts | grep -v config
>        CPU0     CPU1     CPU2    CPU3
> 41:    49057    49262    48828   49421  PCI-MSI-edge    virtio0-input.0
> 42:    5066     5213     5221    5109   PCI-MSI-edge    virtio0-output.0
> 43:    43380    43770    43007   43148  PCI-MSI-edge    virtio0-input.1
> 44:    41433    41727    42101   41175  PCI-MSI-edge    virtio0-input.2
> 45:    38465    37629    38468   38768  PCI-MSI-edge    virtio0-input.3
> 
> # tc -s qdisc show dev eth0
> qdisc mq 0: root      
> 	Sent 393196939897 bytes 271191624 pkt (dropped 59897,
> 	overlimits 0 requeues 67156) backlog 25375720b 1601p
> 	requeues 67156  
> 
> I am not sure if patch #5 is responsible for the hang.  Also, without
> patch #5/patch #6, I changed vp_find_vqs() to:
> static int vp_find_vqs(...)
> {
> 	return vp_try_to_find_vqs(vdev, nvqs, vqs, callbacks, names,
> 				  false, false);
> }
> No packets were getting TX'd with this change when #txqs>1.  This is
> with the MQ-only patch that doesn't touch drivers/virtio/ directory.
> 
> Also, the MQ patch works reasonably well with 2 vectors - with
> use_msix=1 and per_vq_vectors=0 in vp_find_vqs().
> 
> Patch against net-next - please review.
> 
> Signed-off-by: krkumar2@in.ibm.com
> ---
