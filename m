From: Sam Tannous <stannous@cumulusnetworks.com>
Subject: Re: [PATCH] Force speed and duplex mode setting if link down
Date: Mon, 2 Jun 2014 18:47:02 -0700 (PDT)
Message-ID: <1075088676.3395812.1401760022657.JavaMail.zimbra@cumulusnetworks.com>
References: <1401750420-6668-1-git-send-email-stannous@cumulusnetworks.com> <CAGVrzcZMkjFHjE3O80nPe4hmRUgfjWsoY0_g6dNPHKvBRKpOmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44109 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbaFCBrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:47:05 -0400
In-Reply-To: <CAGVrzcZMkjFHjE3O80nPe4hmRUgfjWsoY0_g6dNPHKvBRKpOmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian,

I probably didn't make this clear enough in the description.
I'm not describing a use case.   I'm simply changing the 
speed on two interfaces that are directly connected.  
I don't have autoneg on at all.

1. I start with a working link where the speed is
   10G and duplex is full on both sides.

2. I change the speed on one side to 1G with 
   
      ethtool -s speed 1000
  
   and the command appears to work (at least there is no error message).
   Once I issue this command, the link is no longer usable
   since the speed changed on one side but not the other.  Autoneg
   is disabled (by default).

3. I try to change the speed on the opposite side to 1G as well but
   I don't get very far and I get this error:

------------------------
   # ethtool -s swp29 speed 1000
Cannot set new settings: Operation not supported
  not setting speed
------------------------

In looking into ethtool.c, I found that before we ETHTOOL_SSET, 
we do an ETHTOOL_GSET to get everything.   

So while the link is up, we are getting duplex FULL, and the ETHTOOL_SSET is successful. 
Once the speed changes on one end, the link goes down.
The duplex setting goes to half.  

Then when we do an ETHTOOL_GSET on the second side, we get a duplex of half.
So we use this half duplex in ecmd.duplex (since the user never specified anything,
duplex_wanted == -1).

The net result is that ethtool attempts to set the speed to 1G with half duplex
and this port does not support half duplex so we get an error message with
no mention of the half duplex defaulting. 

This patch lets the user know that he/she must explicitly specify 
the duplex setting along with the speed because we received a duplex
config of 0 (half, ecmd.duplex == 0) with no speed (ecmd.speed == 0).

The motivation for this is simply that the error is not too informative:
the user changes the speed on one side...without problems.  Then the 
user tries to do the same thing on the other side and gets an error.
There is no hint about the duplex mode defaulting to half.  This simply
forces the user to be more explicit and specify both.  

There may be a simpler solution to this.  I thought it would be helpful
to be more explicit here.

Thanks,
--
Sam


----- Original Message -----
From: "Florian Fainelli" <f.fainelli@gmail.com>
To: stannous@cumulusnetworks.com
Cc: "netdev" <netdev@vger.kernel.org>, "Shrijeet Mukherjee" <shm@cumulusnetworks.com>, "Scott Feldman" <sfeldma@cumulusnetworks.com>
Sent: Monday, June 2, 2014 7:32:52 PM
Subject: Re: [PATCH] Force speed and duplex mode setting if link down

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
