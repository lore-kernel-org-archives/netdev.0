From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [RFC PATCH 08/13] xen-netback: clone skb if skb->xmit_more is
 set
Date: Fri, 22 May 2015 17:14:24 +0000
Message-ID: <2115674C-AC21-4EF2-AA96-28F670102C81@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-9-git-send-email-joao.martins@neclab.eu>
 <20150519153613.GG26335@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:38487 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946041AbbEVROl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 13:14:41 -0400
In-Reply-To: <20150519153613.GG26335@zion.uk.xensource.com>
Content-Language: en-US
Content-ID: <32AB5E9973A5F444BFD5A03E9DBCDC6B@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 May 2015, at 17:36, Wei Liu <wei.liu2@citrix.com> wrote:

> On Tue, May 12, 2015 at 07:18:32PM +0200, Joao Martins wrote:
>> On xenvif_start_xmit() we have an additional queue to the netback RX
>> kthread that will sends the packet. When using burst>1 pktgen sets
>> skb->xmit_more to tell the driver that there more skbs in the queue.
>> However, pktgen transmits the same skb <burst> times, which leads to
>> the BUG below. Long story short adding the same skb in the rx_queue
>> queue leads to crash. Specifically, having pktgen running with burst=
=3D2
>> what happens is: when we queue the second skb (that is the same as
>> the first queued skb), the list will have the tail element with skb-=
>prev
>> which is the skb itself. On skb_unlink (i.e. when dequeueing the skb=
)
>> skb->prev will become NULL, but still having list->next pointing to =
the
>> unlinked skb. Because of this skb_peek will still return an skb, whi=
ch
>> will redo the skb_unlink trying to set (skb->prev)->next where skb->=
prev
>> is now NULL, thus leading to the crash (trace below).
>>=20
>=20
> From your description this doesn't sound Xen specific. Sounds like
> pktgen breaks in any driver that has an internal queue, which is plen=
ty.
Yes, it=92s only on drivers with an internal queue.

>> I'm not sure what the best way to fix this but since it's only happe=
ning
>> when we use pktgen with burst>1: I chose doing an skb_clone when we =
don't
>> use persistent grants and skb->xmit_more flag is set, and when
>> CONFIG_NET_PKTGEN is compiled builtin.
>>=20
>=20
> I don't think we should do this.
Ok, I will remove this one out then.=20
Part of the reason I submitted it was to make you aware of the crash.

Joao
