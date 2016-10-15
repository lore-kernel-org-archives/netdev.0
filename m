From: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2 0/2] proc connector: get namespace events
Date: Sat, 15 Oct 2016 14:26:08 +0200
Message-ID: <1476534370-4027-1-git-send-email-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Aaron Campbell <aaron-J6AcJDG0ZEwdnm+yROfE0A@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jesper Derehag <jderehag-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>,
	Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

This is v2 of the patch set to add namespace events in the proc connector.

The act of a process creating or joining a namespace via clone(),
unshare() or setns() is a useful signal for monitoring applications.

I am working on a monitoring application that keeps track of all the
containers and all processes inside each container. The current way of
doing it is by polling regularly in /proc for the list of processes and
in /proc/*/ns/* to know which namespaces they belong to. This is
inefficient on systems with a large number of containers and a large
number of processes.

Instead, I would inspect /proc only one time and get the updates with
the proc connector. Unfortunately, the proc connector gives me the list
of processes but does not notify me when a process changes namespaces.
So I would still need to inspect /proc/*/ns/*.

 (1) Add namespace events for processes. It generates a namespace event each
     time a process changes namespace via clone(), unshare() or setns().

 (2) Add a way for userspace to detect if proc connector is able to send
     namespace events.


Changes since RFC-v1: https://lkml.org/lkml/2016/9/8/588

* Supports userns.

* The reason field says exactly whether it is clone/setns/unshare.

* Sends aggregated messages containing details of several namespaces
  changes. Suggested by Evgeniy Polyakov.

* Add patch 2 to detect if proc connector is able to send namespace events.


This patch set is available in the git repository at:

  https://github.com/kinvolk/linux.git alban/proc_ns_connector-v2-5


Alban Crequy (2):
  proc connector: add namespace events
  proc connector: add a "get feature" op

 drivers/connector/cn_proc.c  | 163 ++++++++++++++++++++++++++++++++++++++++---
 include/linux/cn_proc.h      |  25 +++++++
 include/uapi/linux/cn_proc.h |  27 ++++++-
 kernel/fork.c                |  10 +++
 kernel/nsproxy.c             |   6 ++
 5 files changed, 220 insertions(+), 11 deletions(-)

-- 
2.7.4
