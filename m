From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: Question on e1000 patch, rx-copy-break related.
Date: Wed, 3 May 2006 10:22:54 -0700
Message-ID: <4807377b0605031022s3b5bfad2x757fbd470884c6fd@mail.gmail.com>
References: <4457B96A.4030808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: NetDev <netdev@vger.kernel.org>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.207]:23884 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1030257AbWECRW4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 13:22:56 -0400
Received: by wx-out-0102.google.com with SMTP id t13so150754wxc
        for <netdev@vger.kernel.org>; Wed, 03 May 2006 10:22:55 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <4457B96A.4030808@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/2/06, Ben Greear <greearb@candelatech.com> wrote:
> In commit:  a292ca6efbc1f259ddfb9c902367f2588e0e8b0f
> to e1000_main.c, there is the change below.
>
> I am curious why the skb_put no longer subtracts ETHERNET_FCS_SIZE
> from the length.  Is the idea that we will now always include the
> FCS at the end of the skb?

This is a long and hairy story behind this, but there is a bit called
SECRC that controls hardware stripping of the CRC.  In *this* driver
we turned that bit on, so that we didn't have to mess with skb->len -=
4 and the nasty negative unwrap if we were using multiple descriptors
for rx.

Since then, we've removed multiple descriptor rx.

And after that, I've discovered that some BMCs are very unhappy if we
strip CRCs using SECRC.

So, my related question is: is it okay if we just always leave the CRC
on the end of the data?  It doesn't seem to harm anything.

> It also seems that the skb_put for the else clause is missing here, but
> I think it is fixed in some later patch.
>
> The main reason I ask is that I have a patch that enabled reception of the
> FCS in 2.6.13.  It used a flag to determine whether to subtract the ETHERNET_FCS_SIZE
> from length (or not, if we are capturing FCS).  I am trying to figure out if this
> is still needed in the later releases.

Well, its a changing picture.  I had planned to eventually enable the
hardware to strip the CRC if we aren't connected to some kind of
offboard management.  We'll get there in steps.

> Thanks,
> Ben
>
> @@ -3613,17 +3618,40 @@ #endif
>                         }
>                 }
>
> -               /* Good Receive */
> -               skb_put(skb, length - ETHERNET_FCS_SIZE);
> +               /* code added for copybreak, this should improve
> +                * performance for small packets with large amounts
> +                * of reassembly being done in the stack */
> +#define E1000_CB_LENGTH 256
> +               if ((length < E1000_CB_LENGTH) &&
> +                  !rx_ring->rx_skb_top &&
> +                  /* or maybe (status & E1000_RXD_STAT_EOP) && */
> +                  !multi_descriptor) {
> +                       struct sk_buff *new_skb =
> +                           dev_alloc_skb(length + NET_IP_ALIGN);
> +                       if (new_skb) {
> +                               skb_reserve(new_skb, NET_IP_ALIGN);
> +                               new_skb->dev = netdev;
> +                               memcpy(new_skb->data - NET_IP_ALIGN,
> +                                      skb->data - NET_IP_ALIGN,
> +                                      length + NET_IP_ALIGN);
> +                               /* save the skb in buffer_info as good */
> +                               buffer_info->skb = skb;
> +                               skb = new_skb;
> +                               skb_put(skb, length);
> +                       }
> +               }
> +
> +               /* end copybreak code */
