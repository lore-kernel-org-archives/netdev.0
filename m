From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH 0/7] via-velocity performance fixes
Date: Fri, 20 Nov 2009 16:06:33 +0100
Message-ID: <20091120160633.77b7aee0@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	shemminger@vyatta.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:42331 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753934AbZKTPQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 10:16:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone!

I've been fighting with the via-velocity driver for a while,
suffered a few bad blows, but finally managed to land a few patches on
it. I'm sending them together with this mail.


The main reason for the work is to get performance for the mainline
driver back on par with the out-of-tree VIA driver. Most of it are
backports from the VIA driver although there is some original work as
well. The series comes with a RFC tag, and I'd like feedback and
(preferably) testing of the patches since I'm not that familiar with
the driver and Linux networking.


The patches are:

1. Correct setting of skipped checksums (unsure about this). The
   mainline driver sets CHECKSUM_UNNECESSARY if this is an IP packet
   except if the TCP checksum is NOT ok.

   The VIA driver sets CHECKSUM_UNNECESSARY if this is an UDP/TCP
   packet except if the TCP checksum is not OK. The patch selects the
   VIA behavior.

2. See to it that data is 64-byte aligned (as required by the
   hardware). Again different behavior than the VIA driver, and from
   looking at the code, it seems to me that VIA handles it correct here.

3. Enable support for adaptive interrupt supression. The velocity
   hardware is able to supress interrupts during bursts. This (together
   with the next patch) improves behavior quite a bit in my tests.

4. Add NAPI support for via velocity. Also takes in a change in the
   interrupt handler from upstream VIA (run rx/tx handlers twice) which
   improves performance.

5. Change the DMA_LENGTH_DEF to that of the VIA driver. Large
   performance improvement together with the last two patches.

6. Take back the transmit scatter-gather support. A few months after
   Dave removed it, it gets back in a fixed manner again :-). I'm
   unsure about this one since it doesn't improve performance in my
   netperf tests (rather decreases it!).

   It might be that I need other tests to benefit from this, or that
   it's simply not improving things, but obviously I'm unsure if this
   should be added at all.

7. Bump the version number.


The tests I run are basic (quite arbitrary I must say) netperf tests:

  #!/bin/sh

  netperf -H $1 -c -C -l 20 -t UDP_STREAM
  netperf -H $1 -c -C -l 20 -t TCP_STREAM
  netperf -H $1 -c -C -l 20 -t TCP_SENDFILE

and I have two identical 1.4GHz Pentium M boards with VIA velocities
that the traffic goes between. The remote board has all patches
applied. The numbers are below:

2.6.32-rc8  without patches
---------------------------
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

107520   65507   20.00       20680      0      541.8     41.10    6.214 
108544           20.00       20680             541.8     16.96    2.564 

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    20.02       505.25   60.54    29.52    9.817   4.787  
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    20.02       507.64   60.45    27.63    9.754   4.458  

# cat /proc/interrupts 
           CPU0       
  0:      22153   IO-APIC-edge      timer
  [...]
 16:    2673939   IO-APIC-fasteoi   uhci_hcd:usb1, eth-swa



2.6.32-rc8  with NAPI + adaptive
--------------------------------
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

107520   65507   20.00       26615      0      697.3     17.61    2.069 
108544           20.00       26613             697.2     23.55    2.767 

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    20.02       641.77   41.62    35.61    5.312   4.546  
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    20.02       641.98   43.76    36.50    5.584   4.658  

# cat /proc/interrupts 
           CPU0       
  0:      22605   IO-APIC-edge      timer
  [...]
 16:     321020   IO-APIC-fasteoi   uhci_hcd:usb1, eth-swa



2.6.32-rc8  with all patches
---------------------------
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Socket  Message  Elapsed      Messages                   CPU      Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

107520   65507   20.00       26606      0      697.1     17.60    2.068 
108544           20.00       26605             697.1     24.95    2.932 

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    20.02       563.36   25.58    31.23    3.720   4.542  
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to pl-ncaa (169.254.1.33) port 0 AF_INET : demo
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    20.03       562.54   22.12    30.77    3.221   4.480  

# cat /proc/interrupts 
           CPU0       
  0:      23652   IO-APIC-edge      timer
  [...]
 16:     341394   IO-APIC-fasteoi   uhci_hcd:usb1, eth-swa


As you can see, the best results for this particular test are without
the transmit scatter-gather stuff. Also note the difference in
CPU-utilization and interrupt count between the first and second case,
which is fairly nice. With the patches, the performance is again on par
with the VIA driver.

// Simon
