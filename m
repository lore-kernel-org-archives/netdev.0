From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: v6: faster tree-based sysctl implementation
Date: Mon, 5 Dec 2011 09:55:31 +0200
Message-ID: <CAPLs8y9omncDbLE_KNoKOLLbfwHjWYUJX_i7cC4bLiJsyPbtZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>
To: "Eric W . Biederman" <ebiederm@xmission.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is version 6 of a patch series that introduces a faster/leaner
sysctl internal implementation.
git://github.com/luciang/linux-2.6-new-sysctl.git =C2=A0v6-new-sysctl-a=
lg
A subset of patches that add the minimal set of patches with the new
algorithm is here:
 git://github.com/luciang/linux-2.6-new-sysctl.git  v6-new-sysctl-alg-s=
lim


=3D Stats =3D

$ time modprobe dummy numdummies=3DN

Without this patch series :(
- ipv4 only
  -  N=3D1000  time=3D 0m 07s
  -  N=3D2000  time=3D 0m 38s
  -  N=3D4000  time=3D 4m 01s
- ipv4 and ipv6
  -  N=3D1000  time=3D 0m 35s
  -  N=3D2000  time=3D 3m 09s
  -  N=3D4000  time=3D14m 27s

With this patch series :)
- ipv4 only
  -  N=3D1000  time=3D 0m  0.31s
  -  N=3D2000  time=3D 0m  1.23s
  -  N=3D4000  time=3D 0m  5.14s
  -  N=3D8000  time=3D 0m 20.20s
- ipv4 and ipv6
  -  N=3D1000  time=3D 0m  0.70s
  -  N=3D2000  time=3D 0m  1.93s
  -  N=3D4000  time=3D 0m  7.03s
  -  N=3D8000  time=3D 0m 40.89s



=3D Changes =3D
since v5:
 - https://lkml.org/lkml/2011/6/2/332 - nothing much because of lack
of review. Echo, echo, echo ... :)
 - minor tweaks
 - rebased on 3.2-rc4


since v4: -=C2=A0http://thread.gmane.org/gmane.linux.network/196495/foc=
us=3D1144143
- rebased on 3.0-rc1 - added a new patch manually register
kernel/usermodehelper which=C2=A0  was added in 3.0-rc1 - minor changes=
 to
the "sysctl: simplify find_in_table" patch

since v3:=C2=A0- http://thread.gmane.org/gmane.linux.network/196495/ -
removed a bad patch that shrinked a counter from int to u8

since v2:=C2=A0- http://thread.gmane.org/gmane.linux.kernel/1137032/foc=
us=3D3D194748
- added a compatibility layer to support old registering complex
sysctl trees. This layer will be deleted once all users of the=C2=A0  o=
ld
are changed. - subdirectories and netns correspondent dirs are now
held in rbtrees - split of from the patches that make changes in the
rest of the tree - rebased on top of 2.6.39

since v1: -=C2=A0http://thread.gmane.org/gmane.linux.kernel/1133667 -
rebased on top of 2.6.39-rc6 - split the patch that adds the new
algorithm and data structures. - fixed a few bugs lingering in the old
code - shrinked a reference counter - added a new reference counter to
maintain ownership information - added method to register an empty
sysctl dir and converted some users - added checks enforcing the rule
that a non-netns specific directory may=C2=A0  not be registered after =
a
netns specific one has already been registered. - added cookie
support: register a piece of data with the header to be=C2=A0  used to =
make
simple conversions on the ctl_table.


=3D Summary =3D

Part 1: introduce compatibility layer:
  sysctl: introduce temporary sysctl wrappers
  sysctl: register only tables of sysctl files

Part 2: minimal changes to sysctl users:
  sysctl: call sysctl_init before the first sysctl registration
  sysctl: no-child: manually register kernel/random
  sysctl: no-child: manually register kernel/usermodehelper
  sysctl: no-child: manually register kernel/keys
  sysctl: no-child: manually register fs/inotify
  sysctl: no-child: manually register fs/epoll
  sysctl: no-child: manually register root tables

Part 3: cleanups simplifying the new algorithm:
  sysctl: faster reimplementation of sysctl_check_table
  sysctl: remove useless ctl_table->parent field
  sysctl: simplify find_in_table
  sysctl: sysctl_head_grab defaults to root header on NULL
  sysctl: delete useless grab_header function
  sysctl: rename ->used to ->ctl_use_refs
  sysctl: rename sysctl_head_grab/finish to sysctl_use_header/unuse
  sysctl: rename sysctl_head_next to sysctl_use_next_header
  sysctl: split ->count into ctl_procfs_refs and ctl_header_refs
  sysctl: rename sysctl_head_get/put to sysctl_proc_inode_get/put
  sysctl: rename (un)use_table to __sysctl_(un)use_header
  sysctl: simplify ->permissions hook
  sysctl: move removal from list out of start_unregistering
  sysctl: introduce ctl_table_group and ctl_table_group_ops



Part 4: new algorithm/data structures:
  sysctl: faster tree-based sysctl implementation



Part 5: checks/warns requested during review:
  sysctl: add duplicate entry and sanity ctl_table checks
  sysctl: alloc ctl_table_header with kmem_cache
  sysctl: check netns-specific registration order respected
  sysctl: warn if registration/unregistration order is not respected
  sysctl: always perform sysctl checks
  sysctl: reorder members of ctl_table_header (cleanup)
  sysctl: add ctl_type member

Part 6: further performance optimisations:
  sysctl: replace subdirectory list with rbtree
  sysctl: replace netns corresp list with rbtree
  sysctl: union-ize some ctl_table_header fields

Part 7: Eric requested ability to register an empty dir:
  sysctl: add register_sysctl_dir: register an empty sysctl directory

Part 8: unrequested feature I'd like to piggy back :)
  sysctl: add ctl_cookie and ctl_cookie_handler
  sysctl: add cookie to __register_sysctl_paths
  sysctl: add register_net_sysctl_table_net_cookie

 drivers/char/random.c            |   27 +-
 fs/eventpoll.c                   |   22 +-
 fs/notify/inotify/inotify_user.c |   22 +-
 fs/proc/inode.c                  |    2 +-
 fs/proc/proc_sysctl.c            |  236 +++++---
 include/linux/inotify.h          |    2 -
 include/linux/key.h              |    3 -
 include/linux/kmod.h             |    3 -
 include/linux/poll.h             |    2 -
 include/linux/sysctl.h           |  221 +++++---
 include/net/net_namespace.h      |    4 +-
 init/main.c                      |    1 +
 kernel/Makefile                  |    5 +-
 kernel/kmod.c                    |   14 +-
 kernel/sysctl.c                  | 1170 ++++++++++++++++++++++++++++--=
--------
 kernel/sysctl_check.c            |  316 +++++++----
 lib/Kconfig.debug                |    8 -
 net/sysctl_net.c                 |   86 ++--
 security/keys/key.c              |    7 +
 security/keys/sysctl.c           |   18 +-
 20 files changed, 1500 insertions(+), 669 deletions(-)

--=20
1.7.5.4
--=20
=C2=A0.
=2E.: Lucian
