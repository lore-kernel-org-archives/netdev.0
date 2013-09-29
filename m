From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Subject: Re: [PATCH v2.40 0/7] MPLS actions and matches
Date: Sun, 29 Sep 2013 15:35:56 +1300
Message-ID: <CAOftzPh=3DqNMtuu8Sw+7J8O-EZJ3vv6T2_n-BLBd6x6xgD41A@mail.gmail.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1542146496=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1380241116-7661-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

--===============1542146496==
Content-Type: multipart/alternative; boundary=047d7bdc9e687d450b04e77c9575

--047d7bdc9e687d450b04e77c9575
Content-Type: text/plain; charset=ISO-8859-1

Hi Simon,

I've dropped some comments on a couple of the userspace patches, but I
probably don't need to comment on everything as Ben's given some pretty
clear feedback. The crux would be dropping #3 in favour of something a bit
tidier. Feel free to prod my brain if need be :-).



On Fri, Sep 27, 2013 at 12:18 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:

> Hi,
>
> This series implements MPLS actions and matches based on work by
> Ravi K, Leo Alterman, Yamahata-san and Joe Stringer.
>
> This series provides two changes
>
> * Patches 1 - 5
>
>   Provide user-space support for the VLAN/MPLS tag insertion order
>   up to and including OpenFlow 1.2, and the different ordering
>   specified from OpenFlow 1.3. In a nutshell the datapath always
>   uses the OpenFlow 1.3 ordering, which is to always insert tags
>   immediately after the L2 header, regardless of the presence of other
>   tags. And ovs-vswtichd provides compatibility for the behaviour up
>   to OpenFlow 1.2, which is that MPLS tags should follow VLAN tags
>   if present.
>
>   Ben, these are for you to review.
>
> * Patches 6 and 7
>
>   Adding basic MPLS action and match support to the kernel datapath
>
>   Jesse, these are for you to review.
>
>
> Differences between v2.40 and v2.39:
>
> * Rebase for:
>   + New dev_queue_xmit compat code
>   + Updated put_vlan()
>   + Removal of mpls_depth field from struct flow
> * As suggested by Jesse Gross
>   + Remove bogus mac_len update from push_mpls()
>   + Slightly simplify push_mpls() by using eth_hdr()
>   + Remove dubious condition !eth_p_mpls(inner_protocol) on
>     an skb being considered to be MPLS in netdev_send()
>   + Only use compatibility code for MPLS GSO segmentation on kernels
>     older than 3.11
>   + Revamp setting of inner_protocol
>     1. Do not unconditionally set inner_protocol to the value of
>        skb->protocol in ovs_execute_actions().
>     2. Initialise inner_protocol it to zero only if compatibility code is
> in
>        use. In the case where compatibility code is not in use it will
> either
>        be zero due since the allocation of the skb or some other value set
>        by some other user.
>     3. Conditionally set the inner_protocol in push_mpls() to the value of
>        skb->protocol when entering push_mpls(). The condition is that
>        inner_protocol is zero and the value of skb->protocol is not an MPLS
>        ethernet type.
>     - This new scheme:
>       + Pushes logic to set inner_protocol closer to the case where it is
>         needed.
>       + Avoids over-writing values set by other users.
> * As suggested by Pravin Shelar
>   + Only set and restore skb->protocol in rpl___skb_gso_segment() in the
>     case of MPLS
>   + Add inner_protocol field to struct ovs_gso_cb instead of ovs_skb_cb.
>     This moves compatibility code closer to where it is used
>     and creates fewer differences with mainline.
> * Update comment on mac_len updates in datapath/actions.c
> * Remove HAVE_INNER_PROCOTOL and instead just check
>   against kernel version 3.11 directly.
>   HAVE_INNER_PROCOTOL is a hang-over from work done prior
>   to the merge of inner_protocol into the kernel.
> * Remove dubious condition !eth_p_mpls(inner_protocol) on
>   using inner_protocol as the type in rpl_skb_network_protocol()
> * Do not update type of features in rpl_dev_queue_xmit.
>   Though arguably correct this is not an inherent part of
>   the changes made by this patch.
> * Use skb_cow_head() in push_mpls()
>   + Call skb_cow_head(skb, MPLS_HLEN) instead of
>     make_writable(skb, skb->mac_len) to ensure that there is enough head
>     room to push an MPLS LSE regardless of whether the skb is cloned or
> not.
>   + This is consistent with the behaviour of rpl__vlan_put_tag().
>   + This is a fix for crashes reported when performing mpls_push
>     with headroom less than 4. This problem was introduced in v3.36.
> * Skip popping in mpls_pop if the skb is too short to contain an MPLS LSE
>
>
> Differences between v2.39 and v2.38:
>
> * Rebase for removal of vlan, checksum and skb->mark compat code
>   - This includes adding adding a new patch,
>     "[PATCH v2.39 6/7] datapath: Break out deacceleration portion of
>     vlan_push" to allow re-use of some existing code.
>
>
> Differences between v2.38 and v2.37:
>
> * Rebase for SCTP support
> * Refactor validate_tp_port() to iterate over eth_types rather
>   than open-coding the loop. With the addition of SCTP this logic
>   is now used three times.
>
>
> Differences between v2.37 and v2.36:
>
> * Rebase
>
>
> Differences between v2.36 and v2.35:
>
> * Rebase
>
> * Do not add set_ethertype() to datapath/actions.c.
>   As this patch has evolved this function had devolved into
>   to sets of functionality wrapped into a single function with
>   only one line of common code. Refactor things to simply
>   open-code setting the ether type in the two locations where
>   set_ethertype() was previously used. The aim here is to improve
>   readability.
>
> * Update setting skb->ethertype after mpls push and pop.
>   - In the case of push_mpls it should be set unconditionally
>     as in v2.35 the behaviour of this function to always push
>     an MPLS LSE before any VLAN tags.
>   - In the case of mpls_pop eth_p_mpls(skb->protocol) is a better
>     test than skb->protocol != htons(ETH_P_8021Q) as it will give the
>     correct behaviour in the presence of other VLAN ethernet types,
>     for example 0x88a8 which is used by 802.1ad. Moreover, it seems
>     correct to update the ethernet type if it was previously set
>     according to the top-most MPLS LSE.
>
> * Deaccelerate VLANs when pushing MPLS tags the
>   - Since v2.35 MPLS push will insert an MPLS LSE before any VLAN tags.
>     This means that if an accelerated tag is present it should be
>     deaccelerated to ensure it ends up in the correct position.
>
> * Update skb->mac_len in push_mpls() so that it will be correct
>   when used by a subsequent call to pop_mpls().
>
>   As things stand I do not believe this is strictly necessary as
>   ovs-vswitchd will not send a pop MPLS action after a push MPLS action.
>   However, I have added this in order to code more defensively as I believe
>   that if such a sequence did occur it would be rather unobvious why
>   it didn't work.
>
> * Do not add skb_cow_head() call in push_mpls().
>   It is unnecessary as there is a make_writable() call.
>   This change was also made in v2.30 but some how the
>   code regressed between then and v2.35.
>
>
> Differences between v2.35 and v2.34:
>
> * Add support for the tag ordering specified up until OpenFlow 1.2 and
>   the ordering specified from OpenFlow 1.3.
>
> * Correct error in datapath patch's handling of GSO in the presence
>   of MPLS and absence of VLANs.
>
>
> Pre-requisites.
>
> This series applies on top of "[PATCH v3] Remove mpls_depth field from
> flow"
>
> To aid review this series and its pre-requisite is available in git at:
>
> git://github.com/horms/openvswitch.git devel/mpls-v2.40
>
>
> Patch list and overall diffstat:
>
> Joe Stringer (5):
>   odp: Only pass vlan_tci to commit_vlan_action()
>   odp: Allow VLAN actions after MPLS actions
>   ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
>   ofp-actions: Add separate OpenFlow 1.3 action parser
>   lib: Push MPLS tags in the OpenFlow 1.3 ordering
>
> Simon Horman (2):
>   datapath: Break out deacceleration portion of vlan_push
>   datapath: Add basic MPLS support to kernel
>
>  datapath/Modules.mk                             |   1 +
>  datapath/actions.c                              | 156 ++++++++-
>  datapath/datapath.c                             | 259 ++++++++++++--
>  datapath/datapath.h                             |   2 +
>  datapath/flow.c                                 |  58 ++-
>  datapath/flow.h                                 |  17 +-
>  datapath/linux/compat/gso.c                     | 117 ++++++-
>  datapath/linux/compat/gso.h                     |  53 +++
>  datapath/linux/compat/include/linux/netdevice.h |  14 +-
>  datapath/linux/compat/netdevice.c               |  28 --
>  datapath/mpls.h                                 |  15 +
>  include/linux/openvswitch.h                     |   7 +-
>  lib/flow.c                                      |   2 +-
>  lib/odp-util.c                                  |  21 +-
>  lib/odp-util.h                                  |   2 +-
>  lib/ofp-actions.c                               |  68 +++-
>  lib/ofp-parse.c                                 |   1 +
>  lib/ofp-util.c                                  |   3 +
>  lib/ofp-util.h                                  |   1 +
>  lib/packets.c                                   |  10 +-
>  lib/packets.h                                   |   2 +-
>  ofproto/ofproto-dpif-xlate.c                    |  98 ++++--
>  ofproto/ofproto-dpif-xlate.h                    |   5 +
>  tests/ofproto-dpif.at                           | 446
> ++++++++++++++++++++++++
>  24 files changed, 1246 insertions(+), 140 deletions(-)
>  create mode 100644 datapath/mpls.h
>
>

--047d7bdc9e687d450b04e77c9575
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Simon,<div><br></div><div>I&#39;ve dropped some comment=
s on a couple of the userspace patches, but I probably don&#39;t need to co=
mment on everything as Ben&#39;s given some pretty clear feedback. The crux=
 would be dropping #3 in favour of something a bit tidier. Feel free to pro=
d my brain if need be :-).</div>




<div><br></div></div><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Fri, Sep 27, 2013 at 12:18 PM, Simon Horman <span dir=3D"ltr">&l=
t;<a href=3D"mailto:horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org" target=3D"_blank">horms-/R6kz+dDXgoY1Siqtc7rAw@public.gmane.org=
u</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Hi,<br>
<br>
This series implements MPLS actions and matches based on work by<br>
Ravi K, Leo Alterman, Yamahata-san and Joe Stringer.<br>
<br>
This series provides two changes<br>
<br>
* Patches 1 - 5<br>
<br>
=A0 Provide user-space support for the VLAN/MPLS tag insertion order<br>
=A0 up to and including OpenFlow 1.2, and the different ordering<br>
=A0 specified from OpenFlow 1.3. In a nutshell the datapath always<br>
=A0 uses the OpenFlow 1.3 ordering, which is to always insert tags<br>
=A0 immediately after the L2 header, regardless of the presence of other<br=
>
=A0 tags. And ovs-vswtichd provides compatibility for the behaviour up<br>
=A0 to OpenFlow 1.2, which is that MPLS tags should follow VLAN tags<br>
=A0 if present.<br>
<br>
=A0 Ben, these are for you to review.<br>
<br>
* Patches 6 and 7<br>
<br>
=A0 Adding basic MPLS action and match support to the kernel datapath<br>
<br>
=A0 Jesse, these are for you to review.<br>
<br>
<br>
Differences between v2.40 and v2.39:<br>
<br>
* Rebase for:<br>
=A0 + New dev_queue_xmit compat code<br>
=A0 + Updated put_vlan()<br>
=A0 + Removal of mpls_depth field from struct flow<br>
* As suggested by Jesse Gross<br>
=A0 + Remove bogus mac_len update from push_mpls()<br>
=A0 + Slightly simplify push_mpls() by using eth_hdr()<br>
=A0 + Remove dubious condition !eth_p_mpls(inner_protocol) on<br>
=A0 =A0 an skb being considered to be MPLS in netdev_send()<br>
=A0 + Only use compatibility code for MPLS GSO segmentation on kernels<br>
=A0 =A0 older than 3.11<br>
=A0 + Revamp setting of inner_protocol<br>
=A0 =A0 1. Do not unconditionally set inner_protocol to the value of<br>
=A0 =A0 =A0 =A0skb-&gt;protocol in ovs_execute_actions().<br>
=A0 =A0 2. Initialise inner_protocol it to zero only if compatibility code =
is in<br>
=A0 =A0 =A0 =A0use. In the case where compatibility code is not in use it w=
ill either<br>
=A0 =A0 =A0 =A0be zero due since the allocation of the skb or some other va=
lue set<br>
=A0 =A0 =A0 =A0by some other user.<br>
=A0 =A0 3. Conditionally set the inner_protocol in push_mpls() to the value=
 of<br>
=A0 =A0 =A0 =A0skb-&gt;protocol when entering push_mpls(). The condition is=
 that<br>
=A0 =A0 =A0 =A0inner_protocol is zero and the value of skb-&gt;protocol is =
not an MPLS<br>
=A0 =A0 =A0 =A0ethernet type.<br>
=A0 =A0 - This new scheme:<br>
=A0 =A0 =A0 + Pushes logic to set inner_protocol closer to the case where i=
t is<br>
=A0 =A0 =A0 =A0 needed.<br>
=A0 =A0 =A0 + Avoids over-writing values set by other users.<br>
* As suggested by Pravin Shelar<br>
=A0 + Only set and restore skb-&gt;protocol in rpl___skb_gso_segment() in t=
he<br>
=A0 =A0 case of MPLS<br>
=A0 + Add inner_protocol field to struct ovs_gso_cb instead of ovs_skb_cb.<=
br>
=A0 =A0 This moves compatibility code closer to where it is used<br>
=A0 =A0 and creates fewer differences with mainline.<br>
* Update comment on mac_len updates in datapath/actions.c<br>
* Remove HAVE_INNER_PROCOTOL and instead just check<br>
=A0 against kernel version 3.11 directly.<br>
=A0 HAVE_INNER_PROCOTOL is a hang-over from work done prior<br>
=A0 to the merge of inner_protocol into the kernel.<br>
* Remove dubious condition !eth_p_mpls(inner_protocol) on<br>
=A0 using inner_protocol as the type in rpl_skb_network_protocol()<br>
* Do not update type of features in rpl_dev_queue_xmit.<br>
=A0 Though arguably correct this is not an inherent part of<br>
=A0 the changes made by this patch.<br>
* Use skb_cow_head() in push_mpls()<br>
=A0 + Call skb_cow_head(skb, MPLS_HLEN) instead of<br>
=A0 =A0 make_writable(skb, skb-&gt;mac_len) to ensure that there is enough =
head<br>
=A0 =A0 room to push an MPLS LSE regardless of whether the skb is cloned or=
 not.<br>
=A0 + This is consistent with the behaviour of rpl__vlan_put_tag().<br>
=A0 + This is a fix for crashes reported when performing mpls_push<br>
=A0 =A0 with headroom less than 4. This problem was introduced in v3.36.<br=
>
* Skip popping in mpls_pop if the skb is too short to contain an MPLS LSE<b=
r>
<br>
<br>
Differences between v2.39 and v2.38:<br>
<br>
* Rebase for removal of vlan, checksum and skb-&gt;mark compat code<br>
=A0 - This includes adding adding a new patch,<br>
=A0 =A0 &quot;[PATCH v2.39 6/7] datapath: Break out deacceleration portion =
of<br>
=A0 =A0 vlan_push&quot; to allow re-use of some existing code.<br>
<br>
<br>
Differences between v2.38 and v2.37:<br>
<br>
* Rebase for SCTP support<br>
* Refactor validate_tp_port() to iterate over eth_types rather<br>
=A0 than open-coding the loop. With the addition of SCTP this logic<br>
=A0 is now used three times.<br>
<br>
<br>
Differences between v2.37 and v2.36:<br>
<br>
* Rebase<br>
<br>
<br>
Differences between v2.36 and v2.35:<br>
<br>
* Rebase<br>
<br>
* Do not add set_ethertype() to datapath/actions.c.<br>
=A0 As this patch has evolved this function had devolved into<br>
=A0 to sets of functionality wrapped into a single function with<br>
=A0 only one line of common code. Refactor things to simply<br>
=A0 open-code setting the ether type in the two locations where<br>
=A0 set_ethertype() was previously used. The aim here is to improve<br>
=A0 readability.<br>
<br>
* Update setting skb-&gt;ethertype after mpls push and pop.<br>
=A0 - In the case of push_mpls it should be set unconditionally<br>
=A0 =A0 as in v2.35 the behaviour of this function to always push<br>
=A0 =A0 an MPLS LSE before any VLAN tags.<br>
=A0 - In the case of mpls_pop eth_p_mpls(skb-&gt;protocol) is a better<br>
=A0 =A0 test than skb-&gt;protocol !=3D htons(ETH_P_8021Q) as it will give =
the<br>
=A0 =A0 correct behaviour in the presence of other VLAN ethernet types,<br>
=A0 =A0 for example 0x88a8 which is used by 802.1ad. Moreover, it seems<br>
=A0 =A0 correct to update the ethernet type if it was previously set<br>
=A0 =A0 according to the top-most MPLS LSE.<br>
<br>
* Deaccelerate VLANs when pushing MPLS tags the<br>
=A0 - Since v2.35 MPLS push will insert an MPLS LSE before any VLAN tags.<b=
r>
=A0 =A0 This means that if an accelerated tag is present it should be<br>
=A0 =A0 deaccelerated to ensure it ends up in the correct position.<br>
<br>
* Update skb-&gt;mac_len in push_mpls() so that it will be correct<br>
=A0 when used by a subsequent call to pop_mpls().<br>
<br>
=A0 As things stand I do not believe this is strictly necessary as<br>
=A0 ovs-vswitchd will not send a pop MPLS action after a push MPLS action.<=
br>
=A0 However, I have added this in order to code more defensively as I belie=
ve<br>
=A0 that if such a sequence did occur it would be rather unobvious why<br>
=A0 it didn&#39;t work.<br>
<br>
* Do not add skb_cow_head() call in push_mpls().<br>
=A0 It is unnecessary as there is a make_writable() call.<br>
=A0 This change was also made in v2.30 but some how the<br>
=A0 code regressed between then and v2.35.<br>
<br>
<br>
Differences between v2.35 and v2.34:<br>
<br>
* Add support for the tag ordering specified up until OpenFlow 1.2 and<br>
=A0 the ordering specified from OpenFlow 1.3.<br>
<br>
* Correct error in datapath patch&#39;s handling of GSO in the presence<br>
=A0 of MPLS and absence of VLANs.<br>
<br>
<br>
Pre-requisites.<br>
<br>
This series applies on top of &quot;[PATCH v3] Remove mpls_depth field from=
 flow&quot;<br>
<br>
To aid review this series and its pre-requisite is available in git at:<br>
<br>
git://<a href=3D"http://github.com/horms/openvswitch.git" target=3D"_blank"=
>github.com/horms/openvswitch.git</a> devel/mpls-v2.40<br>
<br>
<br>
Patch list and overall diffstat:<br>
<br>
Joe Stringer (5):<br>
=A0 odp: Only pass vlan_tci to commit_vlan_action()<br>
=A0 odp: Allow VLAN actions after MPLS actions<br>
=A0 ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS<br>
=A0 ofp-actions: Add separate OpenFlow 1.3 action parser<br>
=A0 lib: Push MPLS tags in the OpenFlow 1.3 ordering<br>
<br>
Simon Horman (2):<br>
=A0 datapath: Break out deacceleration portion of vlan_push<br>
=A0 datapath: Add basic MPLS support to kernel<br>
<br>
=A0datapath/Modules.mk =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 1 +<br>
=A0datapath/actions.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| 156 ++++++++-<br>
=A0datapath/datapath.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | 259 ++++++++++++--<br>
=A0datapath/datapath.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 2 +<br>
=A0datapath/flow.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 | =A058 ++-<br>
=A0datapath/flow.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 | =A017 +-<br>
=A0datapath/linux/compat/gso.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | 11=
7 ++++++-<br>
=A0datapath/linux/compat/gso.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A053 +++<br>
=A0datapath/linux/compat/include/linux/netdevice.h | =A014 +-<br>
=A0datapath/linux/compat/netdevice.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A028 --=
<br>
=A0datapath/mpls.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 | =A015 +<br>
=A0include/linux/openvswitch.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 7 +-<br>
=A0lib/flow.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0| =A0 2 +-<br>
=A0lib/odp-util.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0| =A021 +-<br>
=A0lib/odp-util.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0| =A0 2 +-<br>
=A0lib/ofp-actions.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 | =A068 +++-<br>
=A0lib/ofp-parse.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 | =A0 1 +<br>
=A0lib/ofp-util.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0| =A0 3 +<br>
=A0lib/ofp-util.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0| =A0 1 +<br>
=A0lib/packets.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 | =A010 +-<br>
=A0lib/packets.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 | =A0 2 +-<br>
=A0ofproto/ofproto-dpif-xlate.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A098 ++++--<br>
=A0ofproto/ofproto-dpif-xlate.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 5 +<br>
=A0tests/<a href=3D"http://ofproto-dpif.at" target=3D"_blank">ofproto-dpif.=
at</a> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | 446 ++++++++++=
++++++++++++++<br>
=A024 files changed, 1246 insertions(+), 140 deletions(-)<br>
=A0create mode 100644 datapath/mpls.h<br>
<br>
</blockquote></div><br></div>

--047d7bdc9e687d450b04e77c9575--

--===============1542146496==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1542146496==--
