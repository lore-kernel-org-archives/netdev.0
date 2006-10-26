From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: [KJ] [Patch] kmemdup() cleanup in net/
Date: Thu, 26 Oct 2006 22:49:31 +0200
Message-ID: <1161895771.30263.1.camel@alice>
References: <1161889418.7318.1.camel@alice>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:43730 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1423648AbWJZUtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 16:49:36 -0400
To: kernel-janitors <kernel-janitors@lists.osdl.org>
In-Reply-To: <1161889418.7318.1.camel@alice>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

arg, i thought i compile tested everything, please use this
version.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.19-rc3-git1/net/atm/lec.c.orig	2006-10-26 20:21:48.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/atm/lec.c	2006-10-26 20:23:28.000000000 +0200
@@ -1321,11 +1321,10 @@ static int lane2_resolve(struct net_devi
 		if (table == NULL)
 			return -1;
 
-		*tlvs = kmalloc(table->sizeoftlvs, GFP_ATOMIC);
+		*tlvs = kmemdup(table->tlvs, table->sizeoftlvs, GFP_ATOMIC);
 		if (*tlvs == NULL)
 			return -1;
 
-		memcpy(*tlvs, table->tlvs, table->sizeoftlvs);
 		*sizeoftlvs = table->sizeoftlvs;
 
 		return 0;
@@ -1364,11 +1363,10 @@ static int lane2_associate_req(struct ne
 
 	kfree(priv->tlvs);	/* NULL if there was no previous association */
 
-	priv->tlvs = kmalloc(sizeoftlvs, GFP_KERNEL);
+	priv->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
 	if (priv->tlvs == NULL)
 		return (0);
 	priv->sizeoftlvs = sizeoftlvs;
-	memcpy(priv->tlvs, tlvs, sizeoftlvs);
 
 	skb = alloc_skb(sizeoftlvs, GFP_ATOMIC);
 	if (skb == NULL)
--- linux-2.6.19-rc3-git1/net/ax25/ax25_out.c.orig	2006-10-26 20:23:59.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/ax25/ax25_out.c	2006-10-26 20:24:15.000000000 +0200
@@ -70,11 +70,10 @@ ax25_cb *ax25_send_frame(struct sk_buff 
 	ax25->dest_addr   = *dest;
 
 	if (digi != NULL) {
-		if ((ax25->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
+		if ((ax25->digipeat = kmemdup(digi, sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
 			ax25_cb_put(ax25);
 			return NULL;
 		}
-		memcpy(ax25->digipeat, digi, sizeof(ax25_digi));
 	}
 
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
--- linux-2.6.19-rc3-git1/net/ax25/ax25_route.c.orig	2006-10-26 20:24:23.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/ax25/ax25_route.c	2006-10-26 20:24:50.000000000 +0200
@@ -432,11 +432,11 @@ int ax25_rt_autobind(ax25_cb *ax25, ax25
 	}
 
 	if (ax25_rt->digipeat != NULL) {
-		if ((ax25->digipeat = kmalloc(sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
+		if ((ax25->digipeat = kmemdup(ax25_rt->digipeat, 
+			sizeof(ax25_digi), GFP_ATOMIC)) == NULL) {
 			err = -ENOMEM;
 			goto put;
 		}
-		memcpy(ax25->digipeat, ax25_rt->digipeat, sizeof(ax25_digi));
 		ax25_adjust_path(addr, ax25->digipeat);
 	}
 
--- linux-2.6.19-rc3-git1/net/core/neighbour.c.orig	2006-10-26 20:25:20.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/core/neighbour.c	2006-10-26 20:25:52.000000000 +0200
@@ -1266,10 +1266,9 @@ void pneigh_enqueue(struct neigh_table *
 struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				      struct neigh_table *tbl)
 {
-	struct neigh_parms *p = kmalloc(sizeof(*p), GFP_KERNEL);
+	struct neigh_parms *p = kmemdup(&tbl->parms, sizeof(*p), GFP_KERNEL);
 
 	if (p) {
-		memcpy(p, &tbl->parms, sizeof(*p));
 		p->tbl		  = tbl;
 		atomic_set(&p->refcnt, 1);
 		INIT_RCU_HEAD(&p->rcu_head);
--- linux-2.6.19-rc3-git1/net/dccp/feat.c.orig	2006-10-26 20:26:12.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/dccp/feat.c	2006-10-26 20:27:26.000000000 +0200
@@ -279,12 +279,11 @@ static int dccp_feat_nn(struct sock *sk,
 	if (opt == NULL)
 		return -ENOMEM;
 
-	copy = kmalloc(len, GFP_ATOMIC);
+	copy = kmemdup(val, len, GFP_ATOMIC);
 	if (copy == NULL) {
 		kfree(opt);
 		return -ENOMEM;
 	}
-	memcpy(copy, val, len);
 
 	opt->dccpop_type = DCCPO_CONFIRM_R; /* NN can only confirm R */
 	opt->dccpop_feat = feature;
@@ -501,20 +500,18 @@ int dccp_feat_clone(struct sock *oldsk, 
 	list_for_each_entry(opt, &olddmsk->dccpms_pending, dccpop_node) {
 		struct dccp_opt_pend *newopt;
 		/* copy the value of the option */
-		u8 *val = kmalloc(opt->dccpop_len, GFP_ATOMIC);
+		u8 *val = kmemdup(opt->dccpop_val, opt->dccpop_len, GFP_ATOMIC);
 
 		if (val == NULL)
 			goto out_clean;
-		memcpy(val, opt->dccpop_val, opt->dccpop_len);
 
-		newopt = kmalloc(sizeof(*newopt), GFP_ATOMIC);
+		newopt = kmemdup(opt, sizeof(*newopt), GFP_ATOMIC);
 		if (newopt == NULL) {
 			kfree(val);
 			goto out_clean;
 		}
 
 		/* insert the option */
-		memcpy(newopt, opt, sizeof(*newopt));
 		newopt->dccpop_val = val;
 		list_add_tail(&newopt->dccpop_node, &newdmsk->dccpms_pending);
 
@@ -545,10 +542,9 @@ static int __dccp_feat_init(struct dccp_
 			    u8 *val, u8 len)
 {
 	int rc = -ENOMEM;
-	u8 *copy = kmalloc(len, GFP_KERNEL);
+	u8 *copy = kmemdup(val, len, GFP_KERNEL);
 
 	if (copy != NULL) {
-		memcpy(copy, val, len);
 		rc = dccp_feat_change(dmsk, type, feat, copy, len, GFP_KERNEL);
 		if (rc)
 			kfree(copy);
--- linux-2.6.19-rc3-git1/net/decnet/dn_dev.c.orig	2006-10-26 20:27:53.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/decnet/dn_dev.c	2006-10-26 20:28:09.000000000 +0200
@@ -255,12 +255,10 @@ static void dn_dev_sysctl_register(struc
 	struct dn_dev_sysctl_table *t;
 	int i;
 
-	t = kmalloc(sizeof(*t), GFP_KERNEL);
+	t = kmemdup(&dn_dev_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
 		return;
 
-	memcpy(t, &dn_dev_sysctl, sizeof(*t));
-
 	for(i = 0; i < ARRAY_SIZE(t->dn_dev_vars) - 1; i++) {
 		long offset = (long)t->dn_dev_vars[i].data;
 		t->dn_dev_vars[i].data = ((char *)parms) + offset;
--- linux-2.6.19-rc3-git1/net/ieee80211/softmac/ieee80211softmac_auth.c.orig	2006-10-26 20:30:00.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/ieee80211/softmac/ieee80211softmac_auth.c	2006-10-26 20:30:47.000000000 +0200
@@ -218,8 +218,7 @@ ieee80211softmac_auth_resp(struct net_de
 				net->challenge_len = WLAN_AUTH_CHALLENGE_LEN;
 			if (net->challenge != NULL)
 				kfree(net->challenge);
-			net->challenge = kmalloc(net->challenge_len, GFP_ATOMIC);
-			memcpy(net->challenge, data, net->challenge_len);
+			net->challenge = kmemdup(data, net->challenge_len, GFP_ATOMIC);
 			aq->state = IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE; 
 
 			/* We reuse the work struct from the auth request here.
--- linux-2.6.19-rc3-git1/net/ipv4/ipvs/ip_vs_app.c.orig	2006-10-26 20:31:52.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/ipv4/ipvs/ip_vs_app.c	2006-10-26 20:32:04.000000000 +0200
@@ -80,10 +80,9 @@ ip_vs_app_inc_new(struct ip_vs_app *app,
 	if (!pp->unregister_app)
 		return -EOPNOTSUPP;
 
-	inc = kmalloc(sizeof(struct ip_vs_app), GFP_KERNEL);
+	inc = kmemdup(app, sizeof(struct ip_vs_app), GFP_KERNEL);
 	if (!inc)
 		return -ENOMEM;
-	memcpy(inc, app, sizeof(*inc));
 	INIT_LIST_HEAD(&inc->p_list);
 	INIT_LIST_HEAD(&inc->incs_list);
 	inc->app = app;
--- linux-2.6.19-rc3-git1/net/ipv4/ipvs/ip_vs_proto.c.orig	2006-10-26 20:32:43.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/ipv4/ipvs/ip_vs_proto.c	2006-10-26 20:33:57.000000000 +0200
@@ -118,13 +118,7 @@ void ip_vs_protocol_timeout_change(int f
 int *
 ip_vs_create_timeout_table(int *table, int size)
 {
-	int *t;
-
-	t = kmalloc(size, GFP_ATOMIC);
-	if (t == NULL)
-		return NULL;
-	memcpy(t, table, size);
-	return t;
+	return kmemdup(table, size, GFP_ATOMIC);
 }
 
 
--- linux-2.6.19-rc3-git1/net/ipv6/addrconf.c.orig	2006-10-26 20:35:00.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/ipv6/addrconf.c	2006-10-26 20:35:33.000000000 +0200
@@ -3982,10 +3982,9 @@ static void addrconf_sysctl_register(str
 	struct addrconf_sysctl_table *t;
 	char *dev_name = NULL;
 
-	t = kmalloc(sizeof(*t), GFP_KERNEL);
+	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
 		return;
-	memcpy(t, &addrconf_sysctl, sizeof(*t));
 	for (i=0; t->addrconf_vars[i].data; i++) {
 		t->addrconf_vars[i].data += (char*)p - (char*)&ipv6_devconf;
 		t->addrconf_vars[i].de = NULL;
--- linux-2.6.19-rc3-git1/net/irda/irias_object.c.orig	2006-10-26 20:36:26.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/irda/irias_object.c	2006-10-26 20:36:49.000000000 +0200
@@ -501,13 +501,12 @@ struct ias_value *irias_new_octseq_value
 		len = IAS_MAX_OCTET_STRING;
 	value->len = len;
 
-	value->t.oct_seq = kmalloc(len, GFP_ATOMIC);
+	value->t.oct_seq = kmemdup(octseq, len, GFP_ATOMIC);
 	if (value->t.oct_seq == NULL){
 		IRDA_WARNING("%s: Unable to kmalloc!\n", __FUNCTION__);
 		kfree(value);
 		return NULL;
 	}
-	memcpy(value->t.oct_seq, octseq , len);
 	return value;
 }
 
--- linux-2.6.19-rc3-git1/net/netrom/nr_route.c.orig	2006-10-26 20:37:23.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/netrom/nr_route.c	2006-10-26 20:38:26.000000000 +0200
@@ -155,14 +155,13 @@ static int nr_add_node(ax25_address *nr,
 		atomic_set(&nr_neigh->refcount, 1);
 
 		if (ax25_digi != NULL && ax25_digi->ndigi > 0) {
-			if ((nr_neigh->digipeat = kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
+			if ((nr_neigh->digipeat = kmemdup(ax25_digi, 
+				sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
 				kfree(nr_neigh);
 				if (nr_node)
 					nr_node_put(nr_node);
 				return -ENOMEM;
 			}
-			memcpy(nr_neigh->digipeat, ax25_digi,
-					sizeof(*ax25_digi));
 		}
 
 		spin_lock_bh(&nr_neigh_list_lock);
@@ -432,11 +431,11 @@ static int nr_add_neigh(ax25_address *ca
 	atomic_set(&nr_neigh->refcount, 1);
 
 	if (ax25_digi != NULL && ax25_digi->ndigi > 0) {
-		if ((nr_neigh->digipeat = kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
+		if ((nr_neigh->digipeat = kmemdup(ax25_digi,
+			sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
 			kfree(nr_neigh);
 			return -ENOMEM;
 		}
-		memcpy(nr_neigh->digipeat, ax25_digi, sizeof(*ax25_digi));
 	}
 
 	spin_lock_bh(&nr_neigh_list_lock);
--- linux-2.6.19-rc3-git1/net/sched/act_ipt.c.orig	2006-10-26 20:38:51.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sched/act_ipt.c	2006-10-26 20:39:14.000000000 +0200
@@ -156,10 +156,9 @@ static int tcf_ipt_init(struct rtattr *r
 	    rtattr_strlcpy(tname, tb[TCA_IPT_TABLE-1], IFNAMSIZ) >= IFNAMSIZ)
 		strcpy(tname, "mangle");
 
-	t = kmalloc(td->u.target_size, GFP_KERNEL);
+	t = kmemdup(td, td->u.target_size, GFP_KERNEL);
 	if (unlikely(!t))
 		goto err2;
-	memcpy(t, td, td->u.target_size);
 
 	if ((err = ipt_init_target(t, tname, hook)) < 0)
 		goto err3;
--- linux-2.6.19-rc3-git1/net/sched/act_simple.c.orig	2006-10-26 20:39:21.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sched/act_simple.c	2006-10-26 20:39:43.000000000 +0200
@@ -71,11 +71,10 @@ static int tcf_simp_release(struct tcf_d
 
 static int alloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
 {
-	d->tcfd_defdata = kmalloc(datalen, GFP_KERNEL);
+	d->tcfd_defdata = kmemdup(defdata, datalen, GFP_KERNEL);
 	if (unlikely(!d->tcfd_defdata))
 		return -ENOMEM;
 	d->tcfd_datalen = datalen;
-	memcpy(d->tcfd_defdata, defdata, datalen);
 	return 0;
 }
 
--- linux-2.6.19-rc3-git1/net/sched/ematch.c.orig	2006-10-26 20:41:00.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sched/ematch.c	2006-10-26 20:41:16.000000000 +0200
@@ -251,12 +251,11 @@ static int tcf_em_validate(struct tcf_pr
 					goto errout;
 				em->data = *(u32 *) data;
 			} else {
-				void *v = kmalloc(data_len, GFP_KERNEL);
+				void *v = kmemdup(data, data_len, GFP_KERNEL);
 				if (v == NULL) {
 					err = -ENOBUFS;
 					goto errout;
 				}
-				memcpy(v, data, data_len);
 				em->data = (unsigned long) v;
 			}
 		}
--- linux-2.6.19-rc3-git1/net/sctp/sm_make_chunk.c.orig	2006-10-26 20:41:39.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sctp/sm_make_chunk.c	2006-10-26 20:42:33.000000000 +0200
@@ -1910,10 +1910,9 @@ int sctp_process_init(struct sctp_associ
 	/* Copy cookie in case we need to resend COOKIE-ECHO. */
 	cookie = asoc->peer.cookie;
 	if (cookie) {
-		asoc->peer.cookie = kmalloc(asoc->peer.cookie_len, gfp);
+		asoc->peer.cookie = kmemdup(cookie, asoc->peer.cookie_len, gfp);
 		if (!asoc->peer.cookie)
 			goto clean_up;
-		memcpy(asoc->peer.cookie, cookie, asoc->peer.cookie_len);
 	}
 
 	/* RFC 2960 7.2.1 The initial value of ssthresh MAY be arbitrarily
--- linux-2.6.19-rc3-git1/net/sunrpc/auth_gss/auth_gss.c.orig	2006-10-26 20:44:40.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sunrpc/auth_gss/auth_gss.c	2006-10-26 20:44:59.000000000 +0200
@@ -198,11 +198,10 @@ simple_get_netobj(const void *p, const v
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	dest->data = kmalloc(len, GFP_KERNEL);
+	dest->data = kmemdup(p, len, GFP_KERNEL);
 	if (unlikely(dest->data == NULL))
 		return ERR_PTR(-ENOMEM);
 	dest->len = len;
-	memcpy(dest->data, p, len);
 	return q;
 }
 
--- linux-2.6.19-rc3-git1/net/sunrpc/auth_gss/gss_krb5_mech.c.orig	2006-10-26 20:45:18.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sunrpc/auth_gss/gss_krb5_mech.c	2006-10-26 20:45:31.000000000 +0200
@@ -70,10 +70,9 @@ simple_get_netobj(const void *p, const v
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	res->data = kmalloc(len, GFP_KERNEL);
+	res->data = kmemdup(p, len, GFP_KERNEL);
 	if (unlikely(res->data == NULL))
 		return ERR_PTR(-ENOMEM);
-	memcpy(res->data, p, len);
 	res->len = len;
 	return q;
 }
--- linux-2.6.19-rc3-git1/net/sunrpc/auth_gss/gss_spkm3_mech.c.orig	2006-10-26 20:45:44.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sunrpc/auth_gss/gss_spkm3_mech.c	2006-10-26 20:45:55.000000000 +0200
@@ -76,10 +76,9 @@ simple_get_netobj(const void *p, const v
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	res->data = kmalloc(len, GFP_KERNEL);
+	res->data = kmemdup(p, len, GFP_KERNEL);
 	if (unlikely(res->data == NULL))
 		return ERR_PTR(-ENOMEM);
-	memcpy(res->data, p, len);
 	return q;
 }
 
--- linux-2.6.19-rc3-git1/net/sunrpc/clnt.c.orig	2006-10-26 20:46:26.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/sunrpc/clnt.c	2006-10-26 20:46:40.000000000 +0200
@@ -253,10 +253,9 @@ rpc_clone_client(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *new;
 
-	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	new = kmemdup(clnt, sizeof(*new), GFP_KERNEL);
 	if (!new)
 		goto out_no_clnt;
-	memcpy(new, clnt, sizeof(*new));
 	atomic_set(&new->cl_count, 1);
 	atomic_set(&new->cl_users, 0);
 	new->cl_parent = clnt;
--- linux-2.6.19-rc3-git1/net/xfrm/xfrm_user.c.orig	2006-10-26 20:46:58.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/xfrm/xfrm_user.c	2006-10-26 20:47:35.000000000 +0200
@@ -244,11 +244,10 @@ static int attach_one_algo(struct xfrm_a
 	*props = algo->desc.sadb_alg_id;
 
 	len = sizeof(*ualg) + (ualg->alg_key_len + 7U) / 8;
-	p = kmalloc(len, GFP_KERNEL);
+	p = kmemdup(ualg, len, GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	memcpy(p, ualg, len);
 	strcpy(p->alg_name, algo->name);
 	*algpp = p;
 	return 0;
@@ -263,11 +262,10 @@ static int attach_encap_tmpl(struct xfrm
 		return 0;
 
 	uencap = RTA_DATA(rta);
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	p = kmemdup(uencap, sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	memcpy(p, uencap, sizeof(*p));
 	*encapp = p;
 	return 0;
 }
@@ -305,11 +303,10 @@ static int attach_one_addr(xfrm_address_
 		return 0;
 
 	uaddrp = RTA_DATA(rta);
-	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	p = kmemdup(uaddrp, sizeof(*p), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	memcpy(p, uaddrp, sizeof(*p));
 	*addrpp = p;
 	return 0;
 }
--- linux-2.6.19-rc3-git1/net/ipv4/cipso_ipv4.c.orig	2006-10-26 22:39:20.000000000 +0200
+++ linux-2.6.19-rc3-git1/net/ipv4/cipso_ipv4.c	2006-10-26 22:39:35.000000000 +0200
@@ -377,12 +377,11 @@ int cipso_v4_cache_add(const struct sk_b
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL)
 		return -ENOMEM;
-	entry->key = kmalloc(cipso_ptr_len, GFP_ATOMIC);
+	entry->key = kmemdup(cipso_ptr, cipso_ptr_len, GFP_ATOMIC);
 	if (entry->key == NULL) {
 		ret_val = -ENOMEM;
 		goto cache_add_failure;
 	}
-	memcpy(entry->key, cipso_ptr, cipso_ptr_len);
 	entry->key_len = cipso_ptr_len;
 	entry->hash = cipso_v4_map_cache_hash(cipso_ptr, cipso_ptr_len);
 	atomic_inc(&secattr->cache->refcount);


