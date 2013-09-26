From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net v5 1/1] xen-netback: Handle backend state
 transitions in a more robust way
Date: Thu, 26 Sep 2013 12:05:30 +0100
Message-ID: <1380193530.29483.67.camel@kazak.uk.xensource.com>
References: <1380103168-12067-1-git-send-email-paul.durrant@citrix.com>
	 <1380103168-12067-2-git-send-email-paul.durrant@citrix.com>
	 <1380190642.29483.44.camel@kazak.uk.xensource.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD0114155@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54224 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756353Ab3IZLFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 07:05:33 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0114155@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 11:51 +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: Ian Campbell
> > Sent: 26 September 2013 11:17
> > To: Paul Durrant
> > Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David=
 Vrabel
> > Subject: Re: [PATCH net v5 1/1] xen-netback: Handle backend state
> > transitions in a more robust way
> >=20
> > On Wed, 2013-09-25 at 10:59 +0100, Paul Durrant wrote:
> > > When the frontend state changes netback now specifies its desired=
 state
> > to
> > > a new function, set_backend_state(), which transitions through an=
y
> > > necessary intermediate states.
> > > This fixes an issue observed with some old Windows frontend drive=
rs
> > where
> > > they failed to transition through the Closing state and netback w=
ould not
> > > behave correctly.
> >=20
> > I'm somewhat terrified of breaking compatibility with some old or
> > obscure frontend here. I don't think it is reasonable to try and te=
st
> > all of those so I guess we'll just have to deal with that when it
> > happens...
> >=20
> > > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > > Cc: Ian Campbell <ian.campbell@citrix.com>
> > > Cc: Wei Liu <wei.liu2@citrix.com>
> > > Cc: David Vrabel <david.vrabel@citrix.com>
> > > ---
> > >  drivers/net/xen-netback/xenbus.c |  143
> > ++++++++++++++++++++++++++++++--------
> > >  1 file changed, 113 insertions(+), 30 deletions(-)
> > >
> > > diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> > netback/xenbus.c
> > > index a53782e..01329b2 100644
> > > --- a/drivers/net/xen-netback/xenbus.c
> > > +++ b/drivers/net/xen-netback/xenbus.c
> > > @@ -24,6 +24,7 @@
> > >  struct backend_info {
> > >  	struct xenbus_device *dev;
> > >  	struct xenvif *vif;
> > > +	enum xenbus_state state;
> >=20
> > This cannot just be read from xenstore because of the
> > wait-for-hotplug-script deferral stuff, right?
> >=20
>=20
> Yes, that's right.
>=20
> > I'm not sure it is worth clarifying that, either by a comment or by
> > naming it deferred_state_change or something?
> >=20
>=20
> It=E2=80=99s the xenbus state that's deferred, the backend state lead=
s so I
> could name it 'desired_state' or 'target_state' perhaps; probably a
> bit ugly so I'll add a comment above that field I think.

OK.

>=20
> > > -static void destroy_backend(struct xenbus_device *dev)
> > > +static void backend_connect(struct backend_info *be)
> > >  {
> > > -	struct backend_info *be =3D dev_get_drvdata(&dev->dev);
> > > +	if (be->vif)
> > > +		connect(be);
> > > +}
> > >
> > > -	if (be->vif) {
> > > -		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
> > > -		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
> > > -		xenvif_free(be->vif);
> > > -		be->vif =3D NULL;
> >=20
> > Where did this uevent offlining functionality end up?
> >=20
>=20
> It's done in netback_remove() .
>=20
> > > +static inline void backend_switch_state(struct backend_info *be,
> > > +					enum xenbus_state state)
> > > +{
> > > +	struct xenbus_device *dev =3D be->dev;
> > > +
> > > +	pr_debug("%s -> %s\n", dev->nodename, xenbus_strstate(state));
> > > +	be->state =3D state;
> > > +
> > > +	/* If we are waiting for a hotplug script then defer the
> > > +	 * actual xenbus state change.
> >=20
> > Is the right/wise regardless of the state we are moving too? Might =
the
> > state change have effectively "cancelled" the need to wait for the
> > script?
> >=20
> > The previous code only deferred when moving to Connected. If we are=
 now
> > moving to Closed/Closing do we still need to wait?
> >=20
>=20
> I debated about this; we never really dealt with this before. I think
> it's legitimate for the frontend to give up waiting for a backend
> hotplug so we should be able to go from InitWait to Closing, so in
> this case be->state will be Closing when the script (hopefully)
> finishes. Thus we move to that when the watch fires rather than to
> Connected. Then the frontend can move to Closed. If the hotplug scrip=
t
> never finishes then I don't think we're any more screwed than we were
> before.

OK.
