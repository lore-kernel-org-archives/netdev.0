From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Wed, 10 Feb 2010 15:48:47 +0100
Message-ID: <201002101548.47634.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de> <9ae48b021002080914j2811e7cejd1c29aa3653ba8de@mail.gmail.com> <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Ed Swierk <eswierk@aristanetworks.com>, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:58385 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296Ab0BJOtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:49:07 -0500
In-Reply-To: <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 February 2010, Sridhar Samudrala wrote:
> I am also seeing this issue with net-next-2.6.
> Basically macvtap_put_user() and macvtap_get_user() call copy_to/from_user
> from within a RCU read-side critical section.
> 
> The following patch fixes this issue by releasing the RCU read lock before
> calling these routines, but instead hold a reference to q->sk.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Yes, we need something like this, but we also need to protect the
device from going away. The concept right now is to use file_get_queue
to protect both the macvtap_queue and the macvlan_dev from going
away. The sock_hold will keep the macvtap_queue around, but
as far as I can tell, a user could still destroy the macvlan_dev
using netlink at the same time, which still breaks.

>  /* Get packet from user space buffer */
> -static ssize_t macvtap_get_user(struct macvtap_queue *q,
> +static ssize_t macvtap_get_user(struct macvlan_dev *vlan, struct sock *sk,
>                                 const struct iovec *iv, size_t count,
>                                 int noblock)
>  {
> @@ -331,10 +331,10 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
>         if (unlikely(len < ETH_HLEN))
>                 return -EINVAL;
>  
> -       skb = sock_alloc_send_skb(&q->sk, NET_IP_ALIGN + len, noblock, &err);
> +       skb = sock_alloc_send_skb(sk, NET_IP_ALIGN + len, noblock, &err);
>  
>         if (!skb) {
> -               macvlan_count_rx(q->vlan, 0, false, false);
> +               macvlan_count_rx(vlan, 0, false, false);
>                 return err;
>         }
>  
> @@ -342,14 +342,14 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
>         skb_put(skb, count);
>  
>         if (skb_copy_datagram_from_iovec(skb, 0, iv, 0, len)) {
> -               macvlan_count_rx(q->vlan, 0, false, false);
> +               macvlan_count_rx(vlan, 0, false, false);
>                 kfree_skb(skb);
>                 return -EFAULT;
>         }
>  
>         skb_set_network_header(skb, ETH_HLEN);
>  
> -       macvlan_start_xmit(skb, q->vlan->dev);
> +       macvlan_start_xmit(skb, vlan->dev);
>  
>         return count;
>  }

What are these changes for? The lifetime of q is the same as &q->sk, so
it won't change anything, right?
Moving the macvlan_count_rx and maxclan_start_xmit under the lock
should be fine though, but we'd have to take it twice then for
each transmit.

I'd hope that this could get simpler by adding zero-copy transmit,
where we first get_user() the whole buffer and do the rest under
rcu_read_lock_bh().

> @@ -393,15 +399,20 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
>  {
>         struct file *file = iocb->ki_filp;
>         struct macvtap_queue *q = macvtap_file_get_queue(file);
> +       struct macvlan_dev *vlan;
> +       struct sock *sk;
>  
>         DECLARE_WAITQUEUE(wait, current);
>         struct sk_buff *skb;
>         ssize_t len, ret = 0;
>  
> -       if (!q) {
> -               ret = -ENOLINK;
> -               goto out;
> -       }
> +       if (!q)
> +               return -ENOLINK;
> +
> +       vlan = q->vlan;
> +       sk = &q->sk;
> +       sock_hold(sk);
> +       macvtap_file_put_queue();

Here, we probably need to prevent vlan from going away by dev_hold(),
not just sock_hold(). Or is one implied by the other?

	Arnd
