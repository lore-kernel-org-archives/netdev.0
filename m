From: Injong Rhee <injongrhee@gmail.com>
Subject: Re: [PATCH 0/6] TCP CUBIC and Hystart
Date: Fri, 11 Mar 2011 05:49:25 -0500
Message-ID: <4D79FE35.50601@ncsu.edu>
References: <20110310165119.224046957@vyatta.com> <20110311102809.GB15941@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	sangtae.ha@gmail.com, netdev@vger.kernel.org
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55650 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab1CKKte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 05:49:34 -0500
Received: by ywj3 with SMTP id 3so1106803ywj.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 02:49:33 -0800 (PST)
In-Reply-To: <20110311102809.GB15941@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the problem is still in clock resolution (i.e., in use of Hz 
250). I will look into the issue some more.

On 3/11/11 5:28 AM, Lucas Nussbaum wrote:
> On 10/03/11 at 08:51 -0800, Stephen Hemminger wrote:
>> This patch set is my attempt at addressing the problems discovered
>> by Lucas Nussbaum.
> With those patches applied (and the fix I mentioned separately), it
> works much better (still with HZ=250).
>
> When a delayed ack train is detected, slow start ends with cwnd ~= 580
> (sometimes a bit lower).
> When no delayed ack train is detected, slow start ends with the detection of the
> delay increase at cwnd in the [700:1100] range.
>
> performance is still not as good as without hystart, but it is more
> acceptable:
>
> nuttcp -i1 -n1g graphene-34.nancy.grid5000.fr
>     94.8125 MB /   1.00 sec =  795.3059 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6325 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6222 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6335 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6354 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6231 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.5883 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6297 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6391 Mbps     0 retrans
>
>   1024.0000 MB /   9.29 sec =  924.7155 Mbps 14 %TX 28 %RX 0 retrans 11.39 msRTT
> During that run, no ack train was detected, but delay increase was detected when cwnd=1105:
> hystart_update: cwnd=1105 ssthresh=1105 fnd=2 hs_det=3   cur_rtt=122 delay_min=90 DELTRE=16
>
> However:
> echo 1>  /proc/sys/net/ipv4/route/flush; nuttcp -i1 -n1g graphene-34.nancy.grid5000.fr
>     49.5000 MB /   1.00 sec =  415.2278 Mbps     0 retrans
>     59.0000 MB /   1.00 sec =  494.9318 Mbps     0 retrans
>     62.1875 MB /   1.00 sec =  521.6535 Mbps     0 retrans
>     64.1250 MB /   1.00 sec =  537.9329 Mbps     0 retrans
>     67.0625 MB /   1.00 sec =  562.5486 Mbps     0 retrans
>     69.4375 MB /   1.00 sec =  582.4840 Mbps     0 retrans
>     72.3750 MB /   1.00 sec =  607.1395 Mbps     0 retrans
>     75.3125 MB /   1.00 sec =  631.7557 Mbps     0 retrans
>     83.1250 MB /   1.00 sec =  697.2975 Mbps     0 retrans
>     94.3125 MB /   1.00 sec =  791.1569 Mbps     0 retrans
>    107.6250 MB /   1.00 sec =  902.8194 Mbps     0 retrans
>    112.2500 MB /   1.00 sec =  941.6231 Mbps     0 retrans
>
>   1024.0000 MB /  12.97 sec =  662.2669 Mbps 10 %TX 20 %RX 0 retrans 11.39 msRTT
> [ 3050.712333] found ACK TRAIN: cwnd=493 now=2757023598 ca->last_ack=2757023598 ca->round_start=2757023593 ca->delay_min=90 delay_min>>4=5
> [ 3050.726045] hystart_update: cwnd=493 ssthresh=493 fnd=1 hs_det=3   cur_rtt=91 delay_min=90 DELTRE=16
> (delayed ack train detected when cwnd=493 =>  slower convergence)
>
> It seems that the ack train length detection is still a bit too sensitive.
> Changing:
> 	if ((s32)(now - ca->round_start)>= ca->delay_min>>  4)
> To:
> 	if ((s32)(now - ca->round_start)>  ca->delay_min>>  4)
> makes things slightly better, but slow start still exits too early. (optimal cwnd=941).
>
> I'm not sure if we can really do something more about that. The detection by
> ack train length is inherently more likely to trigger false positives since all
> acks are considered, not just a few acks at the beginning of the train.  I'm
> tempted to suggest to disable the ack train length detection by default, but
> then it probably solves problems for other people, and the decrease in
> performance is more acceptable now.

