From: John Crispin <john@phrozen.org>
Subject: Re: [RFC 1/2] net-next: fix DSA flow_disection
Date: Tue, 20 Jun 2017 19:37:35 +0200
Message-ID: <390b4235-1bd4-89d2-3a5f-bc51e3599247@phrozen.org>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620140140.GB12383@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:54347 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751641AbdFTRhu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 13:37:50 -0400
In-Reply-To: <20170620140140.GB12383@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20/06/17 16:01, Andrew Lunn wrote:
> On Tue, Jun 20, 2017 at 10:06:54AM +0200, John Crispin wrote:
>> RPS and probably other kernel features are currently broken on some if not
>> all DSA devices. The root cause of this that skb_hash will call the
>> flow_disector.
> Hi John
>
> What is the call path when the flow_disector is called? I'm wondering
> if we can defer this, and call it later, after the tag code has
> removed the header.
>
> 	Andrew

Hi Andrew,

the ethernet driver receives the frame and passes it down the line. 
Eventually it ends up inside netif_receive_skb_internal() where it gets 
added to the backlog. At this point get_rps_cpu() is called. Inside 
get_rps_cpu() the skb_get_hash() is called which utilizes the 
flow_dissector() ... which is broken for DSA devices. get_rps_cpu() will 
always return the same hash for all flows and the frame is always added 
to the backlog on the same core. Once inside the backlog it will 
traverse through the dsa layer and end up inside the tag driver and be 
passed to the slave device for further processing and keep its bad flow 
hash for its whole life cycle.

In theory we could reset the hash inside the tag driver but ideally the 
whole life cycle of the frame should happen on the same core to avoid 
possible reordering issues. In addition RPS is broken until the frame 
reaches the tag driver. In the case of the mediatek mt7623 we only have 
1 RX IRQ and in the worst case the RPS of the frame while still inside 
ethX will happen on the same core as where we handle IRQs. This will 
increase the IRQ latency and reduce the free cpu time, thus reducing 
maximum throughput. I did test resetting the hash inside the tag driver. 
Calculating the correct hash from the start did yield a huge performance 
difference however, at least on mt7623. We are talking about 30% extra 
max throughput. This might not be such a big problem if the SoC has a 
multi queue ethernet core but on mt7623 it does make a huge difference 
if we can use RPS to delegate all frame processing away from the core 
handling the IRQs.

     John
