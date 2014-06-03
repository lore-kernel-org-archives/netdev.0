From: Igor Royzis <igorr@swortex.com>
Subject: Re: [PATCH] Fixed zero copy GSO without orphaning the fragments
Date: Tue, 3 Jun 2014 14:54:29 +0300
Message-ID: <CAKyyzSSs1PUfJXTPDWTbWU5p+b54qti_N_6kR6mJWWrp__rykw@mail.gmail.com>
References: <CAKyyzSRfO_Hw4bDimfzV9+-8damc9RwoqA_RLkBBa_gMw9e62Q@mail.gmail.com>
	<20140601122152.GB22450@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Simon Horman <horms@verge.net.au>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jiri@resnulli.us>,
	Florian Westphal <fw@strlen.de>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Jan Beulich <JBeulich@suse.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miklos Szeredi <mszeredi@suse.cz>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Anton Nayshtut <anton@swortex.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36573 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101AbaFCLya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 07:54:30 -0400
Received: by mail-qg0-f52.google.com with SMTP id a108so12728791qge.25
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 04:54:29 -0700 (PDT)
In-Reply-To: <20140601122152.GB22450@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, could you please provide a feedback on the suggestion to move
the pointer from skb_shared_info to skbuff? If we must fit
skb_shared_info till the 'frags' field into 1 cache line (I honestly
don't quite understand why (the whole structure as well as the skb's
data will always require > 1 cache line anyway)  and I would
appreciate if you elaborate on this more), then moving the pointer to
the parent fragment off skb_shared_info should help. Am I right?

The pointer is essential if we want to solve the incorrect way the
kernel handles a combination of packet segmentation (of any reason, in
our case it was a VM guest not supporting GRO) and zero-copy feature.
Disabling zero-copy for segmented packets is a workaround but an
efficient solution would require either:
a) a pointer in skb_shared_info, or
b) a pointer in skbuff,  or
c) reusing a [currently unused] existing pointer/field in a skb
structure, which is a bad idea and I list it for completeness only.

Please comment,
-Igor

On Sun, Jun 1, 2014 at 3:21 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Sun, Jun 01, 2014 at 02:39:39PM +0300, Igor Royzis wrote:
>> The patch discussion seems got lost due to a delay it took us to get
>> the numbers. We believe that a 24% improvement in VM's network
>> performance (and probably the better improvement the more guests are
>> running on a host) is worth commenting and getting to some conclusion.
>
> Absolutely, but we need to find a way to address Eric's comments.
>
>> > Before your patch :
>> >
>> > sizeof(struct skb_shared_info)=0x140
>> > offsetof(struct skb_shared_info, frags[1])=0x40
>> >
>> > SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) -> 0x140
>> >
>> > After your patch :
>> >
>> > sizeof(struct skb_shared_info)=0x148
>> > offsetof(struct skb_shared_info, frags[1])=0x48
>> >
>> > SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) -> 0x180
>> >
>> > Thats a serious bump, because it increases all skb truesizes, and
>> > typical skb with one fragment will use 2 cache lines instead of one in
>> > struct skb_shared_info, so this adds memory pressure in fast path.
>> >
>> > So while this patch might increase performance for some workloads,
>> > it generally decreases performance on many others.
>>
>> Would moving  the parent fragment pointer from skb_shared_info to
>> skbuff solve this issue?
>>
>> Regards,
>> -Igor
>>
>> On Sun, May 25, 2014 at 1:54 PM, Igor Royzis <igorr@swortex.com> wrote:
>> >> If true, I'd like to see some performance numbers please.
>> >
>> > The numbers have been obtained by running iperf between 2 QEMU Win2012
>> > VMs, 4 vCPU/ 4GB RAM each.
>> > iperf parameters: -w 256K -l 256K -t 300
>> > Original kernel 3.15.0-rc5:           34.4 Gbytes transferred, 984
>> > Mbits/sec bandwidth.
>> > Kernel 3.15.0-rc5 with our patch: 42.5 Gbytes transferred, 1.22
>> > Gbits/sec bandwidth.
>> >
>> > Overall improvement is about 24%.
>> > Below are raw iperf outputs.
>> >
>> > kernel 3.15.0-rc5:
>> > C:\iperf>iperf -c 192.168.11.2 -w 256K -l 256K -t 300
>> > ------------------------------------------------------------
>> > Client connecting to 192.168.11.2, TCP port 5001
>> > TCP window size:  256 KByte
>> > ------------------------------------------------------------
>> > [  3] local 192.168.11.1 port 49167 connected with 192.168.11.2 port 5001
>> > [ ID] Interval       Transfer     Bandwidth
>> > [  3]  0.0-300.7 sec  34.4 GBytes   984 Mbits/sec
>> >
>> > kernel 3.15.0-rc5-patched:
>> > C:\iperf>iperf -c 192.168.11.2 -w 256K -l 256K -t 300
>> > ------------------------------------------------------------
>> > Client connecting to 192.168.11.2, TCP port 5001
>> > TCP window size:  256 KByte
>> > ------------------------------------------------------------
>> > [  3] local 192.168.11.1 port 49167 connected with 192.168.11.2 port 5001
>> > [ ID] Interval       Transfer     Bandwidth
>> > [  3]  0.0-300.7 sec  42.5 GBytes   1.22 Gbits/sec
>> >
>> > On Tue, May 20, 2014 at 2:50 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> >>
>> >> On Tue, May 20, 2014 at 02:24:21PM +0300, Igor Royzis wrote:
>> >> > Fix accessing GSO fragments memory (and a possible corruption therefore) after
>> >> > reporting completion in a zero copy callback. The previous fix in the commit 1fd819ec
>> >> > orphaned frags which eliminates zero copy advantages. The fix makes the completion
>> >> > called after all the fragments were processed avoiding unnecessary orphaning/copying
>> >> > from userspace.
>> >> >
>> >> > The GSO fragments corruption issue was observed in a typical QEMU/KVM VM setup that
>> >> > hosts a Windows guest (since QEMU virtio-net Windows driver doesn't support GRO).
>> >> > The fix has been verified by running the HCK OffloadLSO test.
>> >> >
>> >> > Signed-off-by: Igor Royzis <igorr@swortex.com>
>> >> > Signed-off-by: Anton Nayshtut <anton@swortex.com>
>> >>
>> >> OK but with 1fd819ec there's no corruption, correct?
>> >> So this patch is in fact an optimization?
>> >> If true, I'd like to see some performance numbers please.
>> >>
>> >> Thanks!
>> >>
>> >> > ---
>> >> >  include/linux/skbuff.h |    1 +
>> >> >  net/core/skbuff.c      |   18 +++++++++++++-----
>> >> >  2 files changed, 14 insertions(+), 5 deletions(-)
>> >> >
>> >> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> >> > index 08074a8..8c49edc 100644
>> >> > --- a/include/linux/skbuff.h
>> >> > +++ b/include/linux/skbuff.h
>> >> > @@ -287,6 +287,7 @@ struct skb_shared_info {
>> >> >       struct sk_buff  *frag_list;
>> >> >       struct skb_shared_hwtstamps hwtstamps;
>> >> >       __be32          ip6_frag_id;
>> >> > +     struct sk_buff  *zcopy_src;
>> >> >
>> >> >       /*
>> >> >        * Warning : all fields before dataref are cleared in __alloc_skb()
>> >> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> >> > index 1b62343..6fa6342 100644
>> >> > --- a/net/core/skbuff.c
>> >> > +++ b/net/core/skbuff.c
>> >> > @@ -610,14 +610,18 @@ EXPORT_SYMBOL(__kfree_skb);
>> >> >   */
>> >> >  void kfree_skb(struct sk_buff *skb)
>> >> >  {
>> >> > +     struct sk_buff *zcopy_src;
>> >> >       if (unlikely(!skb))
>> >> >               return;
>> >> >       if (likely(atomic_read(&skb->users) == 1))
>> >> >               smp_rmb();
>> >> >       else if (likely(!atomic_dec_and_test(&skb->users)))
>> >> >               return;
>> >> > +     zcopy_src = skb_shinfo(skb)->zcopy_src;
>> >> >       trace_kfree_skb(skb, __builtin_return_address(0));
>> >> >       __kfree_skb(skb);
>> >> > +     if (unlikely(zcopy_src))
>> >> > +             kfree_skb(zcopy_src);
>> >> >  }
>> >> >  EXPORT_SYMBOL(kfree_skb);
>> >> >
>> >> > @@ -662,14 +666,18 @@ EXPORT_SYMBOL(skb_tx_error);
>> >> >   */
>> >> >  void consume_skb(struct sk_buff *skb)
>> >> >  {
>> >> > +     struct sk_buff *zcopy_src;
>> >> >       if (unlikely(!skb))
>> >> >               return;
>> >> >       if (likely(atomic_read(&skb->users) == 1))
>> >> >               smp_rmb();
>> >> >       else if (likely(!atomic_dec_and_test(&skb->users)))
>> >> >               return;
>> >> > +     zcopy_src = skb_shinfo(skb)->zcopy_src;
>> >> >       trace_consume_skb(skb);
>> >> >       __kfree_skb(skb);
>> >> > +     if (unlikely(zcopy_src))
>> >> > +             consume_skb(zcopy_src);
>> >> >  }
>> >> >  EXPORT_SYMBOL(consume_skb);
>> >> >
>> >> > @@ -2867,7 +2875,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>> >> >       skb_frag_t *frag = skb_shinfo(head_skb)->frags;
>> >> >       unsigned int mss = skb_shinfo(head_skb)->gso_size;
>> >> >       unsigned int doffset = head_skb->data - skb_mac_header(head_skb);
>> >> > -     struct sk_buff *frag_skb = head_skb;
>> >> >       unsigned int offset = doffset;
>> >> >       unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
>> >> >       unsigned int headroom;
>> >> > @@ -2913,7 +2920,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>> >> >                       i = 0;
>> >> >                       nfrags = skb_shinfo(list_skb)->nr_frags;
>> >> >                       frag = skb_shinfo(list_skb)->frags;
>> >> > -                     frag_skb = list_skb;
>> >> >                       pos += skb_headlen(list_skb);
>> >> >
>> >> >                       while (pos < offset + len) {
>> >> > @@ -2975,6 +2981,11 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>> >> >                                                nskb->data - tnl_hlen,
>> >> >                                                doffset + tnl_hlen);
>> >> >
>> >> > +             if (skb_shinfo(head_skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
>> >> > +                     skb_shinfo(nskb)->zcopy_src = head_skb;
>> >> > +                     atomic_inc(&head_skb->users);
>> >> > +             }
>> >> > +
>> >> >               if (nskb->len == len + doffset)
>> >> >                       goto perform_csum_check;
>> >> >
>> >> > @@ -3001,7 +3012,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>> >> >                               i = 0;
>> >> >                               nfrags = skb_shinfo(list_skb)->nr_frags;
>> >> >                               frag = skb_shinfo(list_skb)->frags;
>> >> > -                             frag_skb = list_skb;
>> >> >
>> >> >                               BUG_ON(!nfrags);
>> >> >
>> >> > @@ -3016,8 +3026,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>> >> >                               goto err;
>> >> >                       }
>> >> >
>> >> > -                     if (unlikely(skb_orphan_frags(frag_skb, GFP_ATOMIC)))
>> >> > -                             goto err;
>> >> >
>> >> >                       *nskb_frag = *frag;
>> >> >                       __skb_frag_ref(nskb_frag);
>> >> > --
>> >> > 1.7.9.5
