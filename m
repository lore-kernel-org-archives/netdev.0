From: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 0/3] Send audit/procinfo/cgroup data in socket-level
	control message
Date: Mon, 13 Jan 2014 09:01:46 +0100
Message-ID: <1389600109-30739-1-git-send-email-jkaluza@redhat.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377614400-27122-1-git-send-email-jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this patchset against net-next (applies also to linux-next) adds 3 new types
of "Socket"-level control message (SCM_AUDIT, SCM_PROCINFO and SCM_CGROUP).

Server-like processes in many cases need credentials and other
metadata of the peer, to decide if the calling process is allowed to
request a specific action, or the server just wants to log away this
type of information for auditing tasks.

The current practice to retrieve such process metadata is to look that
information up in procfs with the $PID received over SCM_CREDENTIALS.
This is sufficient for long-running tasks, but introduces a race which
cannot be worked around for short-living processes; the calling
process and all the information in /proc/$PID/ is gone before the
receiver of the socket message can look it up.

Changes introduced in this patchset can also increase performance
of such server-like processes, because current way of opening and
parsing /proc/$PID/* files is much more expensive than receiving these
metadata using SCM.

Changes in v4:
- Rebased to work with the latest net-next tree

Changes in v3:
- Better description of patches (Thanks to Kay Sievers)

Changes in v2:
- use PATH_MAX instead of PAGE_SIZE in SCM_CGROUP patch
- describe each patch individually

Jan Kaluza (3):
  Send loginuid and sessionid in SCM_AUDIT
  Send comm and cmdline in SCM_PROCINFO
  Send cgroup_path in SCM_CGROUP

 include/linux/socket.h |  9 ++++++
 include/net/af_unix.h  | 10 ++++++
 include/net/scm.h      | 67 ++++++++++++++++++++++++++++++++++++++--
 net/core/scm.c         | 83 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/unix/af_unix.c     | 70 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 237 insertions(+), 2 deletions(-)

-- 
1.8.3.1
