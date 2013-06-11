From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request for net: batman-adv 2013-06-11
Date: Tue, 11 Jun 2013 08:34:58 +0200
Message-ID: <1370932501-3937-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello David,

here you have three patches intended for net/linux-3.10.

Patch 1/3 is substituting a rtnl_trylock with a rtnl_lock. The trylock was used
before to avoid deadlock, but since this situation has been fixed, the trylock
is not necessary anymore. It only creates troubles every time batman-adv is
initialised and the RTNL lock is taken by another component.
Since the deadlock has been fixed in 3.8, I'd like to queue this patch for
stable for 3.8+.


Patch 2/3 fixes an important point in our routing protocol, in particular in the
duplicate control messages detection. In the right condition, the protocol
prevents some control packets to be forwarded making some nodes in the network
totally unreachable and so breaking the mesh. The fix, by Simon Wunderlich,
enhances the duplicate message detection and avoids this situation (the change
may look a bit big, but it is just because a variable has been changed from int
to enum to better describe the duplicate packet event).
Please, enqueue this patch for -stable because the bug is there since a while..


Patch 3/3 fixes the Bridge Loop Avoidance component by avoiding a particular
routine to run even if the aforementioned feature is off. This bug leads to some
useless packets to be sent over the mesh. This one is not critical and therefore
does not need to be enqueued for stable.


Please pull or let me know if there is any problem!

Thanks a lot,
	Antonio


The following changes since commit 40edeff6e1c6f9a6f16536ae3375e3af9d648449:

  net_sched: qdisc_get_rtab() must check data[] array (2013-06-07 15:24:04 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to d5b4c93e67b0b1291aa8e2aaf694e40afc3412d0:

  batman-adv: Don't handle address updates when bla is disabled (2013-06-10 08:42:18 +0200)

----------------------------------------------------------------
Included change:
- fix "rtnl locked" concurrent executions by using rtnl_lock instead of
  rtnl_trylock. This fix enables batman-adv initialisation to do not fail just
  because somewhere else in the system another code path is holding the rtnl
  lock. It is easy to see the problem when batman-adv is trying to start
  together with other networking components.
- fix the routing protocol forwarding policy by enhancing the duplicate control
  packet detection. When the right circumstances trigger the issue, some nodes in
  the network become totally unreachable, so breaking the mesh connectivity.
- fix the Bridge Loop Avoidance component by not running the originator address
  change handling routine when the component is disabled. The routine was
  generating useless packets that were sent over the network.

----------------------------------------------------------------
Matthias Schiffer (1):
      batman-adv: wait for rtnl in batadv_store_mesh_iface instead of failing if it is taken

Simon Wunderlich (2):
      batman-adv: forward late OGMs from best next hop
      batman-adv: Don't handle address updates when bla is disabled

 net/batman-adv/bat_iv_ogm.c            | 86 ++++++++++++++++++++++------------
 net/batman-adv/bridge_loop_avoidance.c |  4 ++
 net/batman-adv/sysfs.c                 |  5 +-
 3 files changed, 60 insertions(+), 35 deletions(-)
