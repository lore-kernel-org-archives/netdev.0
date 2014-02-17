From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 00/10] pull request net: batman-adv 2014-02-17
Date: Mon, 17 Feb 2014 21:48:39 +0100
Message-ID: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:35136 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaBQUwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:52:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have a pull request intended for net/linux-3.14 and linux-3.13=
 (please
take care of queuing these patches for merging in the latter).

Patch 1 fixes the computation of the MTU assigned to a soft-interface. =
This
value is based on the MTUs of the real interfaces handled by batman-adv=
 and due
to an arithmetical error the result was always smaller than what it was=
 supposed
to be.

Patch 2 fixes the access to a TT TVLV message in the RX path this avoid=
ing to
read random memory.
This bug was leading to a bogus TT update messages parsing, thus to a c=
ontinuous
generation of useless traffic needed to recover the entire table from a=
nother
node in the network.

Patch 3 is fixing a memory leak caused by a reference counting unbalanc=
e: after
having used a VLAN object to compare its CRC with the value received by=
 another
node, the reference counter was never decreased so preventing the objec=
t to be
free'd when needed.

Patch 4 is a minor fix which properly addresses a wrong assumption on t=
he
pskb_may_pull return value.

Patch 5 fixes a potential race condition when adding a new neighbour.

Patch 6 fixes a potential memory leak that could be triggered in case o=
f
failure of the originator node initialization routine by Simon Wunderli=
ch.

Patch 7 fixes the TranslationTable CRC computation (used for consistenc=
y check)
by taking into consideration the endianess of the host machine. Prior t=
o this
fix, hosts having different endianess would compute different CRCs thus
continuously triggering an "inconsistency" exception with respect to th=
e
received data which resulted in an endless sequence of recovery message=
s.

Patch 8 fixes a severe memory leak caused by a missing SKB consumption =
after a
successful TVLV message parsing.

Patch 9 avoids a potential double free that could be trigger in case of=
 orig_node
initialization failure.

Patch 10 fixes a potential kernel paging error caused by the wrong usag=
e of an
old skb->data pointer after that the skb itself was reallocated (by
pskb_may_pull()) by me in collaboration with Linus L=C3=BCssing.


Please pull or let me know of any problem!

Thanks a lot,
	Antonio



The following changes since commit 0fd5d57ba3456c4d0b77d1ae64be4818b47d=
7545:

  packet: check for ndo_select_queue during queue selection (2014-02-17=
 00:36:34 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 70b271a78beba787155d6696aacd7c4d4a251c50=
:

  batman-adv: fix potential kernel paging error for unicast transmissio=
ns (2014-02-17 17:17:02 +0100)

----------------------------------------------------------------
Included changes:
- fix soft-interface MTU computation
- fix bogus pointer mangling when parsing the TT-TVLV
  container. This bug led to a wrong memory access.
- fix memory leak by properly releasing the VLAN object
  after CRC check
- properly check pskb_may_pull() return value
- avoid potential race condition while adding new neighbour
- fix potential memory leak by removing all the references
  to the orig_node object in case of initialization failure
- fix the TT CRC computation by ensuring that every node uses
  the same byte order when hosts with different endianess are
  part of the same network
- fix severe memory leak by freeing skb after a successful
  TVLV parsing
- avoid potential double free when orig_node initialization
  fails
- fix potential kernel paging error caused by the usage of
  the old value of skb->data after skb reallocation

----------------------------------------------------------------
Antonio Quartulli (9):
  batman-adv: fix soft-interface MTU computation
  batman-adv: fix TT-TVLV parsing on OGM reception
  batman-adv: release vlan object after checking the CRC
  batman-adv: properly check pskb_may_pull return value
  batman-adv: avoid potential race condition when adding a new neighbou=
r
  batman-adv: fix TT CRC computation by ensuring byte order
  batman-adv: free skb on TVLV parsing success
  batman-adv: avoid double free when orig_node initialization fails
  batman-adv: fix potential kernel paging error for unicast
    transmissions

Simon Wunderlich (1):
  batman-adv: fix potential orig_node reference leak

 net/batman-adv/bat_iv_ogm.c        | 30 ++++++++++++++++++++----------
 net/batman-adv/hard-interface.c    | 22 ++++++++++++++--------
 net/batman-adv/originator.c        | 36 ++++++++++++++++++++++++++++++=
++++++
 net/batman-adv/originator.h        |  4 ++++
 net/batman-adv/routing.c           |  4 +++-
 net/batman-adv/send.c              |  9 +++++++--
 net/batman-adv/translation-table.c | 23 +++++++++++++++++------
 7 files changed, 101 insertions(+), 27 deletions(-)

--=20
1.8.5.3
