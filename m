From: Richard Weinberger <richard@nod.at>
Subject: [RFC] Make predictable/persistent network interface names more handy
Date: Sun, 11 Jan 2015 21:52:48 +0100
Message-ID: <1421009571-5279-1-git-send-email-richard@nod.at>
Cc: coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, john.fastabend@gmail.com,
	herbert@gondor.apana.org.au, vyasevic@redhat.com, jiri@resnulli.us,
	vfalico@gmail.com, therbert@google.com, edumazet@google.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	kay@vrfy.org, stephen@networkplumber.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the Linux distribution of my choice makes use of
predictable network interface names[0] my USB gadgets
are no longer usb0 but enp0s29u1u2. Same for all other network devices.
While I can fully understand that this new naming scheme makes sense
for a lot of people and makes their work easier it does not really work for me.
My brain is not able to remember that my Beaglebone's USB-Ethernet
is now enp0s29u1u2. Even after looking at the output of ifconfig
I have to copy&paste the interface name.
Instead of just disabling the feature I thought about
a generic solution which satisfies both needs.

For block devices we also have predictable device names,
udev creates a symlink to the kernel device.
This works very good and reliable.
My idea is to use the network device alias as symlink.
Such that we can have both the easy to use kernel name and
the predictable/persistent name from udev.
systemd/udev could store the original kernel interface name
as alias after renaming the interface.
Existing users would not notice but one can still use the kernel name.
So I can use tcpdump -i usb0 _and_ tcpdump -i enp0s29u1u2.

This patch series implements my idea.
I'd love to get some feedback!

Patch 1/3 exposes the interfaces alias for general userspace usage, i.e. that ifconfig <alias> works.
Of course you can only use the first 15 chars of an alias.

In-kernel users of interface names need also an update, patch 2/3 updates x_tables.
I'm sure there is more todo, i.e. nftables.
We could also define that netfilter will never use the alias but this needs documented cleary.

Patch 3/3 is a cleanup in continuation of 2/3.

[0] http://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

Thanks,
//richard

git://git.kernel.org/pub/scm/linux/kernel/git/rw/misc.git netalias

[PATCH 1/3] net: Make interface aliases available for general usage
[PATCH 2/3] x_tables: Use also dev->ifalias for interface matching
[PATCH 3/3] x_tables: Factor out 16bit aligment ifname_compare()

 include/linux/netdevice.h          |  1 +
 include/linux/netfilter/x_tables.h | 41 +++++++++++++++++++++++++++---
 include/net/net_namespace.h        |  1 +
 net/core/dev.c                     | 52 ++++++++++++++++++++++++++++++++++++++
 net/ipv4/netfilter/arp_tables.c    | 37 ++++-----------------------
 net/ipv4/netfilter/ip_tables.c     | 15 ++++-------
 net/ipv6/netfilter/ip6_tables.c    | 18 +++++--------
 net/netfilter/xt_physdev.c         |  9 ++-----
 8 files changed, 110 insertions(+), 64 deletions(-)
