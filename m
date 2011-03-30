From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: Re: [PATCH] BRIDGE: As per 802.1D clause 9.3.4 Added
 support to prevent processing port's own BPDU (If a loopback condition
 exists)
Date: Thu, 31 Mar 2011 00:56:41 +0530
Message-ID: <AANLkTim4qxQkXppsanD4z=UY0CRBHPMOd-7R5AS8ioM1@mail.gmail.com>
References: <1301499216-3836-1-git-send-email-sasikanth.v19@gmail.com>
	<20110330092542.6344b324@s6510>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4936309620793594191=="
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20110330092542.6344b324@s6510>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============4936309620793594191==
Content-Type: multipart/alternative; boundary=e0cb4e8877050dbb78049fb828f6

--e0cb4e8877050dbb78049fb828f6
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 30, 2011 at 9:55 PM, Stephen Hemminger <shemminger@vyatta.com>w=
rote:

> On Wed, 30 Mar 2011 21:03:36 +0530
> Sasikanth V <sasikanth.v19@gmail.com> wrote:
>
> >
> > Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
> > ---
> >  net/bridge/br_private.h   |    1 +
> >  net/bridge/br_stp.c       |   20 ++++++++++++++++++--
> >  net/bridge/br_stp_if.c    |    2 ++
> >  net/bridge/br_stp_timer.c |    1 +
> >  4 files changed, 22 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> > index 387013d..d9f79dd 100644
> > --- a/net/bridge/br_private.h
> > +++ b/net/bridge/br_private.h
> > @@ -149,6 +149,7 @@ struct net_bridge_port
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >       struct netpoll                  *np;
> >  #endif
> > +     u8                              is_own_bpdu; /*Port recvd its own
> BPDU*/
> >  };
> >
> >  #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
> > diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> > index 7370d14..491d9c6 100644
> > --- a/net/bridge/br_stp.c
> > +++ b/net/bridge/br_stp.c
> > @@ -107,6 +107,12 @@ static void br_root_selection(struct net_bridge *b=
r)
> >       u16 root_port =3D 0;
> >
> >       list_for_each_entry(p, &br->port_list, list) {
> > +             /*Don't consider the Port for root selection
> > +               which rx'd its own bpdu because of loopback
> > +               in the bridge
> > +              */
> > +             if (p->is_own_bpdu)
> > +                     continue;
> >               if (br_should_become_root_port(p, root_port))
> >                       root_port =3D p->port_no;
> >
> > @@ -278,8 +284,16 @@ static int br_supersedes_port_info(struct
> net_bridge_port *p, struct br_config_b
> >       if (memcmp(&bpdu->bridge_id, &p->br->bridge_id, 8))
> >               return 1;
> >
> > -     if (bpdu->port_id <=3D p->designated_port)
> > +     if (bpdu->port_id <=3D p->designated_port) {
> > +             /*802.1D 9.3.4 Validation of received BPDUs
> > +              NOTE 1=97If the Bridge Identifier and Port Identifier bo=
th
> > +              match the values that would be transmitted in a
> Configuration
> > +              BPDU, the BPDU is discarded to prevent processing of the
> Port=92s
> > +              own BPDUs;*/
> > +             if (bpdu->port_id =3D=3D p->designated_port)
> > +                     p->is_own_bpdu =3D 1;
> >               return 1;
> > +     }
> >
> >       return 0;
> >  }
> > @@ -411,7 +425,7 @@ void br_port_state_selection(struct net_bridge *br)
> >                       p->config_pending =3D 0;
> >                       p->topology_change_ack =3D 0;
> >                       br_make_forwarding(p);
> > -             } else if (br_is_designated_port(p)) {
> > +             } else if (!p->is_own_bpdu && br_is_designated_port(p)) {
> >                       del_timer(&p->message_age_timer);
> >                       br_make_forwarding(p);
> >               } else {
> > @@ -446,6 +460,8 @@ void br_received_config_bpdu(struct net_bridge_port
> *p, struct br_config_bpdu *b
> >       br =3D p->br;
> >       was_root =3D br_is_root_bridge(br);
> >
> > +     p->is_own_bpdu =3D 0;
> > +
> >       if (br_supersedes_port_info(p, bpdu)) {
> >               br_record_config_information(p, bpdu);
> >               br_configuration_update(br);
> > diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> > index 5593f5a..fc4ec63 100644
> > --- a/net/bridge/br_stp_if.c
> > +++ b/net/bridge/br_stp_if.c
> > @@ -37,6 +37,7 @@ void br_init_port(struct net_bridge_port *p)
> >       p->state =3D BR_STATE_BLOCKING;
> >       p->topology_change_ack =3D 0;
> >       p->config_pending =3D 0;
> > +     p->is_own_bpdu =3D 0;
> >  }
> >
> >  /* called under bridge lock */
> > @@ -101,6 +102,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
> >       p->state =3D BR_STATE_DISABLED;
> >       p->topology_change_ack =3D 0;
> >       p->config_pending =3D 0;
> > +     p->is_own_bpdu =3D 0;
> >
> >       del_timer(&p->message_age_timer);
> >       del_timer(&p->forward_delay_timer);
> > diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
> > index 3e96514..99ea288 100644
> > --- a/net/bridge/br_stp_timer.c
> > +++ b/net/bridge/br_stp_timer.c
> > @@ -67,6 +67,7 @@ static void br_message_age_timer_expired(unsigned lon=
g
> arg)
> >       spin_lock(&br->lock);
> >       if (p->state =3D=3D BR_STATE_DISABLED)
> >               goto unlock;
> > +     p->is_own_bpdu =3D 0;
> >       was_root =3D br_is_root_bridge(br);
> >
> >       br_become_designated_port(p);
>
>
> The idea is valid, but putting state variable per port is an
> ugly way to solve it.
>

  Stephen, Thanks for looking at the patch. Will resend you the patch
without the per port state variable.
  Thanks (in my previous mail i missed out CC bridge and netdev group)

--e0cb4e8877050dbb78049fb828f6
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote">On Wed, Mar 30, 2011 at 9:55 PM=
, Stephen Hemminger <span dir=3D"ltr">&lt;<a href=3D"mailto:shemminger@vyat=
ta.com">shemminger@vyatta.com</a>&gt;</span> wrote:<br><blockquote class=3D=
"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rg=
b(204, 204, 204); padding-left: 1ex;">
<div><div></div><div class=3D"h5">On Wed, 30 Mar 2011 21:03:36 +0530<br>
Sasikanth V &lt;<a href=3D"mailto:sasikanth.v19@gmail.com">sasikanth.v19@gm=
ail.com</a>&gt; wrote:<br>
<br>
&gt;<br>
&gt; Signed-off-by: Sasikanth V &lt;<a href=3D"mailto:sasikanth.v19@gmail.c=
om">sasikanth.v19@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0net/bridge/br_private.h =A0 | =A0 =A01 +<br>
&gt; =A0net/bridge/br_stp.c =A0 =A0 =A0 | =A0 20 ++++++++++++++++++--<br>
&gt; =A0net/bridge/br_stp_if.c =A0 =A0| =A0 =A02 ++<br>
&gt; =A0net/bridge/br_stp_timer.c | =A0 =A01 +<br>
&gt; =A04 files changed, 22 insertions(+), 2 deletions(-)<br>
&gt;<br>
&gt; diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h<br>
&gt; index 387013d..d9f79dd 100644<br>
&gt; --- a/net/bridge/br_private.h<br>
&gt; +++ b/net/bridge/br_private.h<br>
&gt; @@ -149,6 +149,7 @@ struct net_bridge_port<br>
&gt; =A0#ifdef CONFIG_NET_POLL_CONTROLLER<br>
&gt; =A0 =A0 =A0 struct netpoll =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*np;<br>
&gt; =A0#endif<br>
&gt; + =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0is_own_bpdu; /*Port recvd its own BPDU*/<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#define br_port_exists(dev) (dev-&gt;priv_flags &amp; IFF_BRIDGE_PO=
RT)<br>
&gt; diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c<br>
&gt; index 7370d14..491d9c6 100644<br>
&gt; --- a/net/bridge/br_stp.c<br>
&gt; +++ b/net/bridge/br_stp.c<br>
&gt; @@ -107,6 +107,12 @@ static void br_root_selection(struct net_bridge *=
br)<br>
&gt; =A0 =A0 =A0 u16 root_port =3D 0;<br>
&gt;<br>
&gt; =A0 =A0 =A0 list_for_each_entry(p, &amp;br-&gt;port_list, list) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*Don&#39;t consider the Port for root selec=
tion<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 which rx&#39;d its own bpdu because of l=
oopback<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 in the bridge<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (p-&gt;is_own_bpdu)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (br_should_become_root_port(p, root_por=
t))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_port =3D p-&gt;port_n=
o;<br>
&gt;<br>
&gt; @@ -278,8 +284,16 @@ static int br_supersedes_port_info(struct net_bri=
dge_port *p, struct br_config_b<br>
&gt; =A0 =A0 =A0 if (memcmp(&amp;bpdu-&gt;bridge_id, &amp;p-&gt;br-&gt;brid=
ge_id, 8))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;<br>
&gt;<br>
&gt; - =A0 =A0 if (bpdu-&gt;port_id &lt;=3D p-&gt;designated_port)<br>
&gt; + =A0 =A0 if (bpdu-&gt;port_id &lt;=3D p-&gt;designated_port) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*802.1D 9.3.4 Validation of received BPDUs<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0NOTE 1=97If the Bridge Identifier and Por=
t Identifier both<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0match the values that would be transmitte=
d in a Configuration<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0BPDU, the BPDU is discarded to prevent pr=
ocessing of the Port=92s<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0own BPDUs;*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (bpdu-&gt;port_id =3D=3D p-&gt;designated=
_port)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p-&gt;is_own_bpdu =3D 1;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;<br>
&gt; + =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt; @@ -411,7 +425,7 @@ void br_port_state_selection(struct net_bridge *br=
)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p-&gt;config_pending =3D 0=
;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p-&gt;topology_change_ack =
=3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 br_make_forwarding(p);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 } else if (br_is_designated_port(p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else if (!p-&gt;is_own_bpdu &amp;&amp; br_=
is_designated_port(p)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&amp;p-&gt;messa=
ge_age_timer);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 br_make_forwarding(p);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; @@ -446,6 +460,8 @@ void br_received_config_bpdu(struct net_bridge_por=
t *p, struct br_config_bpdu *b<br>
&gt; =A0 =A0 =A0 br =3D p-&gt;br;<br>
&gt; =A0 =A0 =A0 was_root =3D br_is_root_bridge(br);<br>
&gt;<br>
&gt; + =A0 =A0 p-&gt;is_own_bpdu =3D 0;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 if (br_supersedes_port_info(p, bpdu)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 br_record_config_information(p, bpdu);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 br_configuration_update(br);<br>
&gt; diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c<br>
&gt; index 5593f5a..fc4ec63 100644<br>
&gt; --- a/net/bridge/br_stp_if.c<br>
&gt; +++ b/net/bridge/br_stp_if.c<br>
&gt; @@ -37,6 +37,7 @@ void br_init_port(struct net_bridge_port *p)<br>
&gt; =A0 =A0 =A0 p-&gt;state =3D BR_STATE_BLOCKING;<br>
&gt; =A0 =A0 =A0 p-&gt;topology_change_ack =3D 0;<br>
&gt; =A0 =A0 =A0 p-&gt;config_pending =3D 0;<br>
&gt; + =A0 =A0 p-&gt;is_own_bpdu =3D 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/* called under bridge lock */<br>
&gt; @@ -101,6 +102,7 @@ void br_stp_disable_port(struct net_bridge_port *p=
)<br>
&gt; =A0 =A0 =A0 p-&gt;state =3D BR_STATE_DISABLED;<br>
&gt; =A0 =A0 =A0 p-&gt;topology_change_ack =3D 0;<br>
&gt; =A0 =A0 =A0 p-&gt;config_pending =3D 0;<br>
&gt; + =A0 =A0 p-&gt;is_own_bpdu =3D 0;<br>
&gt;<br>
&gt; =A0 =A0 =A0 del_timer(&amp;p-&gt;message_age_timer);<br>
&gt; =A0 =A0 =A0 del_timer(&amp;p-&gt;forward_delay_timer);<br>
&gt; diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c<br>
&gt; index 3e96514..99ea288 100644<br>
&gt; --- a/net/bridge/br_stp_timer.c<br>
&gt; +++ b/net/bridge/br_stp_timer.c<br>
&gt; @@ -67,6 +67,7 @@ static void br_message_age_timer_expired(unsigned lo=
ng arg)<br>
&gt; =A0 =A0 =A0 spin_lock(&amp;br-&gt;lock);<br>
&gt; =A0 =A0 =A0 if (p-&gt;state =3D=3D BR_STATE_DISABLED)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unlock;<br>
&gt; + =A0 =A0 p-&gt;is_own_bpdu =3D 0;<br>
&gt; =A0 =A0 =A0 was_root =3D br_is_root_bridge(br);<br>
&gt;<br>
&gt; =A0 =A0 =A0 br_become_designated_port(p);<br>
<br>
<br>
</div></div>The idea is valid, but putting state variable per port is an<br=
>
ugly way to solve it.<br></blockquote><div>=A0</div></div>=A0 Stephen, Than=
ks for looking at the patch. Will resend you the patch without the per port=
 state variable.<br>=A0 Thanks (in my previous mail i missed out CC bridge =
and netdev group)<br>
</div>

--e0cb4e8877050dbb78049fb828f6--

--===============4936309620793594191==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============4936309620793594191==--
