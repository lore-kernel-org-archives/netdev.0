From: Peter Bieringer <pb@bieringer.de>
Subject: Re: (usagi-users 03180) Re: netfilter6: ICMPv6 type 143 doesn't
 match
Date: Sat, 08 Jan 2005 12:45:14 +0100
Message-ID: <EA4274721EC980393BB13B5E@worker.muc.bieringer.de>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
 	<200412270417.iBR4HZRG021429@toshiba.co.jp>
 <20041227.100205.102356251.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, netdev@oss.sgi.com, laforge@gnumonks.org,
        kaber@trash.net, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-users@linux-ipv6.org
In-Reply-To: <20041227.100205.102356251.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Monday, December 27, 2004 10:02:05 AM +0100 "YOSHIFUJI Hideaki /
=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" <yoshfuji@linux-ipv6.org> wrote:

> In article <200412270417.iBR4HZRG021429@toshiba.co.jp> (at Mon, 27 Dec
> 2004 13:17:34 +0900 (JST)), Yasuyuki Kozakai
> <yasuyuki.kozakai@toshiba.co.jp> says:
> 
>>  
>> -		ptr = IPV6_HDR_LEN;
>> +		ptr = ((u8*)skb->nh.ipv6h - skb->data) + IPV6_HDR_LEN;
>>  
> 
> IMHO, skb->nh.ipv6h does not points ipv6 header anymore;
> it should be skb->nh.raw in this case.
> 
> --yoshfuji


I use following patch now:

--- net/ipv6/netfilter/ip6_tables.c.orig        2005-01-07
10:14:08.928948139 +0100
+++ net/ipv6/netfilter/ip6_tables.c     2005-01-07 10:14:54.373283422 +0100
@@ -220,7 +220,7 @@
                u_int16_t ptr;          /* Header offset in skb */
                u_int16_t hdrlen;       /* Header */

-               ptr = IPV6_HDR_LEN;
+               ptr = ((u8*)skb->nh.raw - skb->data) + IPV6_HDR_LEN;

                while (ip6t_ext_hdr(currenthdr)) {
                        /* Is there enough space for the next ext header? */


But it won't help :-((

Current results:

=======================
OK/Packet matches rule:

 1410  147K ACCEPT     icmpv6    *      *       ::/0                 ::/0
ipv6-icmp type 128


12:17:47.666912 2001:6f8:800:1003::2 > 2001:6f8:900:*::*: icmp6: echo
request seq 31744
        0x0000:  6000 0000 0040 3a40 2001 06f8 0800 1003  `....@:@........
        0x0010:  0000 0000 0000 0002 2001 06f8 0900 ****  ................
        0x0020:  **** **** **** **** 8000 5c69 2c49 7c00  ..........\i,I|.
        0x0030:  0400 0000 5bc1 df41 cc41 0000 0000 0000  ....[..A.A......
        0x0040:  0000 0000 0000 0000 0000 0000 0000 0000  ................
        0x0050:  0000 0000 0000 0000 0000 0000 0000 0000  ................
        0x0060:  0000 0000 0000 0000                      ........


=======================
Problem/Packet does not match rule:

    0     0 ACCEPT     icmpv6    *      *       fe80::/10
ff02::1/128        ipv6-icmp type 130 HL match HL == 1

12:40:48.484375 fe80::****:**** > ff02::1: HBH (rtalert: 0x0000)
(padn)[icmp6 sum ok] icmp6: multicast listener query max resp delay: 2000
addr: :: [hlim 1] (len 36)
        0x0000:  6000 0000 0024 0001 fe80 0000 0000 0000  `....$..........
        0x0010:  0000 0000 **** **** ff02 0000 0000 0000  ................
        0x0020:  0000 0000 0000 0001 3a00 0502 0000 0100  ........:.......
        0x0030:  8200 a03a 07d0 0000 0000 0000 0000 0000  ...:............
        0x0040:  0000 0000 0000 0000 027d 0000            .........}..

Jan  8 12:19:58 *** kernel: default-drop-extIN:IN=sit1 OUT=
MAC=**:**:**:**:**:**->**:**:**:**:**:** TUNNEL=212.224.  0.188->217.
80.***.*** SRC=fe80:0000:0000:0000:0000:0000:****:****
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=130 CODE=0


=======================
Problem/Packet does not match rule:

    0     0 ACCEPT     icmpv6    *      *       fe80::/10
ff02::16/128       ipv6-icmp type 143 HL match HL == 1

12:42:42.046741 fe80::200:**ff:fe**:**** > ff02::16: HBH (rtalert: 0x0000)
(padn)[icmp6 sum ok] icmp6: type-#143 [hlim 1] (len 56)
        0x0000:  6000 0000 0038 0001 fe80 0000 0000 0000  `....8..........
        0x0010:  0200 **ff fe** **** ff02 0000 0000 0000  .....*..........
        0x0020:  0000 0000 0000 0016 3a00 0502 0000 0100  ........:.......
        0x0030:  8f00 a1d9 0000 0002 0300 0000 ff02 0000  ................
        0x0040:  0000 0000 0000 0000 0001 0002 0300 0000  ................
        0x0050:  ff05 0000 0000 0000 0000 0000 0001 0003  ................

Jan  8 12:24:37 gate kernel: default-drop-intOUT:IN= OUT=eth0
SRC=fe80:0000:0000:0000:0200:**ff:fe**:****
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=96 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0


It looks like that all packets with a Hop-By-Hop Option header causes
problems at the moment.

I would be glad, if someone can more dig into and provide me patches for
kernel and probably also for tcpdump.

Note also that kernel doesn't log the options, is this a bug or a missing
feature?


Thank you very much,

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
