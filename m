From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Tue, 17 May 2011 07:33:18 -0700
Message-ID: <m1mxil9z2p.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<3A54AB469A0294933EAC2257@nimrod.local>
	<m1fwoqoapn.fsf@fess.ebiederm.org>
	<20110517111148.GA3762520@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Bligh <alex@alex.org.uk>, linux-arch@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	linux-fsdevel@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110517111148.GA3762520@jupiter.n2.diac24.net> (David
	Lamparter's message of "Tue, 17 May 2011 13:11:48 +0200")
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Lamparter <equinox@diac24.net> writes:

> On Sat, May 07, 2011 at 07:18:44AM -0700, Eric W. Biederman wrote:
>> You can read the processes network namespace by opening
>> /proc/<pid>/ns/net.  Unfortunately comparing the network
>> namespaces for identity is another matter.  You will probably
>> be better off simply forcing the routing daemon to start
>> in the desired network namespace in it's initscript.
>> 
>> For purposes of clarity please have a look at my work in
>> progress patch for iproute2.  This demonstrates how I expect
>> userspace to work in a multi-network namespace world.
>> 
> [...]
>> Subject: [PATCH] iproute2:  Add processless netnwork namespace support.
> [...]
>> Configuration specific to a network namespace that
>> would ordinarily be stored under /etc/ is stored under
>> /etc/netns/<name>.  For example if the dns server
>> configuration is different for your vpn you would
>> create a file /etc/netns/myvpn/resolv.conf.
>> 
>> File descriptors that can be used to manipulate a
>> network namespace can be created by opening
>> /var/run/netns/<NAME>.
>> 
>> This adds the following commands to iproute.
>> ip netns add NAME
>> ip netns delete NAME
>> ip netns monitor
>> ip netns list
>> ip netns exec NAME cmd ....
>> ip link set DEV netns NAME
>
> funny, this is almost exactly what my code does - though you're probably
> doing it better and have more features ;)

Well if it has more features it is only because I have managed to keep
everything simple enough that adding features was easy.  I ignored all
of the hard bits.

> http://git.spaceboyz.net/equinox/vrf-tools.git/
> git://spaceboyz.net/equinox/vrf-tools.git
>
> It currently forks off a daemon to keep the namespace open; attaching is
> not possible yet, but opening a socket in a different namespace is.

I went the round of keeping a daemon open, saw how much code that
takes and how fragile that can be in the corner cases and decided to
patch the kernel to make the interfaces better.

> Most of the actual management (mounting things & co.) I offloaded to
> some shell scripts; I use it together with GNU screen (which makes it
> very nice to grab one of the namespaces and start/stop/manage/...
> things).

That does sound like a nice way of doing the management.

> I also have patches for OpenVPN and pptpd floating around that make it
> possible to 'cross' namespace boundaries, i.e. the VPN servers listen in
> one namespace and have their devices in another.

For openvpn I have managed to get away with simply using an up script. 
Mostly the script is:

ip netns add $NSNAME || true
ip netns exec $NSNAME ip link set lo up
ip link set $dev netns $NSNAME
ip netns exec $NSNAME ip link set $dev up
ip netns exec $NSNAME ifconfig $dev $ifconfig_local netmask $ifconfig_netmask broadcast $ifconfig_broadcast

With a few extra bits for dns options and routes.  If I had an openvpn
built with the iproute option I expect I could get away by just wrapping
iproute.  Not that I would mind a patched openvpn.

Personally I think using a vpn in a network namespace seems like a
killer feature.

Eric
