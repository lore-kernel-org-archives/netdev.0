From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: Re: [PATCH v6 net-next 17/17] net: qualcomm: add QCA7000 UART
 driver
Date: Wed, 24 May 2017 16:19:59 +0200
Message-ID: <trinity-2a5e8b0e-888a-49f3-add9-bd0161fa67f5-1495635599212@3capp-gmx-bs75>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
 <1495545173-22150-18-git-send-email-stefan.wahren@i2se.com>
 <053235ad-a963-6a09-ccb0-b643115dee00@gmx.de>
 <1059621060.236992.1495568289051@email.1und1.de>
 <41c7302e-b25c-9f57-470a-dd95200a060f@gmx.de>
 <50e5a442-777f-1516-4e94-16db7fa28f8b@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Rob Herring" <robh+dt@kernel.org>,
        "Mark Rutland" <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-serial@vger.kernel.org, "Jiri Slaby" <jslaby@suse.com>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Jakub Kicinski" <kubakici@wp.pl>, devicetree@vger.kernel.org
To: "Stefan Wahren" <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63959 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935386AbdEXOUq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 10:20:46 -0400
In-Reply-To: <50e5a442-777f-1516-4e94-16db7fa28f8b@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Gesendet: Mittwoch, 24. Mai 2017 um 11:06 Uhr
> Von: "Stefan Wahren" <stefan.wahren@i2se.com>
> An: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>, "Rob Herring" <robh+dt@kernel.org>, "Mark Rutland" <mark.rutland@arm.com>, "David S. Miller" <davem@davemloft.net>
> Cc: linux-serial@vger.kernel.org, "Jiri Slaby" <jslaby@suse.com>, "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Jakub Kicinski" <kubakici@wp.pl>, devicetree@vger.kernel.org
> Betreff: Re: [PATCH v6 net-next 17/17] net: qualcomm: add QCA7000 UART driver
>
> Am 23.05.2017 um 23:01 schrieb Lino Sanfilippo:
> > On 23.05.2017 21:38, Stefan Wahren wrote:
> >>> Lino Sanfilippo <LinoSanfilippo@gmx.de> hat am 23. Mai 2017 um 20:16 geschrieben:
> >>>
> >>> I suggest to avoid this possible race by first unregistering the netdevice and then 
> >>> calling cancel_work_sync().
> >> What makes you sure that's safe to unregister the netdev while the tx work queue is possibly active?
> > unregister_netdevice() calls netdev_close() if the interface is still up. netdev_close() calls flush_work()
> > so the unregistration is delayed until the tx work function is finished. Furthermore both close() and
> > tx work are synchronized by means of the qca->lock which also guarantees that unregister_netdevice() wont
> > be finished until the tx work is done.
> >
> 
> Thanks for the explanation. I suspect there could be the same race
> between serdev_device_close() and the tx work queue.
> 
> So i would propose a variant of your original suggestion:
> 
> unregister_netdev(qca->net_dev);
> 
> /* Flush any pending characters in the driver. */
> serdev_device_close(serdev);
> cancel_work_sync(&qca->tx_work);
> 
> Since we have the same pattern in the error path of the probe function,
> the same applies there.

Agreed, it is much cleaner to have the same cleanup pattern in remove() as
we have in (error case of) probe().

Regards,
Lino
