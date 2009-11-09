From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Mon, 9 Nov 2009 20:33:07 +0800
Message-ID: <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f195.google.com ([209.85.216.195]:43169 "EHLO
	mail-px0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228AbZKIMdC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 07:33:02 -0500
Received: by pxi33 with SMTP id 33so41247pxi.4
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 04:33:07 -0800 (PST)
In-Reply-To: <1257764086.6246.1.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 9, 2009 at 6:54 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2009-11-09 at 16:31 +0800, Changli Gao wrote:
>
>> code cleanup! :)
>
> I dont really see it as a cleanup to be honest. The code
> is not less ugly even after the change;->
>

static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
                      struct tcf_result *res)
{
        struct net_device *dev;
        struct sk_buff *skb2;
        u32 at;
        struct tcf_mirred *m =3D a->priv;
        int retval, err =3D 1;

        spin_lock(&m->tcf_lock);
        m->tcf_tm.lastuse =3D jiffies;
        if (m->tcfm_eaction !=3D TCA_EGRESS_MIRROR &&
            m->tcfm_eaction !=3D TCA_EGRESS_REDIR) {
                if (net_ratelimit())
                        printk("tcf_mirred unknown action %d\n",
                               m->tcfm_eaction);
                goto out;
        }

        dev =3D m->tcfm_dev;
        if (!(dev->flags&IFF_UP) ) {
                if (net_ratelimit())
                        printk("mirred to Houston: device %s is gone!\n=
",
                               dev->name);
                goto out;
        }

        skb2 =3D skb_act_clone(skb, GFP_ATOMIC);
        if (skb2 =3D=3D NULL)
                goto out;

        m->tcf_bstats.bytes +=3D qdisc_pkt_len(skb2);
        m->tcf_bstats.packets++;
        at =3D G_TC_AT(skb->tc_verd);
        if (!(at & AT_EGRESS)) {
                if (m->tcfm_ok_push)
                        skb_push(skb2, skb2->dev->hard_header_len);
        }

        /* mirror is always swallowed */
        if (m->tcfm_eaction !=3D TCA_EGRESS_MIRROR)
                skb2->tc_verd =3D SET_TC_FROM(skb2->tc_verd, at);

        skb2->dev =3D dev;
        skb2->iif =3D skb->dev->ifindex;
        dev_queue_xmit(skb2);
        err =3D 0;

out:
        if (err) {
                m->tcf_qstats.overlimits++;
                m->tcf_bstats.bytes +=3D qdisc_pkt_len(skb);
                m->tcf_bstats.packets++;
                /* should we be asking for packet to be dropped?
                 * may make sense for redirect case only
                 */
                retval =3D TC_ACT_SHOT;
        } else {
                retval =3D m->tcf_action;
        }
        spin_unlock(&m->tcf_lock);

        return retval;
}

How about this version.

1. move skb_act_clone() after all the necessary checks, and it can
eliminate unnecessary skb_act_clone() if tcfm_eaction isn't correct.
2. there is one exit of the critical section.
3. jump forward instead of backward.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
