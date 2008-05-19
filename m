From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v2 00/13] QLogic VNIC Driver
Date: Mon, 19 May 2008 16:01:23 +0530
Message-ID: <20080519102843.12355.832.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland,

This is the second round of QLogic Virtual NIC driver patch series for submission
to 2.6.27 kernel. The series has been tested against your for-2.6.27 branch.

Based on comments received on first series of patches, following fixes are
introduced in this series:

        -  Removal of IB cache implementation for QLogic VNIC ULP.
        -  netdev->priv structure allocation through alloc_netdev and use of
           netdev_priv() to access the same.
        -  Implementation of spinlock to protect potential vnic->current_path
           race conditions.
        -  Removed the use of "vnic->xmit_started" variable.
        -  vnic_multicast.c coding style and lock fixes.
        -  Use of "time_after" macro for jiffies comparison.
        -  vnic_npevent_str has been moved to vnic_main.c to avoid its
           inclusion every time along with vnic_main.h
        -  Use of kernel "is_power_of_2" function in place of driver's own.
        -  Global "recv_ref" variable has been renamed to "vnic_recv_ref".

I have signed-off all patches in the series. The sparse endianness checking
for the driver did not give any warnings and checkpatch.pl have few warnings
indicating lines slightly longer than 80 columns.

Background:
As mentioned in the first version of patch series, this series adds QLogic
Virtual NIC (VNIC) driver which works in conjunction with the the QLogic
Ethernet Virtual I/O Controller (EVIC) hardware. The VNIC driver along with the
QLogic EVIC's two 10 Gigabit ethernet ports, enables Infiniband clusters to
connect to Ethernet networks. This driver also works with the earlier version of
the I/O Controller, the VEx.

The QLogic VNIC driver creates virtual ethernet interfaces and tunnels the
Ethernet data to/from the EVIC over Infiniband using an Infiniband reliable
connection.

      [PATCH v2 01/13] QLogic VNIC: Driver - netdev implementation
      [PATCH v2 02/13] QLogic VNIC: Netpath - abstraction of connection to EVIC/VEx
      [PATCH v2 03/13] QLogic VNIC: Implementation of communication protocol with EVIC/VEx
      [PATCH v2 04/13] QLogic VNIC: Implementation of Control path of communication protocol
      [PATCH v2 05/13] QLogic VNIC: Implementation of Data path of communication protocol
      [PATCH v2 06/13] QLogic VNIC: IB core stack interaction
      [PATCH v2 07/13] QLogic VNIC: Handling configurable parameters of the driver
      [PATCH v2 08/13] QLogic VNIC: sysfs interface implementation for the driver
      [PATCH v2 09/13] QLogic VNIC: IB Multicast for Ethernet broadcast/multicast
      [PATCH v2 10/13] QLogic VNIC: Driver Statistics collection
      [PATCH v2 11/13] QLogic VNIC: Driver utility file - implements various utility macros
      [PATCH v2 12/13] QLogic VNIC: Driver Kconfig and Makefile.
      [PATCH v2 13/13] QLogic VNIC: Modifications to IB Kconfig and Makefile

 drivers/infiniband/Kconfig                         |    2 
 drivers/infiniband/Makefile                        |    1 
 drivers/infiniband/ulp/qlgc_vnic/Kconfig           |   28 
 drivers/infiniband/ulp/qlgc_vnic/Makefile          |   13 
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c     |  379 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h     |  242 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.c    | 2286 ++++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.h    |  179 ++
 .../infiniband/ulp/qlgc_vnic/vnic_control_pkt.h    |  368 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.c       | 1492 +++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.h       |  206 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.c         | 1043 +++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.h         |  206 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.c       | 1098 ++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.h       |  154 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c  |  319 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h  |   77 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c    |  112 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h    |   79 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c      |  234 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h      |  497 ++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c        | 1131 ++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h        |   62 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_trailer.h    |  103 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_util.h       |  250 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.c     | 1214 +++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.h     |  176 ++
 27 files changed, 11951 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/Kconfig
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/Makefile
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_control.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_control.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_control_pkt.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_data.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_data.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_main.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_main.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_trailer.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_util.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.h

-- 
Regards,
Ram
