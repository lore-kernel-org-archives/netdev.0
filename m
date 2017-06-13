From: Mason <slash.tmp@free.fr>
Subject: Re: Toggling link state breaks network connectivity
Date: Tue, 13 Jun 2017 17:07:28 +0200
Message-ID: <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:7916 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752854AbdFMPHl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 11:07:41 -0400
In-Reply-To: <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2017 18:38, Florian Fainelli wrote:

> On 06/12/2017 06:22 AM, Mason wrote:
>
>> I am using the following drivers for Ethernet connectivity.
>> drivers/net/ethernet/aurora/nb8800.c
>> drivers/net/phy/at803x.c
>>
>> Pulling the cable and plugging it back works as expected.
>> (I can ping both before and after.)
>>
>> However, if I toggle the link state in software (using ip link set),
>> the board loses network connectivity.
>>
>> # Statically assign IP address
>> ip addr add 172.27.64.77/18 brd 172.27.127.255 dev eth0
>> # Set link state to "up"
>> ip link set eth0 up
>> # ping -c 3 172.27.64.1 > /tmp/v1
>>
>> PING 172.27.64.1 (172.27.64.1): 56 data bytes
>> 64 bytes from 172.27.64.1: seq=0 ttl=64 time=18.321 ms
> 
> This delay seems abnormally long unless you are purposely introducing
> delay (e.g: with cls_netem) or this is a really remote host, does not
> seem to be based on your traces later on.

I think the delay is due to calling ping before the link
is actually up. For example, if I ping immediately after
setting the link up, the first 4 packets are lost.

PING 172.27.64.1 (172.27.64.1): 56 data bytes
64 bytes from 172.27.64.1: seq=4 ttl=64 time=0.235 ms
64 bytes from 172.27.64.1: seq=5 ttl=64 time=0.142 ms
64 bytes from 172.27.64.1: seq=6 ttl=64 time=0.110 ms
64 bytes from 172.27.64.1: seq=7 ttl=64 time=0.095 ms
64 bytes from 172.27.64.1: seq=8 ttl=64 time=0.139 ms
64 bytes from 172.27.64.1: seq=9 ttl=64 time=0.120 ms

--- 172.27.64.1 ping statistics ---
10 packets transmitted, 6 packets received, 40% packet loss
round-trip min/avg/max = 0.095/0.140/0.235 ms


>> So basically, the board is asking the desktop for its MAC address,
>> and the desktop is answering immediately. But the board doesn't seem
>> to be getting the replies... Any ideas, or words of wisdom, as they say?
> 
> - check the Ethernet MAC counters to see if there is packet loss, or
> error, or both
> 
> - consult with your HW engineers for possible flaws in your
> ndo_open/ndo_close paths and possible interactions with the MAC/PHY
> clocks, or reset etc.
> 
> - see if your PHY needs a complete re-init after an up/down sequence and
> if you are doing this properly

I'm using the following test script:

ip addr add 172.27.64.77/18 brd 172.27.127.255 dev eth0
ip link set eth0 up
sleep 3  ## hopefully autoneg is complete

ethtool -S eth0 > /tmp/s0
ping -c 10 172.27.64.1 > /tmp/v1
ethtool -S eth0 > /tmp/s1
diff -U0 /tmp/s0 /tmp/s1

ip link set eth0 down
sleep 1
ip link set eth0 up
sleep 1

ethtool -S eth0 > /tmp/s0
ping -c 10 172.27.64.1 > /tmp/v2
ethtool -S eth0 > /tmp/s1
diff -U0 /tmp/s0 /tmp/s1

Testing with a generic PHY driver (no Atheros 8035 support built).
Apparently, ethtool doesn't report any packet loss or error.

First time:

# diff -U0 /tmp/s0 /tmp/s1
--- /tmp/s0
+++ /tmp/s1
@@ -2,2 +2,2 @@
-     rx_bytes_ok: 0
-     rx_frames_ok: 0
+     rx_bytes_ok: 1084
+     rx_frames_ok: 11
@@ -6,2 +6,2 @@
-     rx_64_byte_frames: 0
-     rx_127_byte_frames: 0
+     rx_64_byte_frames: 1
+     rx_127_byte_frames: 10
@@ -22,6 +22,6 @@
-     rx_bytes: 0
-     rx_frames: 0
-     tx_bytes_ok: 0
-     tx_frames_ok: 0
-     tx_64_byte_frames: 0
-     tx_127_byte_frames: 0
+     rx_bytes: 1084
+     rx_frames: 11
+     tx_bytes_ok: 1084
+     tx_frames_ok: 11
+     tx_64_byte_frames: 1
+     tx_127_byte_frames: 10
@@ -33 +33 @@
-     tx_broadcast_frames: 0
+     tx_broadcast_frames: 1
@@ -43,2 +43,2 @@
-     tx_bytes: 0
-     tx_frames: 0
+     tx_bytes: 1084
+     tx_frames: 11


Second time:

# diff -U0 /tmp/s0 /tmp/s1
--- /tmp/s0
+++ /tmp/s1
@@ -2,2 +2,2 @@
-     rx_bytes_ok: 1276
-     rx_frames_ok: 14
+     rx_bytes_ok: 1779
+     rx_frames_ok: 19
@@ -6 +6 @@
-     rx_64_byte_frames: 4
+     rx_64_byte_frames: 8
@@ -8 +8 @@
-     rx_255_byte_frames: 0
+     rx_255_byte_frames: 1
@@ -14 +14 @@
-     rx_broadcast_frames: 0
+     rx_broadcast_frames: 1
@@ -22,5 +22,5 @@
-     rx_bytes: 1276
-     rx_frames: 14
-     tx_bytes_ok: 1276
-     tx_frames_ok: 14
-     tx_64_byte_frames: 4
+     rx_bytes: 1779
+     rx_frames: 19
+     tx_bytes_ok: 1724
+     tx_frames_ok: 21
+     tx_64_byte_frames: 11
@@ -33 +33 @@
-     tx_broadcast_frames: 1
+     tx_broadcast_frames: 8
@@ -43,2 +43,2 @@
-     tx_bytes: 1276
-     tx_frames: 14
+     tx_bytes: 1724
+     tx_frames: 21


I did note something that seems important.

If I toggle the link state in software, then connectivity breaks.

If I unplug the ethernet cable, and replug, connectivity remains.

The difference is that plugging/unplugging doesn't call the
.ndo_stop callback. But 'ip link set eth0 down' does call it.

Should the .ndo_stop callback be symmetric to the .ndo_open callback?
In other words, should .ndo_open(); .ndo_stop(); be a NOP?

Regards.
