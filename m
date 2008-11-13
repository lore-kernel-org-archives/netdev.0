From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: Linux 2.6.27.5 / SFQ/HTB scheduling problems
Date: Thu, 13 Nov 2008 16:29:58 +0200
Message-ID: <20081113142958.36pzkmzwtxd3wbox@m.safari.iki.fi>
References: <20081113114814.sslsf752hwbvsh5o@m.safari.iki.fi> <20081113135904.GA23103@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out.inet.fi ([195.156.147.13]:33748 "EHLO kirsi2.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbYKMOaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 09:30:01 -0500
Received: from safari.iki.fi (80.223.84.180) by kirsi2.inet.fi (8.5.014)
        id 48FC5B890139F5D5 for netdev@vger.kernel.org; Thu, 13 Nov 2008 16:29:59 +0200
Content-Disposition: inline
In-Reply-To: <20081113135904.GA23103@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2008 at 13:59:04 +0000, Jarek Poplawski wrote:
> On 13-11-2008 12:48, Sami Farin wrote:
> > On Thu, Nov 13, 2008 at 07:15:43 +0000, Jarek Poplawski wrote:
> >> On 11-11-2008 22:47, Sami Farin wrote:
> >> ...
> >>> When 2.6.27.5 was sending:
> >>>
> >>> 2008-11-11T21:16:13.488287Z IP (tos 0x0, ttl 255, id 10323, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0x96a4), 4123538094:4123545194(7100) ack 1017886112 win 710 <nop,nop,timestamp 418352 372760162>
> >>> 2008-11-11T21:16:13.620018Z IP (tos 0x0, ttl 255, id 10328, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xf1d0), 4123545194:4123552294(7100) ack 1017886112 win 710 <nop,nop,timestamp 418458 372760270>
> >>> 2008-11-11T21:16:13.751751Z IP (tos 0x0, ttl 255, id 10333, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xc685), 4123552294:4123559394(7100) ack 1017886112 win 710 <nop,nop,timestamp 418562 372760374>
> >>>
> >>> I noticed it's 7152 bytes a packet!
> >>> Is this a new trick in 2.6.27 or 2.6.26?
> >>> But:
> >>> <3>[ 1583.914947] 0000:00:19.0: eth0: Jumbo Frames not supported.
> >>>
> >> Could you check for TSO (and maybe turn this off) with ethtool?
> > 
> > It was off:
> > 
> > # ethtool -k eth0
> > Offload parameters for eth0:
> > rx-checksumming: off
> > tx-checksumming: off
> > scatter-gather: off
> > tcp segmentation offload: off
> 
> I guess the later options are off as well? What is mtu btw?

What later options?  MTU is 1472.

Oh, I had old ethtool..
These with v 6:

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: on

Wow.  I turned gso off and now it works just like before.
No packets over size of mtu anymore, either.

State       Recv-Q Send-Q               Local Address:Port                 Peer Address:Port
ESTAB      0      122334        80.223.84.180:57694        74.54.226.166:80     timer:(on,4.475ms,0) uid:518 ino:4546485 sk:2ea3ac80ffff8800
         ts sackcubic wscale:8,3 rto:4499 rtt:2914.12/378.5 cwnd:134 ssthresh:30 send 522.4Kbps rcv_space:5728

--- 84.250.192.1 ping statistics ---
50 packets transmitted, 50 received, 0% packet loss, time 1877ms
rtt min/avg/max/mdev = 22.463/38.354/99.126/13.738 ms, pipe 3, ipg/ewma 38.309/34.963 ms

... 
> Anyway these TSO/GSO/jumbo_frames are usually bad idea with packet
> schedulers (or need more tweaking - e.g. sfq quantum).

Well this GSO on by default was an unexpected surprise for me, for sure.

Maybe a warning on htb (or something) module load
"GSO enabled, everything might not work as expected, try 
'ethtool -K eth0 gso off' to turn GSO off"..? ;)

-- 
"That man is the richest whose pleasures are the cheapest."
 - Henry David Thoreau

