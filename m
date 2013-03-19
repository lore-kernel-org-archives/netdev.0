From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net_sched: don't do precise pkt_len
 computation for untrusted packets
Date: Tue, 19 Mar 2013 05:58:26 -0700
Message-ID: <1363697906.21184.53.camel@edumazet-glaptop>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com>
	 <20130317.121026.733329595817911776.davem@davemloft.net>
	 <51482F14.9030407@redhat.com> <1363695040.21184.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com,
	Daniel Borkmann <dborkman@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363695040.21184.32.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-03-19 at 05:10 -0700, Eric Dumazet wrote:
> On Tue, 2013-03-19 at 17:25 +0800, Jason Wang wrote:
> 
> > I believe before doing header check for untrusted packets, the only
> > thing we can trust is skb->len and that's we've used before
> > 1def9238d4aa2. But after that, we're trying to use unchecked or
> > meaningless value (e.g gso_segs were reset to zero in
> > tun/macvtap/packet), and guest then can utilize this to result a very
> > huge (-1U) pkt_len by filling evil value in the header. Can all kinds of
> > packet scheduler survive this kinds of possible DOS?
> 
> I would use the flow dissector to fix the transport header from all
> DODGY providers.
> 
> Daniel Borkmann is working on a patch serie adding nhoff into flow_keys,
> and adding __skb_get_poff(const struct sk_buff *skb), for a BPF
> extension we talked about in Copenhagen / Netfilter Workshop.
> 
> You could then set the transport header offset to the right value.
> 
> (and drop evil packets before they go further in the stack)
> 
> if (gso_packet(skb)) {
> 	u32 poff = __skb_get_poff(skb);
> 
> 	if (!poff) {
> 		drop_evil_packet(skb);
> 	} else {
> 		skb_set_transport_header(skb, poff);
> 		...
> 	}
> }


Oh well, no need to use __skb_get_poff() but plain skb_flow_dissect()
(once patched to include thoff in struct flow_keys)

struct flow_keys keys;

if (!skb_flow_dissect(skb, &keys))
	goto drop;

if ((gso_type & (SKB_GSO_TCPV4|SKB_GSO_TCPV6)) &&
    keys.ip_proto != IP_PROTO_TCP)
	goto drop;

skb_set_transport_header(skb, keys.thoff);
