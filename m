From: Peter Bieringer <pb@bieringer.de>
Subject: netfilter6: ICMPv6 type 143 doesn't match
Date: Sat, 25 Dec 2004 18:47:52 +0100
Message-ID: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>,
        Maillist USAGI-users <usagi-users@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

playing around with DHCPv6 (running on a very secured box with also 
outgoing netfilter ruleset) I found that something's going wrong with the 
ICMPv6 matcher:


LOG rule reports:

Dec 25 18:31:01 gatepbg kernel: OUTPUT-FW6/cleanup:IN= OUT=eth0 
SRC=0000:0000:0000:0000:0000:0000:0000:0000 
DST=ff02:0000:0000:0000:0000:0000:0000:0016 LEN=96 TC=0 HOPLIMIT=1 
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=143 CODE=0

I tried several rules (don't wonder about the wrong order, it was a try and 
error -I insert, uppest rule was inserted last):

# ip6tables -vn -L OUTPUT
Chain OUTPUT (policy DROP 4 packets, 4872 bytes)
 pkts bytes target     prot opt in     out     source 
destination
    2   192 ACCEPT     all      *      eth0    ::/0                 ::/0
    0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0
    0     0 ACCEPT     icmpv6    *      *       ::/0                 ::/0 
ipv6-icmp type 143
    0     0 ACCEPT     icmpv6    *      *       ::/0 
ff02::/16          ipv6-icmp type 143
    0     0 ACCEPT     icmpv6    *      *       ::/0 
ff02::/16          ipv6-icmp type 143
    0     0 ACCEPT     icmpv6    *      *       ::/0 
ff02::16/128       ipv6-icmp type 143

Packet dump:

18:46:07.984044 :: > ff02::16: HBH (rtalert: 0x0000) (padn)[icmp6 sum ok] 
icmp6: type-#143 [hlim 1] (len 56)
        0x0000:  6000 0000 0038 0001 0000 0000 0000 0000  `....8..........
        0x0010:  0000 0000 0000 0000 ff02 0000 0000 0000  ................
        0x0020:  0000 0000 0000 0016 3a00 0502 0000 0100  ........:.......
        0x0030:  8f00 6b6a 0000 0002 0400 0000 ff05 0000  ..kj............
        0x0040:  0000 0000 0000 0000 0001 0003 0400 0000  ................
        0x0050:  ff02 0000 0000 0000 0000 0000 0001 0002  ................

I wonder that only the proto "all" rule matches such packet.


BTW: makes it sense that ip6tables remember, whether I had used "-p all" on 
insert or not?

# ip6tables -I OUTPUT -p all -o eth0     -j ACCEPT
# ip6tables -D OUTPUT  -o eth0     -j ACCEPT
ip6tables: Bad rule (does a matching rule exist in that chain?)
# ip6tables -D OUTPUT -p all -o eth0     -j ACCEPT
(ok)

Same the other way:
# ip6tables -I OUTPUT -o eth0     -j ACCEPT
# ip6tables -D OUTPUT -p all -o eth0     -j ACCEPT
ip6tables: Bad rule (does a matching rule exist in that chain?)

Strange...I didn't really expect such behaviour as "newbie" ;-)

	Peter
-- 
Dr. Peter Bieringer                        http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                  mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member     http://www.deepspace6.net/
