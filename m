From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix the checksum fill to the error location
Date: Mon, 16 Jul 2012 20:59:08 -0400
Message-ID: <CAP=VYLqWW5qrP0Sp6Tr8+BuAHm7mfFTmU4e=9UyfSbTBijJjCA@mail.gmail.com>
References: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:42261 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab2GQA7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 20:59:40 -0400
Received: by lbbgm6 with SMTP id gm6so9447481lbb.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 17:59:39 -0700 (PDT)
In-Reply-To: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On Mon, Jul 16, 2012 at 4:03 PM, Andy Cress <andy.cress@us.kontron.com> wrote:
>
> Author: Zhong Hongbo <hongbo.zhong@windriver.com>

I'm curious as to how you are generating these mails, since if it
were with the "normal" method, then the above would have a
"From: " prefix, and not "Author: " prefix.  (More on what is the
"normal" method below...)

>
> Due to some unknown hardware limitations the pch_gbe hardware cannot
> calculate checksums when the length of network package is less
> than 64 bytes, where we will surprisingly encounter a problem of
> the destination IP incorrectly changed.

This has the feel of a problem that isn't properly understood, and
a solution that is aimed at masking the symptom at the point
where it rears its ugly head...  Not a good sign, when it comes to
requesting upstream acceptance.

>
> When forwarding network packages at the network layer the IP packages

s/packages/packets/

> won't be relayed to the upper transport layer and analyzed there,
> consequently, skb->transport_header pointer will be mistakenly remained
> the same as that of skb->network_header, resulting in TCP checksum
> wrongly
> filled into the field of destination IP in IP header.

Similarly here, the one-word-per-line symptom seems to hint at it
being a case of data manually entered into a GUI MUA, which
generally translates into headaches for the maintainer who has
to integrate your work.  If you can adopt a "standard" workflow,
it will be easier for both you and the maintainer.  And that
"standard" workflow could be something as simple as this:

--------------------------
cd /path/to/my/git-repo/of/net-next
git pull
git checkout -b pch-fixes master
<create commits, by cherry-pick or manual creation>
<validate with compilation, boot testing>
git format-patch --subject-prefix="PATCH net-next" --cover-letter -o
sendme master..pch-fixes
vi sendme/0000-cover-letter.patch
<enter text describing your series of patches>
git send-email --to netdev@vger.kernel.org -cc maintainer@someaddress.com sendme
-------------------------

>
> We can fix this issue by manually calculate the offset of the TCP
> checksum
>  and update it accordingly.
>
> We would normally use the skb_checksum_start_offset(skb) here, but in
> this
> case it is sometimes -2 (csum_start=0 - skb_headroom=2 => -2), hence the
> manual calculation.
>
> Signed-off-by: Zhong Hongbo <hongbo.zhong@windriver.com>
> Merged-by: Andy Cress <andy.cress@us.kontron.com>

There really isn't a precedent for Merged-by: -- you may want to see:

     http://kerneltrap.org/taxonomy/term/245

A "real" merge actually creates a merge commit, which is unique
in its own right.  So here, if you've carried forward an older patch,
or similar, you'd be most likely to add your own SOB line underneath.

Also a Cc: addition might be in order, say based on the output of:

./scripts/get_maintainer.pl -f drivers/net/ethernet/oki-semi/pch_gbe

A Cc: line put here goes on record.  If you use the --cc option
mentioned above, the Cc: record is limited to the mail header in
the netdev mail archive.

>
> ---
>  drivers/net/pch_gbe/pch_gbe_main.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 3787c64..1642bff 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -1178,32 +1178,35 @@ static void pch_gbe_tx_queue(struct
> pch_gbe_adapter *adapter,
>         /*
>          * It is because the hardware accelerator does not support a
> checksum,
>          * when the received data size is less than 64 bytes.
> +        * Note: skb_checksum_start_offset(skb) is sometimes -2 here.

This comment is borderline useless, without some level of justification
of how/why that happens, and why it is OK/acceptable.

>          */
>         if (skb->len < PCH_GBE_SHORT_PKT && skb->ip_summed !=
> CHECKSUM_NONE) {
> +               struct iphdr *iph = ip_hdr(skb);
>                 frame_ctrl |= PCH_GBE_TXD_CTRL_APAD |
>                               PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
>                 if (skb->protocol == htons(ETH_P_IP)) {
> -                       struct iphdr *iph = ip_hdr(skb);
>                         unsigned int offset;
> -                       offset = skb_transport_offset(skb);
> +                       offset = (unsigned char *)((u8 *)iph + iph->ihl
> * 4) - skb->data;
>                         if (iph->protocol == IPPROTO_TCP) {
> +                               struct tcphdr *tcphdr_point = (struct
> tcphdr *)((u8 *)iph + iph->ihl * 4);

There are several things going on here that are not ideal.  There
are casts of casts with unexplained math magic, there is the
attempt to encode variable types ("_point") in the variable name,
and there is apparently mailer munging which inserts rogue newlines.

At this point, I'd have to suggest that you go back to trying to
describe the use case, and the exact symptoms you are seeing
there; describe that and how you believe it comes about as
articulately as possible, and ask for input on how best to deal
with it; giving reference to this as a workaround that was deployed
some time in the past. In the end, this is a recipe for a good
commit log anyways, i.e. describing the end user symptom,
the use case that triggers it, the underlying reason as to why
it happens, and finally the technically correct fix to deal with
solving it (and indicate why it is the correct fix, if not obvious.)

Hope this helps with basic process and expectations.

Paul.
--

>                                 skb->csum = 0;
> -                               tcp_hdr(skb)->check = 0;
> +                               tcphdr_point->check = 0;
>                                 skb->csum = skb_checksum(skb, offset,
>                                                          skb->len -
> offset, 0);
> -                               tcp_hdr(skb)->check =
> +                               tcphdr_point->check =
>                                         csum_tcpudp_magic(iph->saddr,
>                                                           iph->daddr,
>                                                           skb->len -
> offset,
>                                                           IPPROTO_TCP,
>                                                           skb->csum);
>                         } else if (iph->protocol == IPPROTO_UDP) {
> +                               struct udphdr *udphdr_point = (struct
> udphdr *)((u8 *)iph + iph->ihl * 4);
>                                 skb->csum = 0;
> -                               udp_hdr(skb)->check = 0;
> +                               udphdr_point->check = 0;
>                                 skb->csum =
>                                         skb_checksum(skb, offset,
>                                                      skb->len - offset,
> 0);
> -                               udp_hdr(skb)->check =
> +                               udphdr_point->check =
>                                         csum_tcpudp_magic(iph->saddr,
>                                                           iph->daddr,
>                                                           skb->len -
> offset,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
