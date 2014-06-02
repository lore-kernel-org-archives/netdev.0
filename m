From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Force speed and duplex mode setting if link down
Date: Mon, 2 Jun 2014 16:32:52 -0700
Message-ID: <CAGVrzcZMkjFHjE3O80nPe4hmRUgfjWsoY0_g6dNPHKvBRKpOmg@mail.gmail.com>
References: <1401750420-6668-1-git-send-email-stannous@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: stannous@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:59007 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbaFBXdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:33:33 -0400
Received: by mail-qa0-f53.google.com with SMTP id x12so3776326qac.26
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 16:33:32 -0700 (PDT)
In-Reply-To: <1401750420-6668-1-git-send-email-stannous@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-02 16:07 GMT-07:00  <stannous@cumulusnetworks.com>:
> From: Sam Tannous <stannous@cumulusnetworks.com>
>
> This patch forces the user to set both the speed and the duplex
> mode if the user only specifies the speed while the interface is down.

Is there a valid use case for that, even with auto-negotiation disabled?

>
> If the interface is down, we'll get an ecmd speed
> and duplex mode of 0. This has the ill effect of
> setting the duplex to HALF and this often results in an
> error since many higher speed will not support HALF duplex.

Is this happening under the following scenario:

- interface is forced to a given speed and duplex parameter,
auto-negotiation is disabled
- interface is administratively brought down
- speed and parameters are changed while the interface is down
- interface is brought up with potentially invalid parameters, and
with auto-negotiation disabled resulting in no link

If that's the case, the driver implementing the set_settings()
callback should refuse changing the link parameters while the
interface is down to avoid creating such a situation.

Just curious...

>
> Signed-off-by: Sam Tannous <stannous@cumulusnetworks.com>
> ---
>  ethtool.c |   16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff --git a/ethtool.c b/ethtool.c
> index 8e968a8..9cd3103 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -2461,6 +2461,22 @@ static int do_sset(struct cmd_context *ctx)
>                 if (err < 0) {
>                         perror("Cannot get current device settings");
>                 } else {
> +                       /* If the interface is down, we'll get an ecmd speed and
> +                          duplex of 0.  This has the effect of defaulting
> +                          the duplex mode to HALF.  This results in an
> +                          error since many of our speeds will not support HALF
> +                          any more.  To prevent this, we need to insist that
> +                          the user provide us with specific duplex mode if
> +                          they haven't already (likely FULL) if both the speed
> +                          and duplex are 0 here.
> +                       */
> +                       if (speed_wanted != -1 && duplex_wanted == -1
> +                           && !(ecmd.speed || ecmd.duplex)) {
> +                           fprintf(stderr, "Setting the speed while the link "
> +                                   "is down requires both the speed and the "
> +                                   "duplex mode to be set");
> +                           exit_bad_args();
> +                       }
>                         /* Change everything the user specified. */
>                         if (speed_wanted != -1)
>                                 ethtool_cmd_speed_set(&ecmd, speed_wanted);
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
