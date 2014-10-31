From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/8] net/mlx4_en: Remove redundant code from
 RX/GRO path
Date: Fri, 31 Oct 2014 08:46:02 -0700
Message-ID: <1414770362.27538.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	 <1414685216-28907-6-git-send-email-ogerlitz@mellanox.com>
	 <1414695631.15352.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMjw9rRLBTEXT3cw0+CPRyvJgNbKVHpnmsukas-r=QwmyA@mail.gmail.com>
	 <1414725541.499.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMiDnv9=nvvJ1m7_taoSncdmgv4GJVR8DiD5t5GCsFig1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:51905 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbaJaPqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 11:46:06 -0400
Received: by mail-ie0-f178.google.com with SMTP id rp18so1494191iec.23
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 08:46:04 -0700 (PDT)
In-Reply-To: <CAJ3xEMiDnv9=nvvJ1m7_taoSncdmgv4GJVR8DiD5t5GCsFig1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-31 at 16:00 +0200, Or Gerlitz wrote:
> On Fri, Oct 31, 2014 at 5:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Fri, 2014-10-31 at 01:25 +0200, Or Gerlitz wrote:
> >> On Thu, Oct 30, 2014 at 9:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> > On Thu, 2014-10-30 at 18:06 +0200, Or Gerlitz wrote:
> >> >> Remove the code which goes through napi_gro_frags() on the RX path,
> >> >> use only napi_gro_receive().
> >>
> >> > Hmpff... napi_gro_frags() should be faster.
> >> > Have you benchmarked this ?
> >>
> >>
> >> yep we did, napi_gro_frags() was somehow better for single stream. Do
> >> you think we need to do it the other way around, e.g converge to use
> >> napi_gro_frags()?
> 
> > napi_gro_frags() is faster because the napi->skb is reused fast (not
> > going through kfree_skb()/alloc_skb() for every fragment)
> 
> I see. Is this a strong vote to convert the code to use napi_gro_frags
> on it's usual track?

I don't know yet. In some cases, actually slowing down the rx path can
help by building bigger GRO packets. But instead of inserting delays,
we can simply force napi to be run another time, with a nanosec based
timer.

I've tested this kind of heuristic :

       /* If some packets are waiting in GRO engine and timeout is not expired,
        * reschedule a NAPI poll. We allow servicing other softirqs
        * before repoll, we do not rearm CQ.
        */
       if (rx_nsecs && napi->gro_list && !need_resched()) {
               u64 now = local_clock();
               unsigned long flags;

               /* If we got packets in this round, restart timeout */
               if (done)
                       cq->tstart = now;
               else if (now - cq->tstart >= (u64)rx_nsecs)
                       goto complete;

               /* Since we might need one skb very soon, build it now */
               napi_get_frags(napi);

               local_irq_save(flags);
               list_del(&napi->poll_list);
               __napi_schedule_irqoff(napi);
               local_irq_restore(flags);

        } else {
complete:
                napi_complete(napi);
                mlx4_en_arm_cq(priv, cq);
        }
	return done;
