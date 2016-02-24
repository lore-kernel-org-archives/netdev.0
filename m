From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 3/5] flow_dissector: Correctly handle parsing FCoE
Date: Wed, 24 Feb 2016 10:14:49 -0800
Message-ID: <CALx6S35pfPWTNV9w_k7tpykEyM0=PBzgsh5vtNztWxv1Gz+LJA@mail.gmail.com>
References: <20160224172644.12339.92679.stgit@localhost.localdomain>
	<20160224172951.12339.76173.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34004 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757273AbcBXSPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:15:01 -0500
Received: by mail-io0-f182.google.com with SMTP id 9so52545044iom.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 10:15:01 -0800 (PST)
In-Reply-To: <20160224172951.12339.76173.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 9:29 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> The flow dissector bits handling FCoE didn't bother to actually validate
> that the space there was enough for the FCoE header.  So we need to update
> things so that if there is room we add the header and report a good result,
> otherwise we do not add the header, and report the bad result.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/core/flow_dissector.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 8bd745f72734..6288153d7f36 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -340,8 +340,11 @@ mpls:
>         }
>
>         case htons(ETH_P_FCOE):
> -               key_control->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
> -               /* fall through */
> +               if ((hlen - nhoff) < FCOE_HEADER_LEN)
> +                       goto out_bad;
> +
> +               nhoff += FCOE_HEADER_LEN;
> +               goto out_good;
>         default:
>                 goto out_bad;
>         }
>
