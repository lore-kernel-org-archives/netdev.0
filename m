From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [4.4-RT PATCH RFC/RFT] drivers: net: cpsw: mark rx/tx irq as IRQF_NO_THREAD
Date: Thu, 11 Aug 2016 19:15:40 +0300
Message-ID: <20160811161540.9613-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>,
	Alison Chaiken <alison@peloton-tech.com>,
	<linux-rt-users@vger.kernel.org>, <netdev@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark CPSW Rx/Tx IRQs as IRQF_NO_THREAD and avoid double scheduling on -RT
where this IRQs are forced threaded:
 rx-irq
  |- schedule threaded rx-irq handler
...
  |- threaded rx-irq handler -> cpsw_rx_interrupt()
     |- napi_schedule()
	|- __raise_softirq_irqoff()
	   |- wakeup_proper_softirq()
...
  napi

after:
 rx-irq
  |- cpsw_rx_interrupt()
     |- napi_schedule()
  |- irq_exit()
     |- invoke_softirq()
	   |- wakeup_softirqd()
...
  napi

And, as result, get benefits from the following improvements (tested
on am57xx-evm):

1) "[ 78.348599] NOHZ: local_softirq_pending 80" message will not be
   seen any more. Now these warnings can be seen once iperf is started.
   # iperf -c $IPERFHOST -w 128K  -d -t 60

2) latency reduction when cyclictest is run in parallel with network load
 where net_perf.sh is:
   iperf -c $IPERFHOST -w 8K    -d -t 60
   iperf -c $IPERFHOST -w 16K   -d -t 60
   iperf -c $IPERFHOST -w 32K   -d -t 60
   iperf -c $IPERFHOST -w 64K   -d -t 60
   iperf -c $IPERFHOST -w 128K  -d -t 60

before:
T: 0 ( 1326) P:98 I:1000 C: 240000 Min:      8 Act:   13 Avg:   18 Max:      70
T: 1 ( 1327) P:98 I:1500 C: 159981 Min:      9 Act:   15 Avg:   16 Max:      43
after:
T: 0 ( 1331) P:98 I:1000 C: 240000 Min:      8 Act:   15 Avg:   14 Max:      51
T: 1 ( 1332) P:98 I:1500 C: 159953 Min:      8 Act:   16 Avg:   15 Max:      33

3) network performance increase

win, K	Mbits/s
	before	after	%
8K	354	350.3	0.0
16K	412	551	33.7
32K	423	659.5	55.9
64K	436	728.3	67.0
128K	537	845	57.4

This change does not affect on non-RT.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
Hi All,

I'll be appreciated on any feedback or tested-by.
In case of positive feedback I'll resend it for upstream.

 drivers/net/ethernet/ti/cpsw.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 7b59283..fa4bb81 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -769,7 +769,7 @@ static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 		priv->tx_irq_disabled = true;
 	}
 
-	napi_schedule(&priv->napi_tx);
+	napi_schedule_irqoff(&priv->napi_tx);
 	return IRQ_HANDLED;
 }
 
@@ -785,7 +785,7 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 		priv->rx_irq_disabled = true;
 	}
 
-	napi_schedule(&priv->napi_rx);
+	napi_schedule_irqoff(&priv->napi_rx);
 	return IRQ_HANDLED;
 }
 
@@ -2827,7 +2827,7 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	priv->irqs_table[0] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
-			       0, dev_name(&pdev->dev), priv);
+			       IRQF_NO_THREAD, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
@@ -2842,7 +2842,7 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	priv->irqs_table[1] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
-			       0, dev_name(&pdev->dev), priv);
+			       IRQF_NO_THREAD, dev_name(&pdev->dev), priv);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
-- 
2.9.2

