From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [PATCH RFC net-next v3 4/7] net: use skb->csum_algo to identify packets needing crc32c
Date: Thu, 13 Apr 2017 12:36:34 +0200
Message-ID: <cover.1492077747.git.dcaratti@redhat.com>
References: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751235AbdDMKgl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 06:36:41 -0400
In-Reply-To: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thank you,

On Fri, 2017-04-07 at 08:43 -0700, Tom Herbert wrote:
> Maybe just call it csum_not_ip then. Then just do "if
> (unlikely(skb->csum_not_ip)) ..."

OK, I will rename the bit, avoid the enum and use the 'unlikely'. Up to now,
this series uses the bit for SCTP only and leaves unmodified behavior of
offloaded FCoE frames: please let me know if you disagree on that.

On Fri, 2017-04-07 at 08:43 -0700, Tom Herbert wrote:
> On Fri, Apr 7, 2017 at 10:29 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> > In my understanding, csum_algo needs to be set to INTERNET_CHECKSUM after the
> > CRC32c is computed. Otherwise, after subsequent operation on the skb (e.g. it
> > is encapsulated in a UDP frame), there is the possibility for skb->ip_summed
> > to become CHECKSUM_PARTIAL again. So, to ensure that skb_checksum_help() and
> > not skb_crc32c_help() will be called, csum_algo must be 0.

> ip_summed should no longer be CHECKSUM_PARTIAL with CRC32c is computed.

Even though it's uncommon, skb->ip_summed can become CHECKSUM_PARTIAL again
after the CRC32c is computed and CHECKSUM_NONE is set: for example, when a
veth and a vxlan with UDP checksums are enslaved to the same bridge, and the
NIC below vxlan has no checksumming capabilities. Here, validate_xmit_skb is
called three times on the same skb (see perf output at the bottom): 

* before transmission on the veth: here ip_summed is CHECKSUM_PARTIAL, but
the device supports CRC32c offload so the skb is (correctly) untouched.

* before vxlan encapsulation: here ip_summed is CHECKSUM_PARTIAL,
skb->csum_not_inet is 1 and NETIF_F_SCTP_CRC is not set. Here,
skb_csum_hwoffload_help() correctly fills the CRC32c and assigns ip_summed
to CHECKSUM_NONE.

* before transmission on the NIC: ip_summed is CHECKSUM_PARTIAL again (because
udp_set_csum changed csum_start and csum_offset to point to the tunnel
UDP header). No bit in NETIF_F_HW_CSUM is set: if skb->csum_not_inet is still 1,
the helper (wrongly) computes CRC32c again, thus corrupting the outer UDP
transport header. On the contrary, if skb->csum_not_inet is 0, skb_checksum_help()
correctly resolves CHECKSUM_PARTIAL.

To avoid this problem, skb->csum_not_inet must be assigned to 0 every time
the CHECKSUM_PARTIAL is resolved on skb carrying SCTP packets.

> > To minimize the impact of the patch, I substituted all assignments of skb->ip_summed,
> > done by SCTP-related code, with calls to skb_set_crc32c_ipsummed(). The alternative is
> > to explicitly set csum_algo to 0 (INTERNET_CHECKSUM) in SCTP-related code. Do you agree?

> No, like I said the only case where this new bit is relevant is when
> CHECKSUM_PARTIAL for a CRC is being done. When it's set for offloading
> sctp crc it must be set. When CRC is resolved, in the helper for
> instance, it must be cleared. If these rules are properly followed
> then the bit will be zero in all other cases without needing any
> additional work or conditionals.

At a minimum, this csum_not_inet bit needs to be cleared in three places:
1) in skb_crc32c_csum_help, to fix scenarios like veth->bridge->vxlan->NIC above.
2) in sctp_gso_make_checksum, a SCTP GSO packet is segmented and CRC32c is written
on each segment. skb->ip_summed transitions from CHECKSUM_PARTIAL to CHECKSUM_NONE.
3) in act_csum, because TC action mangling the packet are called before 
validate_xmit_skb().

It is not necessary to do it in netfilter NAT (even it is harmless), because
SCTP packets having CHECKSUM_PARTIAL are not resolved (since commit 3189a290f98d
"netfilter: nat: skip checksum on offload SCTP packets"). And it should be not
needed in IPVS code, because ip_summed is set to CHECKSUM_UNNECESSARY, so skb
is not going to be checksummed anymore.

thank you in advance for the feedback!
regards,
