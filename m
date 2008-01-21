From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2/3] RDMA/cxgb3: fix page shift calculation in
	build_phys_page_list()
Date: Mon, 21 Jan 2008 14:39:36 -0600
Message-ID: <20080121203935.3143.12791.stgit@dell3.ogc.int>
References: <20080121203829.3143.26181.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080121203829.3143.26181.stgit@dell3.ogc.int>
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


RDMA/cxgb3: fix page shift calculation in build_phys_page_list()

The existing logic incorrectly maps this buffer list:

0: addr 0x10001000, size 0x1000
1: addr 0x10002000, size 0x1000

To this bogus page list:

0: 0x10000000
1: 0x10002000

The shift calculation must also take into account the address of the firs=
t
entry masked by the page_mask as well as the last address+size rounded
up to the next page size.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_mem.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_mem.c b/drivers/infiniband/=
hw/cxgb3/iwch_mem.c
index a6c2c4b..73bfd16 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_mem.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_mem.c
@@ -122,6 +122,13 @@ int build_phys_page_list(struct ib_phys_buf *buffer_=
list,
 		*total_size +=3D buffer_list[i].size;
 		if (i > 0)
 			mask |=3D buffer_list[i].addr;
+		else
+			mask |=3D buffer_list[i].addr & PAGE_MASK;
+		if (i !=3D num_phys_buf - 1)
+			mask |=3D buffer_list[i].addr + buffer_list[i].size;
+		else
+			mask |=3D (buffer_list[i].addr + buffer_list[i].size +
+				PAGE_SIZE - 1) & PAGE_MASK;
 	}
=20
 	if (*total_size > 0xFFFFFFFFULL)
