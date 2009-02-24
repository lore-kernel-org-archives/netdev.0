From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated
 and rx path
Date: Tue, 24 Feb 2009 11:34:07 +0800
Message-ID: <1235446447.6354.549.camel@debian>
References: <200901211734.48625.helmut.schaa@gmail.com>
	 <200901271521.24395.helmut.schaa@gmail.com>
	 <200902051511.31268.helmut.schaa@gmail.com>
	 <200902231138.58067.helmut.schaa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jouni Malinen <j@w1.fi>
To: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200902231138.58067.helmut.schaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[ remove ipw2100-devel and cc linux-wireless ]

On Mon, 2009-02-23 at 18:38 +0800, Helmut Schaa wrote:
> Am Donnerstag, 5. Februar 2009 schrieb Helmut Schaa:
> > Am Dienstag, 27. Januar 2009 schrieb Helmut Schaa:
> > > Am Freitag, 23. Januar 2009 schrieb Helmut Schaa:
> > > > Am Freitag, 23. Januar 2009 schrieb Zhu, Yi:
> [...]
> > > > > I see. This should be a firmware bug. I think your idea to queue packets
> > > > > between ASSOCIATING and ASSOCIATED and replay them later (state becomes
> > > > > ASSOCIATED) should work. 
> > > > 
> > > > Agreed, I'll try that (maybe today, maybe next week).
> > > 
> > > Ok, I've done a first try and the frame buffering/replaying works quite well
> > > but I've ran into another issue now:
> > > 
> > > The supplicant successfully receives the EAP frame which was buffered by the
> > > driver and sends the appropriate resone. However the response is not send over
> > > the air. If I just add a sleep(1) before sending the frame in the supplicant
> > > all works well. I have no clue yet why the frame is not send.
> > 
> > JFYI, got a bit further now. The driver never got the frame from the
> > supplicant. It's the netdev which does not accept the frame that short
> > after the queues are woken up.
> 
> Found some time again to investigate this issue again. The current state
> is as follows:
> 
> After the firmware notifies the driver about the association it starts
> buffering all frames. Once the delayed work is executed and moves the
> driver state to ASSOCIATED the following happens:
> 
> 1) netif_carrier_on
> 2) netif_wake_queue
> 3) wireless_send_event
> 4) replay buffered frames
> 
> Hereupon wpa_supplicant receives the buffered EAP-frame and builds the
> according reply and tries to send it. The sendto call does _not_ indicate
> an error. Nevertheless, the frame is not passed to the ipw2100 driver. I
> was able to track that down to the following situation:
> 
> 
> This happens when the driver moves to the associated state:
> ----------------------------
> netif_carrier_on
>   linkwatch_fire_event
>     linkwatch_schedule_work
> netif_wake_queue
> ----------------------------
> At that point in time the device's tx queue has a noop_qdisc assigned.
> 
> Now wpa_supplicant sends the EAP reply:
> ---------------------------
> packet_sendmsg
>   dev_queue_xmit
>     qdisc_enqueue_root
>       qdisc_enqueue
>         return NET_XMIT_CN
>   return 0
> ---------------------------
> Since the qdisc is still noop_qdisc, qdisc_enqueue returns NET_XMIT_CN for
> every frame while packet_sendmsg translates that to 0, see netdevice.h:
> 
> #define net_xmit_errno(e) ((e) != NET_XMIT_CN ? -ENOBUFS : 0)
> 
> Hence, wpa_supplicant thinks the frame was sent out successfully.
> 
> Somewhat later when the queued linkwatch work is executed the qdisc gets
> swapped to the default_qdisc which would allow frames to be send.
> 
> ---------------------------
> linkwatch_event
>   __linkwatch_run_queue
>     activate_dev
>       attach_default_qdisc
> ---------------------------

Thanks for the analysis. Are you sure noop_qdisc is still used when we
are about to netif_carrier_on() after receiving the association success
response? From dev_open(), dev_activate() is called after netdev->open.
So the txq->qdisc_sleeping should be already replaced with pfifo_fast.
But the state is still DEACTIVATED. Should the packet from
wpa_supplicant be dropped by dev_queue_xmit()?

> So, how should I proceed here?
> 
> Some possibilities that come to mind:
> 
> 1) let the noop_qdisc return NET_XMIT_DROP instead of NET_XMIT_CN and extend
>    wpa_supplicant to retry after a short timeout. Already tried this approach
>    and it works fine for me. wpa_supplicant typically needs one retry (200ms
>    delay) until the frame is successfully send out.
> 
> 2) Run activate_dev somehow without a delay. I guess this could be achieved by
>    changing linkwatch_urgent_event. I haven't tested this yet. But I guess we
>    would still have a small race here.
> 
> 3) Wait until activate_dev was called in ipw2100 before replaying the cached
>    frames.

I think making a sync version of netif_carrier_on/activate_dev should be
the way to go. This could be a requirement from wireless. In wired
network, netif_carrier_on() is called after a network cable plug event
is detected. Some delay should be OK. But in wireless,
netif_carrier_on() is usually called after an association is succeeded.
The driver has already some management frames transfered with AP. Now
it's the time to open the data frame transmission. The driver requires
to get the activate_dev() result (synchronously or via callback) because
otherwise the driver has no idea when the Qdisc is ready and then it can
start to deliver data frames to network stack and user space. The real
failure example here is the one Helmut found about the wpa_supplicant
EAPOL frames lost case above.

> Maybe, someone from the netdev people can give me a hand here?

Yeah, please comment.

Thanks,
-yi

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
