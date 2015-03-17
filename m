From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 3/3] Validate all netlink attributes and
 return error if any of the validation fails.
Date: Mon, 16 Mar 2015 20:53:53 -0700
Message-ID: <CAE4R7bDFrE7HXxGBxDa1RD7VQTcUArqpoDJYJpBq_k0g1aavmg@mail.gmail.com>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
	<5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:34485 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbCQDxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 23:53:53 -0400
Received: by qcaz10 with SMTP id z10so63467218qca.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 20:53:53 -0700 (PDT)
In-Reply-To: <5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 4:02 PM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
> This patch validates all netlink attributes and return error if any of the
> validation fails.
>
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
> Suggested-by: David Miller <davem@davemloft.net>
> ---
>  net/bridge/br_netlink.c | 39 ++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 38 insertions(+), 1 deletion(-)
>
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index d80e802..0b18c0d 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -740,12 +740,49 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
>                          struct nlattr *data[])
>  {
>         struct net_bridge *br = netdev_priv(brdev);
> -       int err;
> +       unsigned long forward_delay;
> +       unsigned long hello_time;
> +       unsigned long max_age;
> +       unsigned long ageing_time;
> +       u32 t;
> +       int err = -ERANGE;
>
>         if (!data)
>                 return 0;
>
>         if (data[IFLA_BR_FORWARD_DELAY]) {
> +               t = nla_get_u32(data[IFLA_BR_FORWARD_DELAY]);
> +               forward_delay = clock_t_to_jiffies(t);
> +               if (forward_delay < BR_MIN_FORWARD_DELAY ||
> +                   forward_delay > BR_MAX_FORWARD_DELAY)
> +                       return err;

Is there a way to avoiding duplicate range checking code by passing an
extra arg to br_set_forward_delay(..., bool validate_only) and
friends?
