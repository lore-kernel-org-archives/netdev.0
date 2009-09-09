From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Wed, 9 Sep 2009 06:12:39 -0700 (PDT)
Message-ID: <313388.35529.qm@web111617.mail.gq1.yahoo.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com> <1252376168.5244.11.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from n2a.bullet.mail.ac4.yahoo.com ([76.13.13.65]:29690 "HELO
	n2a.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750910AbZIINSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 09:18:00 -0400
In-Reply-To: <1252376168.5244.11.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I did an experiment. It seems that something is wrong.



>> (1) Could I use  pedit action to modify the dst MAC, so the destination node D will accept it, 
>> then forward it to node C?  

>Yes, you can achieve it with pedit; 
>it is as usable as u32 is - you have to know your offsets
>example, here's something done on an incoming packet:
=-=
#Note:
#dst MAC starts at -14
#src MAC at -8
#ethertype at -2
#
>
>

  A
 /  \
B  D
 \  /
  C
A: eth0,  IP 192.168.1.242
     waln1,  IP 192.168.2.200  ,MAC  00 23 cd af d0 74

D:  wlan1, IP  192.168.2.11, MAC 00 23 cd af ec da
     wlan2, IP 192.168.4.11

On node A,
1) run 'tc qdisc add dev eth0 handle 1: root prio'

2) run 'tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
match ip src 192.168.1.0/24 flowid 1:16 \
action mirred egress mirror dev wlan1'

Node A sent some packets to C. (path: A-B-C)
I can use 'tcpdump -i wlan1 -e' to capture the packets from eth0  (node A),  but I can't forward the mirroring packets to D, (then D forwards them to C).

3 ) run 'tc filter del dev eth0 parent 1: protocol ip prio 10 u32'
then,
'tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
match ip src 192.168.1.0/32 flowid 1:16 \
action pedit munge offset -14 u16 set 0x0023 \
munge offset -12 u32 set 0xcdafecda \
munge offset -8 u32 set 0x0023cdaf \
munge offset -4 u32 set 0xd0740800 pipe \
action mirred egress mirror dev wlan1'

After run 'tcpdump -i wlan1 -e', I can not capture any packets.
I change 'mirror' to 'redirect'   ('action mirred egress mirror dev wlan1'),  also capture nothing.
Why?

BTW,
'uname -a'
Linux fedora 2.6.27.30-170.2.82.fc10.i686 #1 SMP Mon Aug 17 08:38:59 EDT 2009
i686 i686 i386 GNU/Linux
iproute2:
iproute-2.6.27-2.fc10.i386


regards,
wu


      

