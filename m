From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: message reassembly using fragment
 chain
Date: Tue, 29 Oct 2013 13:36:25 +0800
Message-ID: <526F4959.8080501@windriver.com>
References: <20131028.010737.400887499395331496.davem@davemloft.net>	<526E3B49.9030506@donjonn.com>	<526F15E8.9020009@windriver.com> <20131028.234953.1884858499661587979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <paul.gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<tipc-discussion@lists.sourceforge.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <maloy@donjonn.com>,
	<jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35630 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab3J2Fgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 01:36:44 -0400
In-Reply-To: <20131028.234953.1884858499661587979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2013 11:49 AM, David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Tue, 29 Oct 2013 09:56:56 +0800
> 
>> Therefore, the best method is to divide tipc_recv_msg() into several
>> smaller functions to simplify the current implementation. But it's not
>> an easy job. Actually I ever tried to do it, but I gave up lastly
>> because I did not find one perfect solution about how to divide it.
> 
> But you're going to have to find a way, this indent level is out of
> control.
> 
> 

By simply adjusting the order of branch blocks, this is what I can figure out the simplest
method to resolve the issue now :)

Please review below change. If it's fine, I will send one formal patch.
(Below change still follows original code logic)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 12c72d2..6c88dbc 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1592,97 +1592,94 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)

                /* Now (finally!) process the incoming message */
 protocol_check:
-               if (likely(link_working_working(l_ptr))) {
-                       if (likely(seq_no == mod(l_ptr->next_in_no))) {
-                               l_ptr->next_in_no++;
-                               if (unlikely(l_ptr->oldest_deferred_in))
-                                       head = link_insert_deferred_queue(l_ptr,
-                                                                         head);
-deliver:
-                               if (likely(msg_isdata(msg))) {
-                                       tipc_node_unlock(n_ptr);
-                                       tipc_port_recv_msg(buf);
-                                       continue;
-                               }
-                               switch (msg_user(msg)) {
-                                       int ret;
-                               case MSG_BUNDLER:
-                                       l_ptr->stats.recv_bundles++;
-                                       l_ptr->stats.recv_bundled +=
-                                               msg_msgcnt(msg);
-                                       tipc_node_unlock(n_ptr);
-                                       tipc_link_recv_bundle(buf);
-                                       continue;
-                               case NAME_DISTRIBUTOR:
-                                       n_ptr->bclink.recv_permitted = true;
-                                       tipc_node_unlock(n_ptr);
-                                       tipc_named_recv(buf);
-                                       continue;
-                               case BCAST_PROTOCOL:
-                                       tipc_link_recv_sync(n_ptr, buf);
-                                       tipc_node_unlock(n_ptr);
-                                       continue;
-                               case CONN_MANAGER:
-                                       tipc_node_unlock(n_ptr);
-                                       tipc_port_recv_proto_msg(buf);
-                                       continue;
-                               case MSG_FRAGMENTER:
-                                       l_ptr->stats.recv_fragments++;
-                                       ret = tipc_link_recv_fragment(
-                                               &l_ptr->defragm_buf,
-                                               &buf, &msg);
-                                       if (ret == 1) {
-                                               l_ptr->stats.recv_fragmented++;
-                                               goto deliver;
-                                       }
-                                       if (ret == -1)
-                                               l_ptr->next_in_no--;
-                                       break;
-                               case CHANGEOVER_PROTOCOL:
-                                       type = msg_type(msg);
-                                       if (link_recv_changeover_msg(&l_ptr,
-                                                                    &buf)) {
-                                               msg = buf_msg(buf);
-                                               seq_no = msg_seqno(msg);
-                                               if (type == ORIGINAL_MSG)
-                                                       goto deliver;
-                                               goto protocol_check;
-                                       }
-                                       break;
-                               default:
-                                       kfree_skb(buf);
-                                       buf = NULL;
-                                       break;
-                               }
+               if (unlikely(!link_working_working(l_ptr))) {
+                       if (msg_user(msg) == LINK_PROTOCOL) {
+                               link_recv_proto_msg(l_ptr, buf);
+                               head = link_insert_deferred_queue(l_ptr, head);
+                               tipc_node_unlock(n_ptr);
+                               continue;
+                       }
+
+                       /* Traffic message. Conditionally activate link */
+                       link_state_event(l_ptr, TRAFFIC_MSG_EVT);
+
+                       if (link_working_working(l_ptr)) {
+                               /* Re-insert buffer in front of queue */
+                               buf->next = head;
+                               head = buf;
                                tipc_node_unlock(n_ptr);
-                               tipc_net_route_msg(buf);
                                continue;
                        }
+                       tipc_node_unlock(n_ptr);
+                       goto cont;
+               }
+
+               /* Link is now in state WORKING_WORKING */
+               if (unlikely(seq_no != mod(l_ptr->next_in_no))) {
                        link_handle_out_of_seq_msg(l_ptr, buf);
                        head = link_insert_deferred_queue(l_ptr, head);
                        tipc_node_unlock(n_ptr);
                        continue;
                }
-
-               /* Link is not in state WORKING_WORKING */
-               if (msg_user(msg) == LINK_PROTOCOL) {
-                       link_recv_proto_msg(l_ptr, buf);
+               l_ptr->next_in_no++;
+               if (unlikely(l_ptr->oldest_deferred_in))
                        head = link_insert_deferred_queue(l_ptr, head);
+deliver:
+               if (likely(msg_isdata(msg))) {
                        tipc_node_unlock(n_ptr);
+                       tipc_port_recv_msg(buf);
                        continue;
                }
-
-               /* Traffic message. Conditionally activate link */
-               link_state_event(l_ptr, TRAFFIC_MSG_EVT);
-
-               if (link_working_working(l_ptr)) {
-                       /* Re-insert buffer in front of queue */
-                       buf->next = head;
-                       head = buf;
+               switch (msg_user(msg)) {
+                       int ret;
+               case MSG_BUNDLER:
+                       l_ptr->stats.recv_bundles++;
+                       l_ptr->stats.recv_bundled += msg_msgcnt(msg);
+                       tipc_node_unlock(n_ptr);
+                       tipc_link_recv_bundle(buf);
+                       continue;
+               case NAME_DISTRIBUTOR:
+                       n_ptr->bclink.recv_permitted = true;
+                       tipc_node_unlock(n_ptr);
+                       tipc_named_recv(buf);
+                       continue;
+               case BCAST_PROTOCOL:
+                       tipc_link_recv_sync(n_ptr, buf);
+                       tipc_node_unlock(n_ptr);
+                       continue;
+               case CONN_MANAGER:
                        tipc_node_unlock(n_ptr);
+                       tipc_port_recv_proto_msg(buf);
                        continue;
+               case MSG_FRAGMENTER:
+                       l_ptr->stats.recv_fragments++;
+                       ret = tipc_link_recv_fragment(&l_ptr->defragm_buf,
+                                                     &buf, &msg);
+                       if (ret == 1) {
+                               l_ptr->stats.recv_fragmented++;
+                               goto deliver;
+                       }
+                       if (ret == -1)
+                               l_ptr->next_in_no--;
+                       break;
+               case CHANGEOVER_PROTOCOL:
+                       type = msg_type(msg);
+                       if (link_recv_changeover_msg(&l_ptr, &buf)) {
+                               msg = buf_msg(buf);
+                               seq_no = msg_seqno(msg);
+                               if (type == ORIGINAL_MSG)
+                                       goto deliver;
+                               goto protocol_check;
+                       }
+                       break;
+               default:
+                       kfree_skb(buf);
+                       buf = NULL;
+                       break;
                }
                tipc_node_unlock(n_ptr);
+               tipc_net_route_msg(buf);
+               continue;
 cont:
                kfree_skb(buf);
        }

Regards,
Ying
