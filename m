From: Doug Anderson <dianders@chromium.org>
Subject: Re: [PATCH] netpoll: Fix device name check in netpoll_setup()
Date: Wed, 26 Jul 2017 11:44:58 -0700
Message-ID: <CAD=FV=WiS3m=dr5VrhiOPiqVL4Rb53jfEambq79GtPffiYO-Pg@mail.gmail.com>
References: <20170725183625.132345-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matthias Kaehlcke <mka@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35076 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdGZSx2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:53:28 -0400
Received: by mail-wm0-f53.google.com with SMTP id c184so86573085wmd.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:53:28 -0700 (PDT)
In-Reply-To: <20170725183625.132345-1-mka@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jul 25, 2017 at 11:36 AM, Matthias Kaehlcke <mka@chromium.org> wrote:
> Apparently netpoll_setup() assumes that netpoll.dev_name is a pointer
> when checking if the device name is set:
>
> if (np->dev_name) {
>   ...
>
> However the field is a character array, therefore the condition always
> yields true. Check instead whether the first byte of the array has a
> non-zero value.
>
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> ---
>  net/core/netpoll.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 8357f164c660..912731bed7b7 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -666,7 +666,7 @@ int netpoll_setup(struct netpoll *np)
>         int err;
>
>         rtnl_lock();
> -       if (np->dev_name) {
> +       if (np->dev_name[0]) {
>                 struct net *net = current->nsproxy->net_ns;
>                 ndev = __dev_get_by_name(net, np->dev_name);
>         }

It's really up to the maintainer of the code, but my first instinct
here would be to instead remove the "if" test unless we really expect
dev->dev_name to be blank in lots of cases.  It will slightly slow
down the error case but should avoid an "if" test in the non-error
case.  By definition it should be safe since currently the "if" test
should always evaluate to true.

-Doug
