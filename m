From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 1 May 2008 10:58:39 +0200
Message-ID: <200805011058.40197.mb@bu3sch.de>
References: <1209607368.7173.20.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209607368.7173.20.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 01 May 2008 04:02:48 Johannes Berg wrote:
> Hi,
> 
> Whenever you run a monitor interface in mac80211, you can see lots of
> truesize bugs:
> 
> SKB BUG: Invalid truesize (464) len=307, sizeof(sk_buff)=176
> 
> It appears to be caused by mac80211's re-injection of the transmitted
> frame. For those not familiar, here's what happens:
> 
> When a frame comes in on say wlan0's hard_start_xmit(), it is prepared
> for transmission by the code there (802.11 headers added etc.) and then
> scheduled to the master interface. Once it arrives on the master
> (wmaster0) interface's hard_start_xmit(), it is modified again and
> finally handed to the driver.
> 
> When the driver has transmitted the frame (successfully or not) it
> reports the status of the transmission to mac80211 including the skb the
> driver was given. At that point, things go different depending on
> circumstances.
> 
> If no monitor interfaces are present, mac80211 simply orphans the skb
> and destroys it. If there are monitor interfaces, it pushes some data
> into the skb (the radiotap transmit status) and hands clones of the skb
> to netif_rx() for each monitor interface, or the skb itself for the last
> interface in the list.

Hm, unrelated to this...
But I am wondering what happens if the driver adds a device header to the skb.
Is that header then also passed up netif_rx()?
This doesn't happen for b43, as we use the DMA fragmentation to transmit the header,
but it might happen for zd1211rw and others.

> All this is in net/mac80211/main.c:ieee80211_tx_status.
> 
> Now, the thing is that the skb truesize bug ONLY occurs when the last
> part here is done when a radiotap monitor interface is present, if you
> add
> 
> 	dev_kfree_skb(skb);
> 	return;
> 
> in that function somewhere before the skb_orphan() call it never
> happens. Hence, I'm confused. Since I only have a single monitor
> interface when this happens, it can't be due to af_packet either,
> afaict.
> 
> Can anyone help me diagnose this?

Seems the skb->destructor messes it up.

-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
