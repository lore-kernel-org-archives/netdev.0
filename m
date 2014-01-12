From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Sun, 12 Jan 2014 19:09:39 +0200
Message-ID: <20140112170939.GA17202@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-4-git-send-email-mwdalton@google.com>
	<52CCF177.7020500@redhat.com> <20140108192109.GC18312@redhat.com>
	<CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
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

On Fri, Jan 10, 2014 at 09:19:37PM -0800, Michael Dalton wrote:
> Hi Jason, Michael
> 
> Sorry for the delay in response. Jason, I agree this patch ended up
> being larger than expected. The major implementation parts are:
> (1) Setup directory structure (driver/per-netdev/rx-queue directories)
> (2) Network device renames (optional, so debugfs dir has the right name)
> (3) Support resizing the # of RX queues (optional - we could just export
>     max_queue_pairs files and not delete files if an RX queue is disabled)
> (4) Reference counting - used in case someone opens a debugfs
>     file and then removes the virtio-net device.
> (5) The actual mergeable rx buffer file implementation itself. For now
>     I have added a seqcount for memory safety, but if a read-only race
>     condition is acceptable we could elide the seqcount. FWIW, the
>     seqcount write in receive_mergeable() should, on modern x86,
>     translate to two non-atomic adds and two compiler barriers, so
>     overhead is not expected to be meaningful.
> 
> We can move to sysfs and this would simplify or eliminate much of the
> above, including most of (1) - (4). I believe our choices for what to
> do for the next patchset include:
> (a) Use debugfs as is currently done, removing any optional features
> listed above that are deemed unnecessary.
> 
> (b) Add a per-netdev sysfs attribute group to net_device->sysfs_groups.
> Each attribute would display the mergeable packet buffer size for a given
> RX queue, and there would be max_queue_pairs attributes in total. This
> is already supported by net/core/net-sysfs.c:netdev_register_kobject(),
> but means that we would have a static set of per-RX queue files for
> all RX queues supported by the netdev, rather than dynamically displaying
> only the files corresponding to enabled RX queues (e.g., when # of RX
> queues is changed by  ethtool -L <device>).  For an example of this
> approach, see drivers/net/bonding/bond_sysfs.c.
> 
> (c) Modify struct netdev_rx_queue to add virtio-net EWMA fields directly,
> and modify net-sysfs.c to manage the new fields. Unlike (b), this approach
> supports the RX queue resizing in (3) but means putting virtio-net info
> in netdev_rx_queue, which currently has only device-independent fields.

Can't we add struct attribute * to netdevice, and pass that in when
creating the kobj?

> My preference would be (b): try using sysfs and adding a device-specific
> attribute group to the virtio-net netdevice (stored in the existing
> 'sysfs_groups' field and supported by net-sysfs).  This would avoid
> adding virtio-net specific information to net-sysfs. What would you
> prefer (or is there a better way than the approaches above)? Thanks!
> 
> Best,
> 
> Mike
