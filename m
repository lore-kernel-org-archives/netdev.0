From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 12 May 2009 22:52:27 +0200
Message-ID: <4A09E18B.3020402@cosmosbay.com>
References: <49C380A6.4000904@cosmosbay.com> <4A092F59.7020900@cosmosbay.com> <4A093178.9020105@cosmosbay.com> <20090512192748.GA2757@ami.dom.local> <4A09D1B4.7070509@cosmosbay.com> <20090512200515.GB2757@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:52034 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880AbZELUwh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 16:52:37 -0400
In-Reply-To: <20090512200515.GB2757@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Tue, May 12, 2009 at 09:44:52PM +0200, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>>> On Tue, May 12, 2009 at 10:21:12AM +0200, Eric Dumazet wrote:
>>>> Eric Dumazet a =E9crit :
>>> ...
>>>>> List of devices that must clear this flag is :
>>>>>
>>>>> - loopback device, because it calls netif_rx() and quoting Patric=
k :
>>>>>     "ip_route_input() doesn't accept loopback addresses, so loopb=
ack packets
>>>>>      already need to have a dst_entry attached."
>>>>> - appletalk/ipddp.c : needs skb->dst in its xmit function
>>>>>
>>>>> - And all devices that call again dev_queue_xmit() from their xmi=
t function
>>>>> (as some classifiers need skb->dst) : bonding, macvlan, eql, ifb,=
 hdlc_fr
>>> Why not vlan (and/or maybe others in net/ using dev_queue_xmit)?
>>>
>> Yes I spoted vlan earlier this afternoon.
>>
>> For other net/*, I didnt not find candidates yet.
>=20
> Hmm..., if vlan, then why not pppoe (and/or maybe others in drivers/n=
et/
> using dev_queue_xmit)?
>=20

As I said, I didnt found other relevant uses, but I am probably wrong :=
)

About ppoe for example, two calls to dev_queue_xmit() are not relevant.

One is from=20

static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
          struct msghdr *m, size_t total_len)

This is a normal direct call, not a call from its ndo_start_xmit()

Second one is from

static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)

Same observation, there is no impact for this one as well.



So we have to care on device drivers that have a ndo_start_xmit() call =
that could
re-enter dev_queue_xmit(). Not care about drivers that call dev_queue_x=
mit() from
other paths.

