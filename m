From: "Denys" <denys@visp.net.lb>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 4 Apr 2007 15:56:51 +0300
Message-ID: <20070404125231.M65138@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb> <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net> <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:40893 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843AbXDDN4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 09:56:46 -0400
In-Reply-To: <1175684114.4088.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Well, my case is my own mistake, i guess it is just misconfiguration, not 
actual bug. And also it is good push for me "read doc's and think well before 
adding rules".
Maybe it can be in TODO, but it is not N1 priority i guess. There is more 
important things, what u want to do. Another thing, adding one more field in 
skb will add more overhead to whole kernel(i guess).

I have some interesting thing:

Rules:
tc qdisc del dev eth0.5 root
tc qdisc add dev eth0.5 handle 1: root htb
tc class add dev eth0.5 parent 1:0 classid 1:2 htb rate 128Kbit

tc qdisc add dev eth0.5 parent 1:2 handle 2: prio

tc filter add dev eth0.5 parent 1: protocol ip prio 10 u32 \
match ip src 195.69.208.253/32 flowid 1:2

tc filter add dev eth0.5 parent 2: protocol ip prio 10 u32 \
    match ip src 195.69.208.253/32 flowid 2:1 \
    action mirred egress redirect dev eth0.6

(it is not working, but just i tried few things)

At morning i wakeup and see in dmesg, also not sure if it's bug or result of 
misconfiguration:

[46632.941527] KERNEL: assertion (!cl->level && cl->un.leaf.q && cl-
>un.leaf.q->q.qlen) failed at net/sched/sch_htb.c (585)
[46633.270732] KERNEL: assertion (!cl->level && cl->un.leaf.q && cl-
>un.leaf.q->q.qlen) failed at net/sched/sch_htb.c (585)
[46633.379446] KERNEL: assertion (!cl->level && cl->un.leaf.q && cl-
>un.leaf.q->q.qlen) failed at net/sched/sch_htb.c (585)
[46633.450751] KERNEL: assertion (!cl->level && cl->un.leaf.q && cl-
>un.leaf.q->q.qlen) failed at net/sched/sch_htb.c (585)
[46633.570702] KERNEL: assertion (!cl->level && cl->un.leaf.q && cl-
>un.leaf.q->q.qlen) failed at net/sched/sch_htb.c (585)



On Wed, 04 Apr 2007 06:55:14 -0400, jamal wrote
> On Wed, 2007-04-04 at 05:11 +0300, Denys wrote:
> > I think this highly useful feature given by jamal, difficult to be 
avoided 
> > from crash, if user not enough experienced in networking(like me). I 
guess 
> > packet can be even not ipv4/ipv6 packet, maybe it can be cloned IPX or 
ARP, 
> > so TTL field cannot be used. I checked maybe sk_buff have some fields, 
seems 
> > also bad luck, if there can be something like "internal" counter for 
packet, 
> > how much times it got redirected, it will help.
> 
> Adding a field in the skb that keeps track of things would work well,
> but would be a controvesial thing to do because it actually requires 
> a vector not just one field. There is a filed called cb[] but it 
> cant be used in this case because every time we redirect it could be 
> trampled.
> 
> > But in my case of VLAN's it 
> > is really my own mistake and difficult to avoid it. Only bad thing - 
machine 
> > got completely locked up, and if it is remote system - it will not oops/
or 
> > reboot even. But i dont have any idea in mind how to avoid this, only 
than 
> > big warning in DOC and internal iproute2 help :-)
> 
> Your case is easy to detect in user space because it is within the same
> policy.
> Would simple detection and rejection in tc/userspace be useful to 
> add? Note, this doesnt help the general problem though where you 
> have nesting as described in the document.
> 
> cheers,
> jamal
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

