From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 00/16] tipc: socket layer
	improvements
Date: Tue, 1 Nov 2016 14:02:33 +0100
Message-ID: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Stream Server Listening Socket:
+-----------+       +-------------+
| TIPC_OPEN |------>| TIPC_LISTEN |
+-----------+       +-------------+

Stream Server Data Socket:
+-----------+       +------------------+
| TIPC_OPEN |------>| TIPC_ESTABLISHED |
+-----------+       +------------------+
                          ^   |
                          |   |
                          |   v
                    +--------------------+
                    | TIPC_DISCONNECTING |
                    +--------------------+

Stream Socket Client:
+-----------+       +-----------------+
| TIPC_OPEN |------>| TIPC_CONNECTING |------+
+-----------+       +-----------------+      |
                            |                |
                            |                |
                            v                |
                    +------------------+     |
                    | TIPC_ESTABLISHED |     |
                    +------------------+     |
                          ^   |              |
                          |   |              |
                          |   v              |
                    +--------------------+   |
                    | TIPC_DISCONNECTING |<--+
                    +--------------------+

NOTE:
This is just a base refractoring required for socket diagnostics.
TIPC socket diagnostics support will be introduced in a later series.

v2: - remove extra cast and parenthesis as suggested by David S. Miller in #4.
    - map new tipc state values to tcp states to address Eric Dumazet's concern,
      thus allow the usage of generic sk_* helpers. This is done in patch#10-15.
    - remove TIPC_PROBING state and replace it with probe_unacked flag in #11.
    - replace the TIPC_CLOSING state in v1 with sk_shutdown flag in #14.
    - introduce __tipc_shutdown() to avoid code duplication in #14.

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
  tipc: create TIPC_ESTABLISHED as a new sk_state
  tipc: create TIPC_OPEN as a new sk_state
  tipc: create TIPC_DISCONNECTING as a new sk_state
  tipc: remove SS_DISCONNECTING state
  tipc: create TIPC_CONNECTING as a new sk_state
  tipc: remove SS_CONNECTED sock state

 net/tipc/msg.h    |   2 +-
 net/tipc/socket.c | 478 +++++++++++++++++++++++++++---------------------------
 2 files changed, 242 insertions(+), 238 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
