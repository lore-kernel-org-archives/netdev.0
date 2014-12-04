From: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Subject: [PATCH v6 0/7] kernel tinification: optionally compile out splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Thu,  4 Dec 2014 18:50:48 +0100
Message-ID: <1417715473-24110-1-git-send-email-pieter@boesman.nl>
Cc: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>,
	Catalina Mocanu <catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org (open list:FUSE: FILESYSTEM...),
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Iulia Manda <iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jan Beulich <JBeulich-IBi9RG/b67k@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:ABI/API),
	linux-fsd
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

REPO: https://github.com/smipi1/linux-tinification.git

BRANCH: tiny/config-syscall-splice

BACKGROUND: This patch-set forms part of the Linux Kernel Tinification effort (
  https://tiny.wiki.kernel.org/).

GOAL: Support compiling out the splice family of syscalls (splice, vmsplice,
  tee and sendfile) along with all supporting infrastructure if not needed.
  Many embedded systems will not need the splice-family syscalls. Omitting them
  saves space.

HISTORY:
  PATCH v6:
    - Removed unnecessary addition of __maybe_unused in fs/fuse

  PATCH v5:
    - Fix up commit log still referring to dropped __splice_p()

  PATCH v4:
    - Drops __splice_p()
    - Let nfsd fall back to non-splice support when splice is compiled out
    - Style fixes
  
  PATCH v3:
    - Fixup commit logs so that they are consistent with patch strategy
    - Style fixes
  
  PATCH v2:
    - Avoid the ifdef mess introduced in PATCH v1 by mocking out exported splice
      functions.

STRATEGY:
a. With the goal of eventually compiling out fs/splice.c, several functions
   that are only used in support of the the splice family of syscalls are moved
   into fs/splice.c from fs/read_write.c. The kernel_write function that is not
   used to support the splice syscalls is moved to fs/read_write.c.

b. Introduce an EXPERT kernel configuration option; CONFIG_SYSCALL_SPLICE; to
   compile out the splice family of syscalls. This removes all userspace uses
   of the splice infrastructure.

c. Splice exports an operations struct, nosteal_pipe_buf_ops. Eliminate the 
   uses of this struct when CONFIG_SYSCALL_SPLICE is undefined, so that splice
   can later be compiled out.

d. Let nfsd fall back to non-splice support when splice is compiled out.

e. Compile out fs/splice.c. Functions exported by fs/splice are mocked out with
   failing static inlines. This is done so as to all but eliminate the
   maintenance burden on file-system drivers.

RESULTS: A tinyconfig bloat-o-meter score for the entire patch-set:

add/remove: 0/41 grow/shrink: 5/7 up/down: 23/-8422 (-8399)
function                                     old     new   delta
sys_pwritev                                  115     122      +7
sys_preadv                                   115     122      +7
fdput_pos                                     29      36      +7
sys_pwrite64                                 115     116      +1
sys_pread64                                  115     116      +1
pipe_to_null                                   4       -      -4
generic_pipe_buf_nosteal                       6       -      -6
spd_release_page                              10       -     -10
fdput                                         11       -     -11
PageUptodate                                  22      11     -11
lock_page                                     36      24     -12
signal_pending                                39      26     -13
fdget                                         56      42     -14
page_cache_pipe_buf_release                   16       -     -16
user_page_pipe_buf_ops                        20       -     -20
splice_write_null                             24       4     -20
page_cache_pipe_buf_ops                       20       -     -20
nosteal_pipe_buf_ops                          20       -     -20
default_pipe_buf_ops                          20       -     -20
generic_splice_sendpage                       24       -     -24
user_page_pipe_buf_steal                      25       -     -25
splice_shrink_spd                             27       -     -27
pipe_to_user                                  43       -     -43
direct_splice_actor                           47       -     -47
default_file_splice_write                     49       -     -49
wakeup_pipe_writers                           54       -     -54
wakeup_pipe_readers                           54       -     -54
write_pipe_buf                                71       -     -71
page_cache_pipe_buf_confirm                   80       -     -80
splice_grow_spd                               87       -     -87
do_splice_to                                  87       -     -87
ipipe_prep.part                               92       -     -92
splice_from_pipe                              93       -     -93
splice_from_pipe_next                        107       -    -107
pipe_to_sendpage                             109       -    -109
page_cache_pipe_buf_steal                    114       -    -114
opipe_prep.part                              119       -    -119
sys_sendfile                                 122       -    -122
generic_file_splice_read                     131       8    -123
sys_sendfile64                               126       -    -126
sys_vmsplice                                 137       -    -137
do_splice_direct                             148       -    -148
vmsplice_to_user                             205       -    -205
__splice_from_pipe                           246       -    -246
splice_direct_to_actor                       348       -    -348
splice_to_pipe                               371       -    -371
do_sendfile                                  492       -    -492
sys_tee                                      497       -    -497
vmsplice_to_pipe                             558       -    -558
default_file_splice_read                     688       -    -688
iter_file_splice_write                       702       4    -698
sys_splice                                  1075       -   -1075
__generic_file_splice_read                  1109       -   -1109


Pieter Smith (7):
  fs: move sendfile syscall into fs/splice
  fs: moved kernel_write to fs/read_write
  fs/splice: support compiling out splice-family syscalls
  fs/fuse: support compiling out splice
  net/core: support compiling out splice
  fs/nfsd: support compiling out splice
  fs/splice: full support for compiling out splice

 fs/Makefile            |   3 +-
 fs/fuse/dev.c          |   4 +
 fs/read_write.c        | 181 +++------------------------------------------
 fs/splice.c            | 194 +++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/fs.h     |  26 +++++++
 include/linux/skbuff.h |  10 +++
 include/linux/splice.h |  42 +++++++++++
 init/Kconfig           |  10 +++
 kernel/sys_ni.c        |   8 ++
 net/core/skbuff.c      |  11 ++-
 net/sunrpc/svc.c       |   2 +-
 11 files changed, 299 insertions(+), 192 deletions(-)

-- 
2.1.0
