From: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Subject: RE: be2net: GRO for non-inet protocols
Date: Wed, 10 Apr 2013 13:46:53 +0000
Message-ID: <9982e479-7a8c-4520-999b-9fb59dc62689@CMEXHTCAS2.ad.emulex.com>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
 <ffc6a5aa-11f5-4e25-b6ac-e1596e8d5437@CMEXHTCAS1.ad.emulex.com>
 <20130409163108.GA6818@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Perla, Sathya" <Sathya.Perla@Emulex.Com>,
	"Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19293 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab3DJNq7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 09:46:59 -0400
In-Reply-To: <20130409163108.GA6818@eerihug-hybrid.ki.sw.ericsson.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik,
    Can you check if packets are garbled when using netif_receive_skb? Or it happens only when napi_gro_receive is used?

Thanks,
Sarvesh

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Erik Hugne
Sent: Tuesday, April 09, 2013 10:01 PM
To: Bandi,Sarveshwar
Cc: Eric Dumazet; Perla, Sathya; Seetharaman, Subramanian; Khaparde, Ajit; netdev@vger.kernel.org
Subject: Re: be2net: GRO for non-inet protocols

On Tue, Apr 09, 2013 at 02:31:38PM +0000, Bandi,Sarveshwar wrote:
>    Apart from this I can't see anything in the driver that can cause corruption. 
Still, that's what i'm getting..
Now I've removed almost all GRO logic, and it's flushing the queue for all packets.
It looks something like this:
https://gist.github.com/Hugne/5347164

Here's the output when i start up TIPC on node A (node B is already running, sending periodic ndisc requests (msg_user=13)

[ 1656.912898] tipc: packet length=42 data_len=0 mac_len=14 [ 1656.912912] machdr: ff ff ff ff ff ff 10 60 4b b4 29 f0 88 ca  1656.912916] network header: 5b 50 00 28 00 00 a1 de 01 00 10 00 01 00 10 0a 00 00 12 67 00 03 00 01 10 60 4b b4 29 f0 00 00  [P.(...............g.....`K.)...
[ 1656.912920] network header: 00 00 00 00 00 00 00 00 00 00 08 0a 00 86 96 0d 00 05 27 da 4b b4 45 69 00 26 88 a8              ..................'.K.Ei.&..
[ 1656.912922] tipc: msg_user=13 msg_type=0

>>># Proper ndisc message from node B

[ 1657.523303] tipc: packet length=56 data_len=56 mac_len=14 [ 1657.523316] machdr: 10 60 4b b4 45 68 10 60 4b b4 29 f0 88 ca [ 1657.523320] network header: 45 00 00 34 33 a3 40 00 39 06 e8 f3 82 64 5e 8f 0a 33 3a 07 ec e5 00 16 4c 95 9a 58 47 21 b1 ed  E..43.@.9....d^..3:.....L..XG!..
[ 1657.523324] network header: 80 10 01 4b c4 51 00 00 01 01 08 0a 00 86 96 51 00 05 28 1e 4b b4 45 69 00 26 88 a8              ...K.Q.........Q..(.K.Ei.&..
[ 1657.523326] tipc: msg_user=2 msg_type=1

>>># This actually looks like an IPv4 packet.. but the ethertype is TIPC..
>>># The crude "check for tipc header" passes becase it only looks at 
>>>the first 3 bits #(No, this did not come from the wire)

[ 1657.904889] tipc: Garbage packet received [ 1657.904903] tipc: packet length=56 data_len=56 mac_len=14 [ 1657.904907] machdr: 10 60 4b b4 45 68 10 60 4b b4 29 f0 88 ca [ 1657.904911] network header: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 62 a2 48 b9 8e 05  ..........................b.H...
[ 1657.904914] network header: 80 18 b8 23 61 1c 00 ea ff ff 0e 08 00 00 38 00 00 00 10 60 4b b4 45 69 00 26 88 a8              ...#a.........8....`K.Ei.&..
[ 1657.904917] tipc: msg_user=0 msg_type=0

>>># I have no idea what this is.. but it's not a TIPC packet..
>>># And it did not come from the wire either

//E
--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
