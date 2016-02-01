From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH net-next 3/3] sctp: Add GSO support
Date: Mon, 1 Feb 2016 15:41:29 -0200
Message-ID: <56AF98C9.50906@gmail.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
 <b4da9001ca69a7279f68b9cbd0f2a14839a269e6.1453913331.git.marcelo.leitner@gmail.com>
 <CAKgT0Ufaga3ki-0Dv58Lk-_gjo18FAcFfBobyWcWQgae+jsr+Q@mail.gmail.com>
 <20160129194213.GF6604@mrl.redhat.com>
 <CAKgT0UfMQVPRg-TFj6gvr+U1Q5mpBR4L8dNKHNPeNz9itEY7eQ@mail.gmail.com>
 <56AF8629.9060307@gmail.com>
 <CAKgT0UeshMqkjewEVvpLJKU3UrdNbz5dET8WzaLr27o-saDOUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>, pabeni@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	linux-sctp@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:34831 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbcBARlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 12:41:44 -0500
In-Reply-To: <CAKgT0UeshMqkjewEVvpLJKU3UrdNbz5dET8WzaLr27o-saDOUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 01-02-2016 15:03, Alexander Duyck escreveu:
 > On Mon, Feb 1, 2016 at 8:22 AM, Marcelo Ricardo Leitner
 > <marcelo.leitner@gmail.com> wrote:
 >> Em 30-01-2016 02:07, Alexander Duyck escreveu:
 >>>
 >>> On Fri, Jan 29, 2016 at 11:42 AM, Marcelo Ricardo Leitner
 >>> <marcelo.leitner@gmail.com> wrote:
 >>>>
 >>>> On Fri, Jan 29, 2016 at 11:15:54AM -0800, Alexander Duyck wrote:
 >>>>>
 >>>>> On Wed, Jan 27, 2016 at 9:06 AM, Marcelo Ricardo Leitner
 >>
 >> ...
 >>
 >>>>>> diff --git a/net/core/dev.c b/net/core/dev.c
 >>>>>> index
 >>>>>> 
8cba3d852f251c503b193823b71b27aaef3fb3ae..9583284086967c0746de5f553535e25e125714a5
 >>>>>> 100644
 >>>>>> --- a/net/core/dev.c
 >>>>>> +++ b/net/core/dev.c
 >>>>>> @@ -2680,7 +2680,11 @@ EXPORT_SYMBOL(skb_mac_gso_segment);
 >>>>>>    static inline bool skb_needs_check(struct sk_buff *skb, bool 
tx_path)
 >>>>>>    {
 >>>>>>           if (tx_path)
 >>>>>> -               return skb->ip_summed != CHECKSUM_PARTIAL;
 >>>>>> +               /* FIXME: Why only packets with checksum 
offloading are
 >>>>>> +                * supported for GSO?
 >>>>>> +                */
 >>>>>> +               return skb->ip_summed != CHECKSUM_PARTIAL &&
 >>>>>> +                      skb->ip_summed != CHECKSUM_UNNECESSARY;
 >>>>>>           else
 >>>>>>                   return skb->ip_summed == CHECKSUM_NONE;
 >>>>>>    }
 >>>>>
 >>>>>
 >>>>> Tom Herbert just got rid of the use of CHECKSUM_UNNECESSARY in the
 >>>>> transmit path a little while ago.  Please don't reintroduce it.
 >>>>
 >>>>
 >>>> Can you give me some pointers on that? I cannot find such change.
 >>>> skb_needs_check() seems to be like that since beginning.
 >>>
 >>>
 >>> Maybe you need to update your kernel.  All this stuff was changed in
 >>> December and has been this way for a little while now.
 >>>
 >>> Commits:
 >>> 7a6ae71b24905 "net: Elaborate on checksum offload interface 
description"
 >>> 253aab0597d9e "fcoe: Use CHECKSUM_PARTIAL to indicate CRC offload"
 >>> 53692b1de419c "sctp: Rename NETIF_F_SCTP_CSUM to NETIF_F_SCTP_CRC"
 >>>
 >>> The main reason I even noticed it is because of some of the work I did
 >>> on the Intel NIC offloads.
 >>
 >>
 >> Ok I have those here, but my need here is different. I want to do 
GSO with
 >> packets that won't have CRC offloaded, so I shouldn't use 
CHECKSUM_PARTIAL
 >> but something else.
 >
 > CHECKSUM_NONE if you don't want to have any of the CRC or checksums
 > offloaded.  However as I mentioned before you will want to fake it
 > then since skb_segment assumes it is doing a 1's compliment checksum
 > so you will want to pass NET_F_HW_CSUM as a feature flag and then set
 > CHECKSUM_NONE after the frame has been segmented.

Ok

 >> ...
 >>
 >>>>>> diff --git a/net/sctp/offload.c b/net/sctp/offload.c
 >>>>>> index
 >>>>>> 
7080a6318da7110c1688dd0c5bb240356dbd0cd3..3b96035fa180a4e7195f7b6e7a8be7b97c8f8b26
 >>>>>> 100644
 >>>>>> --- a/net/sctp/offload.c
 >>>>>> +++ b/net/sctp/offload.c
 >>>>>> @@ -36,8 +36,61 @@
 >>>>>>    #include <net/sctp/checksum.h>
 >>>>>>    #include <net/protocol.h>
 >>>>>>
 >>>>>> +static __le32 sctp_gso_make_checksum(struct sk_buff *skb)
 >>>>>> +{
 >>>>>> +       skb->ip_summed = CHECKSUM_NONE;
 >>>>>> +       return sctp_compute_cksum(skb, skb_transport_offset(skb));
 >>>>>> +}
 >>>>>> +
 >>>>>
 >>>>>
 >>>>> I really despise the naming of this bit here.  SCTP does not use a
 >>>>> checksum.  It uses a CRC.  Please don't call this a checksum as it
 >>>>> will just make the code really confusing.   I think the name 
should be
 >>>>> something like gso_make_crc32c.
 >>>>
 >>>>
 >>>> Agreed. SCTP code still references it as 'cksum'. I'll change that in
 >>>> another patch.
 >>>>
 >>>>> I think we need to address the CRC issues before we can really get
 >>>>> into segmentation.  Specifically we need to be able to offload SCTP
 >>>>> and FCoE in software since they both use the CHECKSUM_PARTIAL value
 >>>>> and then we can start cleaning up more of this mess and move onto
 >>>>> segmentation.
 >>>>
 >>>>
 >>>> Hm? The mess on CRC issues here is caused by this patch alone. 
It's good
 >>>> as it is today. And a good part of this mess is caused by trying 
to GSO
 >>>> without offloading CRC too.
 >>>>
 >>>> Or you mean that SCTP and FCoE should stop using CHECKSUM_* at all?
 >>>
 >>>
 >>> Well after Tom's change both SCTP and FCoE use CHECKSUM_PARTIAL.
 >>> CHECKSUM_PARTIAL is what is used to indicate to the hardware that a
 >>> checksum offload has been requested so that is what is looked for at
 >>> the driver level.
 >>
 >>
 >> SCTP was actually already using CHECKSUM_PARTIAL. That patch was just a
 >> rename in an attempt to make this crc difference more evident. Yet I'll
 >> continue the rename within sctp code.
 >
 > Yeah it was FCoE that was doing something different.
 >
 >>> My concern with all this is that we should probably be looking at
 >>> coming up with a means of offloading this in software when
 >>> skb_checksum_help is called.  Right now validate_xmit_skb doesn't have
 >>> any understanding of what to do with SCTP or FCoE and will try to just
 >>> compute a checksum for them.
 >>
 >>
 >> My worry is placed a bit earlier than that, I think. Currently I 
just cannot
 >> do GSO with packets that doesn't have checksum/crc offloaded too because
 >> validate_xmit_skb() will complain.
 >
 > That is probably because you are passing CHECKSUM_PARTIAL instead of
 > CHECKSUM_NONE.

Other way around, but it's cool. We are pretty much on the same page 
now, I think.

 >> As NICs hardly have sctp crc offloading capabilities, I'm thinking 
it makes
 >> sense to do GSO even without crc offloaded. After all, it doesn't matter
 >> much in which stage we are computing the crc as we are computing it 
anyway.
 >
 > Agreed.  You will need to support CHECKSUM_PARTIAL being passed to a
 > device that doesn't support SCTP first.  That way you can start
 > looking at just always setting CHECKSUM_PARTIAL in the transport layer
 > which is really needed if you want to do SCO (SCTP Segmentation
 > Offload) in the first place.  Once you have that you could then start
 > looking at doing the SCO since from that point on you should already
 > be in good shape to address those type of issues.  You should probably
 > use the csum_offset value in the skb in order to flag if this is
 > possibly SCTP.  As far as I know for now there shouldn't be any other
 > protocols that are using the same offset, and if needed you can
 > actually parse the headers to verify if the frame is actually SCTP.

Cool, yes.
Just cannot set CHECKSUM_PARTIAL always because if frame is not a GSO, 
we will not have another chance to fill in SCTP CRC if it's not 
offloaded. A check still have to consider for that, but np.

 >>>>>> +static struct sk_buff *sctp_gso_segment(struct sk_buff *skb,
 >>>>>> +                                       netdev_features_t features)
 >>>>>> +{
 >>>>>> +       struct sk_buff *segs = ERR_PTR(-EINVAL);
 >>>>>> +       struct sctphdr *sh;
 >>>>>> +
 >>>>>> +       sh = sctp_hdr(skb);
 >>>>>> +       if (!pskb_may_pull(skb, sizeof(*sh)))
 >>>>>> +               goto out;
 >>>>>> +
 >>>>>> +       __skb_pull(skb, sizeof(*sh));
 >>>>>> +
 >>>>>> +       if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
 >>>>>> +               /* Packet is from an untrusted source, reset 
gso_segs.
 >>>>>> */
 >>>>>> +               int type = skb_shinfo(skb)->gso_type;
 >>>>>> +
 >>>>>> +               if (unlikely(type &
 >>>>>> +                            ~(SKB_GSO_SCTP | SKB_GSO_DODGY |
 >>>>>> +                              0) ||
 >>>>>> +                            !(type & (SKB_GSO_SCTP))))
 >>>>>> +                       goto out;
 >>>>>> +
 >>>>>> +               /* This should not happen as no NIC has SCTP GSO
 >>>>>> +                * offloading, it's always via software and thus we
 >>>>>> +                * won't send a large packet down the stack.
 >>>>>> +                */
 >>>>>> +               WARN_ONCE(1, "SCTP segmentation offloading to 
NICs is
 >>>>>> not supported.");
 >>>>>> +               goto out;
 >>>>>> +       }
 >>>>>> +
 >>>>>
 >>>>>
 >>>>> So what you are going to end up needing here is some way to tell the
 >>>>> hardware that you are doing the checksum no matter what.  There is no
 >>>>> value in you computing a 1's compliment checksum for the payload if
 >>>>> you aren't going to use it.  What you can probably do is just clear
 >>>>> the standard checksum flags and then OR in NETIF_F_HW_CSUM if
 >>>>> NETIF_F_SCTP_CRC is set and that should get skb_segment to skip
 >>>>> offloading the checksum.
 >>>>
 >>>>
 >>>> Interesting, ok
 >>>>
 >>>>> One other bit that will make this more complicated is if we ever get
 >>>>> around to supporting SCTP in tunnels.  Then we will need to sort out
 >>>>> how things like remote checksum offload should impact SCTP, and 
how to
 >>>>> deal with needing to compute both a CRC and 1's compliment checksum.
 >>>>> What we would probably need to do is check for encap_hdr_csum and if
 >>>>> it is set and we are doing SCTP then we would need to clear the
 >>>>> NETIF_F_HW_CSUM, NETIF_F_IP_CSUM, and NETIF_F_IPV6_CSUM flags.
 >>>>
 >>>>
 >>>> Yup. And that includes on storing pointers to where to store each 
of it.
 >>>
 >>>
 >>> Actually the pointers bit is easy.  The csum_start and csum_offset
 >>> values should be set up after you have segmented the skb and should be
 >>> updated after the skb has been segmented.  If nothing else you can
 >>> probably take a look at the TCP code tcp_gso_segment and
 >>> tcp4_gso_segment for inspiration.  Basically you need to make sure
 >>> that you set the ip_summed, csum_start, and csum_offset values for
 >>> your first frame before you start segmenting it into multiple frames.
 >>
 >>
 >> Ah yes, ok, that's for now, when not doing crc offloading with some 
chksum
 >> offloading (tunnel) too.
 >
 > Actually that would be regardless of tunnel offloading.  We don't
 > store the outer checksum offsets.  If we need outer checksum we
 > restore them after the fact since the inner checksum offsets are
 > needed as part of the inner header TCP checksum computation.

Hm okay

 >>>>>> +       segs = skb_segment(skb, features);
 >>>>>> +       if (IS_ERR(segs))
 >>>>>> +               goto out;
 >>>>>> +
 >>>>>> +       /* All that is left is update SCTP CRC if necessary */
 >>>>>> +       for (skb = segs; skb; skb = skb->next) {
 >>>>>> +               if (skb->ip_summed != CHECKSUM_PARTIAL) {
 >>>>>> +                       sh = sctp_hdr(skb);
 >>>>>> +                       sh->checksum = sctp_gso_make_checksum(skb);
 >>>>>> +               }
 >>>>>> +       }
 >>>>>> +
 >>>>>
 >>>>>
 >>>>> Okay, so it looks like you are doing the right thing here and leaving
 >>>>> this as CHECKSUM_PARTIAL.
 >>>>
 >>>>
 >>>> Actually no then. sctp_gso_make_checksum() replaces it:
 >>>> +static __le32 sctp_gso_make_checksum(struct sk_buff *skb)
 >>>> +{
 >>>> +       skb->ip_summed = CHECKSUM_NONE;
 >>>> +       return sctp_compute_cksum(skb, skb_transport_offset(skb));
 >>>>
 >>>> Why again would have to leave it as CHECKSUM_PARTIAL? IP header?
 >>>
 >>>
 >>> My earlier comment is actually incorrect.  This section is pretty much
 >>> broken since CHECKSUM_PARTIAL only reflects a 1's compliment checksum
 >>> in the case of skb_segment so whatever the value it is worthless.
 >>> CHECKSUM_PARTIAL is used to indicate if a given frame needs to be
 >>> offloaded.  It is meant to let the device know that it still needs to
 >>> compute a checksum or CRC beginning at csum_start and then storing the
 >>> new value at csum_offset.  However for skb_segment it is actually
 >>> referring to a 1's compliment checksum and if it returns CHECKSUM_NONE
 >>> it means it is stored in skb->csum which would really wreck things for
 >>> you since that was your skb->csum_start and skb->csum_offset values.
 >>> I have a patch to change this so that we update a checksum in the
 >>> SKB_GSO_CB, but I wasn't planning on submitting that until net-next
 >>> opens.
 >>
 >>
 >> sctp currently ignores skb->csum. It doesn't mess with the crc but 
computing
 >> it is at least not optimal, yes.
 >
 > Actually sctp sets csum_start and csum_offset if it sets
 > CHECKSUM_PARTIAL.  So it does mess with skb->csum since it is
 > contained in a union with those two fields.

Well, yes, but point was that messed value is not used for anything 
useful later on..
I'll implement the NETIF_F_HW_CSUM trick.

 >>> In the case of SCTP you probably don't even need to bother checking
 >>> the value since it is meaningless as skb_segment doesn't know how to
 >>> do an SCTP checksum anyway.  To that end for now what you could do is
 >>> just set NETIF_F_HW_CSUM.  This way skb_segment won't go and try to
 >>> compute a 1's compliment checksum on the payload since there is no
 >>> actual need for it.
 >>
 >>
 >> Nice, ok.
 >>
 >>> One other bit you will need to do is to check the value of SCTP_CRC
 >>> outside of skb_segment.  You might look at how
 >>> __skb_udp_tunnel_segment does this to populate its own offload_csum
 >>> boolean value, though you would want to use features, not
 >>> skb->dev->features as that is a bit of a workaround since features is
 >>> stripped by hw_enc_features in some paths if I recall correctly.
 >>
 >>>
 >>>
 >>> Once the frames are segmented and if you don't support the offload you
 >>> could then call gso_make_crc32c() or whatever you want to name it to
 >>> perform the CRC calculation and populate the field.  One question by
 >>
 >>
 >> Hmmm.. does it mean that we can use CHECKSUM_PARTIAL then even if CRC
 >> offloading is not possible then? Because the packet will not be 
offloaded in
 >> the end, yes, but this solves my questions above. Then while doing 
GSO, it
 >> re-evaluates if it can offload crc or not?
 >
 > If you compute the CRC you set CHECKSUM_NONE, if you want the device
 > to do it on transmit you should set CHECKSUM_PARTIAL.

Okay

 >>> the way.  Don't you need to initialize the checksum value to 0 before
 >>> you compute it?  I think you might have missed that step when you were
 >>> setting this up.
 >>
 >>
 >> It's fine :) sctp_compute_cksum will replace it with zeroes, 
calculate, and
 >> put back the old value, which then we overwrite with the new one at
 >> sctp_gso_segment.
 >
 > Right but there are scenarios where this will be offloaded isn't
 > there?  You would probably be better off setting the CRC to 0 before
 > you start segmentation and then that way you can either just set
 > csum_offset, csum_start and ip_summed if the lower device supports
 > SCTP CRC offload, otherwise you can just compute it without the need
 > to write the 0 into the header.

Ahh, it's also zeroed when the header is constructed. There is 
'sh->checksum = 0;' in sctp_packet_transmit for this.

I'll look into moving this decision on CRC offloading or not into the 
segmentation moment. I think it will have to be done twice, actually, 
for sctp-reasons. Like, if packet will be fragmented by IP, it currently 
doesn't allow offloading CRC computing. I'll check, then post a v2. I 
think at that least the crc offloading is now clarified. Thanks Alex.

Marcelo
