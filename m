From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V3 net-next 1/1] hv_netvsc: Use the xmit_more skb flag to
 optimize signaling the host
Date: Wed, 6 May 2015 19:55:03 +0000
Message-ID: <BY2PR0301MB0711E7B408E3821DFCF6E365A0D00@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1430936436-5837-1-git-send-email-kys@microsoft.com>
 <1430935733.14545.57.camel@edumazet-glaptop2.roam.corp.google.com>
 <BY2PR0301MB071195898775621EBF8FA9DEA0D00@BY2PR0301MB0711.namprd03.prod.outlook.com>
 <1430939859.14545.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1430939859.14545.72.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Wednesday, May 6, 2015 12:18 PM
> To: KY Srinivasan
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH V3 net-next 1/1] hv_netvsc: Use the xmit_more skb flag
> to optimize signaling the host
> 
> On Wed, 2015-05-06 at 18:28 +0000, KY Srinivasan wrote:
> 
> > Ah! I too was wondering how we could get into this situation. The condition
> you mention
> > is already handled in the lower level - if the attempt to put the last packet
> on vmbus were to
> > fail because the ring is full, we will notify the host independent of kick_q
> parameter - look
> > at the function vmbus_sendpacket_ctl() in drivers/hv/channel.c
> >
> > I will resend the patch by reverting this to version 2.
> 
> I am not really convinced by what you are saying ;)
> 
> problem is not when you fail to add an additional packet.
> 
> Problem is :
> 
> You queue a packet but not kick because skb->xmit_more = 1, and _then_
> you call netif_tx_stop_queue().
> 
> No further packet will be delivered to your driver, until
> netif_tx_wake_queue() is called again from netvsc_send_completion(),
> possibly milli seconds later.

Ok; I see your point. We stop the q in our driver under two conditions:

1. When the ring is full and we fail to queue. This situation is taken care of already.
2. We fall below a certain free space in the ring buffer - this is the case you are pointing out.

I will address this and resend the patch. Thanks for the review.

Regards,

K. Y
> 
> If qdisc was replaced by another one, no packet will kick again, unless
> other traffic comes.
> 
> Given complexity of your driver, I have no easy way to check you made
> this xmit_more conversion correctly, and one packet can not sit in the
> equivalent of TX ring buffer for unbound time.
> 
> Better add a full explanation into your changelog.
> 
> 
