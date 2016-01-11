From: Tom Herbert <tom@herbertland.com>
Subject: Re: [Intel-wired-lan] [next PATCH 1/4] ixgbe: Add support for generic
 Tx checksums
Date: Mon, 11 Jan 2016 12:49:29 -0800
Message-ID: <CALx6S34cxoEHHf7hVR+B4NWK_PBjVPzF5MLj=FfSnXhVpn5h7Q@mail.gmail.com>
References: <20160111173724.4101.35798.stgit@localhost.localdomain>
	<20160111175356.4101.8327.stgit@localhost.localdomain>
	<CALx6S36VOrpVoFrdr4eTynmWMkxWGs57uw+LEoXRKOsUFgryDw@mail.gmail.com>
	<CAKgT0UfGsZGywT=rK2SAWO9ZAY2q07DZ8Vx5Hy=k1cmHJx9M7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35582 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933540AbcAKUta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 15:49:30 -0500
Received: by mail-ig0-f171.google.com with SMTP id t15so104759216igr.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 12:49:29 -0800 (PST)
In-Reply-To: <CAKgT0UfGsZGywT=rK2SAWO9ZAY2q07DZ8Vx5Hy=k1cmHJx9M7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 12:29 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, Jan 11, 2016 at 10:11 AM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, Jan 11, 2016 at 9:53 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>> This patch adds support for generic Tx checksums to the ixgbe driver.  It
>>> turns out this is actually pretty easy after going over the datasheet as we
>>> were doing a number of steps we didn't need to.
>>>
>>> In order to perform a Tx checksum for an L4 header we need to fill in the
>>> following fields in the Tx descriptor:
>>>   MACLEN (maximum of 127), retrieved from:
>>>                 skb_network_offset()
>>>   IPLEN  (maximum of 511), retrieved from:
>>>                 skb_checksum_start_offset() - skb_network_offset()
>>>   TUCMD.L4T indicates offset and if checksum or crc32c, based on:
>>>                 skb->csum_offset
>>>
>>> The added advantage to doing this is that we can support inner checksum
>>> offloads for tunnels and MPLS while still being able to transparently insert
>>> VLAN tags.
>>>
>>> I also took the opportunity to clean-up many of the feature flag
>>> configuration bits to make them a bit more consistent between drivers.
>>>
>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>> ---
>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  163 +++++++++----------------
>>>  1 file changed, 59 insertions(+), 104 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> index 77cdaed6de90..1e3a548cc612 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> @@ -7207,103 +7207,61 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
>>>         return 1;
>>>  }
>>>
>>> +static inline bool ixgbe_ipv6_csum_is_sctp(struct sk_buff *skb)
>>> +{
>>> +       unsigned int offset = 0;
>>> +
>>> +       ipv6_find_hdr(skb, &offset, IPPROTO_SCTP, NULL, NULL);
>>> +
>>> +       return offset == skb_checksum_start_offset(skb);
>>> +}
>>> +
>>>  static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
>>>                           struct ixgbe_tx_buffer *first)
>>>  {
>>>         struct sk_buff *skb = first->skb;
>>>         u32 vlan_macip_lens = 0;
>>> -       u32 mss_l4len_idx = 0;
>>>         u32 type_tucmd = 0;
>>>
>>>         if (skb->ip_summed != CHECKSUM_PARTIAL) {
>>> -               if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
>>> -                   !(first->tx_flags & IXGBE_TX_FLAGS_CC))
>>> +csum_failed:
>>> +               if (!(first->tx_flags & (IXGBE_TX_FLAGS_HW_VLAN |
>>> +                                        IXGBE_TX_FLAGS_CC)))
>>>                         return;
>>> -               vlan_macip_lens = skb_network_offset(skb) <<
>>> -                                 IXGBE_ADVTXD_MACLEN_SHIFT;
>>> -       } else {
>>> -               u8 l4_hdr = 0;
>>> -               union {
>>> -                       struct iphdr *ipv4;
>>> -                       struct ipv6hdr *ipv6;
>>> -                       u8 *raw;
>>> -               } network_hdr;
>>> -               union {
>>> -                       struct tcphdr *tcphdr;
>>> -                       u8 *raw;
>>> -               } transport_hdr;
>>> -               __be16 frag_off;
>>> -
>>> -               if (skb->encapsulation) {
>>> -                       network_hdr.raw = skb_inner_network_header(skb);
>>> -                       transport_hdr.raw = skb_inner_transport_header(skb);
>>> -                       vlan_macip_lens = skb_inner_network_offset(skb) <<
>>> -                                         IXGBE_ADVTXD_MACLEN_SHIFT;
>>> -               } else {
>>> -                       network_hdr.raw = skb_network_header(skb);
>>> -                       transport_hdr.raw = skb_transport_header(skb);
>>> -                       vlan_macip_lens = skb_network_offset(skb) <<
>>> -                                         IXGBE_ADVTXD_MACLEN_SHIFT;
>>> -               }
>>> -
>>> -               /* use first 4 bits to determine IP version */
>>> -               switch (network_hdr.ipv4->version) {
>>> -               case IPVERSION:
>>> -                       vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
>>> -                       type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
>>> -                       l4_hdr = network_hdr.ipv4->protocol;
>>> -                       break;
>>> -               case 6:
>>> -                       vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
>>> -                       l4_hdr = network_hdr.ipv6->nexthdr;
>>> -                       if (likely((transport_hdr.raw - network_hdr.raw) ==
>>> -                                  sizeof(struct ipv6hdr)))
>>> -                               break;
>>> -                       ipv6_skip_exthdr(skb, network_hdr.raw - skb->data +
>>> -                                             sizeof(struct ipv6hdr),
>>> -                                        &l4_hdr, &frag_off);
>>> -                       if (unlikely(frag_off))
>>> -                               l4_hdr = NEXTHDR_FRAGMENT;
>>> -                       break;
>>> -               default:
>>> -                       break;
>>> -               }
>>> +               goto no_csum;
>>> +       }
>>>
>>> -               switch (l4_hdr) {
>>> -               case IPPROTO_TCP:
>>> -                       type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
>>> -                       mss_l4len_idx = (transport_hdr.tcphdr->doff * 4) <<
>>> -                                       IXGBE_ADVTXD_L4LEN_SHIFT;
>>> -                       break;
>>> -               case IPPROTO_SCTP:
>>> -                       type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_SCTP;
>>> -                       mss_l4len_idx = sizeof(struct sctphdr) <<
>>> -                                       IXGBE_ADVTXD_L4LEN_SHIFT;
>>> -                       break;
>>> -               case IPPROTO_UDP:
>>> -                       mss_l4len_idx = sizeof(struct udphdr) <<
>>> -                                       IXGBE_ADVTXD_L4LEN_SHIFT;
>>> +       switch (skb->csum_offset) {
>>> +       case offsetof(struct tcphdr, check):
>>> +               type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
>>> +               /* fall through */
>>> +       case offsetof(struct udphdr, check):
>>> +               break;
>>> +       case offsetof(struct sctphdr, checksum):
>>> +               /* validate that this is actually an SCTP request */
>>> +               if (((first->protocol == htons(ETH_P_IP)) &&
>>> +                    (ip_hdr(skb)->protocol == IPPROTO_SCTP)) ||
>>> +                   ((first->protocol == htons(ETH_P_IPV6)) &&
>>> +                    ixgbe_ipv6_csum_is_sctp(skb))) {
>>> +                       type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_SCTP;
>>
>> I think we're going to have to do something different for SCTP CRC
>> this (and FCOE CRC) is a special case of CHECKSUM_PARTIAL that I don't
>> think we're always accounting for. For instance, in LCO we are always
>> assuming that CHECKSUM_PARTIAL refers to an IP checksum. Maybe it's
>> time to add a bit to ip_summed so we can define CHEKCKSUM_SCTP_CRC and
>> CHECKSUM_FCOE_CRC?
>
> I was kind of thinking about that, but for now this is mostly just an
> intermediate step.  My thought was just to add something signifying
> that we are requesting a CRC offload, something like a CRC_PARTIAL
>
> As far as I know the tunnels thing won't be an issue since neither
> FCoE or SCTP will even attempt to offload the protocol unless the
> underlying device supports it.  Since no tunnel supports either of
> these it isn't an issue as the CRCs will always be computed by
> software before passing the frame off to the tunnel.
>
Right, we're probably okay in the short term, but this will need to be
addressed. Good news is that it looks like on Intel supports SCTP CRC
offload so this is probably manageable to fix.

> - Alex
