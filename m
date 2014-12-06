From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v2 iproute] bridge link: add option 'self'
Date: Fri, 5 Dec 2014 21:36:20 -0800
Message-ID: <CAE4R7bBYOW60bL07hD-wPWZZZxQ+jKx95cG0wnEMdU8KMZB5rw@mail.gmail.com>
References: <1417827563-811-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:55164 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaLFFgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 00:36:21 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so525437wiw.15
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 21:36:20 -0800 (PST)
In-Reply-To: <1417827563-811-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 4:59 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Currently self is set internally only if hwmode is set.
> This makes it necessary for the hw to have a mode.
> There is no hwmode really required to go to hardware. So, introduce
> self for anybody who wants to target hardware.
>
> v1 -> v2
>     - fix a few bugs. Initialize flags to zero: this was required to
>     keep the current behaviour unchanged.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  bridge/link.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/bridge/link.c b/bridge/link.c
> index 90d9e7f..b8b8675 100644
> --- a/bridge/link.c
> +++ b/bridge/link.c
> @@ -261,7 +261,7 @@ static int brlink_modify(int argc, char **argv)
>         __s16 priority = -1;
>         __s8 state = -1;
>         __s16 mode = -1;
> -       __u16 flags = BRIDGE_FLAGS_MASTER;
> +       __u16 flags = 0;

I don't follow why this change is necessary.  Seems defaulting to
MASTER unless SELF is set due to "self" or "hwmode" would be more
correct (and expected).

>         struct rtattr *nest;
>
>         memset(&req, 0, sizeof(req));
> @@ -321,6 +321,8 @@ static int brlink_modify(int argc, char **argv)
>                                         "\"veb\".\n");
>                                 exit(-1);
>                         }
> +               } else if (strcmp(*argv, "self") == 0) {
> +                       flags = BRIDGE_FLAGS_SELF;
>                 } else {
>                         usage();
>                 }
> @@ -375,10 +377,11 @@ static int brlink_modify(int argc, char **argv)
>          * devices so far.  Thus we only need to include the flags attribute
>          * if we are setting the hw mode.
>          */

The comment above needs to be updated to reflect the new logic.

> -       if (mode >= 0) {
> +       if (mode >= 0 || flags > 0) {
>                 nest = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
>
> -               addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
> +               if (flags > 0)
> +                       addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
>
>                 if (mode >= 0)
>                         addattr16(&req.n, sizeof(req), IFLA_BRIDGE_MODE, mode);
> --
> 1.7.10.4
>
