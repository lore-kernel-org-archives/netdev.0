From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.35 -> 2.6.36 panic when vlan and promisc with tg3
Date: Tue, 30 Nov 2010 14:27:22 -0800
Message-ID: <AANLkTik8Wn5B9Ovn5yp5fR+Y=CyfXkqta7JpaN6EqsvE@mail.gmail.com>
References: <20101129201716.1d0257c4@xenia.leun.net>
	<4CF442FA.4070701@candelatech.com>
	<20101130095944.41b5f7b6@xenia.leun.net>
	<1291108809.2904.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Leun <lkml20101129@newton.leun.net>,
	Ben Greear <greearb@candelatech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291108809.2904.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 30, 2010 at 1:20 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 30 novembre 2010 =E0 09:59 +0100, Michael Leun a =E9crit :
>> On Mon, 29 Nov 2010 16:19:06 -0800
>> Ben Greear <greearb@candelatech.com> wrote:
>>
>> > On 11/29/2010 11:17 AM, Michael Leun wrote:
>> > > UG: unable to handle kernel paging request at 01cc921c
>> > > IP: [<c034bfce>] vlan_hwaccel_do_receive+0x59/0xd0
>> > > *pdpt =3D 0000000036a2a001 *pde =3D 0000000000000000
>> > > Oops: 0002 [#1] SMP
>> > > last sysfs
>> > >
>> > > Then machine dead.
>> > >
>> > > In 2.6.35.x this did not happen (but vlans broken - cannot see v=
lan
>> > > tags with tcpdump),
>> >
>> > Try this patch:
>> >
>> > http://permalink.gmane.org/gmane.linux.network/176566
>> >
>> > It looks like this hasn't made it into stable yet?
>>
>> > > To reproduce:
>> > >
>> > > ip link set eth0 up
>> > > vconfig add eth0 2
>> > > ip link set eth0 promisc on
>>
>> It makes it better - it does not crash anymore on this commands - bu=
t
>> if you add an "tcpdump -i eth0 -n" at the end it does. So,
>> unfortunately no real solution.
>>
>> I guess, "dropping packet no one is interested in" (as noted in the
>> patch) does not work very well if tcpdump is actually interested?
>>
>
> Could you try with following patch instead, for net/core/dev.c
>
> (and keep the net/8021q/vlan_core.c part)
>
> --- net/core/dev.c.orig
> +++ net/core/dev.c
> @@ -2891,6 +2891,9 @@
> =A0ncls:
> =A0#endif
>
> + =A0 =A0 =A0 if (unlikely(vlan_tx_tag_present(skb)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bypass;
> +
> =A0 =A0 =A0 =A0/* Handle special case of bridge or macvlan */
> =A0 =A0 =A0 =A0rx_handler =3D rcu_dereference(skb->dev->rx_handler);
> =A0 =A0 =A0 =A0if (rx_handler) {
> @@ -2927,6 +2930,7 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> +bypass:
> =A0 =A0 =A0 =A0if (pt_prev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D pt_prev->func(skb, skb->dev, p=
t_prev, orig_dev);
> =A0 =A0 =A0 =A0} else {

Hmm, it looks like I forgot an else between pt_prev->func() and
kfree_skb() in my patch.  Yours is cleaner, so I like it better
anyways (assuming it fixes the problem).

Thanks.
