From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Subject: Re: [PATCH v2.40 2/7] odp: Allow VLAN actions after MPLS
	actions
Date: Sun, 29 Sep 2013 14:51:19 +1300
Message-ID: <CAOftzPg_FJoyS0oS8Ua7cpMaCh=BboWwyn8kVVoXGT9X9HQ0hg@mail.gmail.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
	<1380241116-7661-3-git-send-email-horms@verge.net.au>
	<20130927192108.GA17506@nicira.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0554089873=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130927192108.GA17506-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0554089873==
Content-Type: multipart/alternative; boundary=bcaec51ddb27f141b404e77bf55f

--bcaec51ddb27f141b404e77bf55f
Content-Type: text/plain; charset=ISO-8859-1

On Sat, Sep 28, 2013 at 7:21 AM, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:

> On Fri, Sep 27, 2013 at 09:18:31AM +0900, Simon Horman wrote:
> > From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> >
> > OpenFlow 1.2 and 1.3 differ on their handling of MPLS actions in the
> > presence of VLAN tags. To allow correct behaviour to be committed in
> > each situation, this patch adds a second round of VLAN tag action
> > handling to commit_odp_actions(), which occurs after MPLS actions. This
> > is implemented with a new field in 'struct xlate_in' called 'vlan_tci'.
> >
> > When an push_mpls action is composed, the flow's current VLAN state is
> > stored into xin->vlan_tci, and flow->vlan_tci is set to 0 (pop_vlan). If
> > a VLAN tag is present, it is stripped; if not, then there is no change.
> > Any later modifications to the VLAN state is written to xin->vlan_tci.
> > When committing the actions, flow->vlan_tci is used before MPLS actions,
> > and xin->vlan_tci is used afterwards. This retains the current datapath
> > behaviour, but allows VLAN actions to be applied in a more flexible
> > manner.
> >
> > Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> > Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
>
> The commit message talks about handling OpenFlow 1.2 and 1.3 both
> properly, but I don't see how the code distinguishes between the cases.
> Can you explain?  Maybe this is something added in a later patch, in
> which case it would be nice to mention that in the commit message.
>

It is added in patch #5. IIRC this patch should cause no difference in
behaviour, but set up infrastructure to be used later.

 There seems to be a typo in the comment in vlan_tci_restore() here:
> > +    /* If MPLS actions were executed after MPLS, copy the final
> vlan_tci out
> > +     * and restore the intermediate VLAN state. */
>

Right, that should probably be "...executed after VLAN actions...".

I was a little confused by the new local variable 'vlan_tci' in
> do_xlate_actions().  Partly this was because the fact that I didn't find
> it obvious that sometimes it points to different VLAN tags.  I think
> this would be easier to see if it were initially assigned just under the
> big comment rather than in an initializer, so that one would know to
> look at the comment.
>

Perhaps the big comment could be rearranged and put above the initialiser,
something like the following:-

/* VLAN actions are stored to '*vlan_tci'. This variable initially points
to 'xin->flow->vlan_tci', so that
 * VLAN actions are applied before any MPLS actions. When an MPLS action is
translated,
 * 'vlan_tci' is updated to point to 'xin->vlan_tci'. This causes later
VLAN actions to be applied after MPLS actions.
 * Each time through the loop, 'xin->vlan_tci' is updated to reflect the
final VLAN state of the flow. */

Then, the place where 'xin->vlan_tci' is updated to '*vlan_tci' could have
a simple comment to refer back:-

/* Update the final vlan state to match the current state. */

Simon, do you mind handling the change?

--bcaec51ddb27f141b404e77bf55f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Sat, Sep 28, 2013 at 7:21 AM, Ben Pfaff <span dir=3D"lt=
r">&lt;<a href=3D"mailto:blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org" target=3D"_blank">blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org</=
a>&gt;</span> wrote:<br><div class=3D"gmail_extra"><div class=3D"gmail_quot=
e"><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bord=
er-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:soli=
d;padding-left:1ex">




<div>On Fri, Sep 27, 2013 at 09:18:31AM +0900, Simon Horman wrote:<br>
&gt; From: Joe Stringer &lt;<a href=3D"mailto:joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org" target=3D"_b=
lank">joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org</a>&gt;<br>
&gt;<br>
&gt; OpenFlow 1.2 and 1.3 differ on their handling of MPLS actions in the<b=
r>
&gt; presence of VLAN tags. To allow correct behaviour to be committed in<b=
r>
&gt; each situation, this patch adds a second round of VLAN tag action<br>
&gt; handling to commit_odp_actions(), which occurs after MPLS actions. Thi=
s<br>
&gt; is implemented with a new field in &#39;struct xlate_in&#39; called &#=
39;vlan_tci&#39;.<br>
&gt;<br>
&gt; When an push_mpls action is composed, the flow&#39;s current VLAN stat=
e is<br>
&gt; stored into xin-&gt;vlan_tci, and flow-&gt;vlan_tci is set to 0 (pop_v=
lan). If<br>
&gt; a VLAN tag is present, it is stripped; if not, then there is no change=
.<br>
&gt; Any later modifications to the VLAN state is written to xin-&gt;vlan_t=
ci.<br>
&gt; When committing the actions, flow-&gt;vlan_tci is used before MPLS act=
ions,<br>
&gt; and xin-&gt;vlan_tci is used afterwards. This retains the current data=
path<br>
&gt; behaviour, but allows VLAN actions to be applied in a more flexible<br=
>
&gt; manner.<br>
&gt;<br>
&gt; Signed-off-by: Joe Stringer &lt;<a href=3D"mailto:joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org" tar=
get=3D"_blank">joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org</a>&gt;<br>
&gt; Signed-off-by: Simon Horman &lt;<a href=3D"mailto:horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org" =
target=3D"_blank">horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org</a>&gt;<br>
<br>
</div>The commit message talks about handling OpenFlow 1.2 and 1.3 both<br>
properly, but I don&#39;t see how the code distinguishes between the cases.=
<br>
Can you explain? =A0Maybe this is something added in a later patch, in<br>
which case it would be nice to mention that in the commit message.<br></blo=
ckquote><div><br></div><div>It is added in patch #5. IIRC this patch should=
 cause no difference in behaviour, but set up infrastructure to be used lat=
er.</div>

<div><br></div>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">

There seems to be a typo in the comment in vlan_tci_restore() here:<br>
<div>&gt; + =A0 =A0/* If MPLS actions were executed after MPLS, copy the fi=
nal vlan_tci out<br>
&gt; + =A0 =A0 * and restore the intermediate VLAN state. */<br></div></blo=
ckquote><div><br></div><div>Right, that should probably be &quot;...execute=
d after VLAN actions...&quot;.</div><div><br></div><blockquote class=3D"gma=
il_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-le=
ft-color:rgb(204,204,204);border-left-style:solid;padding-left:1ex">

I was a little confused by the new local variable &#39;vlan_tci&#39; in<br>
do_xlate_actions(). =A0Partly this was because the fact that I didn&#39;t f=
ind<br>
it obvious that sometimes it points to different VLAN tags. =A0I think<br>
this would be easier to see if it were initially assigned just under the<br=
>
big comment rather than in an initializer, so that one would know to<br>
look at the comment.<br></blockquote><div><br></div><div>Perhaps the big co=
mment could be rearranged and put above the initialiser, something like the=
 following:-</div><div><br></div><div>/* VLAN actions are stored to &#39;*v=
lan_tci&#39;. This variable initially points to &#39;xin-&gt;flow-&gt;vlan_=
tci&#39;, so that</div>

<div>=A0* VLAN actions are applied before any MPLS actions. When an MPLS ac=
tion is translated,=A0</div><div>=A0* &#39;vlan_tci&#39; is updated to poin=
t to &#39;xin-&gt;vlan_tci&#39;. This causes later VLAN actions to be appli=
ed after MPLS actions.</div>

<div>=A0* Each time through the loop, &#39;xin-&gt;vlan_tci&#39; is updated=
 to reflect the final VLAN state of the flow. */</div><div><br></div><div>T=
hen, the place where &#39;xin-&gt;vlan_tci&#39; is updated to &#39;*vlan_tc=
i&#39; could have a simple comment to refer back:-</div>

<div><br></div><div><span style=3D"font-family:arial,sans-serif;font-size:1=
3px">/* Update the final vlan state to match the current state.</span><span=
 style=3D"font-family:arial,sans-serif;font-size:13px">=A0*/</span><br></di=
v>

</div></div><div class=3D"gmail_extra"><br></div><div class=3D"gmail_extra"=
>Simon, do you mind handling the change?</div></div>

--bcaec51ddb27f141b404e77bf55f--

--===============0554089873==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0554089873==--
