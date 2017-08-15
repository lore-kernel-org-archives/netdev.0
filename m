From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Tue, 15 Aug 2017 12:28:53 +0200
Message-ID: <20170815122853.0266c971@redhat.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
        <20170812142358.08291888@redhat.com>
        <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
        <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
        <20170814181957.5be27906@redhat.com>
        <1ff1b747-758e-afdd-9376-80ff3bd8a6d5@itcare.pl>
        <20170815112307.2dd366fe@redhat.com>
        <271f731c-080f-8ccb-cd08-f0ec1dfb0c51@itcare.pl>
        <20170815115756.7ef50c23@redhat.com>
        <fee2de62-c781-4ceb-8e97-be2b07eb1ca1@itcare.pl>
        <3d59ff3b-246b-2f46-2351-31c2d58ca6fe@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com
To: =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50532 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753423AbdHOK3C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 06:29:02 -0400
In-Reply-To: <3d59ff3b-246b-2f46-2351-31c2d58ca6fe@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 15 Aug 2017 12:05:37 +0200 Paweł Staszewski <pstaszewski@itcare.pl> wrote:
> W dniu 2017-08-15 o 12:02, Paweł Staszewski pisze:
> > W dniu 2017-08-15 o 11:57, Jesper Dangaard Brouer pisze:  
> >> On Tue, 15 Aug 2017 11:30:43 +0200 Paweł Staszewski 
> >> <pstaszewski@itcare.pl> wrote:
> >>> W dniu 2017-08-15 o 11:23, Jesper Dangaard Brouer pisze:  
> >>>> On Tue, 15 Aug 2017 02:38:56 +0200
> >>>> Paweł Staszewski <pstaszewski@itcare.pl> wrote:  
> >>>>> W dniu 2017-08-14 o 18:19, Jesper Dangaard Brouer pisze:  
> >>>>>> On Sun, 13 Aug 2017 18:58:58 +0200 Paweł Staszewski 
> >>>>>> <pstaszewski@itcare.pl> wrote:  
[... cut ...]

> >>> Ethtool(enp175s0f1) stat:      8895566 (      8,895,566) <= tx_prio0_packets /sec
> >>> Ethtool(enp175s0f1) stat:    640470657 (    640,470,657) <= tx_vport_unicast_bytes /sec
> >>> Ethtool(enp175s0f1) stat:      8895427 (      8,895,427) <= tx_vport_unicast_packets /sec
> >>> Ethtool(enp175s0f1) stat:          498 (            498) <= tx_xmit_more /sec  
> >>
> >> We are seeing some xmit_more, this is interesting.  Have you noticed,
> >> if (in the VLAN case) there is a queue in the qdisc layer?
> >>
> >> Simply inspect with: tc -s qdisc show dev ixgbe2  
[...]
> > physical interface mq attached with pfifo_fast:
> >
> > tc -s -d qdisc show dev enp175s0f1
> > qdisc mq 0: root
> >  Sent 1397200697212 bytes 3965888669 pkt (dropped 78065663, overlimits 0 requeues 629868)
> >  backlog 0b 0p requeues 629868
> > qdisc pfifo_fast 0: parent :38 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
> > qdisc pfifo_fast 0: parent :37 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  backlog 0b 0p requeues 0
[...]

So, it doesn't look like there is any backlog queue.  Although, this
can be difficult to measure/see this way (as the kernel empty the queue
quickly via bulk deq), also given the small amount of xmit_more which
indicate that the queue was likely very small.

There is a "dropped" counter, which indicate that you likely had a
setup (earlier) where you managed to overflow the qdisc queues. 

> just see that after changing RSS on nics did't deleted qdisc and added 
> again:
> Here situation with qdisc del / add
> tc -s -d qdisc show dev enp175s0f1
> qdisc mq 1: root
>   Sent 43738523966 bytes 683414438 pkt (dropped 0, overlimits 0 requeues 1886)
>   backlog 0b 0p requeues 1886
> qdisc pfifo_fast 0: parent 1:10 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>   Sent 2585011904 bytes 40390811 pkt (dropped 0, overlimits 0 requeues 110)
>   backlog 0b 0p requeues 110
> qdisc pfifo_fast 0: parent 1:f bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>   Sent 2602068416 bytes 40657319 pkt (dropped 0, overlimits 0 requeues 121)
>   backlog 0b 0p requeues 121
[...]

Exactly as you indicated above, these "dropped" stats came from another
(earlier) test case. (Great that you caught this yourself)

While trying to reproduce you case, I also managed to cause a situation
with qdisc overload.  This caused some weird behavior, where I saw
RX=8Mpps and TX only 4Mpps.  (I didn't figure out the exact tuning that
caused this, and cannot reproduce it now).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
