From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 11/14] bnxt_en: add support for Flower based
 vxlan encap/decap offload
Date: Fri, 27 Oct 2017 20:32:51 -0700
Message-ID: <20171027203251.4d888ea2@cakuba.netronome.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
        <1509033092-1887-12-git-send-email-michael.chan@broadcom.com>
        <20171027201841.7b572afd@cakuba.netronome.com>
        <CACKFLiksXXneKZ3zrgbJo=rLbY8RW=xZg6a5T+R79hPQP6pK6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Sathya Perla <sathya.perla@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:6361 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750915AbdJ1Dc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 23:32:59 -0400
In-Reply-To: <CACKFLiksXXneKZ3zrgbJo=rLbY8RW=xZg6a5T+R79hPQP6pK6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Oct 2017 20:28:16 -0700, Michael Chan wrote:
> On Fri, Oct 27, 2017 at 8:18 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> > On Thu, 26 Oct 2017 11:51:29 -0400, Michael Chan wrote: =20
> >> From: Sathya Perla <sathya.perla@broadcom.com>
> >>
> >> This patch adds IPv4 vxlan encap/decap action support to TC-flower
> >> offload.
> >>
> >> For vxlan encap, the driver maintains a tunnel encap hash-table.
> >> When a new flow with a tunnel encap action arrives, this table
> >> is looked up; if an encap entry exists, it uses the already
> >> programmed encap_record_handle as the tunnel_handle in the
> >> hwrm_cfa_flow_alloc cmd. Else, a new encap node is added and the
> >> L2 header fields are queried via a route lookup.
> >> hwrm_cfa_encap_record_alloc cmd is used to create a new encap
> >> record and the encap_record_handle is used as the tunnel_handle
> >> while adding the flow.
> >>
> >> For vxlan decap, the driver maintains a tunnel decap hash-table.
> >> When a new flow with a tunnel decap action arrives, this table
> >> is looked up; if a decap entry exists, it uses the already
> >> programmed decap_filter_handle as the tunnel_handle in the
> >> hwrm_cfa_flow_alloc cmd. Else, a new decap node is added and
> >> a decap_filter_handle is alloc'd via the hwrm_cfa_decap_filter_alloc
> >> cmd. This handle is used as the tunnel_handle while adding the flow.
> >>
> >> The code to issue the HWRM FW cmds is introduced in a follow-up patch.
> >>
> >> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
> >> Signed-off-by: Michael Chan <michael.chan@broadcom.com> =20
> >
> > Hi!  I hit this randconfig build testing:
> >
> > ../drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c: In function =E2=80=98b=
nxt_tc_resolve_tunnel_hdrs=E2=80=99:
> > ../drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c:928:32: error: implicit=
 declaration of function =E2=80=98vlan_dev_priv=E2=80=99 [-Werror=3Dimplici=
t-function-declaration]
> >    struct vlan_dev_priv *vlan =3D vlan_dev_priv(dst_dev);
> >                                 ^~~~~~~~~~~~~
> > ../drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c:928:32: warning: initia=
lization makes pointer from integer without a cast [-Wint-conversion]
> > In file included from ../include/uapi/linux/stddef.h:1:0,
> >                  from ../include/linux/stddef.h:4,
> >                  from ../include/uapi/linux/posix_types.h:4,
> >                  from ../include/uapi/linux/types.h:13,
> >                  from ../include/linux/types.h:5,
> >                  from ../include/linux/list.h:4,
> >                  from ../include/linux/timer.h:4,
> >                  from ../include/linux/netdevice.h:28,
> >                  from ../drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c:1=
0:
> > ../drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c:930:11: error: derefere=
ncing pointer to incomplete type =E2=80=98struct vlan_dev_priv=E2=80=99
> >    if (vlan->real_dev !=3D real_dst_dev) {
> >            ^
> > ../include/linux/compiler.h:156:30: note: in definition of macro =E2=80=
=98__trace_if=E2=80=99
> >   if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
> >                               ^~~~
> > ../drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c:930:3: note: in expansi=
on of macro =E2=80=98if=E2=80=99
> >    if (vlan->real_dev !=3D real_dst_dev) {
> >    ^~
> > cc1: some warnings being treated as errors =20
>=20
> Thanks for reporting this.  I think we need to use vlan_dev_real_dev()
> API which will handle the case where CONFIG_VLAN_8021Q is not defined.
>=20
> I will send a patch to fix this shortly.  Thanks again.

I found another one :)

drivers/net/ethernet/broadcom/bnxt/bnxt_tc.o: In function `bnxt_tc_resolve_=
tunnel_hdrs.isra.34':
bnxt_tc.c:(.text+0x5cd): undefined reference to `ip_route_output_flow'

This is when CONFIG_INET is not set.
