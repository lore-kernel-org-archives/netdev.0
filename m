From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC] [PATCH] Network Events Connector
Date: Thu, 15 Mar 2007 01:50:21 +0100
Message-ID: <m2zm6f5nzm.fsf@cerbere.dyndns.info>
References: <m2irecym8t.fsf@cerbere.dyndns.info>
	<20070217163422.GB22369@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 119.235.97-84.rev.gaoland.net ([84.97.235.119]:41556 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422787AbXCOAuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 20:50:23 -0400
In-Reply-To: <20070217163422.GB22369@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Sat, 17 Feb 2007 19:34:22 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> On Fri, Feb 09, 2007 at 05:43:14AM +0100, Samir Bellabes (sam@synack.fr) wrote:
>> Hi,
>> 
>> Here is a new feature which can help firewalls to be more application
>> aware, so more useful for people.
>> 
>> Our previous discussion about cn_net and firewalls:
>> http://marc2.theaimsgroup.com/?t=115976957500002&r=1&w=2
>> 
>> Please, I would really like to have feedback and comments on that tool,
>> in order to improve it.
>
> Technical side does have problems.
> 1. your way to delete and check events is wrong - there is no need to
> allocate new event and search for it in the hash table to remove - use
> values as is.
> 3. why hash table and not rb tree?

You are right, I have rewrite this part of the system, using rbtree

Here is patch to apply on top of the previous 'initialisation path'
patch.

commit 5110880bc67e8329671ffa596cd899995c05ec82
Author: Samir Bellabes <sam@synack.fr>
Date:   Thu Mar 15 01:42:48 2007 +0100

    [PATCH] cn_net: store event's configuration in RB tree
    
    Noticed by Evgeniy Polyakov <johnpol@2ka.mipt.ru>
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/drivers/connector/cn_net.c b/drivers/connector/cn_net.c
index c9eb53e..a15f67b 100644
--- a/drivers/connector/cn_net.c
+++ b/drivers/connector/cn_net.c
@@ -22,7 +22,7 @@ #include <net/inet_sock.h>
 #include <linux/in.h>
 #include <linux/ipv6.h>
 #include <linux/in6.h>
-#include <linux/jhash.h>
+#include <linux/rbtree.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/random.h>
@@ -34,10 +34,8 @@ static struct cb_id cn_net_event_id = { 
 static char cn_net_event_name[] = "cn_net_event";
 static int secondary = 0;
 
-static struct list_head *hash = NULL;
-static rwlock_t hash_lock = RW_LOCK_UNLOCKED;
-static int hash_size = 4;
-module_param(hash_size, uint, 0600);
+struct rb_root event_tree = RB_ROOT;
+static rwlock_t event_lock = RW_LOCK_UNLOCKED;
 
 #if defined(CONFIG_NET_EVENTS)
 #define MY_NAME THIS_MODULE->name
@@ -61,172 +59,198 @@ static unsigned int is_same_event(struct
 }
 
 /**
- * check_event()
- * look for a match in the hash table
- * Returns 1 if data is in the hash table
+ * lookup_event()
+ * look for a match in the rbtree
+ * returns address of the wanted element if it is in the rbtree, or NULL
  */
-static unsigned int check_event(struct event_list *data) {
-	unsigned int err = 0, h = 0;
-	struct list_head *l;
-	struct event_list *evl;
-
-	h = jhash(&(data->ev), sizeof(struct event), 0) % hash_size;
-
-	read_lock(&hash_lock);
-	l = &hash[h];
-	list_for_each_entry(evl, l, list) {
-		if (is_same_event(evl->ev, data->ev)) {
-			err = 1;
-			break;
+static struct event_node *lookup_event(struct event ev) {
+	struct rb_node *rb_node = event_tree.rb_node;
+
+	read_lock(&event_lock);
+
+	while (rb_node) {
+		struct event_node *cur = rb_entry(rb_node, struct event_node, ev_node);
+		
+		if (is_same_event(cur->ev, ev)) {
+			read_unlock(&event_lock);
+			return cur;
 		}
+
+		if (ev.syscall_num < cur->ev.syscall_num)
+			rb_node = rb_node->rb_left;
+		else if (ev.syscall_num > cur->ev.syscall_num)
+			rb_node = rb_node->rb_right;
+		else if (ev.protocol < cur->ev.protocol)
+			rb_node = rb_node->rb_left;
+		else if (ev.protocol > cur->ev.protocol)
+			rb_node = rb_node->rb_right;
 	}
-	read_unlock(&hash_lock);
-	return err;
+
+	read_unlock(&event_lock);
+	return NULL;
 }
 
-/**
- * check_wanted_data
- * We don't send unwanted informations to userspace, according to the
- * dynamic configuration in the hash table.
- * @sock: sock which is changing its state
- * Returns: 1 if data have to be send to userspace
+/** 
+ * check_wanted_data()
+ * we don't send unwanted informations to userspace, according to the
+ * dynamic configuration in the rbtree
  */
-static int check_wanted_data(struct sock *sk, enum cn_net_socket syscall_num) {
-	struct event_list *data = NULL;
-	unsigned int err = 0;
-
-	if (!sk)
-		return -EINVAL;
+static int check_wanted_event(struct sock *sk, enum cn_net_socket syscall_num) {
+	int err = -EINVAL;
+	struct event ev;
 	
-	data = kzalloc(sizeof(struct event_list), GFP_KERNEL);
-	if (!data)
-		return -ENOMEM;
-	data->ev.syscall_num = syscall_num;
-	data->ev.protocol = sk->sk_protocol;
-	INIT_LIST_HEAD(&(data->list));
+	if (!sk)
+		return err;
 
+	ev.syscall_num = syscall_num;
+	ev.protocol = sk->sk_protocol;
+	       
 	/* check if the event is already registered */
-	err = check_event(data);
-	kfree(data);
+	if (lookup_event(ev))
+		err = 0;
+
 	return err;
 }
 
 /**
- * dump_event() dumps the entire hash_table in log
+ * dump_event()
+ * dump the entire rbtree in log
  */
-static void dump_event(struct list_head *hash) {
-	unsigned int i = 0;
-	struct list_head *l = NULL;
-	struct event_list *evl = NULL;
-	
-	read_lock(&hash_lock);
-	for (i = 0; i < hash_size; i++) {
-		l = &hash[i];
-		printk(KERN_INFO "----\n");
-		printk(KERN_INFO "%d.\n", i);
-		list_for_each_entry(evl, l, list) {
-			printk(KERN_INFO " %d:%s\n",
-			       evl->ev.protocol, syscall_name[evl->ev.syscall_num]);
-		}
-	}
-	read_unlock(&hash_lock);
-
-	return;
+static void dump_event(void) {
+	struct rb_node *p = NULL ;
+	struct event_node *tmp = NULL;
+
+	read_lock(&event_lock);
+	p = rb_first(&event_tree);
+	while (p) {
+		tmp = rb_entry(p, struct event_node, ev_node);
+		printk(KERN_INFO "%d:%s\n",
+		       tmp->ev.protocol, syscall_name[tmp->ev.syscall_num]);
+		p = rb_next(p);
+	};
+	read_unlock(&event_lock);
 }
 
 /**
- * deletion of all elements in the hashtable
+ * remove_all_event()
+ * delete all events registered in the rbtree
  */
-static enum ack_err clean_all_event(struct list_head *hash) {
-	unsigned int i = 0;
-	struct event_list *evl = NULL;
-	
-	write_lock(&hash_lock);
-	for (i = 0; i < hash_size; i++) {
-		while(!list_empty(&hash[i])) {
-			evl = list_entry(hash[i].next, struct event_list, list);
-			if (evl) {
-				list_del(&evl->list);
-				kfree(evl);
-			}
-		}
+static enum ack_err remove_all_event(void) {
+	struct rb_node *p = NULL;
+	struct event_node *cur = NULL;
+
+	write_lock(&event_lock);	
+	while ((p = rb_first(&event_tree)) != NULL) {
+		cur = rb_entry(p, struct event_node, ev_node);
+		rb_erase(p, &event_tree);
+		kfree(cur);
 	}
-	write_unlock(&hash_lock);
-	/* hash table is now empty */
+	write_unlock(&event_lock);
+
+	/* rbtree is now empty */
 	return CN_NET_ACK_SUCCES;
 }
 
-/**
- * add a entry to the hash table
- * we are checking if we register a same event twice
+/** 
+ * alloc_event()
+ * alloc memory for a event_node, and return pointer to it
  */
-static enum ack_err add_event(struct list_head *hash, struct event ev) {
+static struct event_node *alloc_event(void) {
+	struct event_node *evn = NULL;
+	evn = kzalloc(sizeof(struct event_node), GFP_KERNEL);
+	return evn;
+}
 
-	struct event_list *data = NULL;
-	unsigned int h = 0;
-	enum ack_err err = CN_NET_ACK_SUCCES;
-	
-	data = kzalloc(sizeof(struct event_list), GFP_KERNEL);
-	if (!data) {
-		err = CN_NET_ACK_ENOMEM;
-		return err;
+/**
+ * insert_event()
+ * insert a event in the rbtree
+ * we are checking if we are trying to register a same event twice
+ */
+static enum ack_err insert_event(struct event ev) {
+	struct rb_node **rb_link, *rb_parent;
+	struct event_node *new_evn;
+	enum ack_err ret = CN_NET_ACK_SUCCES;
+
+	rb_link = &event_tree.rb_node;
+	rb_parent = NULL;
+
+	write_lock(&event_lock);
+
+	while(*rb_link) {
+		struct event_node *tmp;
+
+		rb_parent = *rb_link;
+		tmp = rb_entry(rb_parent, struct event_node, ev_node);
+		
+		if (ev.syscall_num < tmp->ev.syscall_num)
+			rb_link = &rb_parent->rb_left;
+		else if (ev.syscall_num > tmp->ev.syscall_num)
+			rb_link = &rb_parent->rb_right;
+		else if (ev.protocol < tmp->ev.protocol)
+			rb_link = &rb_parent->rb_left;
+		else if (ev.protocol > tmp->ev.protocol)
+			rb_link = &rb_parent->rb_right;
+		else {
+			/* event is already registered */
+			ret = CN_NET_ACK_EINCONFIG;
+			goto out;
+		}
 	}
-	data->ev.syscall_num = ev.syscall_num;
-	data->ev.protocol = ev.protocol;
-	INIT_LIST_HEAD(&(data->list));
 
-	/* check if the event is already registered */
-	if (check_event(data)) {
-		kfree(data);
-		err = CN_NET_ACK_EINCONFIG;
-		return err;
+	/* no match: event is added to the tree */
+	if ((new_evn = alloc_event()) != NULL) {
+		new_evn->ev.syscall_num = ev.syscall_num;
+		new_evn->ev.protocol = ev.protocol;
+	} else {
+		/* can't allocate memory, exiting */
+		ret = CN_NET_ACK_ENOMEM;
+		goto out;
 	}
-	h = jhash(&(data->ev), sizeof(struct event), 0) % hash_size;
 
-	write_lock(&hash_lock);
-	list_add_tail(&data->list, &hash[h]);
-	write_unlock(&hash_lock);
+	rb_link_node(&new_evn->ev_node, rb_parent, rb_link);
+	rb_insert_color(&new_evn->ev_node, &event_tree);
 
-	return err;
+out:
+	write_unlock(&event_lock);
+	return ret;
 }
 
 /**
- * delete a entry from the hash table
- * we are checking if we delete a unregistered event
+ * remove_event()  
+ * delete a entry from the rbtree
+ * we are checking if we are trying to delete a unregistered event
  */
-static enum ack_err del_event(struct list_head *hash, struct event ev) {
-	
-	struct event_list *data;
-	unsigned int h = 0;
-	enum ack_err err = CN_NET_ACK_EINCONFIG;
-	struct list_head *l = NULL;
-	struct event_list *evl = NULL;
-
-	data = kzalloc(sizeof(struct event_list), GFP_KERNEL);
-	if (!data) {
-		err = CN_NET_ACK_ENOMEM;
-		return err;
-	}
-	data->ev.syscall_num = ev.syscall_num;
-	data->ev.protocol = ev.protocol;
-	INIT_LIST_HEAD(&(data->list));
-
-	h = jhash(&(data->ev), sizeof(struct event), 0) % hash_size;
-
-	write_lock(&hash_lock);
-	l = &hash[h];
-	list_for_each_entry(evl, l, list) {
-		if (is_same_event(evl->ev, data->ev)) {
-			list_del(&evl->list);
-			kfree(evl);
-			err = CN_NET_ACK_SUCCES;
+static enum ack_err remove_event(struct event ev) {
+	struct event_node *cur = NULL;
+	enum ack_err ret = CN_NET_ACK_EINCONFIG;
+	struct rb_node *rb_node = event_tree.rb_node;
+
+	write_lock(&event_lock);
+
+	while (rb_node) {
+		cur = rb_entry(rb_node, struct event_node, ev_node);
+		
+		if (is_same_event(cur->ev, ev))
 			break;
-		}
+
+		if (ev.syscall_num < cur->ev.syscall_num)
+			rb_node = rb_node->rb_left;
+		else if (ev.syscall_num > cur->ev.syscall_num)
+			rb_node = rb_node->rb_right;
+		else if (ev.protocol < cur->ev.protocol)
+			rb_node = rb_node->rb_left;
+		else if (ev.protocol > cur->ev.protocol)
+			rb_node = rb_node->rb_right;
 	}
-	write_unlock(&hash_lock);
-	kfree(data);
 
-	return err;
+	if (rb_node) {
+		rb_erase(&cur->ev_node, &event_tree);
+		kfree(cur);
+		ret = CN_NET_ACK_SUCCES;
+	}
+	write_unlock(&event_lock);
+
+	return ret;
 }
 
 /**
@@ -261,13 +285,13 @@ static enum ack_err do_config(struct msg
 
 	switch (cfg->config_cmd) {
 	case CN_NET_CONFIG_ADD:
-		err = add_event(hash, cfg->ev);
+		err = insert_event(cfg->ev);
 		break;
 	case CN_NET_CONFIG_DEL:
-		err = del_event(hash, cfg->ev);
+		err= remove_event(cfg->ev);
 		break;
 	case CN_NET_CONFIG_FLUSH:
-		err = clean_all_event(hash);
+		err = remove_all_event();
 		break;
 	default:
 		err = CN_NET_ACK_EINTYPE;
@@ -353,8 +377,8 @@ void cn_net_ctl(void *data) {
 	case CN_NET_IGNORE:     /* userspace is unregistering */
 		atomic_dec(&net_event_num_listeners);
 		break;
-	case CN_NET_DUMP:     /* dumping hash table -- debug purpose */
-		dump_event(hash);
+	case CN_NET_DUMP:     /* dumping the rbtree -- debug purpose */
+		dump_event();
 		break;
 	default:
 		err = CN_NET_ACK_EINTYPE;
@@ -485,7 +509,7 @@ out:
 static int cn_net_socket_listen(struct socket *sock, int backlog) {
 
 	DEBUGP(KERN_INFO "cn_net_socket_listen\n");
-	if (check_wanted_data(sock->sk, CN_NET_SOCKET_LISTEN) > 0)
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_LISTEN) == NULL)
 		cn_net_send_event(sock->sk, NULL, CN_NET_SOCKET_LISTEN);
 
 	return 0;
@@ -495,7 +519,7 @@ static int cn_net_socket_bind(struct soc
 			      struct sockaddr *address, int addrlen) {
 
 	DEBUGP(KERN_INFO "cn_net_socket_bind\n");
-	if (check_wanted_data(sock->sk, CN_NET_SOCKET_BIND) > 0)
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_BIND) == NULL)
 		cn_net_send_event(sock->sk, address, CN_NET_SOCKET_BIND);
 
 	return 0;
@@ -504,7 +528,7 @@ static int cn_net_socket_bind(struct soc
 static int cn_net_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen) {
 	
 	DEBUGP(KERN_INFO "cn_net_socket_connect\n");
-	if (check_wanted_data(sock->sk, CN_NET_SOCKET_CONNECT) > 0)
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_CONNECT) == NULL)
 		cn_net_send_event(sock->sk, address, CN_NET_SOCKET_CONNECT);
 
 	return 0;
@@ -513,7 +537,7 @@ static int cn_net_socket_connect(struct 
 static int cn_net_socket_shutdown(struct socket *sock, int how) {
 
 	DEBUGP(KERN_INFO "cn_net_socket_shutdown\n");
-	if (check_wanted_data(sock->sk, CN_NET_SOCKET_SHUTDOWN) > 0)
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_SHUTDOWN) == NULL)
 		cn_net_send_event(sock->sk, NULL, CN_NET_SOCKET_SHUTDOWN);
 
 	return 0;
@@ -522,7 +546,7 @@ static int cn_net_socket_shutdown(struct
 static int cn_net_sk_free_security(struct sock *sk) {
 	
 	DEBUGP(KERN_INFO "cn_net_sk_free_security\n");
-	if (check_wanted_data(sk, CN_NET_SK_FREE_SECURITY) > 0)
+	if (check_wanted_event(sk, CN_NET_SK_FREE_SECURITY) == NULL)
 		cn_net_send_event(sk, NULL, CN_NET_SK_FREE_SECURITY);
 
 	return 0;
@@ -537,17 +561,7 @@ static struct security_operations cn_net
 };
 
 static int __init init(void) {
-	int err = 0, i = 0;
-
-	hash = kzalloc(sizeof(struct list_head) * hash_size, GFP_KERNEL);
-	if (!hash) {
-		printk(KERN_WARNING "cn_net: Failure can't alloc memory for hash\n");
-		err = -ENOMEM;
-		goto out;
-	}
-	
-	for (i = 0; i < hash_size; i++)
-		INIT_LIST_HEAD(&(hash[i]));
+	int err = 0;
 
 	err = cn_add_callback(&cn_net_event_id, cn_net_event_name, &cn_net_ctl);
 	if (err) {
@@ -574,9 +588,6 @@ out_security:
 	cn_del_callback(&cn_net_event_id);
 
 out_callback:
-	kfree(hash);
-
-out:
 	return err;
 }
 
@@ -594,10 +605,7 @@ static void __exit fini(void) {
 	cn_del_callback(&cn_net_event_id);
 	
 	/* clean memory */
-	if (hash) {
-		clean_all_event(hash);
-		kfree(hash);
-	}
+	remove_all_event();
 
 	printk(KERN_INFO "cn_net: network events module unloaded\n");
 }
diff --git a/include/linux/cn_net.h b/include/linux/cn_net.h
index 6604053..0d86715 100644
--- a/include/linux/cn_net.h
+++ b/include/linux/cn_net.h
@@ -76,8 +76,8 @@ struct event {
 	__u8 protocol;
 };
 
-struct event_list {
-	struct list_head list;
+struct event_node {
+	struct rb_node ev_node;
 	struct event ev;
 };
 
