From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Thu, 4 Dec 2014 15:23:25 -0800
Message-ID: <CAEP_g=9AH_RShKujVeUmty6BKPJZt=u_-h8NnUL1kX+tSYdBxQ@mail.gmail.com>
References: <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org> <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com> <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com> <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org> <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
 <548011DE.4000208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Du Fan <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog009.obsmtp.com ([74.125.150.58]:37564 "HELO
	na6sys009bog009.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753069AbaLDXXq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 18:23:46 -0500
Received: by mail-qc0-f169.google.com with SMTP id w7so13693202qcr.14
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 15:23:45 -0800 (PST)
In-Reply-To: <548011DE.4000208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 3, 2014 at 11:48 PM, Du Fan <fengyuleidian0615@gmail.com> w=
rote:
> =E4=BA=8E 2014=E5=B9=B412=E6=9C=8804=E6=97=A5 06:51, Jesse Gross =E5=86=
=99=E9=81=93:
>>
>> My proposal would be something like this:
>>   * For L2, reduce the VM MTU to the lowest common denominator on th=
e
>> segment.
>>   * For L3, use path MTU discovery or fragment inner packet (i.e.
>> normal routing behavior).
>>   * As a last resort (such as if using an old version of virtio in t=
he
>> guest), fragment the tunnel packet.
>
>
> After some investigation on OpenvSwitch package, it seems before this
> commit: 06021dcb "datapath: compat: Fix compilation 3.11" OpenvSwitch
> package is doing GSO on its own.
>
> rpl_ip_local_out
>   -> tnl_skb_gso_segment
>       ^^^^^^^^^^^^^^^
>          Perform GSO  in above function
>     -> ip_local_out
>           .
>           .
>         -> ip_finish_output
>
> Which means, when over-MTU-sized skb enter ip_local_out, it's not a g=
so
> type skb, so the stack perform ip fragmentation, and send them out.
> So, over-MTU-sized skb did travel through stack into outside.
>
> Why not dropping such OpenvSwitch level GSO operation after 3.10?

The change in 3.11 was that the tunnel infrastructure used by OVS was
upstreamed and shared by all implementations. It's not right to
perform GSO in OVS itself as it prevents the logic from being used by
other components. Breaking up the packet in OVS also eliminates some
of the benefits of GSO by shortening the optimized path and prevents
offloading to hardware.
