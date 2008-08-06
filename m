From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 6 Aug 2008 13:21:18 +0300
Message-ID: <200808061321.19560.denys@visp.net.lb>
References: <200808060042.53503.denys@visp.net.lb> <1218017085.4755.23.camel@localhost>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_fsXmI01fl8qI3dC"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:47872 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbYHFKWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:22:06 -0400
In-Reply-To: <1218017085.4755.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_fsXmI01fl8qI3dC
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 06 August 2008, jamal wrote:
>
> Indeed there seems to be an issue here, but:
> Have you tried in your batch with a few "index"ed parameters to ipt with
> your fix? I think it will break with your changes. Of course that does
> not invalidate your concern. If you send me a two liner batch example
> which breaks for you, I will test it.
not sure about two lines
attaching example batch

>
> > 2)Since target->t = fw_calloc(1, size); allocated memory in function
> > build_st, it have to be freed at the end, or in batch we will have memory
> > leak. TODO: Probably it must be freed in all "return -1" cases in
> > parse_ipt after build_st. About this i am not sure, up to Stephen.
> >
> > 3)lname and new_name was malloc'ed, but not freed
> >
> > Point 1 fix is critical, since without it m_ipt crashing iproute2 in
> > batch mode.
>
> I think #2 and #3 are leggit. Send two patches - one for #1 when you
> validate and the other for #2,#3 when you validate. BTW, for the
> equivalent of the latter - if you feel brave - theres a lot more of that
> type in the tc code.
#1 is validated 100%, because i was not able to run tc in batch mode for my 
tasks(2nd or 3rd ipt rule will crash), till i implement those patches. The 
batch i gave is short version, full version have around 11k lines. But it 
crashes usually max on 2rd or 3nd ipt.

Well, i can fix what i can sniff&smell in my daily job, and especially if i 
hit a wall because of some code :-) For me it is difficult to inspect the 
code, since i am very weak in C, but i will try. 



--Boundary-00=_fsXmI01fl8qI3dC
Content-Type: text/x-java;
  charset="koi8-r";
  name="batch.example"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="batch.example"

filter del dev ifb0 protocol ip pref 100
class del dev ifb0 classid 1:100 
qdisc del dev ppp0 root
qdisc add dev ppp0 root handle 1: prio
qdisc add dev ppp0 parent 1:1 handle 2: est 1sec 8sec tbf buffer 2048000 latency 500ms rate 256000bit peakrate 1280000bit mtu 1512
filter add dev ppp0 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.24/32 flowid 3:1
filter add dev ppp0 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.26/32 flowid 3:1
filter add dev ppp0 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.6/32 flowid 3:1
filter add dev ppp0 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.19/32 flowid 3:1
filter add dev ppp0 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.102/32 flowid 3:1
filter add dev ppp0 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.105/32 flowid 3:1
filter add dev ppp0 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.106/32 flowid 3:1
filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 match ip dst 0.0.0.0/0 flowid 2:1
class add dev ifb0 classid 1:100 parent 1:0 htb rate 56000bit quantum 1600
qdisc add dev ifb0 parent 1:100 handle 100: bfifo limit 14000
filter add dev ifb0 protocol ip pref 100 parent 1: handle 100 fw classid 1:100
qdisc del dev ppp0 ingress
qdisc add dev ppp0 ingress
filter add dev ppp0 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.102/32 flowid 1:1
filter add dev ppp0 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.105/32 flowid 1:1
filter add dev ppp0 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.106/32 flowid 1:1
filter add dev ppp0 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.24/32 flowid 1:1
filter add dev ppp0 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.6/32 flowid 1:1
filter add dev ppp0 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.26/32 flowid 1:1
filter add dev ppp0 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.19/32 flowid 1:1
filter add dev ppp0 parent ffff: protocol ip prio 10 u32 match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark 100 action mirred egress redirect dev ifb0
filter del dev ifb0 protocol ip pref 101
class del dev ifb0 classid 1:101 
qdisc del dev ppp1 root
qdisc add dev ppp1 root handle 1: prio
qdisc add dev ppp1 parent 1:1 handle 2: est 1sec 8sec tbf buffer 2048000 latency 500ms rate 256000bit peakrate 1280000bit mtu 1512
filter add dev ppp1 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.24/32 flowid 3:1
filter add dev ppp1 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.26/32 flowid 3:1
filter add dev ppp1 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.6/32 flowid 3:1
filter add dev ppp1 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.19/32 flowid 3:1
filter add dev ppp1 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.102/32 flowid 3:1
filter add dev ppp1 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.105/32 flowid 3:1
filter add dev ppp1 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.106/32 flowid 3:1
filter add dev ppp1 parent 1:0 protocol ip prio 10 u32 match ip dst 0.0.0.0/0 flowid 2:1
class add dev ifb0 classid 1:101 parent 1:0 htb rate 56000bit quantum 1600
qdisc add dev ifb0 parent 1:101 handle 101: bfifo limit 14000
filter add dev ifb0 protocol ip pref 101 parent 1: handle 101 fw classid 1:101
qdisc del dev ppp1 ingress
qdisc add dev ppp1 ingress
filter add dev ppp1 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.102/32 flowid 1:1
filter add dev ppp1 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.105/32 flowid 1:1
filter add dev ppp1 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.106/32 flowid 1:1
filter add dev ppp1 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.24/32 flowid 1:1
filter add dev ppp1 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.6/32 flowid 1:1
filter add dev ppp1 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.26/32 flowid 1:1
filter add dev ppp1 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.19/32 flowid 1:1
filter add dev ppp1 parent ffff: protocol ip prio 10 u32 match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark 101 action mirred egress redirect dev ifb0
filter del dev ifb0 protocol ip pref 110
class del dev ifb0 classid 1:110 
qdisc del dev ppp10 root
qdisc add dev ppp10 root handle 1: prio
qdisc add dev ppp10 parent 1:1 handle 2: est 1sec 8sec tbf buffer 2048000 latency 500ms rate 256000bit peakrate 1280000bit mtu 1512
filter add dev ppp10 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.24/32 flowid 3:1
filter add dev ppp10 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.26/32 flowid 3:1
filter add dev ppp10 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.6/32 flowid 3:1
filter add dev ppp10 parent 1:0 protocol ip prio 5 u32 match ip src 194.146.153.19/32 flowid 3:1
filter add dev ppp10 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.102/32 flowid 3:1
filter add dev ppp10 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.105/32 flowid 3:1
filter add dev ppp10 parent 1:0 protocol ip prio 5 u32 match ip src 2.2.2.106/32 flowid 3:1
filter add dev ppp10 parent 1:0 protocol ip prio 10 u32 match ip dst 0.0.0.0/0 flowid 2:1
class add dev ifb0 classid 1:110 parent 1:0 htb rate 56000bit quantum 1600
qdisc add dev ifb0 parent 1:110 handle 110: bfifo limit 14000
filter add dev ifb0 protocol ip pref 110 parent 1: handle 110 fw classid 1:110
qdisc del dev ppp10 ingress
qdisc add dev ppp10 ingress
filter add dev ppp10 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.102/32 flowid 1:1
filter add dev ppp10 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.105/32 flowid 1:1
filter add dev ppp10 parent ffff: protocol ip prio 5 u32 match ip dst 2.2.2.106/32 flowid 1:1
filter add dev ppp10 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.24/32 flowid 1:1
filter add dev ppp10 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.6/32 flowid 1:1
filter add dev ppp10 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.26/32 flowid 1:1
filter add dev ppp10 parent ffff: protocol ip prio 5 u32 match ip dst 194.146.153.19/32 flowid 1:1
filter add dev ppp10 parent ffff: protocol ip prio 10 u32 match u32 0 0 flowid 1:1 action ipt -j MARK --set-mark 110 action mirred egress redirect dev ifb0

--Boundary-00=_fsXmI01fl8qI3dC--
