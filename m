From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/3] net: Make interface aliases available for general usage
Date: Sun, 11 Jan 2015 21:52:49 +0100
Message-ID: <1421009571-5279-2-git-send-email-richard@nod.at>
References: <1421009571-5279-1-git-send-email-richard@nod.at>
Cc: coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, john.fastabend@gmail.com,
	herbert@gondor.apana.org.au, vyasevic@redhat.com, jiri@resnulli.us,
	vfalico@gmail.com, therbert@google.com, edumazet@google.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	kay@vrfy.org, stephen@networkplumber.org,
	Richard Weinberger <richard@nod.at>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421009571-5279-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow interface aliases to be used as regular interfaces.
Such that a command sequence like this one works:
$ ip l set eth0 alias internet
$ ip a s internet
$ tcpdump -n -i internet

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/netdevice.h   |  1 +
 include/net/net_namespace.h |  1 +
 net/core/dev.c              | 52 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 679e6e9..e00b4e2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1493,6 +1493,7 @@ struct net_device {
 	char			name[IFNAMSIZ];
 	struct hlist_node	name_hlist;
 	char 			*ifalias;
+	struct hlist_node	ifalias_hlist;
 	/*
 	 *	I/O specific fields
 	 *	FIXME: Merge these and struct ifmap into one
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2e8756b8..9fa0939 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -76,6 +76,7 @@ struct net {
 	struct list_head 	dev_base_head;
 	struct hlist_head 	*dev_name_head;
 	struct hlist_head	*dev_index_head;
+	struct hlist_head	*dev_ifalias_head;
 	unsigned int		dev_base_seq;	/* protected by rtnl_mutex */
 	int			ifindex;
 	unsigned int		dev_unreg_count;
diff --git a/net/core/dev.c b/net/core/dev.c
index 683d493..2551b03 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -202,6 +202,14 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 	return &net->dev_index_head[ifindex & (NETDEV_HASHENTRIES - 1)];
 }
 
+static inline struct hlist_head *dev_ifalias_hash(struct net *net,
+						  const char *ifalias)
+{
+	unsigned int hash = full_name_hash(ifalias, strnlen(ifalias, IFALIASZ));
+
+	return &net->dev_ifalias_head[hash_32(hash, NETDEV_HASHBITS)];
+}
+
 static inline void rps_lock(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
@@ -228,6 +236,9 @@ static void list_netdevice(struct net_device *dev)
 	hlist_add_head_rcu(&dev->name_hlist, dev_name_hash(net, dev->name));
 	hlist_add_head_rcu(&dev->index_hlist,
 			   dev_index_hash(net, dev->ifindex));
+	if (dev->ifalias)
+		hlist_add_head_rcu(&dev->ifalias_hlist,
+			   dev_ifalias_hash(net, dev->ifalias));
 	write_unlock_bh(&dev_base_lock);
 
 	dev_base_seq_inc(net);
@@ -245,6 +256,8 @@ static void unlist_netdevice(struct net_device *dev)
 	list_del_rcu(&dev->dev_list);
 	hlist_del_rcu(&dev->name_hlist);
 	hlist_del_rcu(&dev->index_hlist);
+	if (dev->ifalias)
+		hlist_del_rcu(&dev->ifalias_hlist);
 	write_unlock_bh(&dev_base_lock);
 
 	dev_base_seq_inc(dev_net(dev));
@@ -679,6 +692,11 @@ struct net_device *__dev_get_by_name(struct net *net, const char *name)
 		if (!strncmp(dev->name, name, IFNAMSIZ))
 			return dev;
 
+	head = dev_ifalias_hash(net, name);
+	hlist_for_each_entry(dev, head, ifalias_hlist)
+		if (dev->ifalias && !strncmp(dev->ifalias, name, IFALIASZ))
+			return dev;
+
 	return NULL;
 }
 EXPORT_SYMBOL(__dev_get_by_name);
@@ -704,6 +722,11 @@ struct net_device *dev_get_by_name_rcu(struct net *net, const char *name)
 		if (!strncmp(dev->name, name, IFNAMSIZ))
 			return dev;
 
+	head = dev_ifalias_hash(net, name);
+	hlist_for_each_entry_rcu(dev, head, ifalias_hlist)
+		if (dev->ifalias && !strncmp(dev->ifalias, name, IFALIASZ))
+			return dev;
+
 	return NULL;
 }
 EXPORT_SYMBOL(dev_get_by_name_rcu);
@@ -1169,6 +1192,20 @@ rollback:
 	return err;
 }
 
+static void __hlist_del_alias(struct net_device *dev)
+{
+	write_lock_bh(&dev_base_lock);
+	hlist_del_rcu(&dev->ifalias_hlist);
+	write_unlock_bh(&dev_base_lock);
+}
+
+static void __hlist_add_alias(struct net_device *dev)
+{
+	write_lock_bh(&dev_base_lock);
+	hlist_add_head_rcu(&dev->ifalias_hlist, dev_ifalias_hash(dev_net(dev), dev->ifalias));
+	write_unlock_bh(&dev_base_lock);
+}
+
 /**
  *	dev_set_alias - change ifalias of a device
  *	@dev: device
@@ -1189,15 +1226,24 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 	if (!len) {
 		kfree(dev->ifalias);
 		dev->ifalias = NULL;
+		__hlist_del_alias(dev);
 		return 0;
 	}
 
 	new_ifalias = krealloc(dev->ifalias, len + 1, GFP_KERNEL);
 	if (!new_ifalias)
 		return -ENOMEM;
+
+	if (dev->ifalias) {
+		__hlist_del_alias(dev);
+		synchronize_rcu();
+	}
+
 	dev->ifalias = new_ifalias;
 
 	strlcpy(dev->ifalias, alias, len+1);
+	__hlist_add_alias(dev);
+
 	return len;
 }
 
@@ -7150,8 +7196,14 @@ static int __net_init netdev_init(struct net *net)
 	if (net->dev_index_head == NULL)
 		goto err_idx;
 
+	net->dev_ifalias_head = netdev_create_hash();
+	if (net->dev_ifalias_head == NULL)
+		goto err_alias;
+
 	return 0;
 
+err_alias:
+	kfree(net->dev_index_head);
 err_idx:
 	kfree(net->dev_name_head);
 err_name:
-- 
1.8.4.5
