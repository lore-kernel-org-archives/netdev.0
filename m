From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: changing usbnet's API to better deal with cdc-ncm
Date: Thu, 6 Sep 2012 10:13:01 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, "bjorn-yOkvZcmFvRU@public.gmane.org" <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2791550.LhGu6po6Xy-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum-l3A5Bk7waGM@public.gmane.org]


> looking at cdc-ncm it seeems to me that cdc-ncm is forced to play very
> dirty games because usbnet doesn't have a notion about aggregating
> packets for a single transfer.

Several issues need to be improved:
Tx path:
1. IP packets must be accumulated in one NTB. Currently it's done via data copy.
Preferred way would be a possibility to have a list of skb-s in resulting frame sent down.

2. Timer is needed to accumulate enough packets to get acceptable throughput and reducing amount of HW INTs on device side.
If we get access to Tx queue size and can read skb from it, time can be removed. But Tx queue is above usbnet, so doesn't look possible in current framework.

3. While trying to get best throughput we also need to keep latency in mind, because in some setups it is quite important.
As a simple solution configuration parameters could be used to address this issue.

Rx path:
4. IP packets are cloned to separate skb and length of actual data set to eth packet size, while skb size is still the same as skb containing full NTB frame. This causes problems with TCP stack when throughput is high because of flow control in the stack, if too much data allocated.
Someone suggested a patch for it, which was rejected. Anyway, I don't think copy data to a new skb would be a nice solution, but keeping several clones with size equal to incoming skb in not good either. 

/alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
