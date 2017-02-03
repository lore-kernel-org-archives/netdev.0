From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Understanding mutual exclusion between rtnl_lock and
 rcu_read_lock
Date: Thu, 02 Feb 2017 21:21:23 -0800
Message-ID: <1486099283.21871.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com>
         <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Joel Cunningham <joel.cunningham@me.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33309 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdBCFV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 00:21:26 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so777462pfg.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 21:21:26 -0800 (PST)
In-Reply-To: <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 15:52 -0800, Alexander Duyck wrote:
> On Thu, Feb 2, 2017 at 3:47 PM, Joel Cunningham <joel.cunningham@me.com> wrote:
> > Hi,
> >
> > I’m studying the synchronization used on different parts of struct net_device and I’m struggling to understand how structure member modifications in dev_ioctl are synchronized.  Getters in dev_ifsioc_locked() are only holding rcu_read_lock() while setters in dev_ifsioc() are holding rtnl_lock, but not using RCU APIs.  I was specifically looking at SIOCGIFHWADDR/SIOCSIFHWADDR.  What’s to prevent one CPU from executing a getter and another CPU from executing a setter resulting in possibly a torn read/write?  I didn’t see anything in rtnl_lock() that would wait for any rcu_reader_lock() critical sections (on other CPUs) to finish before acquiring the mutex.
> >
> > Is there something about dev_ioctl that prevents parallel execution? or maybe something I still don’t understand about the RCU implementation?
> >
> > Thanks,
> >
> > Joel
> 
> My advice would be to spend more time familiarizing yourself with RCU.
> The advantage of RCU is that it allows for updates while other threads
> are accessing the data.  The rtnl_lock is just meant to prevent
> multiple writers from updating the data simultaneously.  So between
> writers the rtnl_lock is used to keep things synchronized, but between
> writers and readers the mechanism that is meant to protect the data
> and keep it sane is RCU.

Note that sometimes we do not properly handle the case one field can be
written by a writer holding RTNL (or socket lock or something else)

We often believe compiler wont do something stupid, but it can
sometimes.

We definitely should scrutinize things a bit more, or maybe add __rcu
like annotations to catch potential problems earlier.

We recently found an issue in drivers/net/macvtap.c and
drivers/net/tun.c using q->vnet_hdr_sz without proper annotation.

macvtap patch would be :

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 4026185658381df004a7d641e2be7bcb9a45b509..d11a807565acf371f9bbb4afbfaca1aacd000138 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -681,7 +681,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	size_t linear;
 
 	if (q->flags & IFF_VNET_HDR) {
-		vnet_hdr_len = q->vnet_hdr_sz;
+		vnet_hdr_len = READ_ONCE(q->vnet_hdr_sz);
 
 		err = -EINVAL;
 		if (len < vnet_hdr_len)
@@ -820,7 +820,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
-		vnet_hdr_len = q->vnet_hdr_sz;
+		vnet_hdr_len = READ_ONCE(q->vnet_hdr_sz);
 		if (iov_iter_count(iter) < vnet_hdr_len)
 			return -EINVAL;
 
@@ -1090,7 +1090,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		if (s < (int)sizeof(struct virtio_net_hdr))
 			return -EINVAL;
 
-		q->vnet_hdr_sz = s;
+		WRITE_ONCE(q->vnet_hdr_sz, s);
 		return 0;
 
 	case TUNGETVNETLE:
