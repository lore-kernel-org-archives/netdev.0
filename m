From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-02-27
Date: Thu, 27 Feb 2014 09:00:28 +0100
Message-ID: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59004 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751263AbaB0IAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 03:00:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the rework of the IPsec virtual tunnel interface
for ipv4 to support inter address family tunneling and
namespace crossing. The only change to the last RFC version
is a compile fix for an odd configuration where CONFIG_XFRM
is set but CONFIG_INET is not set.

1) Add and use a IPsec protocol multiplexer.

2) Add xfrm_tunnel_skb_cb to the skb common buffer
   to store a receive callback there.

3) Make vti work with i_key set by not including the i_key
   when comupting the hash for the tunnel lookup in case of
   vti tunnels.

4) Update ip_vti to use it's own receive hook.

5) Remove xfrm_tunnel_notifier, this is replaced by the IPsec
   protocol multiplexer.

6) We need to be protocol family indepenent, so use the on xfrm_lookup
   returned dst_entry instead of the ipv4 rtable in vti_tunnel_xmit().

7) Add support for inter address family tunneling.

8) Check if the tunnel endpoints of the xfrm state and the vti interface
   are matching and return an error otherwise.

8) Enable namespace crossing tor vti devices.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 51adfcc333e1490d3a22490f5b3504f64c7b28b4:

  net: bcmgenet: remove unused bh_lock member (2014-02-24 20:26:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 895de9a3488abcdd186680f0af3cce7f2d4d4a6e:

  vti4: Enable namespace changing (2014-02-25 07:04:19 +0100)

----------------------------------------------------------------
Steffen Klassert (12):
      xfrm4: Add IPsec protocol multiplexer
      esp4: Use the IPsec protocol multiplexer API
      ah4: Use the IPsec protocol multiplexer API
      ipcomp4: Use the IPsec protocol multiplexer API
      xfrm: Add xfrm_tunnel_skb_cb to the skb common buffer
      ip_tunnel: Make vti work with i_key set
      vti: Update the ipv4 side to use it's own receive hook.
      xfrm4: Remove xfrm_tunnel_notifier
      vti4: Use the on xfrm_lookup returned dst_entry directly
      vti4: Support inter address family tunneling.
      vti4: Check the tunnel endpoints of the xfrm state and the vti interface
      vti4: Enable namespace changing

 include/net/xfrm.h           |   83 +++++++++--
 net/ipv4/Makefile            |    2 +-
 net/ipv4/ah4.c               |   25 ++--
 net/ipv4/esp4.c              |   26 ++--
 net/ipv4/ip_tunnel.c         |    6 +-
 net/ipv4/ip_vti.c            |  310 +++++++++++++++++++++++++++++++++---------
 net/ipv4/ipcomp.c            |   26 ++--
 net/ipv4/xfrm4_input.c       |    9 --
 net/ipv4/xfrm4_mode_tunnel.c |   68 ---------
 net/ipv4/xfrm4_protocol.c    |  275 +++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_input.c        |   22 ++-
 11 files changed, 659 insertions(+), 193 deletions(-)
 create mode 100644 net/ipv4/xfrm4_protocol.c
