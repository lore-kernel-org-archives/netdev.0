From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] team: add ethtool support
Date: Thu, 10 Jan 2013 09:51:07 -0800
Message-ID: <20130110095107.345b741e@nehalam.linuxnetplumber.net>
References: <1356830366-991-1-git-send-email-fbl@redhat.com>
	<20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
	<20121230014403.GA2077@obelix.rh>
	<1356834716.21409.6258.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>, netdev <netdev@vger.kernel.org>,
	Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37031 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753966Ab3AJRwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 12:52:34 -0500
In-Reply-To: <1356834716.21409.6258.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Dec 2012 18:31:56 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Sat, 2012-12-29 at 23:44 -0200, Flavio Leitner wrote:
> 
> > Speaking as a support engineer, it's a lot easier to grab ethtool -S and
> > see everything than grab two or more outputs.
> > 
> 
> I agree its very convenient.
> 
> I have a patch to add GRO statistics at the core layer, in the ethtool
> -S stats. 
> 
> I was about to ask netdev guys what they think of this idea ?
> 
> 
> net-gro: Add GRO counters to ethtool -S
>     
> In order to get an idea of how effective is GRO aggregation on a machine,
> we need appropriate counters. Preferably use "ethtool -S" to display them
> on a per device basis, or even per RX queue.
>     
> In this implementation, I chose to not change NIC drivers.
> 
> Core network stack adds the gro counters at the end of the counters
> each NIC driver provides for ethtool -S
>     
> There are 5 counters per RX queue :
>     
>     gro_complete:  number of time the NAPI handler did not consume its budget
>                    (This force a flush of all GRO packets in the GRO queue)
>     gro_overflows: number of time a segment could not be stored in GRO queue
>                    because current number or messages is too high
>     gro_nogro:     number of time a segment was not stored in GRO queue.
>                    (Because its not a TCP packet, or it includes a
>                    SYN/FIN/RST/PSH flag)
>     gro_msgs:      number of GRO messages (might contain 1 to 17 segments)
>     gro_segs:      number of GRO segments
>     
> Example:
>     
>      On receiver machine, with 8 RX queues :
> 
>      ethtool -S eth4 | tail -n 10
>          gro_complete[7]: 56635
>          gro_overflows[7]: 0
>          gro_nogro[7]: 212
>          gro_msgs[7]: 129410
>          gro_segs[7]: 1434925
>          gro_complete: 699479
>          gro_overflows: 0
>          gro_nogro: 2455
>          gro_msgs: 1626470
>          gro_segs: 17876794
>     
>     In this example, we can compute average number of segments per GRO message :
>     
>     17876794/17876794 = 10.99
>     
>     Or more precisely : 17876794/(17876794+2455) = 10.97
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Ethtool is awkward because it is only available through ioctl, no netlink or /proc.
If you use ethtool for GRO, please make it a separate ioctl not an add-on to
existing device statistics.  ethtool --gro ??
