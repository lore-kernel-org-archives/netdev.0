From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v3 3/6] rtnetlink: add helper to dump ifalias
Date: Sat, 23 Sep 2017 23:21:24 +0200
Message-ID: <20170923212124.GD4324@breakpoint.cc>
References: <20170923192636.3932-1-fw@strlen.de>
 <20170923192636.3932-4-fw@strlen.de>
 <1506200690.29839.217.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:47010 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750839AbdIWVYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 17:24:48 -0400
Content-Disposition: inline
In-Reply-To: <1506200690.29839.217.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2017-09-23 at 21:26 +0200, Florian Westphal wrote:
> > Reviewed-by: David Ahern <dsahern@gmail.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Changes since v3: don't add rtnl assertion, I placed the assertion
> >  in my working tree instead as a reminder.
> > 
> >  net/core/rtnetlink.c | 11 +++++++++--
> >  1 file changed, 9 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> > index c801212ee40e..47c17c3de79a 100644
> > --- a/net/core/rtnetlink.c
> > +++ b/net/core/rtnetlink.c
> > @@ -1332,6 +1332,14 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
> >  	return nla_put_u32(skb, IFLA_LINK, ifindex);
> >  }
> >  
> > +static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
> 
> 
> Why noinline here ?
> 
> This function does not use stack at all (and that would call for
> noinline_for_stack )
> 
> > +{
> > +	if (dev->ifalias)
> > +		return nla_put_string(skb, IFLA_IFALIAS, dev->ifalias);
> > +
> > +	return 0;
> > +}
> > +
> 
> I really do not see the point of not making this RCU aware right away,
> or at least make it in the same patch series...

I saw no point to mix these refactoring with actual change :-|

(and it doesn't help either as-is with netlink dumping, only sysfs path can
 elide rtnl).

Subject: [PATCH net-next] net: core: decouple ifalias get/set from rtnl lock

Device alias can be set by either rtnetlink (rtnl is held) or sysfs.

rtnetlink holds rtnl mutex, sysfs acquires it for this purpose.
Add a new mutex for it plus a seqcount to get a consistent snapshot
of the alias buffer.

This allows the sysfs path to not take rtnl and would later allow
to not hold it when dumping ifalias.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h |  3 +-
 net/core/dev.c            | 70 +++++++++++++++++++++++++++++++++++++++--------
 net/core/net-sysfs.c      | 14 ++++------
 net/core/rtnetlink.c      |  7 +++--
 4 files changed, 70 insertions(+), 24 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1..0bcedb498f6f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1632,7 +1632,7 @@ enum netdev_priv_flags {
 struct net_device {
 	char			name[IFNAMSIZ];
 	struct hlist_node	name_hlist;
-	char 			*ifalias;
+	char 			__rcu *ifalias;
 	/*
 	 *	I/O specific fields
 	 *	FIXME: Merge these and struct ifmap into one
@@ -3275,6 +3275,7 @@ void __dev_notify_flags(struct net_device *, unsigned int old_flags,
 			unsigned int gchanges);
 int dev_change_name(struct net_device *, const char *);
 int dev_set_alias(struct net_device *, const char *, size_t);
+int dev_get_alias(const struct net_device *, char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int __dev_set_mtu(struct net_device *, int);
 int dev_set_mtu(struct net_device *, int);
diff --git a/net/core/dev.c b/net/core/dev.c
index 97abddd9039a..92d87b4a2db1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -188,6 +188,9 @@ static struct napi_struct *napi_by_id(unsigned int napi_id);
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+static DEFINE_MUTEX(ifalias_mutex);
+static seqcount_t ifalias_rename_seq;
+
 /* protects napi_hash addition/deletion and napi_gen_id */
 static DEFINE_SPINLOCK(napi_hash_lock);
 
@@ -1265,29 +1268,72 @@ int dev_change_name(struct net_device *dev, const char *newname)
  */
 int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 {
-	char *new_ifalias;
-
-	ASSERT_RTNL();
+	char *new_ifalias, *old_ifalias;
 
 	if (len >= IFALIASZ)
 		return -EINVAL;
 
+	mutex_lock(&ifalias_mutex);
+
+	old_ifalias = rcu_dereference_protected(dev->ifalias,
+						mutex_is_locked(&ifalias_mutex));
 	if (!len) {
-		kfree(dev->ifalias);
-		dev->ifalias = NULL;
-		return 0;
+		RCU_INIT_POINTER(dev->ifalias, NULL);
+		goto out;
 	}
 
-	new_ifalias = krealloc(dev->ifalias, len + 1, GFP_KERNEL);
-	if (!new_ifalias)
+	new_ifalias = __krealloc(old_ifalias, len + 1, GFP_KERNEL);
+	if (!new_ifalias) {
+		mutex_unlock(&ifalias_mutex);
 		return -ENOMEM;
-	dev->ifalias = new_ifalias;
-	memcpy(dev->ifalias, alias, len);
-	dev->ifalias[len] = 0;
+	}
 
+	if (new_ifalias == old_ifalias) {
+		write_seqcount_begin(&ifalias_rename_seq);
+		memcpy(new_ifalias, alias, len);
+		new_ifalias[len] = 0;
+		write_seqcount_end(&ifalias_rename_seq);
+		mutex_unlock(&ifalias_mutex);
+		return len;
+	}
+
+	memcpy(new_ifalias, alias, len);
+	new_ifalias[len] = 0;
+
+	rcu_assign_pointer(dev->ifalias, new_ifalias);
+out:
+	mutex_unlock(&ifalias_mutex);
+	if (old_ifalias) {
+		synchronize_net();
+		kfree(old_ifalias);
+	}
 	return len;
 }
 
+int dev_get_alias(const struct net_device *dev, char *alias, size_t len)
+{
+	unsigned int seq;
+	int ret;
+
+	for (;;) {
+		const char *name;
+
+		ret = 0;
+		rcu_read_lock();
+		name = rcu_dereference(dev->ifalias);
+		seq = raw_seqcount_begin(&ifalias_rename_seq);
+		if (name)
+			ret = snprintf(alias, len, "%s", name);
+		rcu_read_unlock();
+
+		if (!read_seqcount_retry(&ifalias_rename_seq, seq))
+			break;
+
+		cond_resched();
+	}
+
+	return ret;
+}
 
 /**
  *	netdev_features_change - device changes features
@@ -8749,6 +8795,8 @@ static int __init net_dev_init(void)
 				       NULL, dev_cpu_dead);
 	WARN_ON(rc < 0);
 	rc = 0;
+
+	seqcount_init(&ifalias_rename_seq);
 out:
 	return rc;
 }
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 927a6dcbad96..530de7996d65 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -391,10 +391,7 @@ static ssize_t ifalias_store(struct device *dev, struct device_attribute *attr,
 	if (len >  0 && buf[len - 1] == '\n')
 		--count;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
 	ret = dev_set_alias(netdev, buf, count);
-	rtnl_unlock();
 
 	return ret < 0 ? ret : len;
 }
@@ -403,13 +400,12 @@ static ssize_t ifalias_show(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
 	const struct net_device *netdev = to_net_dev(dev);
+	char tmp[IFALIASZ];
 	ssize_t ret = 0;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-	if (netdev->ifalias)
-		ret = sprintf(buf, "%s\n", netdev->ifalias);
-	rtnl_unlock();
+	ret = dev_get_alias(netdev, tmp, sizeof(tmp));
+	if (ret > 0)
+		ret = sprintf(buf, "%s\n", tmp);
 	return ret;
 }
 static DEVICE_ATTR_RW(ifalias);
@@ -1488,7 +1484,7 @@ static void netdev_release(struct device *d)
 
 	BUG_ON(dev->reg_state != NETREG_RELEASED);
 
-	kfree(dev->ifalias);
+	dev_set_alias(dev, "", 0);
 	netdev_freemem(dev);
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c69451964a44..bab108ced7d8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1368,10 +1368,11 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
 
 static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
 {
-	if (dev->ifalias)
-		return nla_put_string(skb, IFLA_IFALIAS, dev->ifalias);
+	char buf[IFALIASZ];
+	int ret;
 
-	return 0;
+	ret = dev_get_alias(dev, buf, sizeof(buf));
+	return ret > 0 ? nla_put_string(skb, IFLA_IFALIAS, buf) : 0;
 }
 
 static noinline int rtnl_fill_link_netnsid(struct sk_buff *skb,
-- 
2.13.5
