From: Konstantin Khlebnikov <koct9i@gmail.com>
Subject: Re: [BUG] skb corruption and kernel panic at forwarding with fragmentation
Date: Thu, 7 Jan 2016 14:00:53 +0300
Message-ID: <CALYGNiObS1fuDNi7Q69BwoWmU8xOnndzy7Z-m35aphjQWUuEnQ@mail.gmail.com>
References: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
	<CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
	<CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
	<20160106210532.GE27290@indiana.gru.redhat.com>
	<20160106220334.GA23789@breakpoint.cc>
	<20160106234943.GB23789@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160106234943.GB23789@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 7, 2016 at 2:49 AM, Florian Westphal <fw@strlen.de> wrote:
> Florian Westphal <fw@strlen.de> wrote:
>> Thadeu Lima de Souza Cascardo <cascardo@redhat.com> wrote:
>> > On Wed, Jan 06, 2016 at 11:11:41PM +0300, Konstantin Khlebnikov wrote:
>
> [ skb_gso_segment uses skb->cb[], causes oops if ip_fragment is invoked
>   on segmented skbs ]
>
>> > I have hit this as well, this fixes it for me on an older kernel. Can you try it
>> > on latest kernel?
>>
>> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>> > index d8a1745..f44bc91 100644
>> > --- a/net/ipv4/ip_output.c
>> > +++ b/net/ipv4/ip_output.c
>> > @@ -216,6 +216,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>> >     netdev_features_t features;
>> >     struct sk_buff *segs;
>> >     int ret = 0;
>> > +   struct inet_skb_parm ipcb;
>> >
>> >     if (skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
>> >             return ip_finish_output2(skb);
>> > @@ -227,6 +228,10 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>> >      * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
>> >      * from host network stack.
>> >      */
>> > +   /* We need to save IPCB here because skb_gso_segment will use
>> > +    * SKB_GSO_CB.
>> > +    */
>> > +   ipcb = *IPCB(skb);
>> >     features = netif_skb_features(skb);
>> >     segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
>> >     if (IS_ERR_OR_NULL(segs)) {
>> > @@ -241,6 +246,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>> >             int err;
>> >
>> >             segs->next = NULL;
>> > +           *IPCB(segs) = ipcb;
>> >             err = ip_fragment(segs, ip_finish_output2);
>> >
>> >             if (err && ret == 0)
>>
>> I'm worried that this doesn't solve all cases. f.e. xfrm may also
>> call skb_gso_segment(), and it will call into ipv4/ipv6 netfilter
>> postrouting + ipv4 output functions...
>>
>> nfqnl_enqueue_packet() is also affected.
>
> ... but it seems that those three are the only affected callers
> of skb_gso_segment (tbf is ok since skb isn't owned by anyone,
> ovs does save/restore already).
>
> I think this patch is the right way, we just need similar
> save/restore in nfqnl_enqueue_packet and xfrm_output_gso().

Which CB could be here? at this point skb isn't owned by netlink yet.

>
> The latter two can be used by either ipv4 or ipv6 so it might
> be preferable to just save/restore sizeof(struct skb_gso_cb);
> or a union of inet_skb_parm+inet6_skb_parm.

Or just shift GSO CB and add couple checks like
BUILD_BUG_ON(sizeof(SKB_GSO_CB(skb)->room) < sizeof(*IPCB(skb)));
