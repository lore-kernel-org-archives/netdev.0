From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Tue, 22 Mar 2011 16:47:27 -0400
Message-ID: <AANLkTikr=qfFeaXDkiBbK-4KvKS83LzURrUj4L2TP8_u@mail.gmail.com>
References: <201102272122.52643.arnd@arndb.de>
	<4D6B6AE7.2050202@msgid.tls.msk.ru>
	<20110228095133.GA4351@albatros>
	<20110228.112349.104067277.davem@davemloft.net>
	<20110301194845.GA3533@albatros>
	<1299010390.2529.30.camel@bwh-desktop>
	<20110301213313.GA6507@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org, Greg KH <greg@kroah.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	LSM List <linux-security-module@vger.kernel.org>,
	Daniel J Walsh <dwalsh@redhat.com>,
	David Howells <dhowells@redhat.com>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110301213313.GA6507@albatros>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 1, 2011 at 4:33 PM, Vasiliy Kulikov <segoon@openwall.com> w=
rote:
> Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
> CAP_NET_ADMIN may load any module from /lib/modules/. =A0This doesn't=
 mean
> that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are
> limited to /lib/modules/**. =A0However, CAP_NET_ADMIN capability shou=
ldn't
> allow anybody load any module not related to networking.
>
> This patch restricts an ability of autoloading modules to netdev modu=
les
> with explicit aliases. =A0This fixes CVE-2011-1019.
>
> Arnd Bergmann suggested to leave untouched the old pre-v2.6.32 behavi=
or
> of loading netdev modules by name (without any prefix) for processes
> with CAP_SYS_MODULE to maintain the compatibility with network script=
s
> that use autoloading netdev modules by aliases like "eth0", "wlan0".
>
> Currently there are only three users of the feature in the upstream
> kernel: ipip, ip_gre and sit.

This patch is causing a bit of a problem in Fedora.  The problem lies
mostly in the fact that we, by means of using SELinux, grant very very
few domains CAP_SYS_MODULE (and we record when domains attempt to use
this permission).  Unlike most other distros in which uid=3D=3D0 is for
all intensive purposes =3D=3D CAP_FULL_SET and there is no logging of
failures to use capabilities.  What happened is that as soon as we
instituted this change we started getting SELinux denials because lots
of domains (libvirt, udev, iw, NetworkManager) all the sudden started
trying to use CAP_SYS_MODULE.  It took me a minute to make sure this
patch was the problem because I wasn't seeing any printk messages.  I
had to make some changes to the patch to print every time a task got
into the CAP_SYS_MODULE case in order to get an idea what was causing
the problem.  I found on my machine I hit the problem 3 times trying
to load "reg", "wifi0", and "virbr0"    None of these are actual
modules in userspace so the upcall failed.

I'm trying to figure out how I should be dealing with this.

My first idea is changing the capable(CAP_SYS_MODULE) into a
has_capability_noaudit().  Which will not audit the access attempt.
I'm not sure I like that since it uses the read cred, it doesn't set
PF_SUPERPRIV, and it means we could likely miss recording a problem if
a task is doing this intentionally...

The next idea is I guess figuring out what's causing these and fix
them there, but I'm not certain a good way to debug it.  I know from
our audit logs that wpa_supplicant is calling SIOCGIFINDEX which is
causing one of these, libvirt is calling SIOCGIFFLAGS.  I'm not sure
what udev->iw is doing to trigger it's problem.....

If the name in question is not coming from direct userspace request I
guess I need help figuring out what is causing them....

So while this patch might not necessarily be breaking things it
certainly is not regression free and could potentially be breaking
systems with fine grained capabilities controls....

-Eric

> =A0 =A0root@albatros:~# capsh --drop=3D$(seq -s, 0 11),$(seq -s, 13 3=
4) --
> =A0 =A0root@albatros:~# grep Cap /proc/$$/status
> =A0 =A0CapInh: =A0 =A0 0000000000000000
> =A0 =A0CapPrm: =A0 =A0 fffffff800001000
> =A0 =A0CapEff: =A0 =A0 fffffff800001000
> =A0 =A0CapBnd: =A0 =A0 fffffff800001000
> =A0 =A0root@albatros:~# modprobe xfs
> =A0 =A0FATAL: Error inserting xfs
> =A0 =A0(/lib/modules/2.6.38-rc6-00001-g2bf4ca3/kernel/fs/xfs/xfs.ko):=
 Operation not permitted
> =A0 =A0root@albatros:~# lsmod | grep xfs
> =A0 =A0root@albatros:~# ifconfig xfs
> =A0 =A0xfs: error fetching interface information: Device not found
> =A0 =A0root@albatros:~# lsmod | grep xfs
> =A0 =A0root@albatros:~# lsmod | grep sit
> =A0 =A0root@albatros:~# ifconfig sit
> =A0 =A0sit: error fetching interface information: Device not found
> =A0 =A0root@albatros:~# lsmod | grep sit
> =A0 =A0root@albatros:~# ifconfig sit0
> =A0 =A0sit0 =A0 =A0 =A0Link encap:IPv6-in-IPv4
> =A0 =A0 =A0 =A0 =A0 =A0 =A0NOARP =A0MTU:1480 =A0Metric:1
>
> =A0 =A0root@albatros:~# lsmod | grep sit
> =A0 =A0sit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A010457 =A00
> =A0 =A0tunnel4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2957 =A01 sit
>
> For CAP_SYS_MODULE module loading is still relaxed:
>
> =A0 =A0root@albatros:~# grep Cap /proc/$$/status
> =A0 =A0CapInh: =A0 =A0 0000000000000000
> =A0 =A0CapPrm: =A0 =A0 ffffffffffffffff
> =A0 =A0CapEff: =A0 =A0 ffffffffffffffff
> =A0 =A0CapBnd: =A0 =A0 ffffffffffffffff
> =A0 =A0root@albatros:~# ifconfig xfs
> =A0 =A0xfs: error fetching interface information: Device not found
> =A0 =A0root@albatros:~# lsmod | grep xfs
> =A0 =A0xfs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 745319 =A00
>
> Reference: https://lkml.org/lkml/2011/2/24/203
>
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> ---
> =A0v2 - use pr_err()
> =A0 =A0- don't try to load $name if netdev-$name is loaded
>
> =A0include/linux/netdevice.h | =A0 =A03 +++
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 ++++++++++--
> =A0net/ipv4/ip_gre.c =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0net/ipv4/ipip.c =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0net/ipv6/sit.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A05 files changed, 16 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d971346..71caf7a 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2392,6 +2392,9 @@ extern int netdev_notice(const struct net_devic=
e *dev, const char *format, ...)
> =A0extern int netdev_info(const struct net_device *dev, const char *f=
ormat, ...)
> =A0 =A0 =A0 =A0__attribute__ ((format (printf, 2, 3)));
>
> +#define MODULE_ALIAS_NETDEV(device) \
> + =A0 =A0 =A0 MODULE_ALIAS("netdev-" device)
> +
> =A0#if defined(DEBUG)
> =A0#define netdev_dbg(__dev, format, args...) =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0netdev_printk(KERN_DEBUG, __dev, format, ##args)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8ae6631..6561021 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1114,13 +1114,21 @@ EXPORT_SYMBOL(netdev_bonding_change);
> =A0void dev_load(struct net *net, const char *name)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *dev;
> + =A0 =A0 =A0 int no_module;
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0dev =3D dev_get_by_name_rcu(net, name);
> =A0 =A0 =A0 =A0rcu_read_unlock();
>
> - =A0 =A0 =A0 if (!dev && capable(CAP_NET_ADMIN))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 request_module("%s", name);
> + =A0 =A0 =A0 no_module =3D !dev;
> + =A0 =A0 =A0 if (no_module && capable(CAP_NET_ADMIN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 no_module =3D request_module("netdev-%s=
", name);
> + =A0 =A0 =A0 if (no_module && capable(CAP_SYS_MODULE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!request_module("%s", name))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Loading kernel =
module for a network device "
> +"with CAP_SYS_MODULE (deprecated). =A0Use CAP_NET_ADMIN and alias ne=
tdev-%s "
> +"instead\n", name);
> + =A0 =A0 =A0 }
> =A0}
> =A0EXPORT_SYMBOL(dev_load);
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 6613edf..d1d0e2c 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1765,4 +1765,4 @@ module_exit(ipgre_fini);
> =A0MODULE_LICENSE("GPL");
> =A0MODULE_ALIAS_RTNL_LINK("gre");
> =A0MODULE_ALIAS_RTNL_LINK("gretap");
> -MODULE_ALIAS("gre0");
> +MODULE_ALIAS_NETDEV("gre0");
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 988f52f..a5f58e7 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -913,4 +913,4 @@ static void __exit ipip_fini(void)
> =A0module_init(ipip_init);
> =A0module_exit(ipip_fini);
> =A0MODULE_LICENSE("GPL");
> -MODULE_ALIAS("tunl0");
> +MODULE_ALIAS_NETDEV("tunl0");
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 8ce38f1..d2c16e1 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -1290,4 +1290,4 @@ static int __init sit_init(void)
> =A0module_init(sit_init);
> =A0module_exit(sit_cleanup);
> =A0MODULE_LICENSE("GPL");
> -MODULE_ALIAS("sit0");
> +MODULE_ALIAS_NETDEV("sit0");
> --
> 1.7.0.4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
