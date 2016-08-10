From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 9 Aug 2016 20:09:36 -0500
Message-ID: <57AA7ED0.9000707@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
 <214dcbb7-0c3b-1e00-3e50-db513d77b10b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org, bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <214dcbb7-0c3b-1e00-3e50-db513d77b10b-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:

> nr_frags can't be bigger than MAX_SKB_FRAGS, hence these checks all
> other drivers do against 1 + MAX_SKB_FRAGS.

Doh, I just realized something.  emac_mac_tx_buf_send() just needs to 
make sure that there's enough room for ONE skb.  For some reason I 
thought it had to make sure there's enough room for multiple SKBs.

Now it makes a lot more sense.  Thank you.

So it looks like a given SKB can occupy 3 + nr_frags descriptors.  So I 
need to change that line to:

	if (emac_tpd_num_free_descs(tx_q) < (MAX_SKB_FRAGS + 3))
		netif_stop_queue(adpt->netdev);

Question, some  drivers do <= instead of just <, like this:

	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
		netif_tx_stop_queue(txq);

Is it necessary to stop the queue if there exactly enough descriptors to 
hold an SKB?  Shouldn't the above be this instead:

	if (ring->free_bds < (MAX_SKB_FRAGS + 1))
		netif_tx_stop_queue(txq);


>> However, I'm confused about one thing.  Almost every other driver just
>> sets "netdev->mtu = new_mtu" and does nothing else.  I can't find any
>> other driver that actually stops the RX path, reprograms the hardware,
>> and then restarts the RX path.  I know this is a stupid question, but
>> why is my driver doing that?
>
> Most drivers allocate RX buffer sizes that are usually bigger than the
> MTU, but would probably silently fail or expose transient behavior once
> the MTU changes to greater than the size pre-defined.

So it looks like the real problem is a race condition between

	adpt->rxbuf_size = new_mtu > EMAC_DEF_RX_BUF_SIZE ?
		ALIGN(max_frame, 8) : EMAC_DEF_RX_BUF_SIZE;

and

	if (netif_running(netdev))
		return emac_reinit_locked(adpt);


That is, if the interface is running, I set rxbuf_size.  If suddenly I 
receive some packets, then the driver will use the wrong buffer size.

Is there an easy way for me to stop the RX path before I set rxbuf_size? 
  Some netif_xxx function I can call?


-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
