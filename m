From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't remove
Date: Thu, 22 Jul 2010 04:27:02 -0700
Message-ID: <m1sk3bycxl.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<1279792459.12439.0.camel@jlt3.sipsolutions.net>
	<m139vb25nz.fsf@fess.ebiederm.org>
	<1279793435.12439.3.camel@jlt3.sipsolutions.net>
	<m1mxtjztvy.fsf@fess.ebiederm.org>
	<1279795286.12439.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56660 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563Ab0GVL1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 07:27:10 -0400
In-Reply-To: <1279795286.12439.8.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Thu\, 22 Jul 2010 12\:41\:26 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Thu, 2010-07-22 at 03:35 -0700, Eric W. Biederman wrote:
>
>> >> The warning patch just makes things fail faster.  Although I get some of the
>> >> wireless interfaces for hwsim when I use this one.
>> >
>> > Hmm, I didn't.
>> 
>> To be clear I just get hwsim0.  Not wlan0 or wlan1.
>
> Ah, yes, but that's just a regular netdev, you can pretty much ignore
> it. It just shows all hwsim traffic as it is on the "air" for sniffing.
>
>> > Right, it actually starts working again with that patch you sent.
>> > However, netns support is really broken:
>> >
>> > <create net namespace, put phy0/wlan0 into it>
>> 
>> Do we have a convenient command line tool to do this?
>> I remember there being a different netlink message from
>> normal network devices.
>
> iw phy0 set netns <pid>
>
> http://git.sipsolutions.net/iw.git
>
>> > root@kvm:~# ip link
>> > 3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
>> >     link/ether 02:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
>> > 7: lo: <LOOPBACK> mtu 16436 qdisc noop state DOWN 
>> >     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>> > root@kvm:~# ls /sys/class/net/
>> > eth0  hwsim0  lo  wlan1  wlan2
>> 
>> I think this is actually the output of something working.
>> 
>> I expect after you created a new netns you didn't mount
>> a new instance of /sys.  /sys remembers which netns you
>> had when you mounted it.  So you have to mount /sys again
>> so you can see the /sys/class/net for the network namespace
>> you are in.
>
> Ohh, oops! I saw all the "current->" references in the code and somehow
> expected the same instance of sysfs to show the right thing.
>
> Yes, it works now. But the patch below doesn't seem to work, am I
> missing something?

You are trying to move the phy devices as well?

My guess is that at least part of the problem is that you don't have a
ieee80211 directory under hwsim.

My apologies for not thinking about the peculiarities of the wireless
drivers.

Eric


> ---
>  include/linux/netdevice.h |    2 ++
>  net/core/net-sysfs.c      |    3 ++-
>  net/wireless/sysfs.c      |    9 +++++++++
>  3 files changed, 13 insertions(+), 1 deletion(-)
>
> --- wireless-testing.orig/include/linux/netdevice.h	2010-07-22 10:01:22.000000000 +0200
> +++ wireless-testing/include/linux/netdevice.h	2010-07-22 10:11:00.000000000 +0200
> @@ -2148,6 +2148,8 @@ extern void dev_seq_stop(struct seq_file
>  extern int netdev_class_create_file(struct class_attribute *class_attr);
>  extern void netdev_class_remove_file(struct class_attribute *class_attr);
>  
> +extern struct kobj_ns_type_operations net_ns_type_operations;
> +
>  extern char *netdev_drivername(const struct net_device *dev, char *buffer, int len);
>  
>  extern void linkwatch_run_queue(void);
> --- wireless-testing.orig/net/core/net-sysfs.c	2010-07-22 10:01:22.000000000 +0200
> +++ wireless-testing/net/core/net-sysfs.c	2010-07-22 10:11:51.000000000 +0200
> @@ -785,12 +785,13 @@ static const void *net_netlink_ns(struct
>  	return sock_net(sk);
>  }
>  
> -static struct kobj_ns_type_operations net_ns_type_operations = {
> +struct kobj_ns_type_operations net_ns_type_operations = {
>  	.type = KOBJ_NS_TYPE_NET,
>  	.current_ns = net_current_ns,
>  	.netlink_ns = net_netlink_ns,
>  	.initial_ns = net_initial_ns,
>  };
> +EXPORT_SYMBOL_GPL(net_ns_type_operations);
>  
>  static void net_kobj_ns_exit(struct net *net)
>  {
> --- wireless-testing.orig/net/wireless/sysfs.c	2010-07-22 10:01:22.000000000 +0200
> +++ wireless-testing/net/wireless/sysfs.c	2010-07-22 10:13:08.000000000 +0200
> @@ -110,6 +110,13 @@ static int wiphy_resume(struct device *d
>  	return ret;
>  }
>  
> +static const void *wiphy_namespace(struct device *d)
> +{
> +	struct wiphy *wiphy = container_of(d, struct wiphy, dev);
> +
> +	return wiphy_net(wiphy);
> +}
> +
>  struct class ieee80211_class = {
>  	.name = "ieee80211",
>  	.owner = THIS_MODULE,
> @@ -120,6 +127,8 @@ struct class ieee80211_class = {
>  #endif
>  	.suspend = wiphy_suspend,
>  	.resume = wiphy_resume,
> +	.ns_type = &net_ns_type_operations,
> +	.namespace = wiphy_namespace,
>  };
>  
>  int wiphy_sysfs_init(void)
