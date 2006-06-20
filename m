From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 01/06] MLSXFRM: Granular IPSec associations for use in MLS
 environments
Date: Tue, 20 Jun 2006 13:23:27 -0500
Message-ID: <44983D1F.1050306@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:23948 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750773AbWFTSXq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 14:23:46 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current approach to labeling Security Associations for SELinux purp=
oses
uses a one-to-one mapping between xfrm policy rules and security associ=
ations.
This doesn=92t address the needs of real world MLS (Multi-level System,=
 traditional
Bell-LaPadula) environments where a single xfrm policy rule (pertaining=
 to a range,
classified to secret for example) might need to map to multiple Securit=
y Associations
(one each for classified, secret, top secret and all the compartments a=
pplicable to
these security levels).

This patch set addresses the above problem by allowing for the mapping =
of a single
xfrm policy rule to multiple security associations, with each associati=
on used in
the security context it is defined for. It also includes the security c=
ontext to be
used in IKE negotiation in the acquire messages sent to the IKE daemon =
so that a unique
SA can be negotiated for each unique security context. A couple of bug =
fixes are also
included; checks to make sure the SAs used by a packet match policy (se=
curity context-wise)
on the inbound and also that the bundle used for the outbound matches t=
he security context
of the flow. This patch set also makes the use of the SELinux sid in fl=
ow cache lookups
seemless by including the sid in the flow key itself.

Description of changes:

A "sid" member has been added to the flow cache key resulting in the si=
d being available
at all needed locations and the flow cache lookups automatically using =
the sid. The flow
sid is derived from the socket on the outbound and the SAs (unlabeled w=
here an SA was not
used) on the inbound.

Outbound case:
1. Find policy for the socket.

2. OLD: Find an SA that matches the policy.
   NEW: Find an SA that matches BOTH the policy and the flow/socket.
     This is necessary since not every SA that matches the policy
     can be used for the flow/socket. Consider policy range Secret-TS,
     and SAs each for Secret and TS. We don't want a TS socket to
     use the Secret SA. Hence the additional check for the SA Vs. flow/=
socket.

3. NEW: When looking thru bundles for a policy, make sure the flow/sock=
et can use the
   bundle. If a bundle is not found, create one, calling for IKE if nec=
essary. If using IKE,
   include the security context in the acquire message to the IKE daemo=
n.

Inbound case:
1. OLD: Find policy for the socket.
   NEW: Find policy for the incoming packet based on the sid of the SA(=
s) it used or the
   unlabeled sid if no SAs were used. (Consider a case where a socket i=
s "authorized" for
   two policies (unclassified-confidential, secret-top_secret). If the =
packet has come in
   using a secret SA, we really ought to be using the latter policy (se=
cret-top_secret).)

2. OLD: BUG: No check to see if the SAs used by the packet agree with t=
he policy sec_ctx-wise.
   (It was indicated in selinux_xfrm_sock_rcv_skb() that this was being=
 accomplished by
    (x->id.spi =3D=3D tmpl->id.spi || !tmpl->id.spi) in xfrm_state_ok, =
but it turns out tmpl->id.spi
    would normally be zero (unless xfrm policy rules specify one at the=
 template level, which
    they usually don't).
   NEW: The socket is checked for access to the SAs used (based on the =
sid of the SAs) in
   selinux_xfrm_sock_rcv_skb().

=46orward case:
   This would be Step 1 from the Inbound case, followed by Steps 2 and =
3 from the Outbound case.

Outstanding items/issues:
- Timewait acknowledgements and such are generated in the current/upstr=
eam implementation using
 a NULL socket resulting in the any_socket sid (SYSTEM_HIGH) to be used=
=2E This problem is not
 addressed by this patch set.

This patch: Add new flask definitions to SELinux

Adds a new avperm "polmatch" to arbitrate flow/state access to a xfrm p=
olicy rule.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---

The patch set is relative to 2.6.17-rc6-mm2. A policy patch is also inc=
luded for reference.
A patch to ipsec-tools/racoon will follow later on the ipsectools-devel=
 list.
ipsec-tools 0.6.5 src in FC rawhide already has the setkey changes need=
ed to work with this.

=46UNCTIONAL DESCRIPTION:

The basic idea is to have the IPSec policy specify an MLS range and hav=
e unique SAs
generated/used for each of the levels that fall in the range. SAs for d=
ifferent levels
can either be manually loaded (using setkey and such) or negotiated usi=
ng IKE (racoon, etc.).

Example:

Let's say we have the following in the SPD (Security Policy Database):

spdadd 9.2.9.15 9.2.9.17 any -ctx 1 1 "system_u:object_r:zzyzx_t:s0-s9:=
c0-c127"
-P in ipsec esp/transport//require ;
spdadd 9.2.9.17 9.2.9.15 any -ctx 1 1 "system_u:object_r:zzyzx_t:s0-s9:=
c0-c127"
-P out ipsec esp/transport//require ;

with nothing in the SAD (Security Association Database) initially. When=
 the kernel
runs into the first packet with the label s2:c4 destined for 9.2.9.17, =
it will see
that there's no SA available to encrypt it with. So, it will call upon =
racoon/IKE
to generate an SA. Racoon will obtain the label (s2:c4) from the kernel=
, do the
negotiation with its peer, including the label (s2:c4) also in the payl=
oad/proposals.
The negotiation will result in a dynamically generated SPI that is uniq=
ue to the label
(s2:c4) plus the other normal parameters involved. It will then insert =
the SA (along
with the SPI) such as the following into the SAD in the kernel:

add 9.2.9.15 9.2.9.17 esp 0x123456
-ctx 1 1 "system_u:object_r:zzyzx_t:s2:c4"
-E des-cbc 0x0000000000000000;

If the kernel subsequently runs into a packet at a different label (say=
 s2:c5) for which
there's no SA available, it will again call upon racoon (which will get=
 s2:c5 from the
kernel this time) and a different SA (with a different SPI) will be neg=
otiated.

 include/linux/security.h                     |  116 ++++++++-
 include/net/flow.h                           |    5=20
 include/net/sock.h                           |    9=20
 net/core/flow.c                              |    7=20
 net/core/sock.c                              |    2=20
 net/key/af_key.c                             |   22 +
 net/xfrm/xfrm_policy.c                       |   28 +-
 net/xfrm/xfrm_state.c                        |   12 -
 security/dummy.c                             |   28 ++
 security/selinux/hooks.c                     |   33 ++
 security/selinux/include/av_perm_to_string.h |    1=20
 security/selinux/include/av_permissions.h    |    1=20
 security/selinux/include/objsec.h            |    1=20
 security/selinux/include/security.h          |    2=20
 security/selinux/include/xfrm.h              |   22 +
 security/selinux/ss/mls.c                    |   20 -
 security/selinux/ss/mls.h                    |   20 +
 security/selinux/ss/services.c               |   48 ++++
 security/selinux/xfrm.c                      |  200 ++++++++++++++---
 19 files changed, 471 insertions(+), 106 deletions(-)


This patch:

 security/selinux/include/av_perm_to_string.h |    1 +
 security/selinux/include/av_permissions.h    |    1 +
 2 files changed, 2 insertions(+)


--- linux-2.6.16.vanilla/security/selinux/include/av_permissions.h	2006=
-06-12 17:49:44.000000000 -0500
+++ linux-2.6.16/security/selinux/include/av_permissions.h	2006-06-19 1=
9:48:24.000000000 -0500
@@ -909,6 +909,7 @@
 #define ASSOCIATION__SENDTO                       0x00000001UL
 #define ASSOCIATION__RECVFROM                     0x00000002UL
 #define ASSOCIATION__SETCONTEXT                   0x00000004UL
+#define ASSOCIATION__POLMATCH                     0x00000008UL
=20
 #define NETLINK_KOBJECT_UEVENT_SOCKET__IOCTL      0x00000001UL
 #define NETLINK_KOBJECT_UEVENT_SOCKET__READ       0x00000002UL
--- linux-2.6.16.vanilla/security/selinux/include/av_perm_to_string.h	2=
006-06-12 17:49:44.000000000 -0500
+++ linux-2.6.16/security/selinux/include/av_perm_to_string.h	2006-06-1=
9 19:48:24.000000000 -0500
@@ -239,6 +239,7 @@
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SENDTO, "sendto")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__RECVFROM, "recvfrom")
    S_(SECCLASS_ASSOCIATION, ASSOCIATION__SETCONTEXT, "setcontext")
+   S_(SECCLASS_ASSOCIATION, ASSOCIATION__POLMATCH, "polmatch")
    S_(SECCLASS_PACKET, PACKET__SEND, "send")
    S_(SECCLASS_PACKET, PACKET__RECV, "recv")
    S_(SECCLASS_PACKET, PACKET__RELABELTO, "relabelto")
