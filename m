From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH 1/2] net: Add multiqueue support
Date: Sat, 30 Apr 2011 23:15:46 +0800
Message-ID: <19900.10146.44006.188521@gargle.gargle.HOWL>
References: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	<20110420083318.32157.63955.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	<4DBB1A9F.2050803@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	rusty@rustcorp.com.au, qemu-devel@nongnu.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <4DBB1A9F.2050803@codemonkey.ws>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Anthony Liguori writes:
 > On 04/20/2011 03:33 AM, Jason Wang wrote:
 > > This patch adds the multiqueues support for emulated nics. Each VLANClientState
 > > pairs are now abstract as a queue instead of a nic, and multiple VLANClientState
 > > pointers were stored in the NICState and treated as the multiple queues of a
 > > single nic. The netdev options of qdev were now expanded to accept more than one
 > > netdev ids. A queue_index were also introduced to let the emulated nics know
 > > which queue the packet were came from or sent out. Virtio-net would be the first
 > > user.
 > >
 > > The legacy single queue nics can still run happily without modification as the
 > > the compatibility were kept.
 > >
 > > Signed-off-by: Jason Wang<jasowang@redhat.com>
 > > ---
 > >   hw/qdev-properties.c |   37 ++++++++++++++++++++++++++++++-------
 > >   hw/qdev.h            |    3 ++-
 > >   net.c                |   34 ++++++++++++++++++++++++++--------
 > >   net.h                |   15 +++++++++++----
 > >   4 files changed, 69 insertions(+), 20 deletions(-)
 > >
 > > diff --git a/hw/qdev-properties.c b/hw/qdev-properties.c
 > > index 1088a26..dd371e1 100644
 > > --- a/hw/qdev-properties.c
 > > +++ b/hw/qdev-properties.c
 > > @@ -384,14 +384,37 @@ PropertyInfo qdev_prop_chr = {
 > >
 > >   static int parse_netdev(DeviceState *dev, Property *prop, const char *str)
 > >   {
 > > -    VLANClientState **ptr = qdev_get_prop_ptr(dev, prop);
 > > +    VLANClientState ***nc = qdev_get_prop_ptr(dev, prop);
 > > +    const char *ptr = str;
 > > +    int i = 0;
 > > +    size_t len = strlen(str);
 > > +    *nc = qemu_malloc(MAX_QUEUE_NUM * sizeof(VLANClientState *));
 > > +
 > > +    while (i<  MAX_QUEUE_NUM&&  ptr<  str + len) {
 > > +        char *name = NULL;
 > > +        char *this = strchr(ptr, '#');
 > 
 > However this is being used is not going to be right.  Is this taking 
 > netdev=a#b#c#d?
 > 

Yes, through this current netdev codes could be reused but it would bring extra
complexity of link status handling because it makes every queue visible from
monitor. Do you have any suggestions on this kind of cli? Another method is let
netdev accept multiple fd/vhostfd, but the tap fd handling codes need to be
refactored.

You can refer Krishna's patch http://www.spinics.net/lists/kvm/msg52098.html.
His patch make multiqueue only works for vhost while my patch also make the
multiqueue works for userspace and also let it could be used by other nic model.

 > I sort of agree with Michael about using multiple netdevs for this but I 
 > don't yet understand how this gets sets up from userspace.
 > 
 > Can you give an example of usage that involves the full tap device setup?
 > 
 > Ideally, a user/management tool would never need to know about any of this.
 > 

For macvtap, what user/management tool need is:
1 create a macvtap device by either netlink or ip command
2 open the device many times and pass the fd to the qemu

In fact, qemu can do all of this, but for the sake of management, keep the
current tap implementation and accpet a file descriptor from libvirt may be a
better choice.

 > In a perfect world, we could just dup() the tap fd a few times to create 
 > multiple queues.

But dup() can only create file descriptors pointed to the same file which is
hard to implement real multi queues.

 > 
 > Regards,
 > 
 > Anthony Liguori
 > --
 > To unsubscribe from this list: send the line "unsubscribe kvm" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jason Wang
