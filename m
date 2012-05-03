From: Basil Gor <basil.gor@gmail.com>
Subject: Re: [PATCH v3 1/2] vhost-net: fix handle_rx buffer size
Date: Thu, 3 May 2012 18:43:26 +0400
Message-ID: <20120503144326.GA15251@nanobar>
References: <m1ipgtzwew.fsf@fess.ebiederm.org>
 <1335373275-336-1-git-send-email-basil.gor@gmail.com>
 <20120503131623.GA26705@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51141 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098Ab2ECOoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 10:44:13 -0400
Received: by yhmm54 with SMTP id m54so1810813yhm.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 07:44:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120503131623.GA26705@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 03, 2012 at 04:16:24PM +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 25, 2012 at 09:01:15PM +0400, Basil Gor wrote:
> > Take vlan header length into account, when vlan id is stored as
> > vlan_tci. Otherwise tagged packets comming from macvtap will be
> > truncated.
> > 
> > Signed-off-by: Basil Gor <basil.gor@gmail.com>
> 
> So I'm inclined to apply these two patches, we
> this doesn't fix packet socket backend
> but could be fixed by a follow-up patch.
> 

That's what I'm going to do.

While testing packet socket I noticed that tcpdump doesn't work
on macvtap0, since there is no dev_hard_start_xmit like in
tun/tap0 case I think (lines 120-144 in trace attached). And I
have no clear picture how to fix this gracefully.

Also I think there are issues with macvtap on top of bonding, that
I'm also going to verify and debug.

> > ---
> >  drivers/vhost/net.c |    7 ++++++-
> >  1 files changed, 6 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 1f21d2a..5c17010 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -24,6 +24,7 @@
> >  #include <linux/if_arp.h>
> >  #include <linux/if_tun.h>
> >  #include <linux/if_macvlan.h>
> > +#include <linux/if_vlan.h>
> >  
> >  #include <net/sock.h>
> >  
> > @@ -283,8 +284,12 @@ static int peek_head_len(struct sock *sk)
> >  
> >  	spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
> >  	head = skb_peek(&sk->sk_receive_queue);
> > -	if (likely(head))
> > +	if (likely(head)) {
> >  		len = head->len;
> > +		if (vlan_tx_tag_present(head))
> > +			len += VLAN_HLEN;
> > +	}
> > +
> >  	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
> >  	return len;
> >  }
> > -- 
> > 1.7.6.5
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tap_trace.log"

single arp packet receive

		br0
		^ \
		|  +->tap0 <-- tapread + tcpdump
->wlan0-+->macvlan0 
         \->macvtap0 <-- macvtapread + tcpdump

001       0 irq/28-b43(25823): -> netpoll_trap()
002    0xffffffff815209c0 : netpoll_trap+0x0/0x20 [kernel]
003    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
004    0xffffffffa0260a8a [mac80211]
005    0xffffffffa0260ac0 [mac80211]
006    0xffffffffa0318b02 [b43]
007    0xffffffff810e4b60 : irq_thread_fn+0x0/0x50 [kernel]
008    0xffffffffa0313330 [b43]
009    0xffffffffa02f71d6 [b43]
010    0xffffffffa02f7486 [b43]
011    0xffffffff810e4b89 : irq_thread_fn+0x29/0x50 [kernel]
012    0xffffffff810e4ae0 : irq_thread+0x1a0/0x220 [kernel]
013    0xffffffff810e4940 : irq_thread+0x0/0x220 [kernel]
014    0xffffffff81079da3 : kthread+0x93/0xa0 [kernel]
015    0xffffffff81620f24 : kernel_thread_helper+0x4/0x10 [kernel]
016    0xffffffff81079d10 : kthread+0x0/0xa0 [kernel]
017    0xffffffff81620f20 : kernel_thread_helper+0x0/0x10 [kernel]
018      480 irq/28-b43(25823): <- netpoll_trap(): return=0x0
019        0 irq/28-b43(25823): -> netif_receive_skb(skb=0xffff8800a8183300)
020   	skb_dump:dev:wlan0 proto:8100 len:32 vlan_tci:{prio:0 cfi:0 vid:0}
021    0xffffffff8150b360 : netif_receive_skb+0x0/0x90 [kernel]
022    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
023    0xffffffffa02584d6 [mac80211]
024    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
025    0xffffffffa02598f6 [mac80211]
026    0xffffffffa025a56e [mac80211]
027    0xffffffffa0312fd4 [b43]
028    0xffffffffa0318d8a [b43]
029    0xffffffff810e4b60 : irq_thread_fn+0x0/0x50 [kernel]
030    0xffffffffa02f71fd [b43]
031    0xffffffffa02f7486 [b43]
032    0xffffffff810e4b89 : irq_thread_fn+0x29/0x50 [kernel]
033    0xffffffff810e4ae0 : irq_thread+0x1a0/0x220 [kernel]
034    0xffffffff810e4940 : irq_thread+0x0/0x220 [kernel]
035    0xffffffff81079da3 : kthread+0x93/0xa0 [kernel]
036    0xffffffff81620f24 : kernel_thread_helper+0x4/0x10 [kernel]
037    0xffffffff81079d10 : kthread+0x0/0xa0 [kernel]
038    0xffffffff81620f20 : kernel_thread_helper+0x0/0x10 [kernel]
039      551 irq/28-b43(25823):  -> __netif_receive_skb(skb=0xffff8800a8183300 ptype=? pt_prev=? rx_handler=? orig_dev=? null_or_dev=? deliver_exact=? ret=? type=?)
040   	skb_dump:dev:wlan0 proto:8100 len:32 vlan_tci:{prio:0 cfi:0 vid:0}
041      587 irq/28-b43(25823):   -> vlan_untag(skb=0xffff8800a8183300 vhdr=? vlan_tci=?)
042   	skb_dump:dev:wlan0 proto:8100 len:32 vlan_tci:{prio:0 cfi:0 vid:0}
043      616 irq/28-b43(25823):   <- vlan_untag(): return=0xffff8800a8183300
044      639 irq/28-b43(25823):   -> packet_rcv(skb=0xffff8800a8183300 dev=0xffff8800aa24b000 pt=0xffff8800276f5cc0 orig_dev=0xffff8800aa24b000 sk=? sll=? po=? skb_head=? skb_len=? snaplen=? res=?)
045   	skb_dump:dev:wlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
046   	dev:name:wlan0
047   	orig_dev:name:wlan0
048      690 irq/28-b43(25823):   <- packet_rcv(): return=0x0
049      705 irq/28-b43(25823):   -> vlan_do_receive(skbp=0xffff880045c1fa08 last_handler=0x0 skb=? vlan_id=? vlan_dev=0xffff8800aa24b000 rx_stats=?)
050   	skbp_dump:dev:wlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
051      738 irq/28-b43(25823):   <- vlan_do_receive(): return=0x0
052      755 irq/28-b43(25823):   -> macvlan_handle_frame(pskb=0xffff880045c1fa08 port=? skb=? eth=? vlan=? src=0xffff8800aa24b000 dev=? len=? ret=?)
053   	pskb_dump:dev:wlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
054      794 irq/28-b43(25823):    -> macvlan_broadcast(skb=0xffff8800a8183300 port=0xffff8800a9466000 src=0x0 mode=0xf eth=0xffff880045c1f9f0 vlan=? n=? nskb=? i=? err=0x0)
055   	skb_dump:dev:wlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
056      843 irq/28-b43(25823):     -> netif_rx(skb=0xffff8800a7012e00 ret=0xffffffffa7012e00)
057   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
058      877 irq/28-b43(25823):      -> enqueue_to_backlog(skb=0xffff8800a7012e00 cpu=0x0 qtail=0xffff880045c1f930 sd=? flags=?)
059   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
060      930 irq/28-b43(25823):      <- enqueue_to_backlog(): return=0x0
061      942 irq/28-b43(25823):     <- netif_rx(): return=0x0
062      962 irq/28-b43(25823):     -> macvtap_receive(skb=0xffff8800136a7200)
063   	skb_dump:dev:macvtap0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
064      992 irq/28-b43(25823):      -> macvtap_forward(dev=0xffff8800a9467000 skb=0xffff8800136a7200 q=0x0)
065   	skb_dump:dev:macvtap0 proto:0806 len:42 vlan_tci:{prio:0 cfi:4096 vid:50}
066   	dev:name:macvtap0
067     1030 irq/28-b43(25823):       -> __skb_get_rxhash(skb=0xffff8800136a7200 keys={...} hash=?)
068   	skb_dump:dev:macvtap0 proto:0806 len:42 vlan_tci:{prio:0 cfi:4096 vid:50}
069     1058 irq/28-b43(25823):       <- __skb_get_rxhash(): 
070     1080 irq/28-b43(25823):      <- macvtap_forward(): return=0x0
071     1092 irq/28-b43(25823):     <- macvtap_receive(): return=0x0
072     1105 irq/28-b43(25823):    <- macvlan_broadcast(): 
073     1117 irq/28-b43(25823):   <- macvlan_handle_frame(): return=0x3
074     1149 irq/28-b43(25823):  <- __netif_receive_skb(): return=0x0
075     1161 irq/28-b43(25823): <- netif_receive_skb(): return=0x0
076        0 irq/28-b43(25823): -> net_rx_action(h=0xffffffff81c04098 sd=? time_limit=? budget=? have=0x3)
077    0xffffffff8150bc00 : net_rx_action+0x0/0x270 [kernel]
078    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
079    0xffffffff8162101c : call_softirq+0x1c/0x30 [kernel]
080    0xffffffff81016455 : do_softirq+0x65/0xa0 [kernel]
081    0xffffffff8105e654 : local_bh_enable+0x94/0xa0 [kernel]
082    0xffffffffa0312fd9 [b43]
083    0xffffffffa0318d8a [b43]
084    0xffffffff810e4b60 : irq_thread_fn+0x0/0x50 [kernel]
085    0xffffffffa02f71fd [b43]
086    0xffffffffa02f7486 [b43]
087    0xffffffff810e4b89 : irq_thread_fn+0x29/0x50 [kernel]
088    0xffffffff810e4ae0 : irq_thread+0x1a0/0x220 [kernel]
089    0xffffffff810e4940 : irq_thread+0x0/0x220 [kernel]
090    0xffffffff81079da3 : kthread+0x93/0xa0 [kernel]
091    0xffffffff81620f24 : kernel_thread_helper+0x4/0x10 [kernel]
092    0xffffffff81079d10 : kthread+0x0/0xa0 [kernel]
093    0xffffffff81620f20 : kernel_thread_helper+0x0/0x10 [kernel]
094      506 irq/28-b43(25823):  -> process_backlog(napi=0xffff8800afc14118 quota=0x40 work=? sd=?)
095      530 irq/28-b43(25823):   -> __netif_receive_skb(skb=0xffff8800a7012e00 ptype=? pt_prev=? rx_handler=? orig_dev=? null_or_dev=? deliver_exact=? ret=? type=?)
096   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
097      561 irq/28-b43(25823):    -> vlan_do_receive(skbp=0xffff8800afc03e30 last_handler=0x0 skb=? vlan_id=? vlan_dev=0xffff880088528000 rx_stats=?)
098   	skbp_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
099      591 irq/28-b43(25823):    <- vlan_do_receive(): return=0x0
100      626 irq/28-b43(25823):    -> br_flood_forward(br=0xffff8800a995e780 skb=0xffff8800a7012e00 skb2=0xffff8800a7012e00)
101   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
102      667 irq/28-b43(25823):     -> br_flood(br=0xffff8800a995e780 skb=0xffff8800a7012e00 skb0=0xffff8800a7012e00 __packet_hook=0xffffffffa040f380 p=? prev=?)
103   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
104      711 irq/28-b43(25823):      -> maybe_deliver(prev=0x0 p=0xffff8800a85bec00 skb=0xffff8800a7012e00 __packet_hook=0xffffffffa040f380 err=?)
105   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
106      766 irq/28-b43(25823):      <- maybe_deliver(): return=0xffff8800a85bec00
107      784 irq/28-b43(25823):      -> maybe_deliver(prev=0xffff8800a85bec00 p=0xffff8800a7972800 skb=0xffff8800a7012e00 __packet_hook=0xffffffffa040f380 err=?)
108   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
109      820 irq/28-b43(25823):      <- maybe_deliver(): return=0xffff8800a85bec00
110      839 irq/28-b43(25823):      -> deliver_clone(prev=0xffff8800a85bec00 skb=0xffff8800a7012e00 __packet_hook=0xffffffffa040f380 dev=?)
111   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
112      879 irq/28-b43(25823):       -> __br_forward(to=0xffff8800a85bec00 skb=0xffff8800a8183300 indev=?)
113   	skb_dump:dev:macvlan0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
114      914 irq/28-b43(25823):        -> br_forward_finish(skb=0xffff8800a8183300)
115   	skb_dump:dev:tap0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
116      943 irq/28-b43(25823):         -> br_dev_queue_push_xmit(skb=0xffff8800a8183300)
117   	skb_dump:dev:tap0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
118      973 irq/28-b43(25823):          -> dev_queue_xmit(skb=0xffff8800a8183300 dev=? txq=0xffffffffa040f380 q=? rc=?)
119   	skb_dump:dev:tap0 proto:0806 len:42 vlan_tci:{prio:0 cfi:4096 vid:50}
120     1010 irq/28-b43(25823):           -> dev_hard_start_xmit(skb=0xffff8800a8183300 dev=0xffff8800a9866000 txq=0xffff88008864fa00 ops=? rc=? skb_len=?)
121   	skb_dump:dev:tap0 proto:0806 len:42 vlan_tci:{prio:0 cfi:4096 vid:50}
122   	dev:name:tap0
123     1056 irq/28-b43(25823):            -> tpacket_rcv(skb=0xffff8800a9849600 dev=0xffff8800a9866000 pt=0xffff8800662994c0 orig_dev=0xffff8800a9866000 sk=? po=? sll=? h={...} skb_head=? skb_len=? snaplen=? res=? status=? macoff=? netoff=? hdrlen=? copy_skb=? tv={...} ts={...} shhwtstamps=?)
124   	skb_dump:dev:tap0 proto:0806 len:42 vlan_tci:{prio:0 cfi:4096 vid:50}
125   	dev:name:tap0
126   	orig_dev:name:tap0
127     1109 irq/28-b43(25823):             -> packet_lookup_frame(po=0xffff880066299000 rb=0xffff8800662992a0 position=0x6 status=0x0 pg_vec_pos=? frame_offset=? h={...})
128     1137 irq/28-b43(25823):              -> __packet_get_status(po=0xffff880066299000 frame=0xffff880019b60000 h={...})
129     1159 irq/28-b43(25823):              <- __packet_get_status(): return=0x0
130     1171 irq/28-b43(25823):             <- packet_lookup_frame(): return=0xffff880019b60000
131     1192 irq/28-b43(25823):             -> __packet_set_status(po=0xffff880066299000 frame=0xffff880019b60000 status=0x11 h={...})
132     1217 irq/28-b43(25823):             <- __packet_set_status(): 
133     1240 irq/28-b43(25823):            <- tpacket_rcv(): return=0x0
134     1255 irq/28-b43(25823):            -> netif_skb_features(skb=0xffff8800a8183300 protocol=? features=?)
135   	skb_dump:dev:tap0 proto:0806 len:42 vlan_tci:{prio:0 cfi:4096 vid:50}
136     1286 irq/28-b43(25823):             -> harmonize_features(skb=0xffff8800a8183300 protocol=0x608 features=0x0)
137   	skb_dump:dev:tap0 proto:0806 len:42 vlan_tci:{prio:0 cfi:4096 vid:50}
138     1314 irq/28-b43(25823):             <- harmonize_features(): return=0x0
139     1326 irq/28-b43(25823):            <- netif_skb_features(): return=0x0
140     1348 irq/28-b43(25823):            -> tun_net_xmit(skb=0xffff8800a8183300 dev=0xffff8800a9866000 tun=?)
141   	skb_dump:dev:tap0 proto:8100 len:46 vlan_tci:{prio:0 cfi:0 vid:0}
142   	dev:name:tap0
143     1388 irq/28-b43(25823):            <- tun_net_xmit(): return=0x0
144     1401 irq/28-b43(25823):           <- dev_hard_start_xmit(): return=0x0
145     1414 irq/28-b43(25823):          <- dev_queue_xmit(): return=0x0
146     1426 irq/28-b43(25823):         <- br_dev_queue_push_xmit(): return=0x0
147     1438 irq/28-b43(25823):        <- br_forward_finish(): return=0x0
148     1450 irq/28-b43(25823):       <- __br_forward(): 
149     1461 irq/28-b43(25823):      <- deliver_clone(): return=0x0
150     1473 irq/28-b43(25823):     <- br_flood(): 
151     1484 irq/28-b43(25823):    <- br_flood_forward(): 
152     1499 irq/28-b43(25823):    -> netif_receive_skb(skb=0xffff8800a7012e00)
153   	skb_dump:dev:br0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
154     1524 irq/28-b43(25823):     -> __netif_receive_skb(skb=0xffff8800a7012e00 ptype=? pt_prev=? rx_handler=? orig_dev=? null_or_dev=? deliver_exact=? ret=? type=?)
155   	skb_dump:dev:br0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
156     1553 irq/28-b43(25823):      -> vlan_do_receive(skbp=0xffff8800afc03d20 last_handler=0x1 skb=? vlan_id=? vlan_dev=0xffff8800a995e000 rx_stats=?)
157   	skbp_dump:dev:br0 proto:0806 len:28 vlan_tci:{prio:0 cfi:4096 vid:50}
158     1583 irq/28-b43(25823):      <- vlan_do_receive(): return=0x0
159     1596 irq/28-b43(25823):     <- __netif_receive_skb(): return=0x0
160     1608 irq/28-b43(25823):    <- netif_receive_skb(): return=0x0
161     1619 irq/28-b43(25823):   <- __netif_receive_skb(): return=0x1
162     1631 irq/28-b43(25823):  <- process_backlog(): return=0x1
163     1646 irq/28-b43(25823):  -> net_rps_action_and_irq_enable(sd=0xffff8800afc14040 remsd=?)
164     1666 irq/28-b43(25823):  <- net_rps_action_and_irq_enable(): 
165     1678 irq/28-b43(25823): <- net_rx_action(): 
166        0 macvtapread(13215): -> macvtap_poll(file=0xffff88006bb35c00 wait=0xffff8800a86a9ab8 q=? mask=?)
167    0xffffffffa03f6000 : macvtap_poll+0x0/0xa0 [macvtap]
168    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
169    0xffffffff8119561c : core_sys_select+0x1ec/0x370 [kernel]
170    0xffffffff81195860 : sys_select+0xc0/0x100 [kernel]
171    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
172      206 macvtapread(13215): <- macvtap_poll(): return=0x145
173        0 macvtapread(13215): -> macvtap_aio_read(iocb=0xffff8800a86a9e00 iv=0xffff8800a86a9ed8 count=0x1 pos=0x0 file=? q=? len=? ret=?)
174    0xffffffffa03f65e0 : macvtap_aio_read+0x0/0x80 [macvtap]
175    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
176    0xffffffff81182305 : vfs_read+0x165/0x180 [kernel]
177    0xffffffff8118236a : sys_read+0x4a/0x90 [kernel]
178    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
179      193 macvtapread(13215):  -> macvtap_do_read(q=0xffff88001a62f800 iocb=0xffff8800a86a9e00 iv=0xffff8800a86a9ed8 len=0x5de noblock=0x0 wait={...} skb=? ret=?)
180      233 macvtapread(13215):  <- macvtap_do_read(): return=0x34
181      246 macvtapread(13215): <- macvtap_aio_read(): return=0x34
182        0 macvtapread(13215): -> macvtap_poll(file=0xffff88006bb35c00 wait=0xffff8800a86a9ab8 q=? mask=?)
183    0xffffffffa03f6000 : macvtap_poll+0x0/0xa0 [macvtap]
184    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
185    0xffffffff8119561c : core_sys_select+0x1ec/0x370 [kernel]
186    0xffffffff81195860 : sys_select+0xc0/0x100 [kernel]
187    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
188      190 macvtapread(13215): <- macvtap_poll(): return=0x104
189        0 tcpdump(tap0): -> packet_poll(file=0xffff8800885f0e00 sock=0xffff88001904a000 wait=0xffff880017601b88 sk=? po=? mask=?)
190    0xffffffff815e51f0 : packet_poll+0x0/0x130 [kernel]
191    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
192    0xffffffff81195ceb : do_sys_poll+0x25b/0x4c0 [kernel]
193    0xffffffff8119602b : sys_poll+0x6b/0x100 [kernel]
194    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
195      223 tcpdump(tap0):  -> packet_lookup_frame(po=0xffff880066299000 rb=0xffff8800662992a0 position=0x6 status=0x0 pg_vec_pos=? frame_offset=? h={...})
196      249 tcpdump(tap0):   -> __packet_get_status(po=0xffff880066299000 frame=0xffff880019b60000 h={...})
197      269 tcpdump(tap0):   <- __packet_get_status(): return=0x11
198      282 tcpdump(tap0):  <- packet_lookup_frame(): return=0x0
199      294 tcpdump(tap0): <- packet_poll(): return=0x345
200        0 tcpdump(tap0): -> packet_poll(file=0xffff8800885f0e00 sock=0xffff88001904a000 wait=0xffff880017601b88 sk=? po=? mask=?)
201    0xffffffff815e51f0 : packet_poll+0x0/0x130 [kernel]
202    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
203    0xffffffff81195ceb : do_sys_poll+0x25b/0x4c0 [kernel]
204    0xffffffff8119602b : sys_poll+0x6b/0x100 [kernel]
205    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
206      204 tcpdump(tap0):  -> packet_lookup_frame(po=0xffff880066299000 rb=0xffff8800662992a0 position=0x6 status=0x0 pg_vec_pos=? frame_offset=? h={...})
207      229 tcpdump(tap0):   -> __packet_get_status(po=0xffff880066299000 frame=0xffff880019b60000 h={...})
208      250 tcpdump(tap0):   <- __packet_get_status(): return=0x0
209      262 tcpdump(tap0):  <- packet_lookup_frame(): return=0xffff880019b60000
210      277 tcpdump(tap0): <- packet_poll(): return=0x304
211        0 tapread(13310): -> tun_chr_poll(file=0xffff880002451f00 wait=0xffff8800a7435ab8 tfile=? tun=? sk=? mask=?)
212    0xffffffffa042f4a0 : tun_chr_poll+0x0/0x110 [tun]
213    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
214    0xffffffff8119561c : core_sys_select+0x1ec/0x370 [kernel]
215    0xffffffff81195860 : sys_select+0xc0/0x100 [kernel]
216    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
217      196 tapread(13310):  -> __tun_get(tfile=0xffff88000456afc0 tun=?)
218      215 tapread(13310):  <- __tun_get(): return=0xffff8800a9866780
219      234 tapread(13310):  -> tun_put(tun=0xffff8800a9866780 tfile=?)
220      252 tapread(13310):  <- tun_put(): 
221      262 tapread(13310): <- tun_chr_poll(): return=0x145
222        0 tapread(13310): -> tun_chr_aio_read(iocb=0xffff8800a7435e00 iv=0xffff8800a7435ed8 count=0x1 pos=0x0 file=? tfile=? tun=? len=? ret=?)
223    0xffffffffa042f6a0 : tun_chr_aio_read+0x0/0xe0 [tun]
224    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
225    0xffffffff81182250 : vfs_read+0xb0/0x180 [kernel]
226    0xffffffff8118236a : sys_read+0x4a/0x90 [kernel]
227    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
228      213 tapread(13310):  -> __tun_get(tfile=0xffff88000456afc0 tun=?)
229      230 tapread(13310):  <- __tun_get(): return=0xffff8800a9866780
230      248 tapread(13310):  -> tun_do_read(tun=0xffff8800a9866780 iocb=0xffff8800a7435e00 iv=0xffff8800a7435ed8 len=0x5de noblock=0x0 wait={...} skb=? ret=?)
231      284 tapread(13310):   -> netpoll_trap()
232      295 tapread(13310):   <- netpoll_trap(): return=0x0
233      312 tapread(13310):  <- tun_do_read(): return=0x2e
234      325 tapread(13310):  -> tun_put(tun=0xffff8800a9866780 tfile=?)
235      340 tapread(13310):  <- tun_put(): 
236      350 tapread(13310): <- tun_chr_aio_read(): return=0x2e
237        0 tapread(13310): -> tun_chr_poll(file=0xffff880002451f00 wait=0xffff8800a7435ab8 tfile=? tun=? sk=? mask=?)
238    0xffffffffa042f4a0 : tun_chr_poll+0x0/0x110 [tun]
239    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
240    0xffffffff8119561c : core_sys_select+0x1ec/0x370 [kernel]
241    0xffffffff81195860 : sys_select+0xc0/0x100 [kernel]
242    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
243      192 tapread(13310):  -> __tun_get(tfile=0xffff88000456afc0 tun=?)
244      209 tapread(13310):  <- __tun_get(): return=0xffff8800a9866780
245      225 tapread(13310):  -> tun_put(tun=0xffff8800a9866780 tfile=?)
246      241 tapread(13310):  <- tun_put(): 
247      251 tapread(13310): <- tun_chr_poll(): return=0x104
248        0 tcpdump(macvtap0): -> packet_poll(file=0xffff880027793a00 sock=0xffff8800a925c500 wait=0xffff8800a9a99b88 sk=? po=? mask=?)
249    0xffffffff815e51f0 : packet_poll+0x0/0x130 [kernel]
250    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
251    0xffffffff81195ceb : do_sys_poll+0x25b/0x4c0 [kernel]
252    0xffffffff8119602b : sys_poll+0x6b/0x100 [kernel]
253    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
254      242 tcpdump(macvtap0):  -> packet_lookup_frame(po=0xffff88003dd2b000 rb=0xffff88003dd2b2a0 position=0x1e status=0x0 pg_vec_pos=? frame_offset=? h={...})
255      271 tcpdump(macvtap0):   -> __packet_get_status(po=0xffff88003dd2b000 frame=0xffff88003c180000 h={...})
256      294 tcpdump(macvtap0):   <- __packet_get_status(): return=0x0
257      308 tcpdump(macvtap0):  <- packet_lookup_frame(): return=0xffff88003c180000
258      324 tcpdump(macvtap0): <- packet_poll(): return=0x304
259        0 tcpdump(macvtap0): -> packet_poll(file=0xffff880027793a00 sock=0xffff8800a925c500 wait=0xffff8800a9a99b88 sk=? po=? mask=?)
260    0xffffffff815e51f0 : packet_poll+0x0/0x130 [kernel]
261    0xffffffff8161a189 : kretprobe_trampoline+0x0/0x57 [kernel]
262    0xffffffff81195ceb : do_sys_poll+0x25b/0x4c0 [kernel]
263    0xffffffff8119602b : sys_poll+0x6b/0x100 [kernel]
264    0xffffffff8161fb69 : system_call_fastpath+0x16/0x1b [kernel]
265      193 tcpdump(macvtap0):  -> packet_lookup_frame(po=0xffff88003dd2b000 rb=0xffff88003dd2b2a0 position=0x1e status=0x0 pg_vec_pos=? frame_offset=? h={...})
266      217 tcpdump(macvtap0):   -> __packet_get_status(po=0xffff88003dd2b000 frame=0xffff88003c180000 h={...})
267      237 tcpdump(macvtap0):   <- __packet_get_status(): return=0x0
268      248 tcpdump(macvtap0):  <- packet_lookup_frame(): return=0xffff88003c180000
269      264 tcpdump(macvtap0): <- packet_poll(): return=0x304

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tun-trace.stp"

%{
#include <linux/skbuff.h>
#include <linux/if_vlan.h>
%}

function skb_dump:string(skb_ptr:long) %{
	struct sk_buff *skb = (void*)THIS->skb_ptr;
	if (!skb) {
		snprintf(THIS->__retvalue, MAXSTRINGLEN, "skb=NULL");
		return;
	}

	snprintf(THIS->__retvalue, MAXSTRINGLEN, "dev:%s proto:%04x len:%u vlan_tci:{prio:%d cfi:%d vid:%d}",
		skb->dev ? skb->dev->name : "NULL",
		htons(skb->protocol),
		skb->len,
		skb->vlan_tci & VLAN_PRIO_MASK,
		skb->vlan_tci & VLAN_CFI_MASK,
		skb->vlan_tci & VLAN_VID_MASK);
%}

function dev_dump:string(dev_ptr:long) %{
	struct net_device *dev = (void*)THIS->dev_ptr;
	if (!dev) {
		snprintf(THIS->__retvalue, MAXSTRINGLEN, "dev=NULL");
		return;
	}

	snprintf(THIS->__retvalue, MAXSTRINGLEN, "name:%s", dev->name);
%}

function deref_unsafe:long(pskb_ptr:long) %{
	struct sk_buff **pskb = (void*)THIS->pskb_ptr;
	if (!pskb || !(*pskb))
		THIS->__retvalue = 0;
	else
		THIS->__retvalue = (long)*pskb;
%}

probe begin {
	printf ("started\n")
}

global nesting = 0

probe probepoints.call = module("tun").function("*@drivers/net/tun.c").call,
			module("macvlan").function("*@drivers/net/macvlan.c").call,
			module("macvtap").function("*@drivers/net/macvtap.c").call,
			module("bridge").function("*@net/bridge/br_device.c").call,
			module("bridge").function("*@net/bridge/br_forward.c").call,
			kernel.function("vlan_*").call,
			kernel.function("__vlan_*").call,
			kernel.function("*@net/packet/af_packet.c").call,
			kernel.function("*@net/core/netpoll.c").call,
			kernel.function("*@net/core/dev.c").call {
	nesting++
}

probe probepoints.return = module("tun").function("*@drivers/net/tun.c").return,
			module("macvlan").function("*@drivers/net/macvlan.c").return,
			module("macvtap").function("*@drivers/net/macvtap.c").return,
			module("bridge").function("*@net/bridge/br_device.c").return,
			module("bridge").function("*@net/bridge/br_forward.c").return,
			kernel.function("vlan_*").return,
			kernel.function("__vlan_*").return,
			kernel.function("*@net/packet/af_packet.c").return,
			kernel.function("*@net/core/netpoll.c").return,
			kernel.function("*@net/core/dev.c").return {
	nesting--
}

probe probepoints.call {
	printf ("%s -> %s(%s)\n", thread_indent(1), probefunc(), $$vars)
	if (@defined($skb))
		printf("\tskb_dump:%s\n", skb_dump($skb))
	if (@defined($pskb))
		printf("\tpskb_dump:%s\n", skb_dump(deref_unsafe($pskb)))
	if (@defined($skbp))
		printf("\tskbp_dump:%s\n", skb_dump(deref_unsafe($skbp)))
	if (@defined($dev))
		printf("\tdev:%s\n", dev_dump($dev))
	if (@defined($orig_dev))
		printf("\torig_dev:%s\n", dev_dump($dev))
	if (nesting == 1)
		print_stack(backtrace())
}

probe probepoints.return {
	printf ("%s <- %s(): %s\n", thread_indent(-1), probefunc(), $$return)
}

--3V7upXqbjpZ4EhLz--
