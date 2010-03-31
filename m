From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Wed, 31 Mar 2010 02:39:14 -0700
Message-ID: <m1oci4zv7h.fsf@fess.ebiederm.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<1269973889-25260-3-git-send-email-ebiederm@xmission.com>
	<4BB2F083.1050803@kernel.org> <m11vf12ayb.fsf@fess.ebiederm.org>
	<4BB30520.2030100@kernel.org> <4BB30644.9090809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: Tejun Heo <htejun@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BB30644.9090809@gmail.com> (Tejun Heo's message of "Wed\, 31 Mar 2010 17\:22\:28 +0900")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo <htejun@gmail.com> writes:

> Just wanna add a bit more.
>
> On 03/31/2010 05:17 PM, Tejun Heo wrote:
>> If you think all those callbacks are absolute necessities, can you
>> please at least add boatload of comments around them explaning what
>> they're meant to do and how they're gonna be used?  It's probably
>> because I don't have any experience with namespaces but I really can't
>> wrap my head around it as it currently stands.
>
> The reason why I talked about proper layering is the same reason.
> It's very difficult to review your code because I have no idea how
> those callbacks are meant to be used and gonna behave and that lowers
> maintainability significantly in the long run.  If at all possible,
> please make it implement a discrete function which is used to
> implement something higher up.  If it's already done like that and I'm
> just being stupid, please feel free to enlighten me.

Apologies.   There is a fine line between sending enough patches
to give context and completely overwhelming people with patches,
and of course by this time I am so accustomed to this code I am
practically blind to it.

Let me try a happy median between overwhelming and too little
information by giving you some experts, and a bit of overview.

(Ugh after have writing this I certainly will agree that we
 have some many layers in the device model that they become
 obfuscating abstractions).

Looking through my code there are 3 types of callbacks.
- Callbacks to the namespace type of a children.
  .child_ns_type
- Callbacks to find the namespace of a kobject.
  .namespace
- Callbacks on the a namespace type to find the namespace
  of a particular context.
  .current_ns
  .initial_ns  (not used in my patchset)
  .netlink_ns  (not used in my patchset)


In a world of weird explicitness I expect .child_ns_type and
.namespace could be made to go away by pushing through explicit
ns_type, and namespace parameters everywhere. But that seems
like an awful lot of unnecessary code churn and bloat with
the only real advantage being that we have an abstraction
stored explicit at each layer.

I use child_ns_type to see if a directory should be tagged
and to figure out the type of the tags on a sysfs directory.

I use current_ns to capture the namespace (of ns_type) of the
current process when sysfs is mounted so I know what to show
userspace.

I use ktype->namespace to figure out which namespace a given
kobject's name is in.

There are intermediate steps on those methods but that is
just what appears to be the necessary boilerplate to get
from a class down to a kobject.

The nstype callbacks initial_ns and netlink_ns are not used in this
patchset.  Instead they play a role in the filtering of events sent to
userspace.

netlink_ns is used to find the namespace of a netlink socket
to see if it is ok to send an event over a netlink socket.

static int kobj_bcast_filter(struct sock *dest_sk, struct sk_buff *skb, void *data)
{
	struct kobject *kobj = data;
	const struct kobj_ns_type_operations *ops;

	ops = kobj_ns_ops(kobj);
	if (ops) {
		const void *sock_ns, *ns;
		ns = kobj->ktype->namespace(kobj);
		sock_ns = ops->netlink_ns(dsk);
		return sock_ns != ns;
	}

	return 0;
}

initial_ns is used to figure out what the initial/default
namespace is for a class of namespaces.  We only report
with /sbin/hotplug events in the initial network namespace.
At least for now.

static int kobj_usermode_filter(struct kobject *kobj)
{
	const struct kobj_ns_type_operations *ops;

	ops = kobj_ns_ops(kobj);
	if (ops) {
		const void *init_ns, *ns;
		ns = kobj->ktype->namespace(kobj);
		init_ns = ops->initial_ns();
		return ns != init_ns;
	}

	return 0;
}

This is my change that adds support for the network namespace.
The only namespace I expect to add support for in the short term.

I hope this helps,

Eric


commit fdc0adeaa8bfab9a179e1eb349cab400ddb70403
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Thu Jul 3 16:13:11 2008 -0600

    netns: Teach network device kobjects which namespace they are in.

    The problem.  Network devices show up in sysfs and with the network
    namespace active multiple devices with the same name can show up in
    the same directory, ouch!

    To avoid that problem and allow existing applications in network namespaces
    to see the same interface that is currently presented in sysfs, this
    patch enables the tagging directory support in sysfs.

    By using the network namespace pointers as tags to separate out the
    the sysfs directory entries we ensure that we don't have conflicts
    in the directories and applications only see a limited set of
    the network devices.

    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

diff --git a/include/linux/kobject.h b/include/linux/kobject.h
index d9456f6..9452e39 100644
--- a/include/linux/kobject.h
+++ b/include/linux/kobject.h
@@ -138,6 +138,7 @@ extern const struct sysfs_ops kobj_sysfs_ops;

 enum kobj_ns_type {
 	KOBJ_NS_TYPE_NONE = 0,
+	KOBJ_NS_TYPE_NET,
 	KOBJ_NS_TYPES
 };

diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..265e33b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -45,6 +45,14 @@ config COMPAT_NETLINK_MESSAGES

 menu "Networking options"

+config NET_NS
+	bool "Network namespace support"
+	default n
+	depends on EXPERIMENTAL && NAMESPACES
+	help
+	  Allow user space to create what appear to be multiple instances
+	  of the network stack.
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 099c753..1b98e36 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -13,7 +13,9 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
+#include <linux/nsproxy.h>
 #include <net/sock.h>
+#include <net/net_namespace.h>
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
 #include <net/wext.h>
@@ -466,6 +468,37 @@ static struct attribute_group wireless_group = {
 };
 #endif

+static const void *net_current_ns(void)
+{
+	return current->nsproxy->net_ns;
+}
+
+static const void *net_initial_ns(void)
+{
+	return &init_net;
+}
+
+static const void *net_netlink_ns(struct sock *sk)
+{
+	return sock_net(sk);
+}
+
+static struct kobj_ns_type_operations net_ns_type_operations = {
+	.type = KOBJ_NS_TYPE_NET,
+	.current_ns = net_current_ns,
+	.netlink_ns = net_netlink_ns,
+	.initial_ns = net_initial_ns,
+};
+
+static void net_kobj_ns_exit(struct net *net)
+{
+	kobj_ns_exit(KOBJ_NS_TYPE_NET, net);
+}
+
+static struct pernet_operations sysfs_net_ops = {
+	.exit = net_kobj_ns_exit,
+};
+
 #endif /* CONFIG_SYSFS */

 #ifdef CONFIG_HOTPLUG
@@ -506,6 +539,13 @@ static void netdev_release(struct device *d)
 	kfree((char *)dev - dev->padded);
 }

+static const void *net_namespace(struct device *d)
+{
+	struct net_device *dev;
+	dev = container_of(d, struct net_device, dev);
+	return dev_net(dev);
+}
+
 static struct class net_class = {
 	.name = "net",
 	.dev_release = netdev_release,
@@ -515,6 +555,8 @@ static struct class net_class = {
 #ifdef CONFIG_HOTPLUG
 	.dev_uevent = netdev_uevent,
 #endif
+	.ns_type = &net_ns_type_operations,
+	.namespace = net_namespace,
 };

 /* Delete sysfs entries but hold kobject reference until after all
@@ -587,5 +629,9 @@ void netdev_initialize_kobject(struct net_device *net)

 int netdev_kobject_init(void)
 {
+	kobj_ns_type_register(&net_ns_type_operations);
+#ifdef CONFIG_SYSFS
+	register_pernet_subsys(&sysfs_net_ops);
+#endif
 	return class_register(&net_class);
 }
