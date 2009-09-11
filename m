From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 2/8] vfs: introduce FMODE_NONOTIFY
Date: Fri, 11 Sep 2009 01:26:06 -0400
Message-ID: <20090911052605.32359.13248.stgit@paris.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752647AbZIKF0V@vger.kernel.org>
In-Reply-To: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a new f_mode which can only be set by the kernel.  It indicates
that the fd was opened by fanotify and should not cause future fanotify
events.  This is needed to prevent fanotify livelock.  An example of
obvious livelock is from fanotify close events.

Process A closes file1
This creates a close event for file1.
fanotify opens file1 for Listener X
Listener X deals with the event and closes its fd for file1.
This creates a close event for file1.
fanotify opens file1 for Listener X
Listener X deals with the event and closes its fd for file1.
This creates a close event for file1.
fanotify opens file1 for Listener X
Listener X deals with the event and closes its fd for file1.
notice a pattern?

The fix is to add the FMODE_NONOTIFY bit to the open filp done by the kernel
for fanotify.  Thus when that file is used it will not generate future
events.

This patch simply defines the bit.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 include/linux/fs.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 02e111c..433db62 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -87,6 +87,9 @@ struct inodes_stat_t {
  */
 #define FMODE_NOCMTIME		((__force fmode_t)2048)
 
+/* File was opened by fanotify and shouldn't generate fanotify events */
+#define FMODE_NONOTIFY		((__force fmode_t)4096)
+
 /*
  * The below are the various read and write types that we support. Some of
  * them include behavioral modifiers that send information down to the
