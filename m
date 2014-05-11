From: David Newall <davidn@davidnewall.com>
Subject: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 00:11:19 +0930
Message-ID: <536F8C0F.4090206@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:35250 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaEKOlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 10:41:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been chasing a ping problem with record-route set, and it looks 
like a bug.  The problem also occurs with timestamp option set. 
Everything works find when using just the nic, or bonded nics, but 
breaks when I use a bridge.  This is 100% repeatable.

This fault has been observed on amd64 architecture running Ubuntu 13.10 
with various Canonical supplied kernels, and running Ubuntu 14.04 with 
Canonical supplied kernel 3.13.0-24-generic.

To demonstrate:

----8<---- INITIAL STATE OF INTERFACES ----8<----
root@konrad:~# ifconfig
lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:65536  Metric:1
           RX packets:1464473 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1464473 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:954752075 (954.7 MB)  TX bytes:954752075 (954.7 MB)

----8<----8<----  BRING UP eth0  ----8<----8<-----
root@konrad:~# ifconfig eth0 192.168.0.9

----8<----8<----8<-- IT WORKS -8<----8<----8<-----
root@konrad:~# ping -nR 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(124) bytes of data.
64 bytes from 192.168.0.1: icmp_seq=1 ttl=64 time=3.21 ms
RR:     192.168.0.9
         192.168.0.1
         192.168.0.9

64 bytes from 192.168.0.1: icmp_seq=2 ttl=64 time=0.396 ms      (same route)
^C
--- 192.168.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.396/1.804/3.212/1.408 ms

----8<----8<---- BRING UP BRIDGE ----8<----8<-----
root@konrad:~# ifconfig eth0 0.0.0.0
root@konrad:~# brctl addbr br0
root@konrad:~# brctl addif br0 eth0
root@konrad:~# ifconfig br0 192.168.0.9

----8<----8<----8<-- BROKEN ---8<----8<----8<-----
root@konrad:~# ping -nR 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(124) bytes of data.
^C
--- 192.168.0.1 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1006ms

root@konrad:~# ping -nTtsonly 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(124) bytes of data.
^C
--- 192.168.0.1 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1006ms

----8<----8<----8<---- --- ----8<----8<----8<----


Capturing ICMP packets from the "any" interface with tcpdump provides a 
clue.  ICMP replies are being changed when forwarded from the physical 
NIC to the bridge interface.  When RR option is set, an extra address is 
appended to the recorded route (0.0.0.0).  When TS option is set, the 
last set time stamp is overwritten, probably with the preceding 
timestamp, and the (option) pointer is incremented by 4.

The following decoded ICMP reply packets reveal the changes

----8<----8<---- RECEIVED ON eth0 ---8<----8<----
Frame 3: 140 bytes on wire (1120 bits), 140 bytes captured (1120 bits)
     Encapsulation type: Linux cooked-mode capture (25)
     Arrival Time: May 11, 2014 23:06:25.953831000 CST
     [Time shift for this packet: 0.000000000 seconds]
     Epoch Time: 1399815385.953831000 seconds
     [Time delta from previous captured frame: 0.000436000 seconds]
     [Time delta from previous displayed frame: 0.000436000 seconds]
     [Time since reference or first frame: 0.000452000 seconds]
     Frame Number: 3
     Frame Length: 140 bytes (1120 bits)
     Capture Length: 140 bytes (1120 bits)
     [Frame is marked: False]
     [Frame is ignored: False]
     [Protocols in frame: sll:ip:icmp:data]
Linux cooked capture
     Packet type: Unicast to us (0)
     Link-layer address type: 1
     Link-layer address length: 6
     Source: c4:04:15:b4:84:84 (c4:04:15:b4:84:84)
     Protocol: IP (0x0800)
Internet Protocol Version 4, Src: 192.168.0.1 (192.168.0.1), Dst: 192.168.0.9 (192.168.0.9)
     Version: 4
     Header length: 60 bytes
     Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: Not-ECT (Not ECN-Capable Transport))
         0000 00.. = Differentiated Services Codepoint: Default (0x00)
         .... ..00 = Explicit Congestion Notification: Not-ECT (Not ECN-Capable Transport) (0x00)
     Total Length: 124
     Identification: 0xfc40 (64576)
     Flags: 0x02 (Don't Fragment)
         0... .... = Reserved bit: Not set
         .1.. .... = Don't fragment: Set
         ..0. .... = More fragments: Not set
     Fragment offset: 0
     Time to live: 64
     Protocol: ICMP (1)
     Header checksum: 0x443d [correct]
         [Good: True]
         [Bad: False]
     Source: 192.168.0.1 (192.168.0.1)
     Destination: 192.168.0.9 (192.168.0.9)
     [Source GeoIP: Unknown]
     [Destination GeoIP: Unknown]
     Options: (40 bytes), Record Route, End of Options List (EOL)
         Record Route (39 bytes)
             Type: 7
                 0... .... = Copy on fragmentation: No
                 .00. .... = Class: Control (0)
                 ...0 0111 = Number: Record route (7)
             Length: 39
             Pointer: 12
             Recorded Route: 192.168.0.9 (192.168.0.9)
             Recorded Route: 192.168.0.1 (192.168.0.1)
             Empty Route: 0.0.0.0 <- (next)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
         End of Options List (EOL)
             Type: 0
                 0... .... = Copy on fragmentation: No
                 .00. .... = Class: Control (0)
                 ...0 0000 = Number: End of Option List (EOL) (0)
Internet Control Message Protocol
     Type: 0 (Echo (ping) reply)
     Code: 0
     Checksum: 0x66b0 [correct]
     Identifier (BE): 31519 (0x7b1f)
     Identifier (LE): 8059 (0x1f7b)
     Sequence number (BE): 1 (0x0001)
     Sequence number (LE): 256 (0x0100)
     [Request frame: 2]
     [Response time: 0.436 ms]
     Timestamp from icmp data: May 11, 2014 23:06:25.000000000 CST
     [Timestamp from icmp data (relative): 0.953831000 seconds]
     Data (48 bytes)

0000  08 8c 0e 00 00 00 00 00 10 11 12 13 14 15 16 17   ................
0010  18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27   ........ !"#$%&'
0020  28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37   ()*+,-./01234567
         Data: 088c0e0000000000101112131415161718191a1b1c1d1e1f...
         [Length: 48]

----8<----8<----  SENT TO BRIDGE ----8<----8<----
Frame 4: 140 bytes on wire (1120 bits), 140 bytes captured (1120 bits)
     Encapsulation type: Linux cooked-mode capture (25)
     Arrival Time: May 11, 2014 23:06:25.953831000 CST
     [Time shift for this packet: 0.000000000 seconds]
     Epoch Time: 1399815385.953831000 seconds
     [Time delta from previous captured frame: 0.000000000 seconds]
     [Time delta from previous displayed frame: 0.000000000 seconds]
     [Time since reference or first frame: 0.000452000 seconds]
     Frame Number: 4
     Frame Length: 140 bytes (1120 bits)
     Capture Length: 140 bytes (1120 bits)
     [Frame is marked: False]
     [Frame is ignored: False]
     [Protocols in frame: sll:ip:icmp:data]
Linux cooked capture
     Packet type: Unicast to us (0)
     Link-layer address type: 1
     Link-layer address length: 6
     Source: c4:04:15:b4:84:84 (c4:04:15:b4:84:84)
     Protocol: IP (0x0800)
Internet Protocol Version 4, Src: 192.168.0.1 (192.168.0.1), Dst: 192.168.0.9 (192.168.0.9)
     Version: 4
     Header length: 60 bytes
     Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: Not-ECT (Not ECN-Capable Transport))
         0000 00.. = Differentiated Services Codepoint: Default (0x00)
         .... ..00 = Explicit Congestion Notification: Not-ECT (Not ECN-Capable Transport) (0x00)
     Total Length: 124
     Identification: 0xfc40 (64576)
     Flags: 0x02 (Don't Fragment)
         0... .... = Reserved bit: Not set
         .1.. .... = Don't fragment: Set
         ..0. .... = More fragments: Not set
     Fragment offset: 0
     Time to live: 64
     Protocol: ICMP (1)
     Header checksum: 0x443d [incorrect, should be 0x403d (may be caused by "IP checksum offload"?)]
         [Good: False]
         [Bad: True]
             [Expert Info (Error/Checksum): Bad checksum]
                 [Message: Bad checksum]
                 [Severity level: Error]
                 [Group: Checksum]
     Source: 192.168.0.1 (192.168.0.1)
     Destination: 192.168.0.9 (192.168.0.9)
     [Source GeoIP: Unknown]
     [Destination GeoIP: Unknown]
     Options: (40 bytes), Record Route, End of Options List (EOL)
         Record Route (39 bytes)
             Type: 7
                 0... .... = Copy on fragmentation: No
                 .00. .... = Class: Control (0)
                 ...0 0111 = Number: Record route (7)
             Length: 39
             Pointer: 16  ******************************************** CHANGED
             Recorded Route: 192.168.0.9 (192.168.0.9)
             Recorded Route: 192.168.0.1 (192.168.0.1)
             Recorded Route: 0.0.0.0 (0.0.0.0) *********************** CHANGED
             Empty Route: 0.0.0.0 <- (next)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
             Empty Route: 0.0.0.0 (0.0.0.0)
         End of Options List (EOL)
             Type: 0
                 0... .... = Copy on fragmentation: No
                 .00. .... = Class: Control (0)
                 ...0 0000 = Number: End of Option List (EOL) (0)
Internet Control Message Protocol
     Type: 0 (Echo (ping) reply)
     Code: 0
     Checksum: 0x66b0 [correct]
     Identifier (BE): 31519 (0x7b1f)
     Identifier (LE): 8059 (0x1f7b)
     Sequence number (BE): 1 (0x0001)
     Sequence number (LE): 256 (0x0100)
     Timestamp from icmp data: May 11, 2014 23:06:25.000000000 CST
     [Timestamp from icmp data (relative): 0.953831000 seconds]
     Data (48 bytes)

0000  08 8c 0e 00 00 00 00 00 10 11 12 13 14 15 16 17   ................
0010  18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27   ........ !"#$%&'
0020  28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37   ()*+,-./01234567
         Data: 088c0e0000000000101112131415161718191a1b1c1d1e1f...
         [Length: 48]

----8<----8<---- RECEIVED ON eth0 ---8<----8<----
Frame 11: 140 bytes on wire (1120 bits), 140 bytes captured (1120 bits)
     Encapsulation type: Linux cooked-mode capture (25)
     Arrival Time: May 11, 2014 23:06:35.889471000 CST
     [Time shift for this packet: 0.000000000 seconds]
     Epoch Time: 1399815395.889471000 seconds
     [Time delta from previous captured frame: 0.000428000 seconds]
     [Time delta from previous displayed frame: 0.000428000 seconds]
     [Time since reference or first frame: 9.936092000 seconds]
     Frame Number: 11
     Frame Length: 140 bytes (1120 bits)
     Capture Length: 140 bytes (1120 bits)
     [Frame is marked: False]
     [Frame is ignored: False]
     [Protocols in frame: sll:ip:icmp:data]
Linux cooked capture
     Packet type: Unicast to us (0)
     Link-layer address type: 1
     Link-layer address length: 6
     Source: c4:04:15:b4:84:84 (c4:04:15:b4:84:84)
     Protocol: IP (0x0800)
Internet Protocol Version 4, Src: 192.168.0.1 (192.168.0.1), Dst: 192.168.0.9 (192.168.0.9)
     Version: 4
     Header length: 60 bytes
     Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: Not-ECT (Not ECN-Capable Transport))
         0000 00.. = Differentiated Services Codepoint: Default (0x00)
         .... ..00 = Explicit Congestion Notification: Not-ECT (Not ECN-Capable Transport) (0x00)
     Total Length: 124
     Identification: 0xfc50 (64592)
     Flags: 0x02 (Don't Fragment)
         0... .... = Reserved bit: Not set
         .1.. .... = Don't fragment: Set
         ..0. .... = More fragments: Not set
     Fragment offset: 0
     Time to live: 64
     Protocol: ICMP (1)
     Header checksum: 0xdc28 [correct]
         [Good: True]
         [Bad: False]
     Source: 192.168.0.1 (192.168.0.1)
     Destination: 192.168.0.9 (192.168.0.9)
     [Source GeoIP: Unknown]
     [Destination GeoIP: Unknown]
     Options: (40 bytes), Time Stamp
         Time Stamp (40 bytes)
             Type: 68
                 0... .... = Copy on fragmentation: No
                 .10. .... = Class: Debugging and measurement (2)
                 ...0 0100 = Number: Time stamp (4)
             Length: 40
             Pointer: 9
             Overflow: 0
             Flag: Time stamps only
             Time stamp = 48995889
             Time stamp = 518240
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
Internet Control Message Protocol
     Type: 0 (Echo (ping) reply)
     Code: 0
     Checksum: 0xacaa [correct]
     Identifier (BE): 31520 (0x7b20)
     Identifier (LE): 8315 (0x207b)
     Sequence number (BE): 1 (0x0001)
     Sequence number (LE): 256 (0x0100)
     [Request frame: 10]
     [Response time: 0.428 ms]
     Timestamp from icmp data: May 11, 2014 23:06:35.000000000 CST
     [Timestamp from icmp data (relative): 0.889471000 seconds]
     Data (48 bytes)

0000  b9 90 0d 00 00 00 00 00 10 11 12 13 14 15 16 17   ................
0010  18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27   ........ !"#$%&'
0020  28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37   ()*+,-./01234567
         Data: b9900d0000000000101112131415161718191a1b1c1d1e1f...
         [Length: 48]

----8<----8<----  SENT TO BRIDGE ----8<----8<----
Frame 12: 140 bytes on wire (1120 bits), 140 bytes captured (1120 bits)
     Encapsulation type: Linux cooked-mode capture (25)
     Arrival Time: May 11, 2014 23:06:35.889471000 CST
     [Time shift for this packet: 0.000000000 seconds]
     Epoch Time: 1399815395.889471000 seconds
     [Time delta from previous captured frame: 0.000000000 seconds]
     [Time delta from previous displayed frame: 0.000000000 seconds]
     [Time since reference or first frame: 9.936092000 seconds]
     Frame Number: 12
     Frame Length: 140 bytes (1120 bits)
     Capture Length: 140 bytes (1120 bits)
     [Frame is marked: False]
     [Frame is ignored: False]
     [Protocols in frame: sll:ip:icmp:data]
Linux cooked capture
     Packet type: Unicast to us (0)
     Link-layer address type: 1
     Link-layer address length: 6
     Source: c4:04:15:b4:84:84 (c4:04:15:b4:84:84)
     Protocol: IP (0x0800)
Internet Protocol Version 4, Src: 192.168.0.1 (192.168.0.1), Dst: 192.168.0.9 (192.168.0.9)
     Version: 4
     Header length: 60 bytes
     Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00: Not-ECT (Not ECN-Capable Transport))
         0000 00.. = Differentiated Services Codepoint: Default (0x00)
         .... ..00 = Explicit Congestion Notification: Not-ECT (Not ECN-Capable Transport) (0x00)
     Total Length: 124
     Identification: 0xfc50 (64592)
     Flags: 0x02 (Don't Fragment)
         0... .... = Reserved bit: Not set
         .1.. .... = Don't fragment: Set
         ..0. .... = More fragments: Not set
     Fragment offset: 0
     Time to live: 64
     Protocol: ICMP (1)
     Header checksum: 0xdc28 [incorrect, should be 0x1f74 (may be caused by "IP checksum offload"?)]
         [Good: False]
         [Bad: True]
             [Expert Info (Error/Checksum): Bad checksum]
                 [Message: Bad checksum]
                 [Severity level: Error]
                 [Group: Checksum]
     Source: 192.168.0.1 (192.168.0.1)
     Destination: 192.168.0.9 (192.168.0.9)
     [Source GeoIP: Unknown]
     [Destination GeoIP: Unknown]
     Options: (40 bytes), Time Stamp
         Time Stamp (40 bytes)
             Type: 68
                 0... .... = Copy on fragmentation: No
                 .10. .... = Class: Debugging and measurement (2)
                 ...0 0100 = Number: Time stamp (4)
             Length: 40
             Pointer: 13 ********************************************* CHANGED
             Overflow: 0
             Flag: Time stamps only
             Time stamp = 48995889
             Time stamp = 48995889 *********************************** CHANGED
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
             Time stamp = 0
Internet Control Message Protocol
     Type: 0 (Echo (ping) reply)
     Code: 0
     Checksum: 0xacaa [correct]
     Identifier (BE): 31520 (0x7b20)
     Identifier (LE): 8315 (0x207b)
     Sequence number (BE): 1 (0x0001)
     Sequence number (LE): 256 (0x0100)
     Timestamp from icmp data: May 11, 2014 23:06:35.000000000 CST
     [Timestamp from icmp data (relative): 0.889471000 seconds]
     Data (48 bytes)

0000  b9 90 0d 00 00 00 00 00 10 11 12 13 14 15 16 17   ................
0010  18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27   ........ !"#$%&'
0020  28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37   ()*+,-./01234567
         Data: b9900d0000000000101112131415161718191a1b1c1d1e1f...
         [Length: 48]

----8<----8<----8<---- --- ----8<----8<----8<----

David
