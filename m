From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Mon, 19 May 2014 19:06:52 +0300
Message-ID: <20140519160652.GE31595@redhat.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>
 <5379CE8D.2030405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895AbaESQIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 12:08:09 -0400
Content-Disposition: inline
In-Reply-To: <5379CE8D.2030405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 05:27:41PM +0800, Jason Wang wrote:
> > @@ -1330,47 +1329,26 @@ done:
> >  static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
> >  			   const struct iovec *iv, ssize_t len, int noblock)
> >  {
> > -	DECLARE_WAITQUEUE(wait, current);
> >  	struct sk_buff *skb;
> >  	ssize_t ret = 0;
> > +	int peeked, err, off = 0;
> >  
> >  	tun_debug(KERN_INFO, tun, "tun_do_read\n");
> >  
> > -	if (unlikely(!noblock))
> > -		add_wait_queue(&tfile->wq.wait, &wait);
> > -	while (len) {
> > -		if (unlikely(!noblock))
> > -			current->state = TASK_INTERRUPTIBLE;
> > +	if (!len)
> > +		return ret;
> >  
> > -		/* Read frames from the queue */
> > -		if (!(skb = skb_dequeue(&tfile->socket.sk->sk_receive_queue))) {
> > -			if (noblock) {
> > -				ret = -EAGAIN;
> > -				break;
> > -			}
> > -			if (signal_pending(current)) {
> > -				ret = -ERESTARTSYS;
> > -				break;
> > -			}
> > -			if (tun->dev->reg_state != NETREG_REGISTERED) {
> > -				ret = -EIO;
> > -				break;
> > -			}
> > -
> > -			/* Nothing to read, let's sleep */
> > -			schedule();
> > -			continue;
> > -		}
> > +	if (tun->dev->reg_state != NETREG_REGISTERED)
> > +		return -EIO;
> >  
> > +	/* Read frames from queue */
> > +	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
> > +				  &peeked, &off, &err);
> > +	if (skb) {
> 
> Still a little bit difference. We check the reg_state after we're sure
> there's nothing left in sk_receive_queue. But this patch returns -EIO
> before trying to dequeue skb.


Yes but what's the concern here? What does userspace do
to notice the change in behaviour?
tun_detach calls tun_queue_purge before unregister_netdevice
so apparently there's never anything in queue when
state isn't registered.
Did I miss something?

-- 
MST
