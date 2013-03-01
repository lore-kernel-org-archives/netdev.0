From: channing <chao.bi@intel.com>
Subject: Re: [PATCH] n_gsm: Add Mutex to avoid race when net destroy
Date: Fri, 01 Mar 2013 16:51:55 +0800
Message-ID: <1362127915.31563.18.camel@bichao>
References: <1362029486.31563.5.camel@bichao>  <512F28FD.9030502@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
	vincentx.pillet@intel.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <512F28FD.9030502@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-02-28 at 10:53 +0100, Jiri Slaby wrote:
> On 02/28/2013 06:31 AM, channing wrote:
> > 
> > when gsm Net is enabled, data on dlci is transferrd by
> > gsm_mux_net_start_xmit(), while userspace may trigger
> > ioctrl to call gsm_destroy_network() during data was
> > transferring, because there is no mutex protection between
> > the two functions, following scenario may happen:
> > 
> > 1) gsm_mux_net_start_xmit() calls muxnet_get(mux_net);
> > 2) gsm_destroy_network() is called from ioctrl, and it
> > will not call net_free() to release net device because
> > net device is still referred in step 1)
> > 3) continue execute step 1), gsm_mux_net_start_xmit()
> > calls muxnet_put(mux_net), and then calls net_free() to
> > release net device.
> > 4) if userspace triggers gsm_create_network() at same time
> > with net_free() in step 3). it will hit race on dlci->net.
> > 
> > This patch is to add a mutex in tx function to avoid race
> > between it and destroy function.
> > 
> > Signed-off-by: Chao Bi <chao.bi@intel.com>
> > Signed-off-by: Pillet Vincent <vincentx.pillet@intel.com>
> > ---
> >  drivers/tty/n_gsm.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/tty/n_gsm.c b/drivers/tty/n_gsm.c
> > index 4a43ef5..0ca810a 100644
> > --- a/drivers/tty/n_gsm.c
> > +++ b/drivers/tty/n_gsm.c
> > @@ -2660,6 +2660,7 @@ static int gsm_mux_net_start_xmit(struct sk_buff *skb,
> >  {
> >  	struct gsm_mux_net *mux_net = (struct gsm_mux_net *)netdev_priv(net);
> >  	struct gsm_dlci *dlci = mux_net->dlci;
> > +	mutex_lock(&dlci->mutex);
> 
> Nack, start_xmit may be called in an atomic context -- you cannot call
> mutex.
> 
> >  	muxnet_get(mux_net);
> >  
> >  	skb_queue_head(&dlci->skb_list, skb);
> > @@ -2669,6 +2670,7 @@ static int gsm_mux_net_start_xmit(struct sk_buff *skb,
> >  	/* And tell the kernel when the last transmit started. */
> >  	net->trans_start = jiffies;
> >  	muxnet_put(mux_net);
> 
> Instead the concept is broken. If this was the last reference (as
> described in your steps above), it would blow up for the same reason I
> refer to above, i.e. net_free here would call unregister_netdev which is
> not atomic. Plus it will definitely deadlock because unregister_netdev
> waits for start_xmit to finish.
> 
> It should stop the queue and schedule a workqueue to lock the mutex,
> unregister the hetdev and reset dlci->net. (Or maybe just call
> muxnet_put with the lock held.)

Thanks, Jiri, you're right, I didn't notice that in validation because
DEBUG_ATOMIC_SLEEP is not enabled in my platform :( Now I'm trying to
work out the workqueue solution, when it finished I'll re-submit for
review. What do you mean by "call muxnet_put with lock held"? do you
mean to use spin lock instead of mutex?
 
> 
> That will fix 4), but there is still a bug: what protects
> gsm_create_network to be called twice or more in a sequence thus
> re-setting dlci->net to a new and new pointer?

Yes, that's a problem, Vincent has already noticed that and has a check
in gsmtty_ioctl to avoid call net creation multi time, I thought it
might be patch for other issue so didn't put them together.

> 
> > +	mutex_unlock(&dlci->mutex);
> >  	return NETDEV_TX_OK;
> >  }
> 
> thanks,
