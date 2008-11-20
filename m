From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: Slow and asymmetric bandwith with skge, possibly forcedeth involved as well as kacpid. Possible 2.6.27 regression as well.
Date: Thu, 20 Nov 2008 20:49:11 +0000
Message-ID: <200811202049.11931.tvrtko@ursulin.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mk-outboundfilter-6-a-2.mail.uk.tiscali.com ([212.74.114.16]:31208
	"EHLO mk-outboundfilter-6-a-2.mail.uk.tiscali.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642AbYKTU7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 15:59:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi to all,

This is pretty confusing at the moment so I don't know even where to start. Lets see.. I have two machines in a local 
network, a server and a client, both with gigabit NICs and connected via gigabit switch.

Until recently I was running Ubuntu 8.04 (2.6.24 derivative) on the server and openSUSE 11 on the client (2.6.25 
derivative). At that time problem was pretty slow gigabit performance regardless of the transport (Samba, NFS, SFTP) 
which was always just around 20Mbytes/sec. So double of what fast ethernet was providing which was kind of disappointing 
but never mind, interesting stuff hasn't even started yet.

Few words about the hardware. Server is a SFF PC with AMD Turion64 TL-34 CPU and has a D-Link DGE-530T (PCI) NIC with 
a chip which uses skge driver:

02:08.0 Ethernet controller: D-Link System Inc DGE-530T Gigabit Ethernet Adapter (rev 11) (rev 11)
        Subsystem: D-Link System Inc DGE-530T Gigabit Ethernet Adapter (rev 11)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 22
        Region 0: Memory at fdcf8000 (32-bit, non-prefetchable) [size=16K]
        Region 1: I/O ports at dc00 [size=256]
        Expansion ROM at fde00000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Kernel driver in use: skge
        Kernel modules: skge

Client is a more modern desktop with Core2Duo E6550 and onboard NVidia NIC (well integrated in the chipset):

00:0f.0 Ethernet controller: nVidia Corporation MCP73 Ethernet (rev a2)
        Subsystem: Giga-byte Technology Device e000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0 (250ns min, 5000ns max)
        Interrupt: pin A routed to IRQ 4350
        Region 0: Memory at e5109000 (32-bit, non-prefetchable) [size=4K]
        Region 1: I/O ports at e000 [size=8]
        Region 2: Memory at e510a000 (32-bit, non-prefetchable) [size=256]
        Region 3: Memory at e5106000 (32-bit, non-prefetchable) [size=16]
        Capabilities: [44] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ Count=1/8 Enable+
                Address: 00000000fee0100c  Data: 4179
                Masking: 000000fe  Pending: 00000000
        Kernel driver in use: forcedeth
        Kernel modules: forcedeth

Pretty recently I learnt about iperf and had a go testing with it to see if it will agree with file transfer performance I was 
seeing. Here are the results from two runs, one in each direction:

==============================================
client:/tmp/iperf-2.0.4 # src/iperf -c server
------------------------------------------------------------
Client connecting to server, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  5] local 192.168.1.102 port 54508 connected with 192.168.1.104 port 5001
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-10.0 sec    526 MBytes    441 Mbits/sec
client:/tmp/iperf-2.0.4 # src/iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  6] local 192.168.1.102 port 5001 connected with 192.168.1.104 port 36811
[ ID] Interval       Transfer     Bandwidth
[  6]  0.0-10.1 sec    237 MBytes    196 Mbits/sec
==============================================
root@server:~/iperf-2.0.4# src/iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 192.168.1.104 port 5001 connected with 192.168.1.102 port 54508
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.1 sec    526 MBytes    439 Mbits/sec
^C
root@server:~/iperf-2.0.4# src/iperf -c client
------------------------------------------------------------
Client connecting to client, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  4] local 192.168.1.104 port 36811 connected with 192.168.1.102 port 5001
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec    237 MBytes    199 Mbits/sec
==============================================

So it's not only slow and asymmetric. Which kind of gives hope that it could be improved so I did a bit of googling and 
found the same issues was once reported on kernel bugzilla (http://bugzilla.kernel.org/show_bug.cgi?id=6796). I added my 
info there just in case. I tried some things which were suggested there but with no improvement, only turning of TCP 
window scaling managed to halve performance in both directions.

Plot thickens.. recently I upgraded the server to Ubuntu 8.10 and the client to openSUSE 11.1 Beta 5. So both are running 
derivatives of 2.6.27 now, and I am seeing performance degradation when transferring files. Where previously it was pretty 
steady around 20Mbytes/sec even for long transfers, now it is bursty and averages to only 10Mbytes/sec. That is with CIFS 
and Samba, SFTP shows no regression.

IPerf on the other hand reports the same numbers as before.

One thing which I can't say wasn't happening before, but I suspect it wasn't because I have to blame something for this 
performance degradation, is that on the server kacpid uses helluva lot of CPU time when transfer goes in one direction!

In IPerf terminology that is when my server was a server (iperf -s), so the case of higher ~400Mbit bandwith obtainted. In 
file transfer test it is when client is uploading a file to the server. Then kacpid CPU usage ranges between 5-15%, while it is 
even higher, more than 50% in iperf benchmark. It looks like this:

top - 20:22:37 up 1 day, 10:17,  4 users,  load average: 0.83, 0.52, 0.57
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
Cpu(s):  3.0%us, 27.7%sy,  0.0%ni,  8.9%id,  0.0%wa, 28.7%hi, 31.7%si,  0.0%st
Mem:    958652k total,   931048k used,    27604k free,     4812k buffers
Swap:   891568k total,     8688k used,   882880k free,   373832k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
   48 root      15  -5     0    0    0 S 55.9  0.0   2:19.97 kacpid

(only one sample since this post is getting long as it is)

What ACPI has to do with transfer I have no clue.. it definitely does not show up on the client when test is reversed. Both 
with Samba and IPerf. Interestingly, kacpid is nowhere to be seen when transferring via SFTP in either direction.

Then I attempted some amateur fiddling with ethtool as an attempt to optimise things but behold this:

root@server:~# ethtool -C eth1 adaptive-rx on
root@server:~# ethtool -c eth1
Coalesce parameters for eth1:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0
<snip>

Seems to work, but the it doesn't. Hmm... same for any parameter here. 

Any ideas? I can try some debugging and diagnosing if only I had some expert guidance. Hopefully I presented it 
sufficiently clearly for people to understand what is happening here.

Many thanks,

Tvrtko














