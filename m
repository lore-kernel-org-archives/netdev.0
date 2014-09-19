From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next v2 0/9] introduce rocker switch driver
	with hardware accelerated datapath api
Date: Fri, 19 Sep 2014 15:49:41 +0200
Message-ID: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

This patchset can be divided into 3 main sections:
- introduce switchdev api for implementing switch drivers
- introduce switchdev generic netlink api for userspace manipulation
- introduce rocker switch driver which implements switchdev api

More info in separate patches.

So now there is possible to create ovs bridge over rocker
switch ports. ovs daemon can decide which flows to offload to hw
and uses switchdev genl api to tell driver. For now the easiest
way it to do it by hand via "sw" tool (https://github.com/jpirko/switchdev).

v1->v2 changes:
- removed DSA phys switch id implementation for now per Florian's request
- introduced own match key structure so the internal ovs flow struct
  stays untouched
- extended the flow match in order to easily add more match types (hope that
  Jamal will like this :)
- per ovs maintainers' request, removed ovs offload bits - that will be handled
  in ovs userspace using switchdev genl interface.
- added switchdev features so that driver can indicate what it supports
- little renames/fixes here and there

RFC->v1 changes:
- moved include/linux/*.h -> include/net/
- moved net/core/switchdev.c -> net/switchdev/
- moved drivers/net/rocker.* -> drivers/net/ethernet/rocker/
- fixed couple of little bugs and typos
- in dsa the switch id is generated randomly
- fixed rocker schedule in atomic context bug in rocker_port_set_rx_mode
- added switchdev Netlink API

Jiri Pirko (9):
  net: rename netdev_phys_port_id to more generic name
  net: introduce generic switch devices support
  rtnl: expose physical switch id for particular device
  net-sysfs: expose physical switch id for particular device
  net: introduce dummy switch
  switchdev: add basic support for flow matching and actions
  switchdev: add swdev features
  switchdev: introduce Netlink API
  rocker: introduce rocker switch driver

 Documentation/networking/switchdev.txt           |   53 +
 MAINTAINERS                                      |   14 +
 drivers/net/Kconfig                              |    7 +
 drivers/net/Makefile                             |    1 +
 drivers/net/dummyswitch.c                        |  130 +
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 drivers/net/ethernet/rocker/Kconfig              |   29 +
 drivers/net/ethernet/rocker/Makefile             |    5 +
 drivers/net/ethernet/rocker/rocker.c             | 3561 ++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker.h             |  465 +++
 include/linux/netdevice.h                        |   49 +-
 include/net/switchdev.h                          |  160 +
 include/uapi/linux/if_link.h                     |   10 +
 include/uapi/linux/switchdev.h                   |  113 +
 net/Kconfig                                      |    1 +
 net/Makefile                                     |    3 +
 net/core/dev.c                                   |    2 +-
 net/core/net-sysfs.c                             |   26 +-
 net/core/rtnetlink.c                             |   30 +-
 net/switchdev/Kconfig                            |   20 +
 net/switchdev/Makefile                           |    6 +
 net/switchdev/switchdev.c                        |  188 ++
 net/switchdev/switchdev_netlink.c                |  441 +++
 28 files changed, 5307 insertions(+), 17 deletions(-)
 create mode 100644 Documentation/networking/switchdev.txt
 create mode 100644 drivers/net/dummyswitch.c
 create mode 100644 drivers/net/ethernet/rocker/Kconfig
 create mode 100644 drivers/net/ethernet/rocker/Makefile
 create mode 100644 drivers/net/ethernet/rocker/rocker.c
 create mode 100644 drivers/net/ethernet/rocker/rocker.h
 create mode 100644 include/net/switchdev.h
 create mode 100644 include/uapi/linux/switchdev.h
 create mode 100644 net/switchdev/Kconfig
 create mode 100644 net/switchdev/Makefile
 create mode 100644 net/switchdev/switchdev.c
 create mode 100644 net/switchdev/switchdev_netlink.c

-- 
1.9.3
