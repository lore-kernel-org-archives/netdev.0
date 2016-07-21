From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Thu, 21 Jul 2016 11:39:35 -0500
Message-ID: <87d1m754jc.fsf@x220.int.ebiederm.org>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8737n5dscy.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Tue, 19 Jul 2016 20:13:17 -0500")
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


This patchset addresses two use cases:
- Implement a sane upper bound on the number of namespaces.
- Provide a way for sandboxes to limit the attack surface from
  namespaces.

The maximum sane case I can imagine is if every process is a fat
process, so I set the maximum number of namespaces to the maximum
number of threads.

I make these limits recursive and per user namespace so that a
usernamespace root can reduce the limits further.  If a user namespace
root raises the limit the limit in the parent namespace will be honored.

I have cut this implementation to the bare minimum needed to achieve
these objectives.

Does anyone know if there is a proper error code to return for resource
limit exceeded?  I am currently using -EUSERS or -ENFILE but both of
those feel a little wrong.

Assuming nothing problematic shows up in the review I will add these to
my user namespace tree.

These patches are also available at:
    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing

Changes since v1:
- Compilation issues with !CONFIG_SYSCTL and !CONFIG_USER_NS have been addressed
- Comment improvements.
- A few names have been changed to be clearer.

Eric W. Biederman (10):
      sysctl: Stop implicitly passing current into sysctl_table_root.lookup
      userns: Add per user namespace sysctls.
      userns: Add a limit on the number of user namespaces
      userns: Generalize the user namespace count into ucount
      pidns: Add a limit on the number of pid namespaces
      utsns: Add a limit on the number of uts namespaces
      ipcns: Add a  limit on the number of ipc namespaces
      cgroupns: Add a limit on the number of cgroup namespaces
      netns: Add a limit on the number of net namespaces
      mntns: Add a limit on the number of mount namespaces.

 fs/namespace.c                 |  19 ++++-
 fs/proc/proc_sysctl.c          |  14 +--
 include/linux/sysctl.h         |   3 +-
 include/linux/user_namespace.h |  40 +++++++++
 ipc/namespace.c                |  42 ++++++---
 kernel/cgroup.c                |  15 ++++
 kernel/fork.c                  |   5 ++
 kernel/pid_namespace.c         |  22 ++++-
 kernel/user_namespace.c        | 188 ++++++++++++++++++++++++++++++++++++++---
 kernel/utsname.c               |  31 +++++--
 net/core/net_namespace.c       |  15 ++++
 net/sysctl_net.c               |   4 +-
 12 files changed, 355 insertions(+), 43 deletions(-)

Eric
