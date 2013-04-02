From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 1/6] mac802154: Immediately retry
	sending failed packets
Date: Tue, 02 Apr 2013 16:28:40 -0400
Message-ID: <515B3F78.2020301@signal11.us>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364928481-1813-2-git-send-email-alan@signal11.us>
	<CAJmB2rCr5ds11+iN=W5GCKsUgdfb57uKg+mH4NY4CWw6EFCTbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CAJmB2rCr5ds11+iN=W5GCKsUgdfb57uKg+mH4NY4CWw6EFCTbg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/02/2013 03:11 PM, Alexander Smirnov wrote:
> 2013/4/2 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org <mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>>
> 
>     When ops->xmit() fails, immediately retry. Previously the packet was
>     sent
>     to the back of the workqueue.
> 
>     Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org <mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>>
>     ---
>      net/mac802154/tx.c | 17 ++++++++---------
>      1 file changed, 8 insertions(+), 9 deletions(-)
> 
>     diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
>     index 4e09d07..fbf937c 100644
>     --- a/net/mac802154/tx.c
>     +++ b/net/mac802154/tx.c
>     @@ -59,19 +59,18 @@ static void mac802154_xmit_worker(struct
>     work_struct *work)
>                     }
>             }
> 
>     -       res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
>     +       do {
>     +               res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
>     +               if (res && ++xw->xmit_attempts >=
>     MAC802154_MAX_XMIT_ATTEMPTS) {
>     +                       pr_debug("transmission failed for %d times",
>     +                                MAC802154_MAX_XMIT_ATTEMPTS);
>     +                       break;
>     +               }
>     +       } while (res);
> 
>  
> 
> IIRC this 802.15.4 stack uses single-thread-work-queue and all RX/TX
> are performed by using it.

Hi Alexander,

Yes, that is true. As is currently implemented, the driver xmit()
functions are called from a workqueue and block until the packet is sent.


> Doing TX retry in the way you proposed -
> it's possible that you will block other packets pending in this
> queue.

Yes. Since sending data is a blocking operation, any time spent sending
(or re-sending) is blocking.

As it was before this patch series, with the buffer (workqueue) growing
arbitrarily large, doing retry by putting a packet at the end of the
workqueue was largely useless because by the time it came to retry it,
any state associated with it (with respect to fragmentation/reassembly)
had expired.

Keep in mind that with the netif stop/wake code, putting retries at the
end of the workqueue or doing them immediately is basically the same
thing, since the workqueue is no longer the packet queue (and will
ideally only have 0 or 1 packets in it). The workqueue (with these
patches) only serves to lift the driver xmit() calls out of atomic
context, allowing them to block.

However, it is easy to envision one process clogging up the works with
retries by sending many packets to an unavailable address.

What do you recommend doing here instead?

> Despite on Linux is already 'slow' system to provide
> real-time for specific 802.15.4 features, I think it's not a good
> idea to increase nodes communication latency.

With the transmit buffer length increased (and actually being used),
maybe the packets with realtime requirements can be given a higher
priority to deal with these requirements.

Alan.

> 
> 
>      out:
>             mutex_unlock(&xw->priv->phy->pib_lock);
> 
>     -       if (res) {
>     -               if (xw->xmit_attempts++ < MAC802154_MAX_XMIT_ATTEMPTS) {
>     -                       queue_work(xw->priv->dev_workqueue, &xw->work);
>     -                       return;
>     -               } else
>     -                       pr_debug("transmission failed for %d times",
>     -                                MAC802154_MAX_XMIT_ATTEMPTS);
>     -       }
> 
>             dev_kfree_skb(xw->skb);
> 
>     --
>     1.7.11.2
> 
> 


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
