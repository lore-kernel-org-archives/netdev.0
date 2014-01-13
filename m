From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Mon, 13 Jan 2014 15:36:46 +0800
Message-ID: <52D3978E.4060109@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-4-git-send-email-mwdalton@google.com>
	<52CCF177.7020500@redhat.com> <20140108192109.GC18312@redhat.com>
	<CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
	<20140112170939.GA17202@redhat.com>
	<CANJ5vP+Vu8=haCetZkcefPgR8pGe0iDZ03EZhJHLSgunCaHJsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	lf-virt <virtualization@lists.linux-foundation.org>
To: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vP+Vu8=haCetZkcefPgR8pGe0iDZ03EZhJHLSgunCaHJsQ@mail.gmail.com>
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

On 01/13/2014 07:32 AM, Michael Dalton wrote:
> Hi Michael,
>
> On Sun, Jan 12, 2014 at 9:09 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> Can't we add struct attribute * to netdevice, and pass that in when
>> creating the kobj?
> I like that idea, I think that will work and should be better than
> the alternatives. The actual kobjs for RX queues (struct netdev_rx_queue)
> are allocated and deallocated by calls to net_rx_queue_update_kobjects,
> which resizes RX queue kobjects when the netdev RX queues are resized.
>
> Is this what you had in mind:
> (1) Add a pointer to an attribute group to struct net_device, used for
>     per-netdev rx queue attributes and initialized before the call to
>     register_netdevice().
> (2) Declare an attribute group containing the mergeable_rx_buffer_size
>     attribute in virtio-net, and initialize the per-netdevice group pointer
>     to the address of this group in virtnet_probe before register_netdevice
> (3) In net-sysfs, modify net_rx_queue_update_kobjects
>     (or rx_queue_add_kobject) to call sysfs_create_group on the
>     per-netdev attribute group (if non-NULL), adding the attributes in
>     the group to the RX queue kobject.
>
> That should allow us to have per-RX queue attributes that are
> device-specific. I'm not a sysfs expert, but it seems that rx_queue_ktype
> and rx_queue_sysfs_ops presume that all rx queue sysfs operations are
> performed on attributes of type rx_queue_attribute. That type will need
> to be moved from net-sysfs.c to a header file like netdevice.h so that
> the type can be used in virtio-net when we declare the
> mergeable_rx_buffer_size attribute.

There's a possible issue, rx queue sysfs depends on CONFIG_RPS. So we
probably need a dedicated attribute just for virtio-net.
>
> The last issue is how the rx_queue_attribute 'show' function
> implementation for mergeable_rx_buffer_size will access the appropriate
> per-receive queue EWMA data. The arguments to the show function will be
> the netdev_rx_queue and the attribute itself. We can get to the
> struct net_device from the netdev_rx_queue.  If we extended
> netdev_rx_queue to indicate the queue_index or to store a void *priv_data
> pointer, that would be sufficient to allow us to resolve this issue.
>
> Please let me know if the above sounds good or if you see a better way
> to accomplish this goal. Thanks!
>
> Best,
>
> Mike
