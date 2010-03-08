From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] tipc: filter out messages not intended for this host
Date: Mon, 8 Mar 2010 15:39:24 -0500
Message-ID: <20100308203924.GF23634@hmsreliant.think-freely.org>
References: <20100308194149.GD23634@hmsreliant.think-freely.org>
 <20100308.122030.112176481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43829 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755362Ab0CHUj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:39:27 -0500
Content-Disposition: inline
In-Reply-To: <20100308.122030.112176481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 08, 2010 at 12:20:30PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 8 Mar 2010 14:41:49 -0500
> 
> > Port commit 20deb48d16fdd07ce2fdc8d03ea317362217e085
> > from git://tipc.cslab.ericsson.net/pub/git/people/allan/tipc.git
> > 
> > Part of the larger effort I'm trying to help with getting all the downstreamed
> > code from windriver forward ported to the upstream tree
> > 
> > Origional commit message
> > Restore check to filter out inadverdently received messages
> > This patch reimplements a check that allows TIPC to discard messages
> > that are not intended for it.  This check was present in TIPC 1.5/1.6,
> > but was removed by accident during the development of TIPC 1.7; it has
> > now been updated to account for new features present in TIPC 1.7 and
> > reinserted into TIPC.  The main benefit of this check is to filter
> > out messages arriving from orphaned link endpoints, which can arise
> > when a node exits the network and then re-enters it with a different
> > TIPC network address (i.e. <Z.C.N> value).
> > 
> > tested with the tipc sanity test suite.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Origionally-authored-by: Allan Stephens <allan.stephens@windriver.com>
> 
> Adds trailing whitespace, please fix:
> 
> davem@sunset:~/src/GIT/net-2.6$ pcheck diff
> + git apply --check --whitespace=error-all diff
> diff:11: trailing whitespace.
> 		if (unlikely(!msg_isdata(msg) && 
> fatal: 1 line adds whitespace errors.
> 
> 


Apologies, heres the repost, whitespace fixed


Port commit 20deb48d16fdd07ce2fdc8d03ea317362217e085
from git://tipc.cslab.ericsson.net/pub/git/people/allan/tipc.git

Part of the large effort I'm trying to help with getting all the downstreamed
code from windriver forward ported to the upstream tree

Origional commit message
Restore check to filter out inadverdently received messages
This patch reimplements a check that allows TIPC to discard messages
that are not intended for it.  This check was present in TIPC 1.5/1.6,
but was removed by accident during the development of TIPC 1.7; it has
now been updated to account for new features present in TIPC 1.7 and
reinserted into TIPC.  The main benefit of this check is to filter
out messages arriving from orphaned link endpoints, which can arise
when a node exits the network and then re-enters it with a different
TIPC network address (i.e. <Z.C.N> value).

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Origionally-authored-by: Allan Stephens <allan.stephens@windriver.com>


 link.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6f50f64..da3a384 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1882,6 +1882,15 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 			     (msg_destnode(msg) != tipc_own_addr)))
 			goto cont;
 
+		/* Discard non-routeable messages destined for another node */
+
+		if (unlikely(!msg_isdata(msg) &&
+			     (msg_destnode(msg) != tipc_own_addr))) {
+			if ((msg_user(msg) != CONN_MANAGER) &&
+			    (msg_user(msg) != MSG_FRAGMENTER))
+				goto cont;
+		}
+
 		/* Locate unicast link endpoint that should handle message */
 
 		n_ptr = tipc_node_find(msg_prevnode(msg));
