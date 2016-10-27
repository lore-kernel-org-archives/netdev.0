From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 00/16] tipc: socket layer
	improvements
Date: Thu, 27 Oct 2016 16:22:21 +0200
Message-ID: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The following issues with the current socket layer hinders socket diagnostics
implementation, which led to this patch series.

1. tipc socket state is derived from multiple variables like
   sock->state, tsk->probing_state and tsk->connected. This style forces
   us to export multiple attributes to the user space, which has to be
   backward compatible.

2. Abuse of sock->state cannot be exported to user-space without
   requiring tipc specific hacks in the user-space.
   - For connection less (CL) sockets sock->state is overloaded to
     tipc state SS_READY.
   - For connection oriented (CO) listening socket sock->state is
     overloaded to tipc state SS_LISTEN.

This series is split into four:
1. Bug fixes in patch #1,2,3.
2. Minor cleanups in patch#4-5.
3. Express all tipc states using a single variable in patch#6-8.
4. Migrate the new tipc states to sk->sk_state in patch#9-16.

The figures below represents the FSM after this series:

For connectionless sockets:
+-----------+       +--------------+
| TIPC_OPEN |------>| TIPC_CLOSING |
+-----------+       +--------------+

Stream Server Listening Socket:
+-----------+       +-------------+
| TIPC_OPEN |------>| TIPC_LISTEN |
+-----------+       +-------------+
                            |
+--------------+            |
| TIPC_CLOSING |<-----------+
+--------------+

Stream Server Data Socket:
+-----------+       +------------------+
| TIPC_OPEN |------>| TIPC_ESTABLISHED |<---+
+-----------+       +------------------+    |
                        ^   |    |          |
                        |   |    +----------+
                        |   v
                    +--------------+
                    | TIPC_PROBING |
                    +--------------+
                           |
                           |
                           v
+--------------+    +--------------------+
| TIPC_CLOSING |<---| TIPC_DISCONNECTING |
+--------------+    +--------------------+

Stream Socket Client:
+-----------+       +-----------------+
| TIPC_OPEN |------>| TIPC_CONNECTING |
+-----------+       +-----------------+
                            |
                            |
                            v
                    +------------------+
                    | TIPC_ESTABLISHED |<---+
                    +------------------+    |
                         ^   |    |         |
                         |   |    +---------+
                         |   v
                    +--------------+
                    | TIPC_PROBING |
                    +--------------+
                           |
                           |
                           v
+--------------+    +--------------------+
| TIPC_CLOSING |<---| TIPC_DISCONNECTING |
+--------------+    +--------------------+

NOTE:
This is just a base refractoring required for socket diagnostics.
TIPC socket diagnostics support will be introduced in a later series.

Parthasarathy Bhuvaragan (16):
  tipc: return early for non-blocking sockets at link congestion
  tipc: wakeup sleeping users at disconnect
  tipc: set kern=0 in sk_alloc() during tipc_accept()
  tipc: rename struct tipc_skb_cb member handle to bytes_read
  tipc: rename tsk->remote to tsk->peer for consistent naming
  tipc: remove tsk->connected for connectionless sockets
  tipc: remove tsk->connected from tipc_sock
  tipc: remove probing_intv from tipc_sock
  tipc: remove socket state SS_READY
  tipc: create TIPC_LISTEN as a new sk_state
  tipc: create TIPC_PROBING/TIPC_ESTABLISHED as new sk_states
  tipc: create TIPC_OPEN as a new sk_state
  tipc: create TIPC_DISCONNECTING as a new sk_state
  tipc: create TIPC_CLOSING as a new sk_state
  tipc: create TIPC_CONNECTING as a new sk_state
  tipc: remove SS_CONNECTED sock state

 include/uapi/linux/tipc.h |  13 ++
 net/tipc/msg.h            |   2 +-
 net/tipc/socket.c         | 385 +++++++++++++++++++++++++---------------------
 3 files changed, 222 insertions(+), 178 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
