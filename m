From: =?ISO-8859-1?Q?Andreas_Bofj=E4ll?= <andreas.bofjall@ericsson.com>
Subject: Re: [PATCH net-next] tipc: remove two indentation
 levels in tipc_recv_msg routine
Date: Tue, 29 Oct 2013 13:40:09 +0100
Message-ID: <526FACA9.9020004@ericsson.com>
References: <1383044471-12982-1-git-send-email-ying.xue@windriver.com>	<AE90C24D6B3A694183C094C60CF0A2F6026B73BC@saturn3.aculab.com>
	<20131029120708.GI14038@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net,
	Paul.Gortmaker@windriver.com
To: Erik Hugne <erik.hugne@ericsson.com>, David Laight
	<David.Laight@ACULAB.COM>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20131029120708.GI14038@eerihug-hybrid.rnd.ki.sw.ericsson.se>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 10/29/2013 01:07 PM, Erik Hugne wrote:
> On Tue, Oct 29, 2013 at 11:13:09AM +0000, David Laight wrote:
>> I can only see one 'goto cont', an explicit kfree_skb() and
>> continue would be clearer.
>
> There's actually a few more 'goto cont' in the early error checks
> in this function causes it to bail early. Those are not visible
> in the patchdiff however.

If you wanted to make this a bit simpler, you could make two labels and 
move the calls to tipc_node_unlock(n_ptr). The blocks on lines 1545, 
1558 and 1614 (in the patched code) could be replaced by a simple "goto 
unlock" this way.

--- link.c-old	2013-10-29 13:34:35.804926348 +0100
+++ link.c	2013-10-29 13:39:23.991842809 +0100
@@ -1541,10 +1541,8 @@

  		/* Locate unicast link endpoint that should handle message */
  		l_ptr = n_ptr->links[b_ptr->identity];
-		if (unlikely(!l_ptr)) {
-			tipc_node_unlock(n_ptr);
-			goto cont;
-		}
+		if (unlikely(!l_ptr))
+			goto unlock;

  		/* Verify that communication with node is currently allowed */
  		if ((n_ptr->block_setup & WAIT_PEER_DOWN) &&
@@ -1554,10 +1552,8 @@
  			!msg_redundant_link(msg))
  			n_ptr->block_setup &= ~WAIT_PEER_DOWN;

-		if (n_ptr->block_setup) {
-			tipc_node_unlock(n_ptr);
-			goto cont;
-		}
+		if (n_ptr->block_setup)
+			goto unlock;

  		/* Validate message sequence number info */
  		seq_no = msg_seqno(msg);
@@ -1611,8 +1607,7 @@
  				tipc_node_unlock(n_ptr);
  				continue;
  			}
-			tipc_node_unlock(n_ptr);
-			goto cont;
+			goto unlock;
  		}

  		/* Link is now in state WORKING_WORKING */
@@ -1681,6 +1676,9 @@
  		tipc_node_unlock(n_ptr);
  		tipc_net_route_msg(buf);
  		continue;
+
+unlock:
+		tipc_node_unlock(n_ptr);
  cont:
  		kfree_skb(buf);
  	}

/Andreas

------------------------------------------------------------------------------
Android is increasing in popularity, but the open development platform that
developers love is also attractive to malware creators. Download this white
paper to learn more about secure code signing practices that can help keep
Android apps secure.
http://pubads.g.doubleclick.net/gampad/clk?id=65839951&iu=/4140/ostg.clktrk
