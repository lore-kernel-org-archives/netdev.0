From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Wed, 15 Apr 2009 21:50:22 +0200
Message-ID: <20090415195022.GA3322@ami.dom.local>
References: <200904131550.37208.asid@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alex Sidorenko <asid@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:34882 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbZDOTva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 15:51:30 -0400
Received: by ti-out-0910.google.com with SMTP id 11so22214tim.23
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 12:51:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200904131550.37208.asid@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Sidorenko wrote, On 04/13/2009 09:50 PM:

> Hello,
> 
> while experimenting with 'netem' we have found some strange behaviour. It 
> seemed that ingress delay as measured by 'ping' command shows up on some 
> hosts but not on others.
> 
> After some investigation I have found that the problem is that skbuff->tstamp 
> field value depends on whether there are any packet sniffers enabled. That 
> is:
> 
> - if any ptype_all handler is registered, the tstamp field is as expected
> - if there are no ptype_all handlers, the tstamp field does not show the delay
> 
> I was able to see the problem on RHEL5 (2.6.18 kernel) and Ubuntu/Jaunty 
> (2.6.28 kernel).
> 
> Duplication
> -----------
> 
> 1. Enable ingress delay, e.g. 100ms
> 
> # modprobe ifb
> # ip link set dev ifb0 up
> # tc qdisc add dev eth0 ingress
> # tc filter add dev eth0 parent ffff: \
>    protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress \
>    redirect dev ifb0
> # tc qdisc add dev ifb0 root netem delay 100ms
> 
> 2. Check that there are no ptype_all handlers registered (stop DHCP, tcpdump, 
> vmware etc.)
> 
> 3. ping any other host on the LAN, e.g.
> {asid 14:54:24} ping cats
> PING cats (192.168.0.33) 56(84) bytes of data.
> 64 bytes from cats (192.168.0.33): icmp_seq=1 ttl=64 time=0.258 ms
>                                                      ^^^^^^^^^^^^^
> Now start tcpdump on any interface (not necessarily eth0)
> 
> {asid 15:25:45} ping cats
> PING cats (192.168.0.33) 56(84) bytes of data.
> 64 bytes from cats (192.168.0.33): icmp_seq=1 ttl=64 time=100 ms
>                                                      ^^^^^^^^^^^
> 
> The ingress packets are really delayed as can be seen from 'ping -U', even 
> without tcpdump running:
> 
> {asid 15:26:12} ping -U cats
> PING cats (192.168.0.33) 56(84) bytes of data.
> 64 bytes from cats (192.168.0.33): icmp_seq=1 ttl=64 time=100 ms
>                                                      ^^^^^^^^^^^

I agree there is an inconsistency, but it seems 100 ms isn't the
"right" thing to show here. It shows an internal delay added on ifb by
any packet scheduler, so probably not what a user usually expects.

> 
> The problem is that modern 'ping' uses SO_TIMESTAMP facility and for some 
> reason skb->tstamp is not updated. I was able to verify this with stap script 
> (printing skb->tstamp.tv64 in several places).
> 
> The strange thing is that as soon as there is any ptype_all handler installed, 
> skb->tstamp is updated properly. Unfortunately, my knowledge of TC internals 
> is not good enough to find how exactly this happens.

Isn't it when act_mirred calls dev_queue_xmit with dev_queue_xmit_nit?
But, as above mentioned, I doubt it's "updated properly" in this case.

Jarek P.
