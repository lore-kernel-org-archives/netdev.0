From: Anton Blanchard <anton@samba.org>
Subject: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 20 Sep 2004 16:30:13 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920063012.GL2825@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

I just tried latest 2.6.9-rc2-BK on a machine with an e1000 on it. With
TSO off it does about 100MB/sec. With TSO on it does between 1MB/sec and
10MB/sec.

Here are some tcpdumps of socklib (just a TCP bw test). The client makes the 
connection and the server streams bytes down the connection.

client:

14:59:21.745368 IP client.32818 > server.7001: S 2966429246:2966429246(0) win 5840 <mss 1460,sackOK,timestamp 102828576 0,nop,wscale 0>
14:59:21.745497 IP server.7001 > client.32818: S 3127678265:3127678265(0) ack 2966429247 win 5792 <mss 1460,sackOK,timestamp 1452516 102828576,nop,wscale 2>
14:59:21.745511 IP client.32818 > server.7001: . ack 1 win 5840 <nop,nop,timestamp 102828576 1452516>
14:59:21.746245 IP server.7001 > client.32818: . 1:1449(1448) ack 1 win 1448 <nop,nop,timestamp 1452516 102828576>
14:59:21.746253 IP server.7001 > client.32818: . 1449:2897(1448) ack 1 win 1448 <nop,nop,timestamp 1452516 102828576>
14:59:21.746273 IP client.32818 > server.7001: . ack 1449 win 8688 <nop,nop,timestamp 102828576 1452516>
14:59:21.746284 IP client.32818 > server.7001: . ack 2897 win 11584 <nop,nop,timestamp 102828576 1452516>
14:59:21.746492 IP server.7001 > client.32818: . 2897:4345(1448) ack 1 win 1448 <nop,nop,timestamp 1452516 102828576>
14:59:21.746500 IP server.7001 > client.32818: P 4345:5793(1448) ack 1 win 1448 <nop,nop,timestamp 1452516 102828576>
14:59:21.746515 IP client.32818 > server.7001: . ack 4345 win 14480 <nop,nop,timestamp 102828576 1452516>
14:59:21.746525 IP client.32818 > server.7001: . ack 5793 win 17376 <nop,nop,timestamp 102828576 1452516>
14:59:21.746742 IP server.7001 > client.32818: . 5793:7241(1448) ack 1 win 1448 <nop,nop,timestamp 1452517 102828576>
14:59:21.746749 IP server.7001 > client.32818: . 7241:8689(1448) ack 1 win 1448 <nop,nop,timestamp 1452517 1028

...

It finally settles down and we see 3 packets per ack:

4:59:24.343034 IP client.32818 > server.7001: . ack 13078337 win 34752 <nop,nop,timestamp 102828836 1455113>
14:59:24.343367 IP server.7001 > client.32818: . 13078337:13079785(1448) ack 1 win 1448 <nop,nop,timestamp 1455113 102828836>
14:59:24.343375 IP server.7001 > client.32818: . 13079785:13081233(1448) ack 1 win 1448 <nop,nop,timestamp 1455113 102828836>
14:59:24.343380 IP server.7001 > client.32818: . 13081233:13082681(1448) ack 1 win 1448 <nop,nop,timestamp 1455113 102828836>
14:59:24.343419 IP client.32818 > server.7001: . ack 13082681 win 34752 <nop,nop,timestamp 102828836 1455113>
14:59:24.343750 IP server.7001 > client.32818: . 13082681:13084129(1448) ack 1 win 1448 <nop,nop,timestamp 1455114 102828836>
14:59:24.343759 IP server.7001 > client.32818: . 13084129:13085577(1448) ack 1 win 1448 <nop,nop,timestamp 1455114 102828836>
14:59:24.343765 IP server.7001 > client.32818: P 13085577:13087025(1448) ack 1 win 1448 <nop,nop,timestamp 1455114 102828836>

server:

15:44:04.939695 IP client.32823 > server.7001: S 4245828116:4245828116(0) win 5840 <mss 1460,sackOK,timestamp 102953269 0,nop,wscale 0>
15:44:04.939703 IP server.7001 > client.32823: S 130434711:130434711(0) ack 4245828117 win 5792 <mss 1460,sackOK,timestamp 2699455 102953269,nop,wscale 2>
15:44:04.939899 IP client.32823 > server.7001: . ack 1 win 5840 <nop,nop,timestamp 102953269 2699455>
15:44:04.940439 IP bad-len 0
15:44:04.940649 IP client.32823 > server.7001: . ack 1449 win 8688 <nop,nop,timestamp 102953269 2699456>
15:44:04.940650 IP client.32823 > server.7001: . ack 2897 win 11584 <nop,nop,timestamp 102953269 2699456>
15:44:04.940675 IP bad-len 0

...

This is what it looks like after things settle down. Nasty how tcpdump doesnt
understand TSO bundles. Notice how we send out one TSO bundle and then wait
for the ack:

15:44:05.068048 IP client.32823 > server.7001: . ack 2213993 win 34752 <nop,nop,timestamp 102953282 2699583>
15:44:05.068059 IP bad-len 0
15:44:05.068298 IP client.32823 > server.7001: . ack 2218337 win 34752 <nop,nop,timestamp 102953282 2699584>
15:44:05.068310 IP bad-len 0
15:44:05.068549 IP client.32823 > server.7001: . ack 2222681 win 34752 <nop,nop,timestamp 102953282 2699584>
15:44:05.068565 IP bad-len 0

>From the first trace we see that each TSO bundle consists of 3 packets. The
application is doing 64kB sends so its surprising that we only pack 3 packets
into a TSO bundle. It looks like we only think there is a 5k window on
this connection when TSO is enabled.

Anton
