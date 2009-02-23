From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated and rx path
Date: Mon, 23 Feb 2009 11:38:57 +0100
Message-ID: <200902231138.58067.helmut.schaa@gmail.com>
References: <200901211734.48625.helmut.schaa@gmail.com> <200901271521.24395.helmut.schaa@gmail.com> <200902051511.31268.helmut.schaa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: "Zhu, Yi" <yi.zhu@intel.com>,
	"ipw2100-devel@lists.sourceforge.net"
	<ipw2100-devel@lists.sourceforge.net>, Jouni Malinen <j@w1.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f167.google.com ([209.85.220.167]:38544 "EHLO
	mail-fx0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbZBWKjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 05:39:16 -0500
Received: by fxm11 with SMTP id 11so1578831fxm.13
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2009 02:39:14 -0800 (PST)
In-Reply-To: <200902051511.31268.helmut.schaa@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 5. Februar 2009 schrieb Helmut Schaa:
> Am Dienstag, 27. Januar 2009 schrieb Helmut Schaa:
> > Am Freitag, 23. Januar 2009 schrieb Helmut Schaa:
> > > Am Freitag, 23. Januar 2009 schrieb Zhu, Yi:
[...]
> > > > I see. This should be a firmware bug. I think your idea to queue packets
> > > > between ASSOCIATING and ASSOCIATED and replay them later (state becomes
> > > > ASSOCIATED) should work. 
> > > 
> > > Agreed, I'll try that (maybe today, maybe next week).
> > 
> > Ok, I've done a first try and the frame buffering/replaying works quite well
> > but I've ran into another issue now:
> > 
> > The supplicant successfully receives the EAP frame which was buffered by the
> > driver and sends the appropriate resone. However the response is not send over
> > the air. If I just add a sleep(1) before sending the frame in the supplicant
> > all works well. I have no clue yet why the frame is not send.
> 
> JFYI, got a bit further now. The driver never got the frame from the
> supplicant. It's the netdev which does not accept the frame that short
> after the queues are woken up.

Found some time again to investigate this issue again. The current state
is as follows:

After the firmware notifies the driver about the association it starts
buffering all frames. Once the delayed work is executed and moves the
driver state to ASSOCIATED the following happens:

1) netif_carrier_on
2) netif_wake_queue
3) wireless_send_event
4) replay buffered frames

Hereupon wpa_supplicant receives the buffered EAP-frame and builds the
according reply and tries to send it. The sendto call does _not_ indicate
an error. Nevertheless, the frame is not passed to the ipw2100 driver. I
was able to track that down to the following situation:


This happens when the driver moves to the associated state:
----------------------------
netif_carrier_on
  linkwatch_fire_event
    linkwatch_schedule_work
netif_wake_queue
----------------------------
At that point in time the device's tx queue has a noop_qdisc assigned.

Now wpa_supplicant sends the EAP reply:
---------------------------
packet_sendmsg
  dev_queue_xmit
    qdisc_enqueue_root
      qdisc_enqueue
        return NET_XMIT_CN
  return 0
---------------------------
Since the qdisc is still noop_qdisc, qdisc_enqueue returns NET_XMIT_CN for
every frame while packet_sendmsg translates that to 0, see netdevice.h:

#define net_xmit_errno(e) ((e) != NET_XMIT_CN ? -ENOBUFS : 0)

Hence, wpa_supplicant thinks the frame was sent out successfully.

Somewhat later when the queued linkwatch work is executed the qdisc gets
swapped to the default_qdisc which would allow frames to be send.

---------------------------
linkwatch_event
  __linkwatch_run_queue
    activate_dev
      attach_default_qdisc
---------------------------

So, how should I proceed here?

Some possibilities that come to mind:

1) let the noop_qdisc return NET_XMIT_DROP instead of NET_XMIT_CN and extend
   wpa_supplicant to retry after a short timeout. Already tried this approach
   and it works fine for me. wpa_supplicant typically needs one retry (200ms
   delay) until the frame is successfully send out.

2) Run activate_dev somehow without a delay. I guess this could be achieved by
   changing linkwatch_urgent_event. I haven't tested this yet. But I guess we
   would still have a small race here.

3) Wait until activate_dev was called in ipw2100 before replaying the cached
   frames.

Maybe, someone from the netdev people can give me a hand here?

Jouni, would you accept a patch for wpa_supplicant that adds some retries
to l2_packet_send when the network stack returns an error?

Thanks,
Helmut
