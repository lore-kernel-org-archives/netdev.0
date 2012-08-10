From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
Date: Fri, 10 Aug 2012 16:57:23 +0400
Message-ID: <20120810125701.7115.71612.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, eric.dumazet@gmail.com,
	xemul@parallels.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bfields@fieldses.org,
	viro@zeniv.linux.org.uk, tim.c.chen@linux.intel.com,
	devel@openvz.org
To: Trond.Myklebust@netapp.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Today, there is a problem in connecting of local SUNRPC thansports. These
transports uses UNIX sockets and connection itself is done by rpciod
workqueue.
But UNIX sockets lookup is done in context of process file system root. I.e.
all local thunsports are connecting in rpciod context.
This works nice until we will try to mount NFS from process with other root -
for example in container. This container can have it's own (nested) root and
rcpbind process, listening on it's own unix sockets. But NFS mount attempt in
this container will register new service (Lockd for example) in global rpcbind
- not containers's one.

This patch set introduces kernel connect helper for UNIX stream sockets and
modifies unix_find_other() to be able to search from specified root.
It also replaces generic socket connect call for local transports by new
helper in SUNRPC layer.

The following series implements...

---

Stanislav Kinsbursky (2):
      unix sockets: add ability for search for peer from passed root
      SUNRPC: connect local transports with unix_stream_connect_root() helper


 include/net/af_unix.h |    2 ++
 net/sunrpc/xprtsock.c |   28 +++++++++++++++++++++++++---
 net/unix/af_unix.c    |   25 ++++++++++++++++++-------
 3 files changed, 45 insertions(+), 10 deletions(-)
