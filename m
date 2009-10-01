From: Lars Ellenberg <lars.ellenberg@linbit.com>
Subject: Re: [PATCH] connector: Allow permission checking in the receiver
	callbacks
Date: Thu, 1 Oct 2009 10:01:52 +0200
Message-ID: <20091001080152.GA8018@barkeeper1-xen.linbit>
References: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com> <20090930112057.GA15150@ioremap.net> <20090930132034.GE8032@barkeeper1-xen.linbit> <20090930192928.GA1315@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Philipp Reisner <philipp.reisner@linbit.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755821AbZJAIBv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090930192928.GA1315@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2009 at 11:29:28PM +0400, Evgeniy Polyakov wrote:
> On Wed, Sep 30, 2009 at 03:20:35PM +0200, Lars Ellenberg (lars.ellenb=
erg@linbit.com) wrote:
> > Actually it is the basis for follow-up security fixes.
> >=20
> > Without this, unprivileged user space is able to send arbitrary
> > connector requests to kernel subsystems, which have no way to verif=
y the
> > privileges of the sender anymore, because that information, even th=
ough
> > available at the netlink layer, has been dropped by the connector.
>=20
> It is not. One can add some checks at receiving time which happens in
> process context to get its credentials, but nothing in netlink itself
> carry this info. Getting that connector schedules workqueue this abil=
ity
> is lost.

Please correct me if I'm wrong.

My understanding is, that in netlink_sendmsg, the credentials and
capabilities are copied into skb->cb.
During kernel side receive, these can be checked.

If we pass the skb, instead of just the msg, then even an asynchronousl=
y
scheduled receive callback, running in any workqueue or other context,
can check for these credentials.

Passing skb instead of just the msg for use in cn_queue_wrapper
is what the fist patch does.

Second patch changes the semantics of the actual callback
to be passed in the msg _and_ the netlink_skb_parms, both
"reconstructed" from the skb.

Now, in the end-user callback, there is the actual msg,
but also the netlink_skb_parms.
So this enables the end-user callback, running in arbitrary context,
to check capabilities and other credentials of the sending process.


> > Once this is applied, the various in-kernel receiving connector
> > callbacks can (and need to) add cap_raised(nsb->eff_cap, cap) where
> > appropriate. For example, you don't want some guest user to be able=
 to
> > trigger a dst_del_node callback by sending a crafted netlink messag=
e,
> > right?
> >=20
> > So it _is_ a (design-) bug fix.
> > Or am I missing something?
>=20
> This patchset is not a bugfix, just a cleanup, since none in patchset
> uses netlink_skb_parms

3. and 4. patch are in fact merely cleanups.

> and currently I see no users which are affected
> by this behaviour in the mainline branch (not counting staging tree).
>=20
> But if proposed configuration changes for DM are on the way, then I
> agree and they should force this patchset into the tree as a bugfix.
>=20
> --=20
> 	Evgeniy Polyakov
>=20

--=20
: Lars Ellenberg
: LINBIT | Your Way to High Availability
: DRBD/HA support and consulting http://www.linbit.com

DRBD=AE and LINBIT=AE are registered trademarks of LINBIT, Austria.
