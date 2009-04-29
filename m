From: Ranjit Manomohan <ranjitm@google.com>
Subject: Re: [PATCH] tc_cgroup : enabling live socket to change its cgroup in
	a runtime
Date: Wed, 29 Apr 2009 10:20:35 -0700
Message-ID: <166fe7950904291020g50d806dds291d8444530efb4b@mail.gmail.com>
References: <loom.20090424T023126-788@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chei-yol Kim <gauri@etri.re.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14183 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZD2RUk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 13:20:40 -0400
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n3THKbmZ005393
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 18:20:37 +0100
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by spaceape14.eur.corp.google.com with ESMTP id n3THKP3K001288
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 10:20:35 -0700
Received: by qyk10 with SMTP id 10so335491qyk.25
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 10:20:35 -0700 (PDT)
In-Reply-To: <loom.20090424T023126-788@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 7:32 PM, Chei-yol Kim <gauri@etri.re.kr> wrote:
> Ranjit=92s tc cgroup subsystem patch is useful as a network controlle=
r of
> container.
> But when the task having a socket connection changes its cgroup, the =
socket
> will not be affected by changed cgroup, because there are not a perma=
nent
> linkage between the task and its socket.
> I fixed this disadvantage, so when the tasks move among groups, their=
 socket=92s
> classid will be changed according to their owner task.
>
> I am planning to put the additional function to tc cgroup, monitoring=
 each
> group=92s network bandwidth usage with res_count facility.
> I don=92t think this job could be possible to every traffic control p=
olicies at
> the same time.
> First, I=92m going to work in the HTB, because HTB is the most useful=
 and
> efficient policy to control network bandwidth.
>
> Any comments and suggestions are very welcom.
>

Chei-yol,
    You may want to re-base your work on Thomas Graf's cgroup work in
commit id f400923735ecbb67cbe4a3606c9479f694754f51.

As such these patches are not relevant to the current implementation
of cgroup network controllers in the tree.

-Thanks,
Ranjit.

> Below patch codes are based on the Ranjit=92s tc cgroup code.
>
> - Chei-yol Kim
>
> --- ./linux-2.6.27/include/linux/cgroup_subsys.h 2008-10-10 07:13:53.=
000000000
> +0900
> +++ ./linux-2.6.27-corset-net/include/linux/cgroup_subsys.h 2009-04-0=
3
> 11:27:50.000000000 +0900
> @@ -48,3 +48,9 @@
> =A0#endif
>
> =A0/* */
> +
> +#ifdef CONFIG_CGROUP_TC
> +SUBSYS(tc)
> +#endif
> +
> +/* */
> --- ./linux-2.6.27/include/linux/cgroup_tc.h 1970-01-01 09:00:00.0000=
00000
> +0900
> +++ ./linux-2.6.27-corset-net/include/linux/cgroup_tc.h 2009-04-23
> 11:44:31.000000000 +0900
> @@ -0,0 +1,22 @@
> +#ifndef __LINUX_CGROUP_TC_H
> +#define __LINUX_CGROUP_TC_H
> +
> +/* Interface to obtain tasks cgroup identifier. */
> +
> +#include <linux/cgroup.h>
> +#include <linux/skbuff.h>
> +#include <net/sock.h>
> +
> +#ifdef CONFIG_CGROUP_TC
> +
> +void cgroup_tc_do_sock(struct sock *sk);
> +void tc_list_del(struct sock *sk);
> +
> +#else
> +
> +#define cgroup_tc_do_sock(sk)
> +#define tc_list_del(sk)
> +
> +#endif /* CONFIG_CGROUP_TC */
> +
> +#endif /* __LINUX_CGROUP_TC_H */
> --- ./linux-2.6.27/include/linux/pkt_cls.h 2008-10-10 07:13:53.000000=
000 +0900
> +++ ./linux-2.6.27-corset-net/include/linux/pkt_cls.h 2009-04-03
> 11:27:50.000000000 +0900
> @@ -380,6 +380,21 @@
>
> =A0#define TCA_FLOW_MAX (__TCA_FLOW_MAX - 1)
>
> +/* Cgroups filter */
> +
> +enum {
> + TCA_CGROUP_UNSPEC,
> + TCA_CGROUP_CLASSID,
> + TCA_CGROUP_MASK,
> + TCA_CGROUP_VALUE,
> + TCA_CGROUP_ACT,
> + TCA_CGROUP_POLICE,
> + TCA_CGROUP_EMATCHES,
> + __TCA_CGROUP_MAX
> +};
> +
> +#define TCA_CGROUP_MAX (__TCA_CGROUP_MAX - 1)
> +
> =A0/* Basic filter */
>
> =A0enum
> --- ./linux-2.6.27/include/net/sock.h 2008-10-10 07:13:53.000000000 +=
0900
> +++ ./linux-2.6.27-corset-net/include/net/sock.h 2009-04-23 10:35:49.=
000000000
> +0900
> @@ -57,6 +57,7 @@
> =A0#include <net/dst.h>
> =A0#include <net/checksum.h>
>
> +
> =A0/*
> =A0* This structure really needs to be cleaned up.
> =A0* Most of it is for TCP, and not used by any of
> @@ -271,6 +272,11 @@
> =A0int =A0 sk_write_pending;
> =A0void =A0 *sk_security;
> =A0__u32 =A0 sk_mark;
> +#ifdef CONFIG_CGROUP_TC
> + struct list_head sk_tc_list; // link to sk_list
> + int =A0 sk_cid; =A0// creator pid
> + __u32 =A0 sk_cgroup_classid;
> +#endif
> =A0/* XXX 4 bytes hole on 64 bit */
> =A0void =A0 (*sk_state_change)(struct sock *sk);
> =A0void =A0 (*sk_data_ready)(struct sock *sk, int bytes);
> --- ./linux-2.6.27/init/Kconfig 2008-10-10 07:13:53.000000000 +0900
> +++ ./linux-2.6.27-corset-net/init/Kconfig 2009-04-03 11:27:41.000000=
000 +0900
> @@ -290,6 +290,17 @@
>
> =A0 =A0Say N if unsure
>
> +config CGROUP_TC
> + bool "Traffic control cgroup subsystem"
> + depends on CGROUPS
> + default n
> + help
> + =A0 This option enables a simple cgroup subsystem that
> + =A0 allows network traffic to be classified based on the
> + =A0 cgroup of the task originating the traffic.
> +
> + =A0 Say N if unsure
> +
> =A0config CGROUP_NS
> =A0 =A0 =A0 =A0 bool "Namespace cgroup subsystem"
> =A0 =A0 =A0 =A0 depends on CGROUPS
> --- ./linux-2.6.27/kernel/Makefile 2008-10-10 07:13:53.000000000 +090=
0
> +++ ./linux-2.6.27-corset-net/kernel/Makefile 2009-04-03 11:28:03.000=
000000
> +0900
> @@ -57,6 +57,7 @@
> =A0obj-$(CONFIG_CGROUP_DEBUG) +=3D cgroup_debug.o
> =A0obj-$(CONFIG_CPUSETS) +=3D cpuset.o
> =A0obj-$(CONFIG_CGROUP_NS) +=3D ns_cgroup.o
> +obj-$(CONFIG_CGROUP_TC) +=3D tc_cgroup.o
> =A0obj-$(CONFIG_UTS_NS) +=3D utsname.o
> =A0obj-$(CONFIG_USER_NS) +=3D user_namespace.o
> =A0obj-$(CONFIG_PID_NS) +=3D pid_namespace.o
> --- ./linux-2.6.27/kernel/tc_cgroup.c 1970-01-01 09:00:00.000000000 +=
0900
> +++ ./linux-2.6.27-corset-net/kernel/tc_cgroup.c 2009-04-23 11:42:33.=
000000000
> +0900
> @@ -0,0 +1,183 @@
> +/*
> + * tc_cgroup.c - traffic control cgroup subsystem
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/cgroup.h>
> +#include <linux/fs.h>
> +#include <linux/slab.h>
> +#include <linux/cgroup_tc.h>
> +
> +#define ENTER_FN printk("%s:%i: ENTER \n", __FUNCTION__, __LINE__)
> +#define OUT_FN =A0printk("%s:%i: OUT \n", __FUNCTION__, __LINE__)
> +
> +LIST_HEAD(sk_list);
> +DEFINE_SPINLOCK(sk_list_lock);
> +
> +EXPORT_SYMBOL(sk_list);
> +EXPORT_SYMBOL(sk_list_lock);
> +
> +
> +struct tc_cgroup {
> + struct cgroup_subsys_state css;
> + unsigned int classid;
> +};
> +
> +struct cgroup_subsys tc_subsys;
> +
> +static inline struct tc_cgroup *cgroup_to_tc(
> + =A0struct cgroup *cgroup)
> +{
> + return container_of(cgroup_subsys_state(cgroup, tc_subsys_id),
> + =A0 =A0 =A0 struct tc_cgroup, css);
> +}
> +
> +static unsigned int cgroup_tc_classid(struct task_struct *tsk)
> +{
> + unsigned int tc_classid;
> +
> + rcu_read_lock();
> + tc_classid =3D container_of(task_subsys_state(tsk, tc_subsys_id),
> + =A0 =A0 =A0struct tc_cgroup, css)->classid;
> + rcu_read_unlock();
> + return tc_classid;
> +}
> +
> +void cgroup_tc_set_sock_classid(struct sock *sk)
> +{
> + if (sk)
> + =A0sk->sk_cgroup_classid =3D cgroup_tc_classid(current);
> +}
> +
> +static void cgroup_tc_set_sock_pid_classid(struct sock *sk)
> +{
> + struct task_struct *tsk =3D current;
> +
> + if(sk) {
> + =A0rcu_read_lock();
> + =A0sk->sk_cgroup_classid =3D container_of(task_subsys_state(tsk, tc=
_subsys_id),
> + =A0 =A0 =A0struct tc_cgroup, css)->classid;
> + =A0sk->sk_cid =3D tsk->pid; =A0// socket creator id
> + =A0rcu_read_unlock();
> + }
> +}
> +
> +static void cgroup_tc_add_sk_list(struct sock *sk)
> +{
> + spin_lock(&sk_list_lock);
> + lock_sock(sk);
> + list_add_tail(&sk->sk_tc_list, &sk_list);
> + release_sock(sk);
> + spin_unlock(&sk_list_lock);
> +}
> +
> +void cgroup_tc_do_sock(struct sock *sk)
> +{
> + if(sk) {
> + =A0cgroup_tc_add_sk_list(sk);
> + =A0cgroup_tc_set_sock_pid_classid(sk);
> + }
> +}
> +
> +void tc_list_del(struct sock *sk)
> +{
> + spin_lock(&sk_list_lock);
> + list_del(&sk->sk_tc_list);
> + spin_unlock(&sk_list_lock);
> +}
> +
> +
> +static struct cgroup_subsys_state *tc_create(struct cgroup_subsys *s=
s,
> + =A0 =A0 =A0struct cgroup *cgroup)
> +{
> + struct tc_cgroup *tc_cgroup;
> +
> + tc_cgroup =3D kzalloc(sizeof(*tc_cgroup), GFP_KERNEL);
> +
> + if (!tc_cgroup)
> + =A0return ERR_PTR(-ENOMEM);
> +
> + /* Copy parent's class id if present */
> + if (cgroup->parent)
> + =A0tc_cgroup->classid =3D cgroup_to_tc(cgroup->parent)->classid;
> +
> + return &tc_cgroup->css;
> +}
> +
> +static void tc_destroy(struct cgroup_subsys *ss,
> + =A0 struct cgroup *cgroup)
> +{
> + kfree(cgroup_to_tc(cgroup));
> +}
> +
> +static void tc_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> + =A0 struct cgroup *old_cgrp, struct task_struct *tsk)
> +{
> + struct list_head *head;
> + struct sock *sk;
> + int pid;
> + unsigned int old_classid, new_classid;
> + int i=3D1;
> +
> + pid =3D tsk->pid;
> + old_classid =3D cgroup_to_tc(old_cgrp)->classid;
> + new_classid =3D cgroup_to_tc(cgrp)->classid;
> +
> +
> + spin_lock(&sk_list_lock);
> + list_for_each(head, &sk_list) {
> + =A0if(head =3D=3D &sk_list)
> + =A0 break;
> + =A0sk =3D container_of(head, struct sock, sk_tc_list);
> +
> + =A0if(sk->sk_cid =3D=3D pid) {
> + =A0 if(sk->sk_cgroup_classid !=3D old_classid)
> + =A0 sk->sk_cgroup_classid =3D new_classid;
> + =A0}
> + =A0i++;
> + }
> + spin_unlock(&sk_list_lock);
> +}
> +
> +static int tc_write_u64(struct cgroup *cgroup, struct cftype *cft, u=
64 val)
> +{
> + struct tc_cgroup *tc =3D cgroup_to_tc(cgroup);
> +
> + if (!cgroup_lock_live_group(cgroup))
> + =A0return -ENODEV;
> +
> + tc->classid =3D (unsigned int) (val & 0xffffffff);
> + cgroup_unlock();
> + return 0;
> +}
> +
> +static u64 tc_read_u64(struct cgroup *cgroup, struct cftype *cft)
> +{
> + struct tc_cgroup *tc =3D cgroup_to_tc(cgroup);
> + return tc->classid;
> +}
> +
> +static struct cftype tc_files[] =3D {
> + {
> + =A0.name =3D "classid",
> + =A0.read_u64 =3D tc_read_u64,
> + =A0.write_u64 =3D tc_write_u64,
> + }
> +};
> +
> +static int tc_populate(struct cgroup_subsys *ss, struct cgroup *cgro=
up)
> +{
> + int err;
> + err =3D cgroup_add_files(cgroup, ss, tc_files, ARRAY_SIZE(tc_files)=
);
> + return err;
> +}
> +
> +struct cgroup_subsys tc_subsys =3D {
> + .name =3D "tc",
> + .create =3D tc_create,
> + .destroy =A0=3D tc_destroy,
> + .attach =3D tc_attach,
> + .populate =3D tc_populate,
> + .subsys_id =3D tc_subsys_id,
> +};
> --- ./linux-2.6.27/Makefile 2008-10-10 07:13:53.000000000 +0900
> +++ ./linux-2.6.27-corset-net/Makefile 2009-04-03 11:30:05.000000000 =
+0900
> @@ -1,7 +1,7 @@
> =A0VERSION =3D 2
> =A0PATCHLEVEL =3D 6
> =A0SUBLEVEL =3D 27
> -EXTRAVERSION =3D
> +EXTRAVERSION =3D -corset-net
> =A0NAME =3D Rotary Wombat
>
> =A0# *DOCUMENTATION*
> --- ./linux-2.6.27/net/sched/cls_cgroup.c 1970-01-01 09:00:00.0000000=
00 +0900
> +++ ./linux-2.6.27-corset-net/net/sched/cls_cgroup.c 2009-04-03
> 11:27:55.000000000 +0900
> @@ -0,0 +1,330 @@
> +/*
> + * net/sched/cls_cgroup.c Simple packet classifier which can filter
> + * =A0 =A0 packets based on the cgroups they belong to.
> + *
> + * =A0This program is free software; you can redistribute it and/or
> + * =A0modify it under the terms of the GNU General Public License
> + * =A0as published by the Free Software Foundation; either version
> + * =A02 of the License, or (at your option) any later version.
> + *
> + */
> +
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <net/pkt_cls.h>
> +#include <net/netlink.h>
> +#include <net/sock.h>
> +
> +struct cgroup_head {
> + struct list_head flist; =A0/* Head of filter list */
> +};
> +
> +struct cgroup_filter {
> + u32 =A0 handle; =A0/* Unique filter handle */
> + struct tcf_exts =A0exts;
> + struct tcf_ematch_tree ematches;
> + struct tcf_result res;
> + struct list_head link;
> + u32 =A0 mask;
> + u32 =A0 value;
> +};
> +
> +static const struct tcf_ext_map cgroup_ext_map =3D {
> + .action =3D TCA_CGROUP_ACT,
> + .police =3D TCA_CGROUP_POLICE,
> +};
> +
> +/* This function is called from the qdisc to classify a particular p=
acket
> + * contained in the skb to the appropriate sub-classes. It returns t=
he
> + * classid of the target class. This filter will match if the cgroup=
_classid
> + * in the skb matches the value in the filter.
> + */
> +static int cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp=
,
> + =A0 =A0 struct tcf_result *res)
> +{
> + struct cgroup_head *head =3D (struct cgroup_head *)tp->root;
> + struct cgroup_filter *f;
> + uint32_t cgroup_classid =3D 0;
> + int r;
> +
> +#ifdef CONFIG_CGROUP_TC
> + if (skb->sk)
> + =A0cgroup_classid =3D =A0skb->sk->sk_cgroup_classid;
> +#endif
> +
> + list_for_each_entry(f, &head->flist, link) {
> +
> + =A0if (!tcf_em_tree_match(skb, &f->ematches, NULL))
> + =A0 continue;
> +
> + =A0if ((cgroup_classid & f->mask) =3D=3D f->value) {
> + =A0 *res =3D f->res;
> + =A0 r =3D tcf_exts_exec(skb, &f->exts, res);
> + =A0 if (r < 0)
> + =A0 =A0continue;
> + =A0 return r;
> + =A0}
> + }
> + return -1;
> +}
> +
> +/* Returns pointer to filter matching the handle passed into the fun=
ction.*/
> +static unsigned long cgroup_get(struct tcf_proto *tp, u32 handle)
> +{
> + unsigned long l =3D 0UL;
> + struct cgroup_head *head =3D (struct cgroup_head *) tp->root;
> + struct cgroup_filter *f;
> +
> + if (head =3D=3D NULL)
> + =A0return 0UL;
> +
> + list_for_each_entry(f, &head->flist, link)
> + =A0if (f->handle =3D=3D handle)
> + =A0 l =3D (unsigned long) f;
> +
> + return l;
> +}
> +
> +/* Does not seem to be used for classifiers. */
> +static void cgroup_put(struct tcf_proto *tp, unsigned long f)
> +{
> +}
> +
> +/* Initializer function called when tp is created. */
> +static int cgroup_init(struct tcf_proto *tp)
> +{
> + struct cgroup_head *head =3D kzalloc(sizeof(*head), GFP_KERNEL);
> + if (head =3D=3D NULL)
> + =A0return -ENOBUFS;
> +
> + INIT_LIST_HEAD(&head->flist);
> + tp->root =3D head;
> + return 0;
> +}
> +
> +/* Simple delete function called when filter is deleted */
> +static inline void cgroup_delete_filter(struct tcf_proto *tp,
> + =A0 =A0 =A0 =A0 =A0 struct cgroup_filter *f)
> +{
> + tcf_unbind_filter(tp, &f->res);
> + tcf_exts_destroy(tp, &f->exts);
> + tcf_em_tree_destroy(tp, &f->ematches);
> + kfree(f);
> +}
> +
> +/* Destroy the entire tp structure.*/
> +static void cgroup_destroy(struct tcf_proto *tp)
> +{
> + struct cgroup_head *head =3D (struct cgroup_head *) xchg(&tp->root,=
 NULL);
> + struct cgroup_filter *f, *n;
> +
> + list_for_each_entry_safe(f, n, &head->flist, link) {
> + =A0list_del(&f->link);
> + =A0cgroup_delete_filter(tp, f);
> + }
> + kfree(head);
> +}
> +
> +/* Delete one filter entry */
> +static int cgroup_delete(struct tcf_proto *tp, unsigned long arg)
> +{
> + struct cgroup_head *head =3D (struct cgroup_head *) tp->root;
> + struct cgroup_filter *t, *f =3D (struct cgroup_filter *) arg;
> +
> + list_for_each_entry(t, &head->flist, link)
> + =A0if (t =3D=3D f) {
> + =A0 tcf_tree_lock(tp);
> + =A0 list_del(&t->link);
> + =A0 tcf_tree_unlock(tp);
> + =A0 cgroup_delete_filter(tp, t);
> + =A0 return 0;
> + =A0}
> +
> + return -ENOENT;
> +}
> +
> +/* Set the mask and value parameters in the tp structure. */
> +static inline int cgroup_set_parms(struct tcf_proto *tp,
> + =A0 unsigned long base,
> + =A0 struct cgroup_filter *f, struct nlattr **tb)
> +{
> + int err =3D -EINVAL;
> +
> + if (tb[TCA_CGROUP_MASK]) {
> + =A0if (nla_len(tb[TCA_CGROUP_MASK]) < sizeof(u32))
> + =A0 return err;
> + =A0f->mask =3D =A0nla_get_u32(tb[TCA_CGROUP_MASK]);
> + } else
> + =A0f->mask =3D UINT_MAX;
> +
> + if (tb[TCA_CGROUP_VALUE]) {
> + =A0if (nla_len(tb[TCA_CGROUP_VALUE]) < sizeof(u32))
> + =A0 return err;
> + =A0f->value =3D nla_get_u32(tb[TCA_CGROUP_VALUE]);
> + } else
> + =A0return err;
> +
> + if (tb[TCA_CGROUP_CLASSID]) {
> + =A0if (nla_len(tb[TCA_CGROUP_CLASSID]) < sizeof(u32))
> + =A0 return err;
> + =A0f->res.classid =3D nla_get_u32(tb[TCA_CGROUP_CLASSID]);
> + =A0tcf_bind_filter(tp, &f->res, base);
> + } else
> + =A0return err;
> +
> + return 0;
> +}
> +
> +/* Change the mask and value parameters in the current settings. */
> +static int cgroup_change(struct tcf_proto *tp, unsigned long base, u=
32 handle,
> + =A0 =A0struct nlattr **tca, unsigned long *arg)
> +{
> + int err =3D -EINVAL;
> + struct cgroup_head *head =3D (struct cgroup_head *) tp->root;
> + struct nlattr *tb[TCA_CGROUP_MAX];
> + struct cgroup_filter *f =3D (struct cgroup_filter *) *arg;
> + struct tcf_exts e;
> + struct tcf_ematch_tree t;
> +
> + if (tca[TCA_OPTIONS] =3D=3D NULL)
> + =A0return -EINVAL;
> +
> + if (nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS], NULL) < =
0)
> + =A0return -EINVAL;
> +
> + err =3D tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &cgroup_ext_ma=
p);
> + if (err < 0)
> + =A0return err;
> +
> + err =3D tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
> + if (err < 0)
> + =A0goto error1;
> +
> + if (f !=3D NULL) {
> + =A0if (handle && f->handle !=3D handle)
> + =A0 goto error2;
> + } else {
> + =A0if (!handle)
> + =A0 goto error2;
> + =A0f =3D kzalloc(sizeof(*f), GFP_KERNEL);
> + =A0if (f =3D=3D NULL)
> + =A0 goto error2;
> + =A0f->handle =3D handle;
> + }
> +
> + err =3D cgroup_set_parms(tp, base, f, tb);
> + if (err < 0)
> + =A0goto error3;
> +
> + tcf_exts_change(tp, &f->exts, &e);
> + tcf_em_tree_change(tp, &f->ematches, &t);
> +
> + if (*arg =3D=3D 0) {
> + =A0tcf_tree_lock(tp);
> + =A0list_add(&f->link, &head->flist);
> + =A0tcf_tree_unlock(tp);
> + }
> +
> + *arg =3D (unsigned long)f;
> + return 0;
> +
> +error3:
> + if (*arg =3D=3D 0)
> + =A0kfree(f);
> +error2:
> + tcf_em_tree_destroy(tp, &t);
> +error1:
> + tcf_exts_destroy(tp, &e);
> +
> + return err;
> +}
> +
> +/* Walk the filter list for things like displaying contents.*/
> +static void cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg=
)
> +{
> + struct cgroup_head *head =3D (struct cgroup_head *) tp->root;
> + struct cgroup_filter *f;
> +
> + list_for_each_entry(f, &head->flist, link) {
> + =A0if (arg->count < arg->skip)
> + =A0 goto skip;
> +
> + =A0if (arg->fn(tp, (unsigned long) f, arg) < 0) {
> + =A0 arg->stop =3D 1;
> + =A0 break;
> + =A0}
> +skip:
> + =A0arg->count++;
> + }
> +}
> +
> +/* Retreive current settings in the filter */
> +static int cgroup_dump(struct tcf_proto *tp, unsigned long fh,
> + =A0 =A0 =A0 =A0struct sk_buff *skb, struct tcmsg *t)
> +{
> + struct cgroup_filter *f =3D (struct cgroup_filter *) fh;
> + struct nlattr *nest;
> +
> + if (f =3D=3D NULL)
> + =A0return skb->len;
> +
> + t->tcm_handle =3D f->handle;
> +
> + nest =3D nla_nest_start(skb, TCA_OPTIONS);
> + if (nest =3D=3D NULL)
> + =A0goto nla_put_failure;
> +
> + NLA_PUT_U32(skb, TCA_CGROUP_CLASSID, f->res.classid);
> + NLA_PUT_U32(skb, TCA_CGROUP_MASK, f->mask);
> + NLA_PUT_U32(skb, TCA_CGROUP_VALUE, f->value);
> +
> + if (tcf_exts_dump(skb, &f->exts, &cgroup_ext_map) < 0)
> + =A0goto nla_put_failure;
> +
> +#ifdef CONFIG_NET_EMATCH
> + if (f->ematches.hdr.nmatches &&
> + =A0 tcf_em_tree_dump(skb, &f->ematches, TCA_CGROUP_EMATCHES) < 0)
> + =A0goto nla_put_failure;
> +#endif
> +
> + if (tcf_exts_dump_stats(skb, &f->exts, &cgroup_ext_map) < 0)
> + =A0goto nla_put_failure;
> +
> + nla_nest_end(skb, nest);
> + return skb->len;
> +
> +nla_put_failure:
> + nla_nest_cancel(skb, nest);
> + return -1;
> +}
> +
> +static struct tcf_proto_ops cls_cgroup_ops =3D {
> + .kind =A0=3D "cgroup",
> + .classify =3D cgroup_classify,
> + .init =A0=3D cgroup_init,
> + .destroy =3D cgroup_destroy,
> + .get =A0=3D cgroup_get,
> + .put =A0=3D cgroup_put,
> + .change =A0=3D cgroup_change,
> + .delete =A0=3D cgroup_delete,
> + .walk =A0=3D cgroup_walk,
> + .dump =A0=3D cgroup_dump,
> + .owner =A0=3D THIS_MODULE,
> +};
> +
> +static int __init init_cgroup(void)
> +{
> + return register_tcf_proto_ops(&cls_cgroup_ops);
> +}
> +
> +static void __exit exit_cgroup(void)
> +{
> + unregister_tcf_proto_ops(&cls_cgroup_ops);
> +}
> +
> +module_init(init_cgroup)
> +module_exit(exit_cgroup)
> +MODULE_LICENSE("GPL");
> +
> --- ./linux-2.6.27/net/sched/Kconfig 2008-10-10 07:13:53.000000000 +0=
900
> +++ ./linux-2.6.27-corset-net/net/sched/Kconfig 2009-04-03 11:27:55.0=
00000000
> +0900
> @@ -307,6 +307,16 @@
> =A0 =A0To compile this code as a module, choose M here: the
> =A0 =A0module will be called cls_flow.
>
> +config NET_CLS_CGROUP
> + tristate "Cgroups tc classifier"
> + select NET_CLS
> + ---help---
> + =A0 If you say Y here, you will be able to classify packets based o=
n
> + =A0 cgroup membership of the task originating the packet.
> +
> + =A0 To compile this code as a module, choose M here: the
> + =A0 module will be called cls_cgroup.
> +
> =A0config NET_EMATCH
> =A0bool "Extended Matches"
> =A0select NET_CLS
> --- ./linux-2.6.27/net/sched/Makefile 2008-10-10 07:13:53.000000000 +=
0900
> +++ ./linux-2.6.27-corset-net/net/sched/Makefile 2009-04-03 11:27:55.=
000000000
> +0900
> @@ -36,6 +36,7 @@
> =A0obj-$(CONFIG_NET_CLS_RSVP6) +=3D cls_rsvp6.o
> =A0obj-$(CONFIG_NET_CLS_BASIC) +=3D cls_basic.o
> =A0obj-$(CONFIG_NET_CLS_FLOW) +=3D cls_flow.o
> +obj-$(CONFIG_NET_CLS_CGROUP) +=3D cls_cgroup.o
> =A0obj-$(CONFIG_NET_EMATCH) +=3D ematch.o
> =A0obj-$(CONFIG_NET_EMATCH_CMP) +=3D em_cmp.o
> =A0obj-$(CONFIG_NET_EMATCH_NBYTE) +=3D em_nbyte.o
> --- ./linux-2.6.27/net/socket.c 2008-10-10 07:13:53.000000000 +0900
> +++ ./linux-2.6.27-corset-net/net/socket.c 2009-04-23 11:47:06.000000=
000 +0900
> @@ -96,6 +96,7 @@
>
> =A0#include <net/sock.h>
> =A0#include <linux/netfilter.h>
> +#include <linux/cgroup_tc.h>
>
> =A0static int sock_no_open(struct inode *irrelevant, struct file *don=
tcare);
> =A0static ssize_t sock_aio_read(struct kiocb *iocb, const struct iove=
c *iov,
> @@ -526,6 +527,9 @@
>
> =A0void sock_release(struct socket *sock)
> =A0{
> + if(sock->sk)
> + =A0tc_list_del(sock->sk);
> +
> =A0if (sock->ops) {
> =A0 struct module *owner =3D sock->ops->owner;
>
> @@ -1173,6 +1177,8 @@
> =A0if (err < 0)
> =A0 goto out_module_put;
>
> + cgroup_tc_do_sock(sock->sk);
> +
> =A0/*
> =A0 * Now to bump the refcnt of the [loadable] module that owns this
> =A0 * socket at sock_release time we decrement its refcnt.
> @@ -1477,6 +1483,8 @@
> =A0if (err < 0)
> =A0 goto out_fd;
>
> + cgroup_tc_do_sock(newsock->sk);
> +
> =A0if (upeer_sockaddr) {
> =A0 if (newsock->ops->getname(newsock, (struct sockaddr *)&address,
> =A0 =A0 =A0 =A0&len, 2) < 0) {
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
