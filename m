From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: ipgre rss is broken since gro
Date: Sun, 9 Dec 2012 22:49:21 +0200
Message-ID: <1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
 <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
 <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4304 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934486Ab2LIUtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Dec 2012 15:49:23 -0500
In-Reply-To: <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-09 at 04:04 +0200, Dmitry Kravkov wrote:
> On Sat, 2012-12-08 at 18:01 -0800, Eric Dumazet wrote:
> > On Sat, Dec 8, 2012 at 3:31 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> > > Here is the trace for a while:
> > >
> > > BUG: unable to handle kernel NULL pointer dereference at           (null)
> > > IP: [<ffffffff8144f35e>] skb_gro_receive+0xbe/0x5a0
> > 
> > Hi Dmitry
> > 
> > NULL pointer deref probably fixed on net tree (or Linus tree) by
> > 
> > http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commit;h=c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255

This resolved the deref. Thanks.

> > For the GRO stuff and RSS, I wonder if skbs have a property that makes
> > them dropped somewhere, you might try drop_monitor / drop_watch

for this item: drop_watch does not show any drops (i've disable all
other interfaces for clear env)
I will explain a little bit more the setup:
bnx2x device (under testing) is configured for RSS for IPGRE packets.
Sending multiple (3) TCP_STREAM causes ip_gre interface to disappear
packets (even ICMP).
This is not happening with single TCP_STREAM, or before gro_cell
introduction.

i was searching for the drops by print-out in ip_gre.c but disappeared
packets completes this code:

static int ipgre_rcv(struct sk_buff *skb)
(snip)
	        printk("%s:%d\n", __FUNCTION__, __LINE__);

                tstats = this_cpu_ptr(tunnel->dev->tstats);
                u64_stats_update_begin(&tstats->syncp);
                tstats->rx_packets++;
                tstats->rx_bytes += skb->len;
                u64_stats_update_end(&tstats->syncp);

                gro_cells_receive(&tunnel->gro_cells, skb);
                return 0;

> > 
> 
> I will try both and update ... 
> Thanks
