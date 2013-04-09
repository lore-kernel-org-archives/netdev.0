From: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Subject: RE: be2net: GRO for non-inet protocols
Date: Tue, 9 Apr 2013 14:31:38 +0000
Message-ID: <ffc6a5aa-11f5-4e25-b6ac-e1596e8d5437@CMEXHTCAS1.ad.emulex.com>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Perla, Sathya" <Sathya.Perla@Emulex.Com>,
	"Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Erik Hugne <erik.hugne@ericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:55084 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935076Ab3DIObp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 10:31:45 -0400
In-Reply-To: <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik,
   Checked the driver code. With the change that Eric proposed the driver does nothing more than call eth_type_trans to parse the ether protocol type and set up skb variables appropriately.  Please verify that all packets are only taking the be_rx_compl_process path which calls napi_gro_receive. 

   Apart from this I can't see anything in the driver that can cause corruption. 

Thanks,
Sarvesh

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Erik Hugne
Sent: Monday, April 08, 2013 8:54 PM
To: Eric Dumazet
Cc: Perla, Sathya; Seetharaman, Subramanian; Khaparde, Ajit; netdev@vger.kernel.org
Subject: Re: be2net: GRO for non-inet protocols

On Mon, Apr 08, 2013 at 08:40:10AM +0200, Erik Hugne wrote:
> Thanks Eric, it works as expected after applying this.

So, on to the next problem, now i'm getting corrupted packets from the driver instead. Would be great to get some comments from the Emulex guys regarding this.

Attaching a printk trace where i log the mac header and packet data of all 0x88CA (TIPC) packets in the gro_receive routine that have an erroneous TIPC header. This happens immediately when i register myself with the device.


kernel: [ 3455.608572] tipc: Activated (version 2.0.0)
kernel: [ 3455.609545] NET: Registered protocol family 30
kernel: [ 3455.609547] tipc: Started in single node mode
kernel: [ 3458.837149] tipc: Started in network mode
kernel: [ 3458.837153] tipc: Own node address <1.1.11>, network identity 4711
kernel: [ 3458.837244] tipc: Enabled bearer <eth:eth1>, discovery domain <1.1.0>, priority 10
kernel: [ 3458.837916] tipc: Garbage packet received
kernel: [ 3458.837919] tipc: packet length=56 data_len=56
kernel: [ 3458.837925] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.837929] pdata: 10 0b 00 00 00 01 9e dd 00 a0 01 00 10 0b 01 00 10 0a 00 00 00 00 01 77 05 dc 65 74 68 31 00 00  .......................w..eth1..
kernel: [ 3458.837933] pdata: 00 00 00 00 00 00 00 00 00 00 04 00 00 00 04 00 00 00 50 e5 74 64 5c e6                          ..................P.td\.
kernel: [ 3458.837942] tipc: Established link <1.1.11:eth1-1.1.10:eth1> on network plane A
kernel: [ 3458.838225] tipc: Garbage packet received
kernel: [ 3458.838228] tipc: packet length=56 data_len=56
kernel: [ 3458.838232] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.838236] pdata: 10 0b 00 00 00 01 9e dd 00 a1 01 00 10 0b 01 00 10 0a 00 00 00 00 00 00 00 00 65 74 68 31 00 00  ..........................eth1..
kernel: [ 3458.838239] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                          ........................
kernel: [ 3458.838244] tipc: Garbage packet received
kernel: [ 3458.838246] tipc: packet length=56 data_len=56
kernel: [ 3458.838249] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.838254] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00  ................................
kernel: [ 3458.838258] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                          ........................
kernel: [ 3458.838262] tipc: Garbage packet received
kernel: [ 3458.838263] tipc: packet length=60 data_len=60
kernel: [ 3458.838268] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3458.838272] pdata: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 72 65 65 64 65 73  ..........................reedes
kernel: [ 3458.838276] pdata: 6b 74 6f 70 2f 48 61 6c 2f 64 65 76 69 63 65 73 2f 6e 65 74 5f 65 34 5f 31 31 5f 35              ktop/Hal/devices/net_e4_11_5
kernel: [ 3459.976074] tipc: Garbage packet received
kernel: [ 3459.976077] tipc: packet length=56 data_len=56
kernel: [ 3459.976081] pmachdr: e4 11 5b db 24 a4 e4 11 5b d7 36 9c 88 ca                                                        ..[.$...[.6...
kernel: [ 3459.976085] pdata: 10 0b 00 00 00 03 9e dd 00 a1 01 00 10 0b 01 00 10 0a 00 00 00 00 00 00 00 00 65 74 68 31 00 00  ..........................eth1..
kernel: [ 3459.976089] pdata: 00 00 00 00 00 00 00 00 00 00 04 00 00 00 04 00 00 00 50 e5 74 64 5c e6                          ..................P.td\.
--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
