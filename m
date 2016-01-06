From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [BUG] skb corruption and kernel panic at forwarding with
 fragmentation
Date: Wed, 6 Jan 2016 19:05:32 -0200
Message-ID: <20160106210532.GE27290@indiana.gru.redhat.com>
References: <CALYGNiP-0MZ-FExV2HutTvE9U-QQtkKSoE--KN=JQE5STYsjAA@mail.gmail.com>
 <CAM_iQpWsx6w2tFvSAy66M69FNi5iSp===EFCrO=4EPjy7y3iSg@mail.gmail.com>
 <CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALYGNiOjeh4Jfvmc6fJHaZYJyinXmZjTHXcacNreBXvzB1ajtQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 06, 2016 at 11:11:41PM +0300, Konstantin Khlebnikov wrote:
> On Wed, Jan 6, 2016 at 10:59 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Wed, Jan 6, 2016 at 11:15 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> >> Looks like this happens because ip_options_fragment() relies on
> >> correct ip options length in ip control block in skb. But in
> >> ip_finish_output_gso() control block in segments is reused by
> >> skb_gso_segment(). following ip_fragment() sees some garbage.
> >>
> >> In my case there was no ip options but length becomes non-zero and
> >> ip_options_fragment() picked some bytes from payload and decides to
> >> fill huge range with IPOPT_NOOP (1). One of that ones flipped nr_frags
> >> in skb_shared_info at the end of data =)
> >>
> >
> > Hmm, it looks like SKB_GSO_CB should be cleared after skb_gso_segment()
> > since all the gso information should be saved in shared_info after it finishes.
> >
> > Does a memset(0) on SKB_GSO_CB after skb_gso_segment() work as well?
> 
> This will break present logic around ip_options_fragment() - it clears
> options from
> second and following fragments. With zeroed cb it will do nothing.
> 
> ip_options_fragment() can get required information directly from ip header but
> it also resets fields in IPCB -- probably it should stay valid here
> and somebody else will use it later.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I have hit this as well, this fixes it for me on an older kernel. Can you try it
on latest kernel?

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d8a1745..f44bc91 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -216,6 +216,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	netdev_features_t features;
 	struct sk_buff *segs;
 	int ret = 0;
+	struct inet_skb_parm ipcb;
 
 	if (skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
 		return ip_finish_output2(skb);
@@ -227,6 +228,10 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	 * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
 	 * from host network stack.
 	 */
+	/* We need to save IPCB here because skb_gso_segment will use
+	 * SKB_GSO_CB.
+	 */
+	ipcb = *IPCB(skb);
 	features = netif_skb_features(skb);
 	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
 	if (IS_ERR_OR_NULL(segs)) {
@@ -241,6 +246,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
+		*IPCB(segs) = ipcb;
 		err = ip_fragment(segs, ip_finish_output2);
 
 		if (err && ret == 0)
