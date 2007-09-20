From: Frithjof Hammer <mail@frithjof-hammer.de>
Subject: Re: ifb and ppp
Date: Thu, 20 Sep 2007 16:00:14 +0200
Message-ID: <200709201600.15202.mail@frithjof-hammer.de>
References: <200709191417.43768.mail@frithjof-hammer.de>
	<46F25F9A.7010007@trash.net> <1190294388.4734.6.camel@localhost>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_vzn8GCACSzCDWqq"
Cc: lartc@mailman.ds9a.nl, Linux Netdev List <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <1190294388.4734.6.camel@localhost>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

--Boundary-00=_vzn8GCACSzCDWqq
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

> Sorry, I didnt follow the thread - what is the goal to be achieved with
> the setup?

A simple ingress shaping on ppp0 (PPPOE DSL line). I want to replace my old 
imq ingress shaper in favor of ifb. My former script used iptables marks  to 
classify the packets. My iptables marks are getting set, as like before with 
imq. But tc seems not to recognize them: It only uses the default class.

So i run tcpdump -i ifb0  and discovered that the packets seems to be still 
encapsulated on ifb0. I suppose this is why my iptables stuff is not working.

I've attached the ingress part of my shaping script. 

Thanks for your help
Frithjof

--Boundary-00=_vzn8GCACSzCDWqq
Content-Type: text/plain; charset="utf-8"; name="trafficshaping_ifb.sh.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="trafficshaping_ifb.sh.txt"


 
tc qdisc del dev ppp0 root    2> /dev/null > /dev/null
tc qdisc del dev ifb0 root 2> /dev/null > /dev/null
tc qdisc del dev ppp0 ingress

 modprobe ifb
 ifconfig ifb0 up

 tc qdisc add dev ppp0 ingress
 tc filter add dev ppp0 parent ffff: protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress redirect dev ifb0

 tc qdisc add dev ifb0 handle 1: root hfsc default 32
 tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 6000kbit ul rate 6000kbit

 tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 208b dmax 20ms rate 83kbit ls rate 120kbit
 tc class add dev ifb0 parent 1:1 classid 1:31 hfsc sc rate $[(6000-120)/3]kbit ul rate 6000kbit
 tc class add dev ifb0 parent 1:1 classid 1:32 hfsc sc rate $[(6000-120)/3*2]kbit ul rate  6000kbit

 tc qdisc add dev ifb0 parent 1:30 handle 30: sfq perturb 10
 tc qdisc add dev ifb0 parent 1:31 handle 31: sfq perturb 10
 tc qdisc add dev ifb0 parent 1:32 handle 32: red limit 1000000 min 5000 max 100000 avpkt 1000 burst 50

 tc filter add dev ifb0 parent 1:0 prio 0 protocol ip handle 30 fw flowid 1:30
 tc filter add dev ifb0 parent 1:0 prio 0 protocol ip handle 31 fw flowid 1:31
 tc filter add dev ifb0 parent 1:0 prio 0 protocol ip handle 32 fw flowid 1:32


 iptables -t mangle -N MYSHAPER-IN
 iptables -t mangle -I PREROUTING -i ppp0 -j MYSHAPER-IN

 iptables -t mangle -A MYSHAPER-IN -p tcp -m length --length :64 -j MARK --set-mark 31 # short TCP packets are probably ACKs
 iptables -t mangle -A MYSHAPER-IN -p tcp --dport 22 -m length --length :500 -j MARK --set-mark 3    # secure shell
 iptables -t mangle -A MYSHAPER-IN -p tcp --sport 22 -m length --length :500 -j MARK --set-mark 31    # secure shell
 iptables -t mangle -A MYSHAPER-IN -p ! tcp -j MARK --set-mark 31              # Set non-tcp packets to high priority
 iptables -t mangle -A MYSHAPER-IN -m mark --mark 0 -j MARK --set-mark 32              # redundant- mark any unmarked packets as 26 (low prio)

[...]
--Boundary-00=_vzn8GCACSzCDWqq
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
LARTC mailing list
LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc

--Boundary-00=_vzn8GCACSzCDWqq--
