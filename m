From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] add refcounting and /proc to nfnetlink_queue
Date: Sat, 30 Jul 2005 12:32:26 +0200
Message-ID: <20050730103226.GC6620@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1XWsVB21DFCvn2e8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--1XWsVB21DFCvn2e8
Content-Type: multipart/mixed; boundary="1Ow488MNN9B9o/ov"
Content-Disposition: inline


--1Ow488MNN9B9o/ov
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This patch is against nfnetlink_queue (which is already in your
net-2.6.14 tree).  Since it adds a file to /proc/net/netfilter, it also
depends on <20050728200434.GA3763@rama.de.gnumonks.org>.

Please apply, thanks.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--1Ow488MNN9B9o/ov
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="18-nfnetlink_queue-refcount.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] Add refcounting and /proc/net/netfilter interface to
	    nfnetlink_queue

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit f00815c7d2b718eccbc3e7ec77592faff45e9ccc
tree 3af9c34bcc5bfb11f1a71f20694f4cae78f40cb4
parent 66ad9b079da5c6a181506fba350aa33d26417431
author laforge <laforge@netfilter.org> Sa, 30 Jul 2005 12:12:26 +0200
committer laforge <laforge@netfilter.org> Sa, 30 Jul 2005 12:12:26 +0200

 include/linux/netfilter/nfnetlink_queue.h |    1=20
 net/netfilter/nfnetlink_queue.c           |  248 +++++++++++++++++++++++++=
+---
 2 files changed, 221 insertions(+), 28 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netf=
ilter/nfnetlink_queue.h
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -81,5 +81,6 @@ enum nfqnl_attr_config {
 	NFQA_CFG_PARAMS,		/* nfqnl_msg_config_params */
 	__NFQA_CFG_MAX
 };
+#define NFQA_CFG_MAX (__NFQA_CFG_MAX-1)
=20
 #endif /* _NFNETLINK_QUEUE_H */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queu=
e.c
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -20,6 +20,7 @@
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
+#include <linux/proc_fs.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter/nfnetlink.h>
@@ -48,6 +49,7 @@ struct nfqnl_queue_entry {
=20
 struct nfqnl_instance {
 	struct hlist_node hlist;		/* global list of queues */
+	atomic_t use;
=20
 	int peer_pid;
 	unsigned int queue_maxlen;
@@ -105,17 +107,28 @@ __instance_lookup(u_int16_t queue_num)
 }
=20
 static struct nfqnl_instance *
-instance_lookup(u_int16_t queue_num)
+instance_lookup_get(u_int16_t queue_num)
 {
 	struct nfqnl_instance *inst;
=20
 	read_lock_bh(&instances_lock);
 	inst =3D __instance_lookup(queue_num);
+	if (inst)
+		atomic_inc(&inst->use);
 	read_unlock_bh(&instances_lock);
=20
 	return inst;
 }
=20
+static void
+instance_put(struct nfqnl_instance *inst)
+{
+	if (inst && atomic_dec_and_test(&inst->use)) {
+		QDEBUG("kfree(inst=3D%p)\n", inst);
+		kfree(inst);
+	}
+}
+
 static struct nfqnl_instance *
 instance_create(u_int16_t queue_num, int pid)
 {
@@ -141,6 +154,8 @@ instance_create(u_int16_t queue_num, int
 	inst->copy_range =3D 0xfffff;
 	inst->copy_mode =3D NFQNL_COPY_NONE;
 	atomic_set(&inst->id_sequence, 0);
+	/* needs to be two, since we _put() after creation */
+	atomic_set(&inst->use, 2);
 	inst->lock =3D SPIN_LOCK_UNLOCKED;
 	INIT_LIST_HEAD(&inst->queue_list);
=20
@@ -182,8 +197,8 @@ _instance_destroy2(struct nfqnl_instance
 	/* then flush all pending skbs from the queue */
 	nfqnl_flush(inst, NF_DROP);
=20
-	/* and finally free the data structure */
-	kfree(inst);
+	/* and finally put the refcount */
+	instance_put(inst);
=20
 	module_put(THIS_MODULE);
 }
@@ -471,7 +486,7 @@ nfqnl_enqueue_packet(struct sk_buff *skb
=20
 	QDEBUG("entered\n");
=20
-	queue =3D instance_lookup(queuenum);
+	queue =3D instance_lookup_get(queuenum);
 	if (!queue) {
 		QDEBUG("no queue instance matching\n");
 		return -EINVAL;
@@ -479,7 +494,8 @@ nfqnl_enqueue_packet(struct sk_buff *skb
=20
 	if (queue->copy_mode =3D=3D NFQNL_COPY_NONE) {
 		QDEBUG("mode COPY_NONE, aborting\n");
-		return -EAGAIN;
+		status =3D -EAGAIN;
+		goto err_out_put;
 	}
=20
 	entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
@@ -487,7 +503,8 @@ nfqnl_enqueue_packet(struct sk_buff *skb
 		if (net_ratelimit())
 			printk(KERN_ERR=20
 				"nf_queue: OOM in nfqnl_enqueue_packet()\n");
-		return -ENOMEM;
+		status =3D -ENOMEM;
+		goto err_out_put;
 	}
=20
 	entry->info =3D info;
@@ -523,6 +540,7 @@ nfqnl_enqueue_packet(struct sk_buff *skb
 	__enqueue_entry(queue, entry);
=20
 	spin_unlock_bh(&queue->lock);
+	instance_put(queue);
 	return status;
=20
 err_out_free_nskb:
@@ -533,6 +551,8 @@ err_out_unlock:
=20
 err_out_free:
 	kfree(entry);
+err_out_put:
+	instance_put(queue);
 	return status;
 }
=20
@@ -685,6 +705,12 @@ static struct notifier_block nfqnl_rtnl_
 	.notifier_call	=3D nfqnl_rcv_nl_event,
 };
=20
+static const int nfqa_verdict_min[NFQA_MAX] =3D {
+	[NFQA_VERDICT_HDR-1]	=3D sizeof(struct nfqnl_msg_verdict_hdr),
+	[NFQA_MARK-1]		=3D sizeof(u_int32_t),
+	[NFQA_PAYLOAD-1]	=3D 0,
+};
+
 static int
 nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 		   struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
@@ -696,26 +722,40 @@ nfqnl_recv_verdict(struct sock *ctnl, st
 	struct nfqnl_instance *queue;
 	unsigned int verdict;
 	struct nfqnl_queue_entry *entry;
+	int err;
=20
-	queue =3D instance_lookup(queue_num);
+	if (nfattr_bad_size(nfqa, NFQA_MAX, nfqa_verdict_min)) {
+		QDEBUG("bad attribute size\n");
+		return -EINVAL;
+	}
+
+	queue =3D instance_lookup_get(queue_num);
 	if (!queue)
 		return -ENODEV;
=20
-	if (queue->peer_pid !=3D NETLINK_CB(skb).pid)
-		return -EPERM;
+	if (queue->peer_pid !=3D NETLINK_CB(skb).pid) {
+		err =3D -EPERM;
+		goto err_out_put;
+	}
=20
-	if (!nfqa[NFQA_VERDICT_HDR-1])
-		return -EINVAL;
+	if (!nfqa[NFQA_VERDICT_HDR-1]) {
+		err =3D -EINVAL;
+		goto err_out_put;
+	}
=20
 	vhdr =3D NFA_DATA(nfqa[NFQA_VERDICT_HDR-1]);
 	verdict =3D ntohl(vhdr->verdict);
=20
-	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT)
-		return -EINVAL;
+	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT) {
+		err =3D -EINVAL;
+		goto err_out_put;
+	}
=20
 	entry =3D find_dequeue_entry(queue, id_cmp, ntohl(vhdr->id));
-	if (entry =3D=3D NULL)
-		return -ENOENT;
+	if (entry =3D=3D NULL) {
+		err =3D -ENOENT;
+		goto err_out_put;
+	}
=20
 	if (nfqa[NFQA_PAYLOAD-1]) {
 		if (nfqnl_mangle(NFA_DATA(nfqa[NFQA_PAYLOAD-1]),
@@ -727,7 +767,12 @@ nfqnl_recv_verdict(struct sock *ctnl, st
 		skb->nfmark =3D ntohl(*(u_int32_t *)NFA_DATA(nfqa[NFQA_MARK-1]));
 	=09
 	issue_verdict(entry, verdict);
+	instance_put(queue);
 	return 0;
+
+err_out_put:
+	instance_put(queue);
+	return err;
 }
=20
 static int
@@ -737,6 +782,11 @@ nfqnl_recv_unsupp(struct sock *ctnl, str
 	return -ENOTSUPP;
 }
=20
+static const int nfqa_cfg_min[NFQA_CFG_MAX] =3D {
+	[NFQA_CFG_CMD-1]	=3D sizeof(struct nfqnl_msg_config_cmd),
+	[NFQA_CFG_PARAMS-1]	=3D sizeof(struct nfqnl_msg_config_params),
+};
+
 static int
 nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		  struct nlmsghdr *nlh, struct nfattr *nfqa[], int *errp)
@@ -744,10 +794,16 @@ nfqnl_recv_config(struct sock *ctnl, str
 	struct nfgenmsg *nfmsg =3D NLMSG_DATA(nlh);
 	u_int16_t queue_num =3D ntohs(nfmsg->res_id);
 	struct nfqnl_instance *queue;
+	int ret =3D 0;
=20
 	QDEBUG("entering for msg %u\n", NFNL_MSG_TYPE(nlh->nlmsg_type));
=20
-	queue =3D instance_lookup(queue_num);
+	if (nfattr_bad_size(nfqa, NFQA_CFG_MAX, nfqa_cfg_min)) {
+		QDEBUG("bad attribute size\n");
+		return -EINVAL;
+	}
+
+	queue =3D instance_lookup_get(queue_num);
 	if (nfqa[NFQA_CFG_CMD-1]) {
 		struct nfqnl_msg_config_cmd *cmd;
 		cmd =3D NFA_DATA(nfqa[NFQA_CFG_CMD-1]);
@@ -766,17 +822,19 @@ nfqnl_recv_config(struct sock *ctnl, str
 			if (!queue)
 				return -ENODEV;
=20
-			if (queue->peer_pid !=3D NETLINK_CB(skb).pid)
-				return -EPERM;
+			if (queue->peer_pid !=3D NETLINK_CB(skb).pid) {
+				ret =3D -EPERM;
+				goto out_put;
+			}
=20
 			instance_destroy(queue);
 			break;
 		case NFQNL_CFG_CMD_PF_BIND:
 			QDEBUG("registering queue handler for pf=3D%u\n",
 				ntohs(cmd->pf));
-			return nf_register_queue_handler(ntohs(cmd->pf),
-							 nfqnl_enqueue_packet,
-							 NULL);
+			ret =3D nf_register_queue_handler(ntohs(cmd->pf),
+							nfqnl_enqueue_packet,
+							NULL);
=20
 			break;
 		case NFQNL_CFG_CMD_PF_UNBIND:
@@ -784,20 +842,23 @@ nfqnl_recv_config(struct sock *ctnl, str
 				ntohs(cmd->pf));
 			/* This is a bug and a feature.  We can unregister
 			 * other handlers(!) */
-			return nf_unregister_queue_handler(ntohs(cmd->pf));
+			ret =3D nf_unregister_queue_handler(ntohs(cmd->pf));
 			break;
 		default:
-			return -EINVAL;
+			ret =3D -EINVAL;
+			break;
 		}
 	} else {
 		if (!queue) {
 			QDEBUG("no config command, and no instance ENOENT\n");
-			return -ENOENT;
+			ret =3D -ENOENT;
+			goto out_put;
 		}
=20
 		if (queue->peer_pid !=3D NETLINK_CB(skb).pid) {
 			QDEBUG("no config command, and wrong pid\n");
-			return -EPERM;
+			ret =3D -EPERM;
+			goto out_put;
 		}
 	}
=20
@@ -809,7 +870,9 @@ nfqnl_recv_config(struct sock *ctnl, str
 				ntohl(params->copy_range));
 	}
=20
-	return 0;
+out_put:
+	instance_put(queue);
+	return ret;
 }
=20
 static struct nfnl_callback nfqnl_cb[NFQNL_MSG_MAX] =3D {
@@ -829,14 +892,132 @@ static struct nfnetlink_subsystem nfqnl_
 	.cb		=3D nfqnl_cb,
 };
=20
+#ifdef CONFIG_PROC_FS
+struct iter_state {
+	unsigned int bucket;
+};
+
+static struct hlist_node *get_first(struct seq_file *seq)
+{
+	struct iter_state *st =3D seq->private;
+
+	if (!st)
+		return NULL;
+
+	for (st->bucket =3D 0; st->bucket < INSTANCE_BUCKETS; st->bucket++) {
+		if (!hlist_empty(&instance_table[st->bucket]))
+			return instance_table[st->bucket].first;
+	}
+	return NULL;
+}
+
+static struct hlist_node *get_next(struct seq_file *seq, struct hlist_node=
 *h)
+{
+	struct iter_state *st =3D seq->private;
+
+	h =3D h->next;
+	while (!h) {
+		if (++st->bucket >=3D INSTANCE_BUCKETS)
+			return NULL;
+
+		h =3D instance_table[st->bucket].first;
+	}
+	return h;
+}
+
+static struct hlist_node *get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct hlist_node *head;
+	head =3D get_first(seq);
+
+	if (head)
+		while (pos && (head =3D get_next(seq, head)))
+			pos--;
+	return pos ? NULL : head;
+}
+
+static void *seq_start(struct seq_file *seq, loff_t *pos)
+{
+	read_lock_bh(&instances_lock);
+	return get_idx(seq, *pos);
+}
+
+static void *seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	(*pos)++;
+	return get_next(s, v);
+}
+
+static void seq_stop(struct seq_file *s, void *v)
+{
+	read_unlock_bh(&instances_lock);
+}
+
+static int seq_show(struct seq_file *s, void *v)
+{
+	const struct nfqnl_instance *inst =3D v;
+
+	return seq_printf(s, "%5d %6d %5d %1d %5d %5d %5d %8d %2d\n",
+			  inst->queue_num,
+			  inst->peer_pid, inst->queue_total,
+			  inst->copy_mode, inst->copy_range,
+			  inst->queue_dropped, inst->queue_user_dropped,
+			  atomic_read(&inst->id_sequence),
+			  atomic_read(&inst->use));
+}
+
+static struct seq_operations nfqnl_seq_ops =3D {
+	.start	=3D seq_start,
+	.next	=3D seq_next,
+	.stop	=3D seq_stop,
+	.show	=3D seq_show,
+};
+
+static int nfqnl_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	struct iter_state *is;
+	int ret;
+
+	is =3D kmalloc(sizeof(*is), GFP_KERNEL);
+	if (!is)
+		return -ENOMEM;
+	memset(is, 0, sizeof(*is));
+	ret =3D seq_open(file, &nfqnl_seq_ops);
+	if (ret < 0)
+		goto out_free;
+	seq =3D file->private_data;
+	seq->private =3D is;
+	return ret;
+out_free:
+	kfree(is);
+	return ret;
+}
+
+static struct file_operations nfqnl_file_ops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open	 =3D nfqnl_open,
+	.read	 =3D seq_read,
+	.llseek	 =3D seq_lseek,
+	.release =3D seq_release_private,
+};
+
+#endif /* PROC_FS */
+
 static int
 init_or_cleanup(int init)
 {
-	int status =3D -ENOMEM;
+	int i, status =3D -ENOMEM;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *proc_nfqueue;
+#endif
 =09
 	if (!init)
 		goto cleanup;
=20
+	for (i =3D 0; i < INSTANCE_BUCKETS; i++)
+		INIT_HLIST_HEAD(&instance_table[i]);
+
 	netlink_register_notifier(&nfqnl_rtnl_notifier);
 	status =3D nfnetlink_subsys_register(&nfqnl_subsys);
 	if (status < 0) {
@@ -844,14 +1025,25 @@ init_or_cleanup(int init)
 		goto cleanup_netlink_notifier;
 	}
=20
+#ifdef CONFIG_PROC_FS
+	proc_nfqueue =3D create_proc_entry("nfnetlink_queue", 0440,
+					 proc_net_netfilter);
+	if (!proc_nfqueue)
+		goto cleanup_subsys;
+	proc_nfqueue->proc_fops =3D &nfqnl_file_ops;
+#endif
+
 	register_netdevice_notifier(&nfqnl_dev_notifier);
+
 	return status;
=20
 cleanup:
 	nf_unregister_queue_handlers(nfqnl_enqueue_packet);
 	unregister_netdevice_notifier(&nfqnl_dev_notifier);
+#ifdef CONFIG_PROC_FS
+cleanup_subsys:
+#endif=09
 	nfnetlink_subsys_unregister(&nfqnl_subsys);
-=09
 cleanup_netlink_notifier:
 	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
 	return status;

--1Ow488MNN9B9o/ov--

--1XWsVB21DFCvn2e8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC61c5XaXGVTD0i/8RAr+7AKC0vUYe0VV5/0FSzhH5IhICjrF28QCdGBT9
dFbbVh4brPn0AJQ0STcwm48=
=lpiJ
-----END PGP SIGNATURE-----

--1XWsVB21DFCvn2e8--
