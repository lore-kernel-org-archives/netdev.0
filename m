From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Thu, 18 Aug 2016 07:37:59 -0700
Message-ID: <CAKgT0UfmWpeNsjH+dtYewiVSuxapck2zyczJGP7WvE30irJcmw@mail.gmail.com>
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
Received: from mail-io0-f181.google.com ([209.85.223.181]:33428 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767276AbcHROiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 10:38:01 -0400
Received: by mail-io0-f181.google.com with SMTP id 38so20734599iol.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 07:38:01 -0700 (PDT)
In-Reply-To: <1471470587-24813-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thought I would go through and do a second pass since it sounds like
the inner_mac_header idea isn't going to fly.  If we can't push this
as an L2 encapsulation there are few tweaks we probably need in order
to make this work as an L3.  I have included comments inline below.

Also I haven't worked with MPLS much before.  Is there a simple way to
setup an MPLS tunnel between two hosts connected back to back so that
I could try testing a few things related to this patch?

Thanks.

- Alex


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
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index 2055e57ed1c3..fa6899f02cc8 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -22,33 +22,35 @@
>  static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>                                        netdev_features_t features)
>  {
> +       int mpls_hlen = skb_inner_network_header(skb) - skb_network_header(skb);
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
> +       u16 mac_offset = skb->mac_header;
>         netdev_features_t mpls_features;
>         __be16 mpls_protocol;
> +       u16 mac_len = skb->mac_len;

So one thing you may want to do here is defer the skb_network_header()
call until after being able to call skb_reset_network_header().  For
reference you might look at how we handle inet_gso_segment.  That way
if at some point in the future we end up having to support MPLS
encapsulated in an IP tunnel it should be able to play the same as
IP-in-IP.

>
>         /* Setup inner SKB. */
>         mpls_protocol = skb->protocol;
>         skb->protocol = skb->inner_protocol;
>
> -       /* Push back the mac header that skb_mac_gso_segment() has pulled.
> -        * It will be re-pulled by the call to skb_mac_gso_segment() below
> -        */
> -       __skb_push(skb, skb->mac_len);
> +       __skb_pull(skb, mpls_hlen);
> +       skb->mac_len = skb_inner_network_offset(skb);

So I am not sure sure setting the skb->mac_len here really does
anything.  If I am not mistaken I think the value should always come
out 0 since you already pulled mpls_hlen, and skb->data should be
equal to skb_network_header().  So you might save yourself a few
cycles and just set skb->mac_len = 0.

Also you may need to call skb_reset_mac_header() so that you don't
have the skb_mac_gso_segment call pushing your MPLS header and the
headers below it back on before you can capture those offsets back in
your frame.

>         /* Segment inner packet. */
>         mpls_features = skb->dev->mpls_features & features;
>         segs = skb_mac_gso_segment(skb, mpls_features);
> -
> +       if (IS_ERR_OR_NULL(segs)) {
> +               skb_gso_error_unwind(skb, mpls_protocol, mpls_hlen, mac_offset,
> +                                    mac_len);
> +               goto out;
> +       }
>
>         /* Restore outer protocol. */
>         skb->protocol = mpls_protocol;
> +       for (skb = segs; skb; skb = skb->next)
> +               skb->protocol = mpls_protocol;

At this point you should probably be pushing back on your MPLS header
and resetting the inner network header, network header, and mac
header.  Otherwise either the inner IPv4 or IPv6 header will be set as
the network_header after you have segmented the frame.  This is one of
the reasons why I thought my original ideal would work.  You might
refer to the approach taken in gre_gso_segment as an example of how to
approach that.  The key bit here is that you can't lose the offsets
you setup when you were creating the frame and I don't see anything
anywhere that is handling the inner_network_header value.

> -       /* Re-pull the mac header that the call to skb_mac_gso_segment()
> -        * above pulled.  It will be re-pushed after returning
> -        * skb_mac_gso_segment(), an indirect caller of this function.
> -        */
> -       __skb_pull(skb, skb->data - skb_mac_header(skb));
> -
> +out:
>         return segs;
>  }
>
> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
> index aed872cc05a6..55c5ab907563 100644
> --- a/net/mpls/mpls_iptunnel.c
> +++ b/net/mpls/mpls_iptunnel.c
> @@ -90,7 +90,12 @@ static int mpls_xmit(struct sk_buff *skb)
>         if (skb_cow(skb, hh_len + new_header_size))
>                 goto drop;
>
> +       skb_set_inner_protocol(skb, skb->protocol);
> +       skb_reset_inner_network_header(skb);
> +       skb->encapsulation = 1;
> +

So you probably shouldn't be updating skb->encapsulation.  Normally
that is used or L4 encapsulation over UDP or GRE.  The problem is it
signals that the checksum needs to be computed at
inner_transport_header instead of transport_header and can cause
issues if we try to offload the checksum for this.

>         skb_push(skb, new_header_size);
> +
>         skb_reset_network_header(skb);
>
>         skb->dev = out_dev;
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
> --
> 2.1.4
>
