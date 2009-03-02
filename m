From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Mon, 02 Mar 2009 15:32:15 -0700
Message-ID: <49AC5E6F.3010204@mlbassoc.com>
References: <20090227145746.GD17040@xi.wantstofly.org>  <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>  <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>  <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>  <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>  <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>  <20090227222802.GZ17040@xi.wantstofly.org>  <1235991382.30736.62.camel@localhost.localdomain> <1235991937.30736.65.camel@localhost.localdomain> <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com> <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:2447 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbZCBWcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 17:32:41 -0500
In-Reply-To: <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> 
> 
> 
> On Mon, 2 Mar 2009, Gary Thomas wrote:
> 
>> Gary Thomas wrote:
>>> Jesper Dangaard Brouer wrote:
>>>> On Mon, 2009-03-02 at 11:56 +0100, Jesper Dangaard Brouer wrote:
>>>>
>>>>> You should write 0x003E ... see attached patch
>>>> Ups, I see (from the thread) that you have already done/tried this...
>>>>
>>>
>>> Yes, although I think it will need some work in the future
>>> (I've set it to 1000Mb connection, you said you used 100Mb, etc)
>>>
>>> Question: I'm testing this by trying a ping out of my box.
>>> Linux replies by sending an ARP packet out, and the destination
>>> replies with an ARP packet in.  I can see from the ethtool stats
>>> that the reply packets get into lan1.1 (the physical port I'm
>>> using), but I don't see them get moved through the CPU port.
> 
> Well, thats a break through :-) If I understand you correctly, the
> destination host actually receives the ARP packet and responds with a
> packet.
> 
> That should means that the outgoing DSA tagging is working.  Although
> I'm not sure about the incomming...
> 
>>> My understanding is that this should work via the VLAN map?
> 
> I think that the "VLAN map/table" has gotten a wrong name as it does not
> really determine the VLANs, it only says who can talk to whom.  The
> switch does support a real vlan setup, but its deactivated in Lennerts
> driver, as I guess he wants Linux to handle the VLANs.  (I use the real
> VLAN setup extensively in my driver).

I agree that the simple mode Lennert's code uses is not VLAN on
the hardware, just internal switch path routes.

>>> I checked that setup and it looks OK.
> 
> I have also checked the different registers setting, and things looks
> quite alright.  Although I'm missing the register datasheets for the
> 6131 chip, I found that I only have part 1 of 3 crap...
> 
> I did find that the 6095 and 6097 does differ in the way DSA handling is
> done, as the 6097 supports Ethertype DSA and 6095 don't.  But the 6131
> driver looks like it does the right thing for the 6095.

I didn't look at the 6097 yet, but I have scoured the 6095 and 6131
data sheets and I can't see what's wrong.  The differences between
these two parts are extremely minor - basically the number of ports
and which one might be used for the CPU.

> 
>>> Any ideas where this might be going wrong?
> 
> Is lan1.1 up and have you given it an IP address?
> (could I get a 'ifconfig' output?)

Yes it's up.

> Are you sending packets with VLAN tags?

No VLAN tagging (by Linux), just normal IPv4 packets. Here's what I did:

root@ppc_target:~ ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1180 (1.1 KiB)  TX bytes:1180 (1.1 KiB)
          Base address:0x6000

root@ppc_target:~ ifconfig lan1.1 192.168.12.188 up
root@ppc_target:~ lan1.1: link up, 100 Mb/s, full duplex, flow control disabled

root@ppc_target:~ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1180 (1.1 KiB)  TX bytes:1180 (1.1 KiB)
          Base address:0x6000

lan1.1    Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
          inet addr:192.168.12.188  Bcast:192.168.12.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

root@ppc_target:~ ethtool -S lan1.1
NIC statistics:
     tx_packets: 0
     tx_bytes: 0
     rx_packets: 0
     rx_bytes: 0
     in_good_octets: 2096784
     in_bad_octets: 0
     in_unicast: 3601
     in_broadcasts: 528
     in_multicasts: 70
     in_pause: 0
     in_undersize: 0
     in_fragments: 0
     in_oversize: 0
     in_jabber: 0
     in_rx_error: 0
     in_fcs_error: 0
     out_octets: 230866
     out_unicast: 3595
     out_broadcasts: 3
     out_multicasts: 0
     out_pause: 0
     excessive: 0
     collisions: 0
     deferred: 0
     single: 0
     multiple: 0
     out_fcs_error: 0
     late: 0
     hist_64bytes: 3705
     hist_65_127bytes: 326
     hist_128_255bytes: 159
     hist_256_511bytes: 15
     hist_512_1023bytes: 3592
     hist_1024_max_bytes: 0
root@ppc_target:~ ethtool -S lan1.8
mv88e6131_get_ethtool_stats(7) => CPU
NIC statistics:
     tx_packets: 0
     tx_bytes: 0
     rx_packets: 0
     rx_bytes: 0
     in_good_octets: 232054
     in_bad_octets: 0
     in_unicast: 3595
     in_broadcasts: 5
     in_multicasts: 0
     in_pause: 0
     in_undersize: 0
     in_fragments: 0
     in_oversize: 0
     in_jabber: 0
     in_rx_error: 0
     in_fcs_error: 0
     out_octets: 2021576
     out_unicast: 3599
     out_broadcasts: 9
     out_multicasts: 1
     out_pause: 0
     excessive: 0
     collisions: 0
     deferred: 0
     single: 0
     multiple: 0
     out_fcs_error: 0
     late: 0
     hist_64bytes: 3600
     hist_65_127bytes: 9
     hist_128_255bytes: 0
     hist_256_511bytes: 4
     hist_512_1023bytes: 3596
     hist_1024_max_bytes: 0
root@ppc_target:~ ping -c 5 192.168.12.18
PING 192.168.12.18 (192.168.12.18): 56 data bytes

--- 192.168.12.18 ping statistics ---
5 packets transmitted, 0 packets received, 100% packet loss
root@ppc_target:~ ifconfig lan1.1
lan1.1    Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
          inet addr:192.168.12.188  Bcast:192.168.12.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:252 (252.0 B)

root@ppc_target:~ ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1180 (1.1 KiB)  TX bytes:1456 (1.4 KiB)
          Base address:0x6000

root@ppc_target:~ ethtool -S lan1.1
NIC statistics:
     tx_packets: 6
     tx_bytes: 252
     rx_packets: 0
     rx_bytes: 0
     in_good_octets: 2099816
     in_bad_octets: 0
     in_unicast: 3607
     in_broadcasts: 542
     in_multicasts: 71
     in_pause: 0
     in_undersize: 0
     in_fragments: 0
     in_oversize: 0
     in_jabber: 0
     in_rx_error: 0
     in_fcs_error: 0
     out_octets: 231250
     out_unicast: 3595
     out_broadcasts: 9
     out_multicasts: 0
     out_pause: 0
     excessive: 0
     collisions: 0
     deferred: 0
     single: 0
     multiple: 0
     out_fcs_error: 0
     late: 0
     hist_64bytes: 3718
     hist_65_127bytes: 331
     hist_128_255bytes: 168
     hist_256_511bytes: 15
     hist_512_1023bytes: 3592
     hist_1024_max_bytes: 0
root@ppc_target:~ ethtool -S lan1.8
mv88e6131_get_ethtool_stats(7) => CPU
NIC statistics:
     tx_packets: 0
     tx_bytes: 0
     rx_packets: 0
     rx_bytes: 0
     in_good_octets: 232438
     in_bad_octets: 0
     in_unicast: 3595
     in_broadcasts: 11
     in_multicasts: 0
     in_pause: 0
     in_undersize: 0
     in_fragments: 0
     in_oversize: 0
     in_jabber: 0
     in_rx_error: 0
     in_fcs_error: 0
     out_octets: 2021576
     out_unicast: 3599
     out_broadcasts: 9
     out_multicasts: 1
     out_pause: 0
     excessive: 0
     collisions: 0
     deferred: 0
     single: 0
     multiple: 0
     out_fcs_error: 0
     late: 0
     hist_64bytes: 3606
     hist_65_127bytes: 9
     hist_128_255bytes: 0
     hist_256_511bytes: 4
     hist_512_1023bytes: 3596
     hist_1024_max_bytes: 0

You can see that lan1.1 "in_unicast" changed by 6 packets.  These
correspond to the ARP reply packets I see the destination host
(192.168.12.18) send out.

> 
>> I also just noticed that the ESA registers (Global 1,2,3)
>> aren't set at all.  I'm pretty sure that the way I'm using
>> the switch in my bootloader this doesn't matter as all packets
>> have a fixed routing and the ESA recognition happens at the
>> actual ethernet device.
> 
> Don't think the switch needs a MAC address...
> 
>> Is this going to cause problems with the VLAN (+DSA) based
>> routing?
> 
> Don't think so...

I added in the correct ESA on the switch and the lan1.1
incoming counters now track the unicode packets.  Since I
still can't get them through to the CPU port, I don't
know if this was important.

Any ideas how I might troubleshoot why packets that come
into lan1.1 (port 0) aren't being pushed to the CPU port?

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
