From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 10:47:15 +0300
Message-ID: <200808051047.15605.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:34289 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbYHEHsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 03:48:00 -0400
Received: from [195.69.208.252] (unknown [195.69.208.252])
	by relay2.globalproof.net (Postfix) with ESMTP id 725BE1304C9
	for <netdev@vger.kernel.org>; Tue,  5 Aug 2008 10:47:57 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did script, that looks something like this (to simulate SFQ by flow 
classifier):

$2 (is ppp interface)
echo "qdisc del dev $2 root ">>${TEMP}
echo "qdisc add dev $2 root handle 1: htb ">>${TEMP}
 echo "filter add dev $2 protocol ip pref 16 parent 1: u32 \
	match ip dst 0.0.0.0/0 police rate 8kbit burst 2048kb \
	peakrate 1024Kbit mtu 10000 \
	conform-exceed continue/ok">>${TEMP}

echo "filter add dev $2 protocol ip pref 32 parent 1: handle 1 \
	flow hash keys nfct divisor 128 baseclass 1:2">>${TEMP}

echo "class add dev $2 parent 1: classid 1:1 htb \
	rate ${rate}bit ceil ${rate}Kbit quantum 1514">>${TEMP}

#Cycle to add 128 classes
maxslot=130
for slot in `seq 2 $maxslot`; do
echo "class add dev $2 parent 1:1 classid 1:$slot htb \
	rate 8Kbit ceil 256Kbit quantum 1514">>${TEMP}
echo "qdisc add dev $2 handle $slot: parent 1:$slot bfifo limit 3000">>${TEMP}
done

After adding around 400-450 interfaces (ppp) server start to "crack". Sure 
there is packetloss to eth0 (but there is no filters or shapers on it). Even 
deleting all classes becomes a challenge. After deleting all root handles on 
ppp interfaces - it becomes ok. 


Traffic over host is 15-20Mbit/s at that moment, it is 1 CPU Xeon 3.0 Ghz on 
server motherboard SE7520 with 1GB ram available (at moment of testing more 
than 512Mb was free).

Kernel is 2.6.26.1-vanilla
Anything else i need to add to info?

Error message appearing in dmesg:
[149650.006939] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149650.006943]   Tx Queue             <0>
[149650.006944]   TDH                  <a3>
[149650.006945]   TDT                  <a3>
[149650.006947]   next_to_use          <a3>
[149650.006948]   next_to_clean        <f8>
[149650.006949] buffer_info[next_to_clean]
[149650.006951]   time_stamp           <8e69a7c>
[149650.006952]   next_to_watch        <f8>
[149650.006953]   jiffies              <8e6a111>
[149650.006954]   next_to_watch.status <1>
[149655.964100] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149655.964104]   Tx Queue             <0>
[149655.964105]   TDH                  <6c>
[149655.964107]   TDT                  <6c>
[149655.964108]   next_to_use          <6c>
[149655.964109]   next_to_clean        <c1>
[149655.964111] buffer_info[next_to_clean]
[149655.964112]   time_stamp           <8e6b198>
[149655.964113]   next_to_watch        <c1>
[149655.964115]   jiffies              <8e6b853>
[149655.964116]   next_to_watch.status <1>
[149666.765110] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149666.765110]   Tx Queue             <0>
[149666.765110]   TDH                  <28>
[149666.765110]   TDT                  <28>
[149666.765110]   next_to_use          <28>
[149666.765110]   next_to_clean        <7e>
[149666.765110] buffer_info[next_to_clean]
[149666.765110]   time_stamp           <8e6db6a>
[149666.765110]   next_to_watch        <7e>
[149666.765110]   jiffies              <8e6e27f>
[149666.765110]   next_to_watch.status <1>
[149668.629051] e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
[149668.629056]   Tx Queue             <0>
[149668.629058]   TDH                  <1b>
[149668.629060]   TDT                  <1b>
[149668.629062]   next_to_use          <1b>
[149668.629064]   next_to_clean        <f1>
[149668.629066] buffer_info[next_to_clean]
[149668.629068]   time_stamp           <8e6e4c3>
[149668.629070]   next_to_watch        <f1>
[149668.629072]   jiffies              <8e6e9c7>
[149668.629074]   next_to_watch.status <1>
[149676.606031] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149676.606035]   Tx Queue             <0>
[149676.606037]   TDH                  <9b>
[149676.606038]   TDT                  <9b>
[149676.606039]   next_to_use          <9b>
[149676.606040]   next_to_clean        <f0>
[149676.606042] buffer_info[next_to_clean]
[149676.606043]   time_stamp           <8e7024c>
[149676.606044]   next_to_watch        <f0>
[149676.606046]   jiffies              <8e708eb>
[149676.606047]   next_to_watch.status <1>
[149680.151750] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149680.151750]   Tx Queue             <0>
[149680.151750]   TDH                  <84>
[149680.151750]   TDT                  <84>
[149680.151750]   next_to_use          <84>
[149680.151750]   next_to_clean        <d9>
[149680.151750] buffer_info[next_to_clean]
[149680.151750]   time_stamp           <8e7100d>
[149680.151750]   next_to_watch        <d9>
[149680.151750]   jiffies              <8e716c3>
[149680.151750]   next_to_watch.status <1>
[149680.153751] e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
[149680.153751]   Tx Queue             <0>
[149680.153751]   TDH                  <aa>
[149680.153751]   TDT                  <d2>
[149680.153751]   next_to_use          <d2>
[149680.153751]   next_to_clean        <2d>
[149680.153751] buffer_info[next_to_clean]
[149680.153751]   time_stamp           <8e710db>
[149680.153751]   next_to_watch        <2d>
[149680.153751]   jiffies              <8e716c5>
[149680.153751]   next_to_watch.status <1>
[149702.565549] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149702.565549]   Tx Queue             <0>
[149702.565549]   TDH                  <3c>
[149702.565549]   TDT                  <3c>
[149702.565549]   next_to_use          <3c>
[149702.565549]   next_to_clean        <91>
[149702.565549] buffer_info[next_to_clean]
[149702.565549]   time_stamp           <8e7676e>
[149702.565549]   next_to_watch        <91>
[149702.565549]   jiffies              <8e76e48>
[149702.565549]   next_to_watch.status <1>
[149708.020581] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149708.020581]   Tx Queue             <0>
[149708.020581]   TDH                  <4c>
[149708.020581]   TDT                  <4c>
[149708.020581]   next_to_use          <4c>
[149708.020581]   next_to_clean        <a1>
[149708.020581] buffer_info[next_to_clean]
[149708.020581]   time_stamp           <8e77cc3>
[149708.020581]   next_to_watch        <a1>
[149708.020581]   jiffies              <8e78394>
[149708.020581]   next_to_watch.status <1>
[149713.864829] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149713.864833]   Tx Queue             <0>
[149713.864835]   TDH                  <b0>
[149713.864836]   TDT                  <b0>
[149713.864837]   next_to_use          <b0>
[149713.864839]   next_to_clean        <5>
[149713.864840] buffer_info[next_to_clean]
[149713.864841]   time_stamp           <8e7937b>
[149713.864842]   next_to_watch        <5>
[149713.864844]   jiffies              <8e79a64>
[149713.864845]   next_to_watch.status <1>
[149759.710721] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149759.710726]   Tx Queue             <0>
[149759.710729]   TDH                  <88>
[149759.710730]   TDT                  <88>
[149759.710732]   next_to_use          <88>
[149759.710734]   next_to_clean        <dd>
[149759.710736] buffer_info[next_to_clean]
[149759.710738]   time_stamp           <8e8465c>
[149759.710740]   next_to_watch        <dd>
[149759.710742]   jiffies              <8e84d6f>
[149759.710744]   next_to_watch.status <1>
[149759.712712] e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
[149759.712715]   Tx Queue             <0>
[149759.712717]   TDH                  <84>
[149759.712719]   TDT                  <90>
[149759.712721]   next_to_use          <90>
[149759.712723]   next_to_clean        <e5>
[149759.712725] buffer_info[next_to_clean]
[149759.712726]   time_stamp           <8e84782>
[149759.712728]   next_to_watch        <e5>
[149759.712730]   jiffies              <8e84d71>
[149759.712732]   next_to_watch.status <1>
[149768.334753] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149768.334757]   Tx Queue             <0>
[149768.334758]   TDH                  <92>
[149768.334760]   TDT                  <92>
[149768.334761]   next_to_use          <92>
[149768.334762]   next_to_clean        <e7>
[149768.334764] buffer_info[next_to_clean]
[149768.334765]   time_stamp           <8e86829>
[149768.334766]   next_to_watch        <e7>
[149768.334767]   jiffies              <8e86f1c>
[149768.334769]   next_to_watch.status <1>
[149776.537825] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[149776.537825]   Tx Queue             <0>
[149776.537825]   TDH                  <4e>
[149776.537825]   TDT                  <4e>
[149776.537825]   next_to_use          <4e>
[149776.537825]   next_to_clean        <a3>
[149776.537825] buffer_info[next_to_clean]
[149776.537825]   time_stamp           <8e8882b>
[149776.537825]   next_to_watch        <a3>
[149776.537825]   jiffies              <8e88f21>
[149776.537825]   next_to_watch.status <1>
