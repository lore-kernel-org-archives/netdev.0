From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless netns work
Date: Thu, 18 Jun 2009 14:55:13 +0200
Message-ID: <1245329713.13790.37.camel@johannes.local>
References: <1245328543.13790.31.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1245328543.13790.31.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-06-18 at 14:35 +0200, Johannes Berg wrote:

> Oddly, the link works unidirectionally in both directions, if I ping
> from either side tcpdump shows the echo requests on the other side, but
> no echo reply is being generated. Still investigating why this is, since
> it works fine with veth. Ideas why this is broken would be
> appreciated :)

Ok, the missing piece of the puzzle is this patch:
http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-hwsim-skb-cleanup.patch

root@(none):~# ping -Q 0x80 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
Warning: time of day goes back (-311263us), taking countermeasures.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.487 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.122 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=0.121 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=0.130 ms

(this is between net namespaces on the same user-mode-linux instance)

Wireshark also shows the packets on hwsim0:

No.     Time        Source                Destination           Protocol Info
      9 0.709807    10.0.0.2              10.0.0.1              ICMP     Echo (ping) request

Frame 9 (130 bytes on wire, 130 bytes captured)
    Arrival Time: Jun 18, 2009 14:47:40.533741000
    [Time delta from previous captured frame: 0.010281000 seconds]
    [Time delta from previous displayed frame: 0.010281000 seconds]
    [Time since reference or first frame: 0.709807000 seconds]
    Frame Number: 9
    Frame Length: 130 bytes
    Capture Length: 130 bytes
    [Frame is marked: True]
    [Protocols in frame: radiotap:wlan:llc:ip:icmp:data]
    [Coloring Rule Name: ICMP]
    [Coloring Rule String: icmp]
Radiotap Header v0, Length 14
    Header revision: 0
    Header pad: 0
    Header length: 14
    Present flags: 0x0000000e
        .... .... .... .... .... .... .... ...0 = TSFT: False
        .... .... .... .... .... .... .... ..1. = Flags: True
        .... .... .... .... .... .... .... .1.. = Rate: True
        .... .... .... .... .... .... .... 1... = Channel: True
        .... .... .... .... .... .... ...0 .... = FHSS: False
        .... .... .... .... .... .... ..0. .... = DBM Antenna Signal: False
        .... .... .... .... .... .... .0.. .... = DBM Antenna Noise: False
        .... .... .... .... .... .... 0... .... = Lock Quality: False
        .... .... .... .... .... ...0 .... .... = TX Attenuation: False
        .... .... .... .... .... ..0. .... .... = DB TX Attenuation: False
        .... .... .... .... .... .0.. .... .... = DBM TX Attenuation: False
        .... .... .... .... .... 0... .... .... = Antenna: False
        .... .... .... .... ...0 .... .... .... = DB Antenna Signal: False
        .... .... .... .... ..0. .... .... .... = DB Antenna Noise: False
        .... .... .... .... .0.. .... .... .... = FCS in header: False
        .... .... .... .0.. .... .... .... .... = Channel+: False
        0... .... .... .... .... .... .... .... = Ext: False
    Flags: 0x00
        .... ...0 = CFP: False
        .... ..0. = Preamble: Long
        .... .0.. = WEP: False
        .... 0... = Fragmentation: False
        ...0 .... = FCS at end: False
        ..0. .... = Data Pad: False
        .0.. .... = Bad FCS: False
        0... .... = Short GI: False
    Data Rate: 1.0 Mb/s
    Channel frequency: 2462 [BG 11]
    Channel type: 802.11b (0x00a0)
        .... .... ...0 .... = Turbo: False
        .... .... ..1. .... = Complementary Code Keying (CCK): True
        .... .... .0.. .... = Orthogonal Frequency-Division Multiplexing (OFDM): False
        .... .... 1... .... = 2 GHz spectrum: True
        .... ...0 .... .... = 5 GHz spectrum: False
        .... ..0. .... .... = Passive: False
        .... .0.. .... .... = Dynamic CCK-OFDM: False
        .... 0... .... .... = Gaussian Frequency Shift Keying (GFSK): False
        ...0 .... .... .... = GSM (900MHz): False
        ..0. .... .... .... = Static Turbo: False
        .0.. .... .... .... = Half Rate Channel (10MHz Channel Width): False
        0... .... .... .... = Quarter Rate Channel (5MHz Channel Width): False
IEEE 802.11 Data, Flags: .......T
    Type/Subtype: Data (0x20)
    Frame Control: 0x0108 (Normal)
        Version: 0
        Type: Data frame (2)
        Subtype: 0
        Flags: 0x1
            DS status: Frame from STA to DS via an AP (To DS: 1 From DS: 0) (0x01)
            .... .0.. = More Fragments: This is the last fragment
            .... 0... = Retry: Frame is not being retransmitted
            ...0 .... = PWR MGT: STA will stay up
            ..0. .... = More Data: No data buffered
            .0.. .... = Protected flag: Data is not protected
            0... .... = Order flag: Not strictly ordered
    Duration: 218
    BSS Id: 02:00:00:00:00:00 (02:00:00:00:00:00)
    Source address: 02:00:00:00:01:00 (02:00:00:00:01:00)
    Destination address: 02:00:00:00:00:00 (02:00:00:00:00:00)
    Fragment number: 0
    Sequence number: 52
Logical-Link Control
    DSAP: SNAP (0xaa)
    IG Bit: Individual
    SSAP: SNAP (0xaa)
    CR Bit: Command
    Control field: U, func=UI (0x03)
        000. 00.. = Command: Unnumbered Information (0x00)
        .... ..11 = Frame type: Unnumbered frame (0x03)
    Organization Code: Encapsulated Ethernet (0x000000)
    Type: IP (0x0800)
Internet Protocol, Src: 10.0.0.2 (10.0.0.2), Dst: 10.0.0.1 (10.0.0.1)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x80 (DSCP 0x20: Class Selector 4; ECN: 0x00)
        1000 00.. = Differentiated Services Codepoint: Class Selector 4 (0x20)
        .... ..0. = ECN-Capable Transport (ECT): 0
        .... ...0 = ECN-CE: 0
    Total Length: 84
    Identification: 0x0000 (0)
    Flags: 0x04 (Don't Fragment)
        0... = Reserved bit: Not set
        .1.. = Don't fragment: Set
        ..0. = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: ICMP (0x01)
    Header checksum: 0x2627 [correct]
        [Good: True]
        [Bad : False]
    Source: 10.0.0.2 (10.0.0.2)
    Destination: 10.0.0.1 (10.0.0.1)
Internet Control Message Protocol
    Type: 8 (Echo (ping) request)
    Code: 0 ()
    Checksum: 0xdbb9 [correct]
    Identifier: 0xb503
    Sequence number: 9 (0x0009)
    Data (56 bytes)
        Data: 6C373A4A00000000F5E40C00000000001011121314151617...

0000  00 00 0e 00 0e 00 00 00 00 02 9e 09 a0 00 08 01   ................
0010  da 00 02 00 00 00 00 00 02 00 00 00 01 00 02 00   ................
0020  00 00 00 00 40 03 aa aa 03 00 00 00 08 00 45 80   ....@.........E.
0030  00 54 00 00 40 00 40 01 26 27 0a 00 00 02 0a 00   .T..@.@.&'......
0040  00 01 08 00 db b9 b5 03 00 09 6c 37 3a 4a 00 00   ..........l7:J..
0050  00 00 f5 e4 0c 00 00 00 00 00 10 11 12 13 14 15   ................
0060  16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25   .......... !"#$%
0070  26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35   &'()*+,-./012345
0080  36 37                                             67

No.     Time        Source                Destination           Protocol Info
     10 0.709841    10.0.0.1              10.0.0.2              ICMP     Echo (ping) reply

Frame 10 (130 bytes on wire, 130 bytes captured)
    Arrival Time: Jun 18, 2009 14:47:40.533775000
    [Time delta from previous captured frame: 0.000034000 seconds]
    [Time delta from previous displayed frame: 0.000034000 seconds]
    [Time since reference or first frame: 0.709841000 seconds]
    Frame Number: 10
    Frame Length: 130 bytes
    Capture Length: 130 bytes
    [Frame is marked: True]
    [Protocols in frame: radiotap:wlan:llc:ip:icmp:data]
    [Coloring Rule Name: ICMP]
    [Coloring Rule String: icmp]
Radiotap Header v0, Length 14
    Header revision: 0
    Header pad: 0
    Header length: 14
    Present flags: 0x0000000e
        .... .... .... .... .... .... .... ...0 = TSFT: False
        .... .... .... .... .... .... .... ..1. = Flags: True
        .... .... .... .... .... .... .... .1.. = Rate: True
        .... .... .... .... .... .... .... 1... = Channel: True
        .... .... .... .... .... .... ...0 .... = FHSS: False
        .... .... .... .... .... .... ..0. .... = DBM Antenna Signal: False
        .... .... .... .... .... .... .0.. .... = DBM Antenna Noise: False
        .... .... .... .... .... .... 0... .... = Lock Quality: False
        .... .... .... .... .... ...0 .... .... = TX Attenuation: False
        .... .... .... .... .... ..0. .... .... = DB TX Attenuation: False
        .... .... .... .... .... .0.. .... .... = DBM TX Attenuation: False
        .... .... .... .... .... 0... .... .... = Antenna: False
        .... .... .... .... ...0 .... .... .... = DB Antenna Signal: False
        .... .... .... .... ..0. .... .... .... = DB Antenna Noise: False
        .... .... .... .... .0.. .... .... .... = FCS in header: False
        .... .... .... .0.. .... .... .... .... = Channel+: False
        0... .... .... .... .... .... .... .... = Ext: False
    Flags: 0x00
        .... ...0 = CFP: False
        .... ..0. = Preamble: Long
        .... .0.. = WEP: False
        .... 0... = Fragmentation: False
        ...0 .... = FCS at end: False
        ..0. .... = Data Pad: False
        .0.. .... = Bad FCS: False
        0... .... = Short GI: False
    Data Rate: 1.0 Mb/s
    Channel frequency: 2462 [BG 11]
    Channel type: 802.11b (0x00a0)
        .... .... ...0 .... = Turbo: False
        .... .... ..1. .... = Complementary Code Keying (CCK): True
        .... .... .0.. .... = Orthogonal Frequency-Division Multiplexing (OFDM): False
        .... .... 1... .... = 2 GHz spectrum: True
        .... ...0 .... .... = 5 GHz spectrum: False
        .... ..0. .... .... = Passive: False
        .... .0.. .... .... = Dynamic CCK-OFDM: False
        .... 0... .... .... = Gaussian Frequency Shift Keying (GFSK): False
        ...0 .... .... .... = GSM (900MHz): False
        ..0. .... .... .... = Static Turbo: False
        .0.. .... .... .... = Half Rate Channel (10MHz Channel Width): False
        0... .... .... .... = Quarter Rate Channel (5MHz Channel Width): False
IEEE 802.11 Data, Flags: ......F.
    Type/Subtype: Data (0x20)
    Frame Control: 0x0208 (Normal)
        Version: 0
        Type: Data frame (2)
        Subtype: 0
        Flags: 0x2
            DS status: Frame from DS to a STA via AP(To DS: 0 From DS: 1) (0x02)
            .... .0.. = More Fragments: This is the last fragment
            .... 0... = Retry: Frame is not being retransmitted
            ...0 .... = PWR MGT: STA will stay up
            ..0. .... = More Data: No data buffered
            .0.. .... = Protected flag: Data is not protected
            0... .... = Order flag: Not strictly ordered
    Duration: 314
    Destination address: 02:00:00:00:01:00 (02:00:00:00:01:00)
    BSS Id: 02:00:00:00:00:00 (02:00:00:00:00:00)
    Source address: 02:00:00:00:00:00 (02:00:00:00:00:00)
    Fragment number: 0
    Sequence number: 33
Logical-Link Control
    DSAP: SNAP (0xaa)
    IG Bit: Individual
    SSAP: SNAP (0xaa)
    CR Bit: Command
    Control field: U, func=UI (0x03)
        000. 00.. = Command: Unnumbered Information (0x00)
        .... ..11 = Frame type: Unnumbered frame (0x03)
    Organization Code: Encapsulated Ethernet (0x000000)
    Type: IP (0x0800)
Internet Protocol, Src: 10.0.0.1 (10.0.0.1), Dst: 10.0.0.2 (10.0.0.2)
    Version: 4
    Header length: 20 bytes
    Differentiated Services Field: 0x80 (DSCP 0x20: Class Selector 4; ECN: 0x00)
        1000 00.. = Differentiated Services Codepoint: Class Selector 4 (0x20)
        .... ..0. = ECN-Capable Transport (ECT): 0
        .... ...0 = ECN-CE: 0
    Total Length: 84
    Identification: 0xe172 (57714)
    Flags: 0x00
        0... = Reserved bit: Not set
        .0.. = Don't fragment: Not set
        ..0. = More fragments: Not set
    Fragment offset: 0
    Time to live: 64
    Protocol: ICMP (0x01)
    Header checksum: 0x84b4 [correct]
        [Good: True]
        [Bad : False]
    Source: 10.0.0.1 (10.0.0.1)
    Destination: 10.0.0.2 (10.0.0.2)
Internet Control Message Protocol
    Type: 0 (Echo (ping) reply)
    Code: 0 ()
    Checksum: 0xe3b9 [correct]
    Identifier: 0xb503
    Sequence number: 9 (0x0009)
    Data (56 bytes)
        Data: 6C373A4A00000000F5E40C00000000001011121314151617...

0000  00 00 0e 00 0e 00 00 00 00 02 9e 09 a0 00 08 02   ................
0010  3a 01 02 00 00 00 01 00 02 00 00 00 00 00 02 00   :...............
0020  00 00 00 00 10 02 aa aa 03 00 00 00 08 00 45 80   ..............E.
0030  00 54 e1 72 00 00 40 01 84 b4 0a 00 00 01 0a 00   .T.r..@.........
0040  00 02 00 00 e3 b9 b5 03 00 09 6c 37 3a 4a 00 00   ..........l7:J..
0050  00 00 f5 e4 0c 00 00 00 00 00 10 11 12 13 14 15   ................
0060  16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25   .......... !"#$%
0070  26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35   &'()*+,-./012345
0080  36 37                                             67


Yay!

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
