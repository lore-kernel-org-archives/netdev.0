From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless-testing (2.6.36-rc6):  inconsistent {IN-SOFTIRQ-W} ->
 {SOFTIRQ-ON-W} usage.
Date: Fri, 01 Oct 2010 13:49:49 +0200
Message-ID: <1285933789.3739.34.camel@jlt3.sipsolutions.net>
References: <4CA4F000.2060509@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4CA4F000.2060509-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-30 at 13:16 -0700, Ben Greear wrote:
> We saw this on a system that has two ath9k APs, some extra routing tables
> and rules to use them, and a user-space 'bridge' that uses packet-sockets.
> 
> Aside from a few patches to help virtualize wireless devices (and none directly to ath9k),
> this is today's wireless-testing tree.
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.36-rc6-wl+ #20
> ---------------------------------
> inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> kworker/u:0/5 [HC0[0]:SC0[0]:HE1:SE1] takes:
>   (&(&list->lock)->rlock){+.?...}, at: [<c0741066>] packet_rcv+0x1f3/0x27a

I think this is due to

commit 5ed3bc7288487bd4f891f420a07319e0b538b4fe
Author: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date:   Thu Jun 24 14:38:30 2010 -0400

    mac80211: use netif_receive_skb in ieee80211_tx_status callpath


since

/**
 *      netif_receive_skb - process receive buffer from network
 *      @skb: buffer to process
 *
 *      netif_receive_skb() is the main receive data processing function.
 *      It always succeeds. The buffer may be dropped during processing   
 *      for congestion control or by the protocol layers.
 *
 *      This function may only be called from softirq context and interrupts
 *      should be enabled.

but we don't explicitly disable BHs. I suppose we should impose the same
on drivers calling ieee80211_tx_status().

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
