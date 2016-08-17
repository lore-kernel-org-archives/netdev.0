From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 17 Aug 2016 16:16:09 -0700
Message-ID: <CAKgT0UeU+-jxnBr3H5P6ADzMH2Xv29atDrCyzngcOOEyqObUDg@mail.gmail.com>
References: <1471470587-24813-1-git-send-email-dsa@cumulusnetworks.com> <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Simon Horman <simon.horman@netronome.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
	Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	olivier.dugeon@orange.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33671 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbcHQXQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:16:11 -0400
Received: by mail-io0-f194.google.com with SMTP id y195so942330iod.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:16:11 -0700 (PDT)
In-Reply-To: <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 2:49 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> As reported by Lennert the MPLS GSO code is failing to properly segment
> large packets. There are a couple of problems:
>
> 1. the inner protocol is not set so the gso segment functions for inner
>    protocol layers are not getting run, and
>
> 2  MPLS labels for packets that use the "native" (non-OVS) MPLS code
>    are not properly accounted for in mpls_gso_segment.
>
> The MPLS GSO code was added for OVS. It is re-using skb_mac_gso_segment
> to call the gso segment functions for the higher layer protocols. That
> means skb_mac_gso_segment is called twice -- once with the network
> protocol set to MPLS and again with the network protocol set to the
> inner protocol.
>
> This patch sets the inner skb protocol addressing item 1 above and sets
> the network_header and inner_network_header to mark where the MPLS labels
> start and end. The MPLS code in OVS is also updated to set the two
> network markers.
>
> From there the MPLS GSO code uses the difference between the network
> header and the inner network header to know the size of the MPLS header
> that was pushed. It then pulls the MPLS header, resets the mac_len and
> protocol for the inner protocol and then calls skb_mac_gso_segment
> to segment the skb. Afterwards the skb protocol is set to mpls for
> each segment as suggested by Simon.
>
> Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/mpls/mpls_gso.c       | 24 +++++++++++++-----------
>  net/mpls/mpls_iptunnel.c  |  5 +++++
>  net/openvswitch/actions.c |  6 ++++++
>  3 files changed, 24 insertions(+), 11 deletions(-)
>

<snip>

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 1ecbd7715f6d..6d78f162a88b 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>                 skb->mac_len);
>         skb_reset_mac_header(skb);
>
> +       /* for GSO: set MPLS as network header and encapsulated protocol
> +        * header as inner network header
> +        */
> +       skb_set_network_header(skb, skb->mac_len);
> +       skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
> +
>         new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>         *new_mpls_lse = mpls->mpls_lse;
>

So the one question I would have about this is how attached are you to
using the network_header to record the offset for the MPLS header?  I
ask because I think from a hardware offloading perspective it would
make it much easier if instead you used the inner_mac_header to
represent the offset for the MPLS header.  This way device drivers
could just skip over it like a VLAN and just use network and transport
header values like they would otherwise.

- Alex
