From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Mon, 10 Aug 2009 17:06:58 +0200
Message-ID: <200908101706.58261.arnd@arndb.de>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net> <200908081149.27409.arnd@arndb.de> <0199E0D51A61344794750DC57738F58E6D6AE99743@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	Eric Biederman <ebiederm@xmission.com>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932117AbZHJPKU@vger.kernel.org>
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6AE99743@GVW1118EXC.americas.hpqcorp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 August 2009, Fischer, Anna wrote:
> > Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
> > 
> > On Friday 07 August 2009, Paul Congdon (UC Davis) wrote:
> > > As I understand the macvlan code, it currently doesn't allow two VMs
> > on the
> > > same machine to communicate with one another.
> > 
> > There are patches to do that. I think if we add that, there should be
> > a way to choose the behavior between either bridging between the
> > guests or VEPA.
> 
> If you implement this direct bridging capability between local VMs for 
> macvlan, then would this not break existing applications that currently
> use it? It would be quite a significant change to how macvlan works 
> today. I guess, ideally, you would want to have macvlan work in 
> separate modes, e.g. traditional macvlan, bridging, and VEPA.

Right, that's what I meant with my sentence above. I'm not sure
if we need to differentiate traditional macvlan and VEPA though.
AFAICT, the only difference should be the handling of broadcast
and multicast frames returning from the hairpin turn. Since this
does not happen with a traditional macvlan, we can always send them
to all macvlan ports except the source port.

> > > I could imagine a hairpin mode on the adjacent bridge making this
> > > possible, but the macvlan code would need to be updated to filter
> > > reflected frames so a source did not receive his own packet.
> > 
> > Right, I missed this point so far. I'll follow up with a patch
> > to do that.
> 
> Can you maybe point me to the missing patches for macvlan that you
> have mentioned in other emails, and the one you mention above? 
> E.g. enabling multicast distribution and allowing local bridging etc.
> I could not find any of those in the archives. Thanks.

The patch from Eric Biederman to allow macvlan to bridge between
its slave ports is at

http://kerneltrap.org/mailarchive/linux-netdev/2009/3/9/5125774

I could not find any patches for the other features (or bugs).

> > This is the interesting part of the discussion. The bridge and macvlan
> > drivers certainly have an overlap in functionality and you can argue
> > that you only need one. Then again, the bridge code is a little crufty
> > and we might not want to add much more to it for functionality that can
> > be implemented in a much simpler way elsewhere. My preferred way would
> > be to use bridge when you really need 802.1d MAC learning, netfilter-
> > bridge
> > and STP, while we put the optimizations for stuff like VMDq, zero-copy
> > and multiqueue guest adapters only into the macvlan code.
> 
> I can see this being a possible solution. 
> 
> My concern with putting VEPA into macvlan instead of the bridging code
> is that there will be more work required to make it usable for other
> virtualization solution as macvtap will only work for KVM type setups.

Right, I understand.

> Basically, VEPA capabilities would rely on someone developing further
> drivers to connect macvlan to different backend interfaces, e.g. one for
> KVM (macvtap), one for Xen PV drivers, one for virtio, and whatever else
> is out there, or will be there in the future. The bridging code is
> already very generic in that respect, and all virtualization layers
> can deal with connecting interfaces to a bridge. 
> 
> Our extensions to the bridging code to enable VEPA for the Linux kernel
> are only very minimal code changes and would allow to make VEPA available
> to most virtualization solutions today.

I don't object to having VEPA supported in the bridge code at all.
I think your patch is simple enough so it won't hurt in the bridge
code. If Stephen prefers to do VEPA only in one component, we should
probably make it possible for that component to act as a bridge between
1+n existing interfaces as well. You can almost do that with the regular
macvlan and the bridge driver, like

      / macvlan0 - br0 - tap0
eth0 -- macvlan1 - br1 - tap1
      \ macvlan2 - br2 - tap2

Here, you can have two guests attached to tap devices (or xen net ...)
and the macvlan driver doing the VEPA. Of course this is not how bridge
works -- you would have the same mac addresses on two sides of
the bridge.

So we could have another macvlan backend (let's call it macvbridge)
so you can do this:

      / macvlan0 - 'qemu -net raw'
eth0 -- macvtap0 - 'qemu -net tap,fd=3 3<>/dev/net/macvtap0'
      \ macvbr0 -- tap0 - 'qemu -net tap'

The macvbr driver could this way be used to associate an existing
network device to a slave of a macvlan port. Not sure if this
has any significant advantage over your bridge patches, it does
have the obvious disadvantage that someone needs to implement
it first, while your patch is there ;-)

	Arnd <><
