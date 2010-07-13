From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 15:28:50 +0200
Message-ID: <20100713132849.GB2641@sortiz-mobl>
References: <20100713001115.GA3751@sortiz-mobl>
 <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 13, 2010 at 02:18:26PM +0800, Changli Gao wrote:
> On Tue, Jul 13, 2010 at 8:11 AM, Samuel Ortiz <sameo@linux.intel.com>=
 wrote:
> >
> > The userspace notification Xtables target sends a netlink notificat=
ion
> > whenever a packet hits the target. Notifications have a label attri=
bute
> > for userspace to match it against a previously set rule. The rules =
also
> > take a --all option to switch between sending a notification for al=
l
> > packets or for the first one only.
> > Userspace can also send a netlink message to toggle this switch whi=
le the
> > target is in place. This target uses the nefilter netlink framework=
=2E
> >
> > This target combined with various matches (quota, rateest, etc..) a=
llows
> > userspace to make decisions on interfaces handling. One could for e=
xample
> > decide to switch between power saving modes depending on estimated =
rate
> > thresholds.
> >
>=20
> It much like the following iptables rules.
>=20
> iptables -N log_and_drop
> iptables -A log_and_drop -j NFLOG --nflog-group 1 --nflog-prefix "log=
_and_drop"
> iptables -A log_and_drop -j DROP
>=20
> ...
> iptables ... -m quota --quota-bytes 20000 -j log_and_drop
> ...
We'd still be missing the possibility of having only the first packet l=
ogged,
and we'd have to also send an initial netlink message to switch the cop=
y_mode
to COPY_NONE. We're not interested in the actual packet, but just by th=
e match
hit.
I know it's not big deal after all, I'm just trying to have one simple =
target
for that simple task of notifying userspace of a match hit.

> > +static unsigned int nfnotif_tg_target(struct sk_buff *skb,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 const struct xt_action_param *par)
> > +{
> > + =A0 =A0 =A0 const struct nfnotif_tg_info *info =3D par->targinfo;
> > +
> > + =A0 =A0 =A0 BUG_ON(!info->notif);
> > +
> > + =A0 =A0 =A0 if (!info->notif->send_notif)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return XT_CONTINUE;
> > +
> > + =A0 =A0 =A0 pr_debug("Sending notification for %s\n", info->label=
);
> > +
> > + =A0 =A0 =A0 schedule_work(&info->notif->work);
> > +
>=20
> Why do you use another kernel activity: kernel thread? netlink
> messages can be sent in atomic context.
That's right, I should have used the ATOMIC gfp flags from my sending r=
outine.
I'll fix that with my next revision of the patch.

Thanks for the review.

Cheers,
Samuel.

--=20
Intel Open Source Technology Centre
http://oss.intel.com/
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
