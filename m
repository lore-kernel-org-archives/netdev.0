From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netchannel subsystem.
Date: Tue, 16 May 2006 11:07:17 +0400
Message-ID: <20060516070717.GA12719@2ka.mipt.ru>
References: <200605051248.42662.kelly@au.ibm.com> <200605161102.29472.kelly@au.ibm.com> <20060516061909.GA28670@2ka.mipt.ru> <20060515.235712.26771832.davem@davemloft.net> <20060516065923.GA8649@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:30167 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751614AbWEPHHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 03:07:32 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060516065923.GA8649@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006 at 10:59:23AM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Mon, May 15, 2006 at 11:57:12PM -0700, David S. Miller (davem@davemloft.net) wrote:
> > From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > Date: Tue, 16 May 2006 10:19:09 +0400
> > 
> > > +static int netchannel_convert_skb_ipv4(struct sk_buff *skb, struct unetchannel *unc)
> > > +{
> >  ...
> > > +	switch (unc->proto) {
> > > +		case IPPROTO_TCP:
> >  ...
> > > +		case IPPROTO_UDP:
> >  ...
> > 
> > Why do people write code like this?
> > 
> > Port location is protocol agnostic, there are always 2
> > 16-bit ports at beginning of header without exception.
> > 
> > Without this, ICMP would be useless :-)
> 
> And what if we use ESP which would place it's hashed sequence number as
> port?

Actually it should be one big hash, no matter if it is ipv4/tcp or
ipv6/esp, src/dst/sport/dport/proto were created just to allow easier
debug in ipv4 environment.

Attached patch for userspace copy:

--- /tmp/netchannel.1	2006-05-16 10:33:17.000000000 +0400
+++ /tmp/netchannel.2	2006-05-16 11:23:44.000000000 +0400
@@ -35,10 +35,10 @@
  
 diff --git a/include/linux/netchannel.h b/include/linux/netchannel.h
@@ -100,6 +100,7 @@
 +
 +	struct page *		(*nc_alloc_page)(unsigned int size);
 +	void			(*nc_free_page)(struct page *page);
++	int			(*nc_read_data)(struct netchannel *, unsigned int *len, void __user *arg);
 +
 +	struct sk_buff_head 	list;
 +};
@@ -228,10 +229,10 @@
  		ret = deliver_skb(skb, pt_prev, orig_dev);
 diff --git a/net/core/netchannel.c b/net/core/netchannel.c
 --- /dev/null
 +++ b/net/core/netchannel.c
-@@ -0,0 +1,583 @@
+@@ -0,0 +1,649 @@
 +/*
 + * 	netchannel.c
 + * 
@@ -578,6 +579,40 @@
 +	return err;
 +}
 +
++/*
++ * Actually it should be something like recvmsg().
++ */
++static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *len, void __user *arg)
++{
++	unsigned int copied;
++	struct sk_buff *skb;
++	struct iovec to;
++	int err = -EINVAL;
++	
++	to.iov_base = arg;
++	to.iov_len = *len;
++
++	skb = skb_dequeue(&nc->list);
++	if (!skb)
++		return -EAGAIN;
++
++	copied = skb->len;
++	if (copied > *len)
++		copied = *len;
++	
++	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
++		err = skb_copy_datagram_iovec(skb, 0, &to, copied);
++	} else {
++		err = skb_copy_and_csum_datagram_iovec(skb,0, &to);
++	}
++
++	*len = (err == 0)?copied:0;
++
++	kfree_skb(skb);
++
++	return err;
++}
++
 +static int netchannel_create(struct unetchannel *unc)
 +{
 +	struct netchannel *nc;
@@ -612,6 +647,8 @@
 +	atomic_set(&nc->refcnt, 1);
 +	memcpy(&nc->unc, unc, sizeof(struct unetchannel));
 +
++	nc->nc_read_data = &netchannel_copy_to_user;
++
 +	hlist_add_head_rcu(&nc->node, &bucket->head);
 +
 +out_unlock:
@@ -658,6 +695,30 @@
 +	return 0;
 +}
 +
++static int netchannel_recv_data(struct unetchannel_control *ctl, void __user *data)
++{
++	int ret = -ENODEV;
++	struct netchannel_cache_head *bucket;
++	struct netchannel *nc;
++	
++	bucket = netchannel_bucket(&ctl->unc);
++
++	mutex_lock(&bucket->mutex);
++
++	nc = netchannel_check_full(&ctl->unc, bucket);
++	if (!nc)
++		nc = netchannel_check_dest(&ctl->unc, bucket);
++
++	if (!nc)
++		goto out_unlock;
++
++	ret = nc->nc_read_data(nc, &ctl->len, data);
++
++out_unlock:
++	mutex_unlock(&bucket->mutex);
++	return ret;
++}
++
 +asmlinkage int sys_netchannel_control(void __user *arg)
 +{
 +	struct unetchannel_control ctl;
@@ -677,10 +738,16 @@
 +		case NETCHANNEL_REMOVE:
 +			ret = netchannel_remove(&ctl.unc);
 +			break;
++		case NETCHANNEL_READ:
++			ret = netchannel_recv_data(&ctl, arg + sizeof(struct unetchannel_control));
++			break;
 +		default:
 +			ret = -EINVAL;
 +			break;
 +	}
++	
++	if (copy_to_user(arg, &ctl, sizeof(struct unetchannel_control)))
++		return -ERESTARTSYS;
 +
 +	return ret;
 +}


-- 
	Evgeniy Polyakov
