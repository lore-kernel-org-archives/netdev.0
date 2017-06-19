From: Ganesh GR <ganeshgr@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: notify uP to route ctrlq compl to rdma
 rspq
Date: Mon, 19 Jun 2017 13:53:51 +0000
Message-ID: <CY4PR12MB1432D0980746A4195B8CBFBFC1C40@CY4PR12MB1432.namprd12.prod.outlook.com>
References: <1497874248-9716-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Nirranjan Kirubaharan <nirranjan@chelsio.com>,
        Indranil Choudhury <indranil@chelsio.com>,
        Venkatesh Pottem <venkatesh@chelsio.com>,
        "Raju Rangoju" <rajur@chelsio.com>, Stable <stable@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1497874248-9716-1-git-send-email-ganeshgr@chelsio.com>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch is supposed to go to net tree, I will send a v2.





From: Ganesh Goudar <ganeshgr@chelsio.com>
Sent: Monday, June 19, 2017 5:40 PM
To: netdev@vger.kernel.org; davem@davemloft.net
Cc: Nirranjan Kirubaharan; Indranil Choudhury; Venkatesh Pottem; Raju Rango=
ju; Stable; Ganesh GR
Subject: [PATCH net-next] cxgb4: notify uP to route ctrlq compl to rdma rsp=
q
=A0   =20
From: Raju Rangoju <rajur@chelsio.com>

During the module initialisation there is a possible race
(basically race between uld and lld) where neither the uld
nor lld notifies the uP about where to route the ctrl queue
completions. LLD skips notifying uP as the rdma queues were
not created by then (will leave it to ULD to notify the uP).
As the ULD comes up, it also skips notifying the uP as the
flag FULL_INIT_DONE is not set yet (ULD assumes that the
interface is not up yet).

Consequently, this race between uld and lld leaves uP
unnotified about where to send the ctrl queue completions
to, leading to iwarp RI_RES WR failure.

Here is the race:

CPU 0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 CPU1

- allocates nic rx queus
- t4_sge_alloc_ctrl_txq()
(if rdma rsp queues exists,
tell uP to route ctrl queue
compl to rdma rspq)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 - acquires the mutex_lock
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 - allocates rdma response queues
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 - if FULL_INIT_DONE set,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 tell uP to route ctrl queue compl
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 to rdma rspq
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 - relinquishes mutex_lock
- acquires the mutex_lock
- enable_rx()
- set FULL_INIT_DONE
- relinquishes mutex_lock

This patch fixes the above issue.

Fixes: e7519f9926f1('cxgb4: avoid enabling napi twice to the same queue')
Signed-off-by: Raju Rangoju <rajur@chelsio.com>
Acked-by: Steve Wise <swise@opengridcomputing.com>
CC: Stable <stable@vger.kernel.org> # 4.9+
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
=A0drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 10 ++++++----
=A01 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/=
ethernet/chelsio/cxgb4/cxgb4_main.c
index ea1bfcf..53309f6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2171,9 +2171,10 @@ static int cxgb_up(struct adapter *adap)
=A0{
=A0=A0=A0=A0=A0=A0=A0=A0 int err;
=A0
+=A0=A0=A0=A0=A0=A0 mutex_lock(&uld_mutex);
=A0=A0=A0=A0=A0=A0=A0=A0 err =3D setup_sge_queues(adap);
=A0=A0=A0=A0=A0=A0=A0=A0 if (err)
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto out;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto rel_lock;
=A0=A0=A0=A0=A0=A0=A0=A0 err =3D setup_rss(adap);
=A0=A0=A0=A0=A0=A0=A0=A0 if (err)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto freeq;
@@ -2197,7 +2198,6 @@ static int cxgb_up(struct adapter *adap)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 go=
to irq_err;
=A0=A0=A0=A0=A0=A0=A0=A0 }
=A0
-=A0=A0=A0=A0=A0=A0 mutex_lock(&uld_mutex);
=A0=A0=A0=A0=A0=A0=A0=A0 enable_rx(adap);
=A0=A0=A0=A0=A0=A0=A0=A0 t4_sge_start(adap);
=A0=A0=A0=A0=A0=A0=A0=A0 t4_intr_enable(adap);
@@ -2210,13 +2210,15 @@ static int cxgb_up(struct adapter *adap)
=A0#endif
=A0=A0=A0=A0=A0=A0=A0=A0 /* Initialize hash mac addr list*/
=A0=A0=A0=A0=A0=A0=A0=A0 INIT_LIST_HEAD(&adap->mac_hlist);
- out:
=A0=A0=A0=A0=A0=A0=A0=A0 return err;
+
=A0 irq_err:
=A0=A0=A0=A0=A0=A0=A0=A0 dev_err(adap->pdev_dev, "request_irq failed, err %=
d\n", err);
=A0 freeq:
=A0=A0=A0=A0=A0=A0=A0=A0 t4_free_sge_resources(adap);
-=A0=A0=A0=A0=A0=A0 goto out;
+ rel_lock:
+=A0=A0=A0=A0=A0=A0 mutex_unlock(&uld_mutex);
+=A0=A0=A0=A0=A0=A0 return err;
=A0}
=A0
=A0static void cxgb_down(struct adapter *adapter)
--=20
2.1.0

    =
