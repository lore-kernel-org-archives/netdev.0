From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] vhost-net: add dhclient work-around from userspace
Date: Tue, 29 Jun 2010 00:36:47 -0700 (PDT)
Message-ID: <20100629.003647.214219303.davem@davemloft.net>
References: <20100628100807.GA30685@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arozansk@redhat.com, herbert.xu@redhat.com, quintela@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ykaul@redhat.com, markmc@redhat.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100628100807.GA30685@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 28 Jun 2010 13:08:07 +0300

> Userspace virtio server has the following hack
> so guests rely on it, and we have to replicate it, too:
> 
> Use port number to detect incoming IPv4 DHCP response packets,
> and fill in the checksum for these.
> 
> The issue we are solving is that on linux guests, some apps
> that use recvmsg with AF_PACKET sockets, don't know how to
> handle CHECKSUM_PARTIAL;
> The interface to return the relevant information was added
> in 8dc4194474159660d7f37c495e3fc3f10d0db8cc,
> and older userspace does not use it.
> One important user of recvmsg with AF_PACKET is dhclient,
> so we add a work-around just for DHCP.
> 
> Don't bother applying the hack to IPv6 as userspace virtio does not
> have a work-around for that - let's hope guests will do the right
> thing wrt IPv6.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Yikes, this is awful too.

Nothing in the kernel should be mucking around with procotol packets
like this by default.  In particular, what the heck does port 67 mean?
Locally I can use it for whatever I want for my own purposes, I don't
have to follow the conventions for service ports as specified by the
IETF.

But I can't have the packet checksum state be left alone for port 67
traffic on a box using virtio because you have this hack there.

And yes it's broken on machines using the qemu thing, but at least the
hack there is restricted to userspace.

I really don't want anything in the kernel that looks like this.

These applications are broken, and we've provided a way for them to
work properly.  What's the point of having fixed applications if
all of these hacks grow like fungus over every virtualization transport?

It just means that people won't fix the apps, since they don't have
to.  There is no incentive, and the mechanism we created to properly
handle this loses it's value.

At best, you can write a netfilter module that mucks up the packet
checksum state in these situations.  At least in that case, you can
make it generic (it mangles iff a packet matches a certain rule,
so for your virtio guests you'd make it match for DHCP frames) instead
of being some hard-coded DHCP thing by design.

And since this is so cleanly seperated and portable you don't even
need to push it upstream.  It's a temporary workaround for a temporary
problem.  You can just delete it as soon as the majority of guests
have the fixed dhcp.  The qemu crap should disappear similarly.
