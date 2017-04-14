From: Ansis Atteka <ansisatteka@gmail.com>
Subject: Re: [PATCH net] xfrm: calculate L4 checksums also for GSO case before
 encrypting packets
Date: Thu, 13 Apr 2017 19:54:35 -0700
Message-ID: <CAMQa7Bhr3VTSzRucCX_nJEFTuO7nFpV+g_DD_qekvJm5ZMxdBA@mail.gmail.com>
References: <1491849727-32008-1-git-send-email-aatteka@ovn.org>
 <20170411070755.GW5092@secunet.com> <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org, Ansis Atteka <aatteka@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33473 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdDNCyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 22:54:37 -0400
Received: by mail-io0-f195.google.com with SMTP id k87so16625853ioi.0
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 19:54:36 -0700 (PDT)
In-Reply-To: <CAMQa7Biajree5Kc1fOWQN42R1UDDGp7ZevZZRtUMZOKDWTk-Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 April 2017 at 19:45, Ansis Atteka <ansisatteka@gmail.com> wrote:
>
>
>
> On 11 April 2017 at 00:07, Steffen Klassert <steffen.klassert@secunet.com> wrote:
>>
>> On Mon, Apr 10, 2017 at 11:42:07AM -0700, Ansis Atteka wrote:
>> > Otherwise, if L4 checksum calculation is done after encryption,
>> > then all ESP packets end up being corrupted at the location
>> > where pre-encryption L4 checksum field resides.
>> >
>> > One of the ways to reproduce this bug is to have a VM with virtio_net
>> > driver (UFO set to ON in the guest VM); and then encapsulate all guest's
>> > Ethernet frames in GENEVE; and then further encrypt GENEVE with IPsec.
>> > In this case following symptoms are observed:
>> > 1. If using ixgbe NIC, then the driver will also emit following
>> >    warning message:
>> >    ixgbe 0000:01:00.1: partial checksum but l4 proto=32!
>> > 2. Receiving VM will drop all the corrupted ESP packets, hence UDP iperf test
>> >    with large packets will fail completely or TCP iperf will get ridiculously
>> >    low performance because TCP window will never grow above MTU.
>> >
>> > Signed-off-by: Ansis Atteka <aatteka@ovn.org>
>> > ---
>> >  net/xfrm/xfrm_output.c | 19 +++++++++++++------
>> >  1 file changed, 13 insertions(+), 6 deletions(-)
>> >
>> > diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
>> > index 8ba29fe..7ad7e5f 100644
>> > --- a/net/xfrm/xfrm_output.c
>> > +++ b/net/xfrm/xfrm_output.c
>> > @@ -168,7 +168,8 @@ static int xfrm_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
>> >
>> >  static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb)
>> >  {
>> > -     struct sk_buff *segs;
>> > +     struct sk_buff *segs, *nskb;
>> > +     int err;
>> >
>> >       BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
>> >       BUILD_BUG_ON(sizeof(*IP6CB(skb)) > SKB_SGO_CB_OFFSET);
>> > @@ -180,21 +181,27 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
>> >               return -EINVAL;
>> >
>> >       do {
>> > -             struct sk_buff *nskb = segs->next;
>> > -             int err;
>> > +             nskb = segs->next;
>> >
>> >               segs->next = NULL;
>> > -             err = xfrm_output2(net, sk, segs);
>> > +             err = skb_checksum_help(segs);
>>
>> What's wrong with the checksum provided by the GSO layer and
>> why we have to do this unconditionally here?

I believe with "GSO layer" you meant the skb_gso_segment() function
invocation from xfrm_output_gso()?

If so, then the problem with that is that the list of the skb's
returned by that function could be in CHECKSUM_PARTIAL state, if skbs
came from a UDP tunnel such as Geneve:

   xfrm_output() {
     __skb_gso_segment() {
       skb_mac_gso_segment() {
         skb_network_protocol();
         inet_gso_segment() {
           udp4_ufo_fragment() {
             skb_udp_tunnel_segment() {
               skb_mac_gso_segment() {
                 skb_network_protocol();
                 inet_gso_segment() {
                   udp4_ufo_fragment() {
                     skb_checksum() {
                       __skb_checksum() {
                         csum_partial() {
                           do_csum();
                         }
                         csum_partial() {
                           do_csum();
                         }
                       }


Since those skbs could remain in CHECKSUM_PARTIAL state even after
IPsec encryption, then ixgbe tries to calculate L4 checksums on
already encrypted skb where L4 layer is already protected through
IPsec integrity checks. Hence, ESP packets end up being corrupted and
dropped on receive side by XFRM. I clearly see this ESP packet
corruption happening by observing:
1. in wireshark that the same ESP packet differs at the offset where
UDP checksum field should reside; AND
2. in dmesg that ixgbe driver complains on send side with "partial
checksum but L4 proto is 0x32 (ESP)". AND
3. in /proc/net/xfrm_stat where XfrmInStateProtoErrorcounter is
incremented on receive side each time it receives corrupted packet.


>>
>>
>> We don't announce any checksum capabilities, so the GSO
>> layer should provide the checksum. If this is not the case,
>> something along the path is taking wrong assumptions.
>
>
The same explicit checksum calculation is done from xfrm_output() for
non-GSO case, so it was tempting for me to simply put a similar
skb_checksum_help() for GSO case as well.
>
>> Btw. all GSO packets on a standard IPv4 xfrm tunnel are getting
>> dropped with your patch applied.
>>
I think I just noticed possible issue with my patch that I sent out.
In your setup were packets getting dropped on receive side due to UDP
checksum failure (and not IPsec integrity check failure)? If so then I
wonder if after my patch applied skb_checksum_help() was called twice
under conditions that you tested for. Hence the skbs ended up with
wrong checksums.

So, would you mind to give another spin for my patch after applying
this small amendment that calls skb_checkum_help() only in
CHECKSUM_PARTIAL case:

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 7ad7e5f..a870164 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -184,10 +184,12 @@ static int xfrm_output_gso(struct net *net,
struct sock *sk, struct sk_buff *skb
                nskb = segs->next;

                segs->next = NULL;
-               err = skb_checksum_help(segs);
-               if (unlikely(err)) {
-                       XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
-                       goto error;
+               if (skb->ip_summed == CHECKSUM_PARTIAL) {
+                       err = skb_checksum_help(segs);
+                       if (unlikely(err)) {
+                               XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
+                               goto error;
+                       }
                }

                err = xfrm_output2(net, sk, segs);
