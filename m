From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Sun, 10 Jul 2016 23:14:10 +0300
Message-ID: <20160710231410.14fa44c2@halley>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
	<20160705130327.GA10737@breakpoint.cc>
	<20160705170541.3f210675@pixies>
	<20160709090020.GB2067@breakpoint.cc>
	<20160709153017.791f2607@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36140 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757187AbcGJUOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 16:14:18 -0400
Received: by mail-wm0-f48.google.com with SMTP id f126so69566076wma.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 13:14:18 -0700 (PDT)
In-Reply-To: <20160709153017.791f2607@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Jul 2016 15:30:17 +0300 Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> On Sat, 9 Jul 2016 11:00:20 +0200 Florian Westphal <fw@strlen.de> wrote:
> > I am worried about this patch, skb_gso_validate_mtu is more costly than
> > the ->flags & FORWARD check; everyone pays this extra cost.  
> 
> I can get back with numbers regarding the impact on local traffic.

Florian, I've repeatedly tested how this affects locally generated
traffic and it seems there's no impact (or at least too negligible for
netperf workload to notice):

- veth to veth (netns separated), both UFO enabled
- UDP_RR, with Request Size (udp payload) of 1500, to ensure UFO in place
  (sender reaches ip_finish_output_gso)
- Before: stable v4.6.3
- After:  stable v4.6.3 + suggested fix (kill flags&IPSKB_FORWARDED check)

# netperf -T1,2 -c -C -L 192.168.13.2 -H 192.168.13.1 -l 20 -I 99,2 -i 10 -t UDP_RR -- -P 10002,10001 -r 1500,1

MIGRATED UDP REQUEST/RESPONSE TEST from 192.168.13.2 () port 10002 AF_INET to 192.168.13.1 () port 10001 AF_INET : +/-1.000% @ 99% conf.  : demo : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

[before]
212992 212992 1500    1      20.00   45368.10   20.56  20.56  18.131  18.131
[after]
212992 212992 1500    1      20.00   45376.09   20.74  20.74  18.287  18.287

Therefore it seems trying to optimize this by setting IPSKB_FORWARDED
(or introducing a different mark) in 'iptunnel_xmit' would offer no
genuine benefit.

WDYT?

Were you thinking of different workloads that we should assess the
impact on?

Thanks,
Shmulik
