From: John Partridge <johnip@sgi.com>
Subject: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 08 Oct 2003 12:12:24 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F844578.40306@sgi.com>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Partridge <johnip@sgi.com>, Jeff Garzik <jgarzik@pobox.com>,
        "David S. Miller" <davem@redhat.com>, Jes Sorensen <jes@sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am seeing a problem with PCI-X recv performance on the Broadcom 5701 cards.
This is due to a known PCI-X errata with the DMA engine when buffers are non zero
offset aligned. As well as performance problems there are also a lot of kernel
unaligned access messages in the system log (hundereds of them) :-

kernel unaligned access to 0xe0000030174f382e, ip=0xe0000000047d1f80

This affects both 2.4x and 2.6x tg3.o drivers

Measure of performance WITHOUT fix :-
mig125:~ # nttcp -r -T -l262144 -w1024 -n1000 10.50.1.130 -l262144 -w1024
      Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CPU-C/s
l2621440000  118.36   43.24    177.1846    484.9782 1818304  15362.52   42049.3
12621440000  118.34   12.70    177.2167   1651.3857   10000     84.50     787.4

I then applied a fix to the driver :-

line 2260 of linux-2.6.0-test6/drivers/net/tg3.c

-               if (len > RX_COPY_THRESHOLD) {
+               if (len > RX_COPY_THRESHOLD && tp->rx_offset == 2) {

Then I loaded a tg3.o module which has the fix, and ran the test again

Measure of performance WITH fix :-
mig125:~ # nttcp -r -T -l262144 -w1024 -n1000 10.50.1.130 -l262144 -w1024
      Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CPU-C/s
l262144000    2.23    1.64    940.6910   1277.5033   35082  15736.26   21370.6
1262144000    2.22    1.43    944.0677   1470.4690    1000    450.17     701.2

This ONLY affects Broadcom 5701 based Gigabit Ethernet cards 5704 cards do not
have the same errata. I confirmed that the fix did not affect the performance
or functionality of 5704 cards, actually the fix ensures that the 5701 cards don't
go through the same code path as 5704 (becuase tp->rx_offset is 0 for 5701 so we
always align the buffers for the 5701 card).

John

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com	
