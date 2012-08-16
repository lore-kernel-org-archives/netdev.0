From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Slow inbound traffic on macvtap interfaces
Date: Thu, 16 Aug 2012 18:36:13 +0300
Message-ID: <20120816153613.GA22326@redhat.com>
References: <20120816092004.GA1894@arachsys.com>
	<20120816114233.GA21343@redhat.com>
	<20120816142756.GA9806@arachsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	qemu-devel@nongnu.org, Arnd Bergmann <arnd@arndb.de>
To: Chris Webb <chris@arachsys.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <20120816142756.GA9806@arachsys.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2012 at 03:27:57PM +0100, Chris Webb wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> 
> > On Thu, Aug 16, 2012 at 10:20:05AM +0100, Chris Webb wrote:
> >
> > > For example, I can run
> > > 
> > >   ip addr add 192.168.1.2/24 dev eth0
> > >   ip link set eth0 up
> > >   ip link add link eth0 name tap0 address 02:02:02:02:02:02 type macvtap mode bridge
> > >   ip link set tap0 up
> > >   qemu-kvm -hda debian.img -cpu host -m 512 -vnc :0 \
> > >     -net nic,model=virtio,macaddr=02:02:02:02:02:02 \
> > >     -net tap,fd=3 3<>/dev/tap$(< /sys/class/net/tap0/ifindex)
> > > 
> > > on one physical host which is otherwise completely idle. From a second
> > > physical host on the same network, I then scp a large (say 50MB) file onto
> > > the new guest. On a gigabit LAN, speeds consistently drop to less than
> > > 100kB/s as the transfer progresses, within a second of starting.
> 
> > Thanks for the report.
> > I'll try to reproduce this early next week.
> > Meanwhile a question - do you still observe this behaviour if you enable
> > vhost-net?
> 
> I haven't tried running with vhost-net before. Is it sufficient to compile
> the host kernel with CONFIG_VHOST_NET=y and boot the guest with
> 
>   qemu-kvm -hda debian.img -cpu host -m 512 -vnc :0 \
>     -net nic,model=virtio,macaddr=02:02:02:02:02:02 \
>     -net tap,fd=3,vhost=on,vhostfd=4 \
>     3<>/dev/tap$(< /sys/class/net/tap0/ifindex) 4<>/dev/vhost-net
> 
> ? If so, then I'm afraid this doesn't make any difference: it still stalls
> and drops right down in speed.
> 
> The reason I'm hesitant about whether the vhost-net is actually working is
> that with both vhost=off and vhost=on, I see an identical virtio feature set
> within the guest:
> 
>   # cat /sys/bus/virtio/devices/virtio0/features 
>   0000011000000001111100000000100000000000000000000000000000000000

Yes that is expected.

> However, without the 4<>/dev/vhost-net or with 4<>/dev/null, it seems to
> fail to start altogether with vhost=on,vhostfd=4, so perhaps it's fine?
> 
> Cheers,
> 
> Chris.
