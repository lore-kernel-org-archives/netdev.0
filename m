From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Failure to send fragmented IP packet in case of missing ARP
 entry
Date: Mon, 10 Sep 2012 11:53:18 +0200
Message-ID: <1347270798.1234.1370.camel@edumazet-glaptop>
References: <504DAC02.8040808@cogentembedded.com>
	 <1347270171.1234.1353.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrei Dolnikov <andrey.dolnikov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63748 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355Ab2IJJxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 05:53:25 -0400
Received: by eaac11 with SMTP id c11so786165eaa.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 02:53:24 -0700 (PDT)
In-Reply-To: <1347270171.1234.1353.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 11:42 +0200, Eric Dumazet wrote:
> On Mon, 2012-09-10 at 12:59 +0400, Andrei Dolnikov wrote:
> > Hello all,
> > 
> > The following issue is observed on most Linux distributions:
> > Transmission of fragmented IP packets in case of missing ARP entry for 
> > destination IP fails.
> > Actually ARP request is sent, and, once ARP response is received, only 
> > few queued fragments are transmitted. Remaining fragments are lost.
> > It can be easily reproduced as follows:
> >      # arp -d <dst IP>
> >      # ping -s 65000 -c 1 <dst IP>
> > Ping result is: "1 packets transmitted, 0 received, 100% packet loss, 
> > time 0ms".
> > 
> > The latest kernel version I tried was 3.5.0-1 x86_64, but I also was 
> > able to reproduce it with 3.2.x, 3.0.x and 2.6.32.
> > It doesn't depend on hardware: was able to reproduce with VMWare Player, 
> > Intel based laptop, Intel Atom and ARM based custom boards.
> > As I'm not a networking standards expert I'm not sure if it's a real bug 
> > or acceptable behaviour, but decided to raise the issue here as I can't 
> > reproduce this anomaly with the Windows 7 PC.
> > 
> > Thanks,
> > Andrei.
> > --
> 
> Its a bit better with linux-3.3, with commit
> 8b5c171bb3dc0686b2647a84e990199c5faa9ef8
> (neigh: new unresolved queue limits)
> 
> +neigh/default/unres_qlen_bytes - INTEGER
> +       The maximum number of bytes which may be used by packets
> +       queued for each unresolved address by other network layers.
> +       (added in linux 3.3)
> +
> +neigh/default/unres_qlen - INTEGER
> +       The maximum number of packets which may be queued for each
> +       unresolved address by other network layers.
> +       (deprecated in linux 3.3) : use unres_qlen_bytes instead.
> 
> 
> Problem is : unres_qlen_bytes default value is 65536, so its a bit too
> small once you take into account truesize overhead
> 
> I guess following patch would be needed :
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 4780045..3395bb6 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -171,7 +171,7 @@ struct neigh_table arp_tbl = {
>  		.gc_staletime		= 60 * HZ,
>  		.reachable_time		= 30 * HZ,
>  		.delay_probe_time	= 5 * HZ,
> -		.queue_len_bytes	= 64*1024,
> +		.queue_len_bytes	= 64 * SKB_TRUESIZE(1024),
>  		.ucast_probes		= 3,
>  		.mcast_probes		= 3,
>  		.anycast_delay		= 1 * HZ,

In the mean time, you can also do

echo 50 >/proc/sys/net/ipv4/neigh/eth0/unres_qlen

(change eth0 by the name of your interface)
