From: bert hubert <ahu@ds9a.nl>
Subject: tc lockup on 2.4.19 up
Date: Mon, 8 Jul 2002 22:48:58 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020708204858.GA16318@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wa@almesberger.net
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi,

While writing a chapter on tcng (USE IT!), I made this setup, which locks up
my 2.4.19-pre10 laptop solidly after a single packet matched:

#include "fields.tc"

dev eth0 
{       
        cbq (bandwidth 100Mbps, maxburst 5p, avpkt 1000B, allot 1500B){
                class (2, rate 10kBps, bounded)
                        if ip_dst == 213.244.168.210 && ip_tos!=0x10;
        }
}

which translates into:

tc qdisc add dev eth0 handle 1:0 root cbq bandwidth 12500000bps avpkt 1000
tc class add dev eth0 parent 1:0 classid 1:2 cbq bandwidth 12500000bps rate \
 10000bps allot 1500 avpkt 1000 maxburst 5 bounded
tc filter add dev eth0 parent 1:0 protocol ip prio 1 handle 1:0:0 u32 \
 divisor 1
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match u32 \
 0xd5f4a8d2 0xffffffff at 16 match u8 0x10 0xff at 1 classid 1:0
########
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match u32 \
 0xd5f4a8d2 0xffffffff at 16 classid 1:2
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match u32 0 0 at 0 \
 classid 1:0

The lines up to #### suffice to lock up the machine upon a ssh keystroke to
213.244.168.210 - the last line is supposed to match on an ssh keystroke.

I think the rule gets matched circularly, but I'm unsure. 

Please let me know - I can investigate more later on if I can reproduce this
in uml.

Regards,

bert hubert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
