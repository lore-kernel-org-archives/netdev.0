From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: mlx4: "failed to allocate default counter port 1"
Date: Wed, 1 Jul 2015 16:18:07 +0300
Message-ID: <5593E88F.10006@mellanox.com>
References: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
 <5592913C.3000207@mellanox.com>
 <alpine.LFD.2.11.1506301520180.1799@denkbrett>
 <55929F2D.9050805@mellanox.com>
 <alpine.LFD.2.11.1506301615100.1799@denkbrett>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eran Ben Elisha <eranbe@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	<netdev@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0054.outbound.protection.outlook.com ([157.56.112.54]:52096
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752374AbbGANS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 09:18:28 -0400
In-Reply-To: <alpine.LFD.2.11.1506301615100.1799@denkbrett>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/30/2015 5:17 PM, Sebastian Ott wrote:
> On Tue, 30 Jun 2015, Or Gerlitz wrote:
>> On 6/30/2015 4:24 PM, Sebastian Ott wrote:
>>>>> Do you run the VF on the same system/kernel as the PF, or the VF is
>>>>> probed to
>>>>> VM which runs the latest kernel and the PF runsolder kernel (which?)
>>> The latter case. The PF is driven by a much older Kernel running OFED
>>> 2.3.2.0.0.1
>>>
>> Can you try running the inbox PF driver that comes with the PF kernel (what
>> kernel is that?) I'd like to see we're OK there.
> Frankly, I don't know. Plus I also don't know how to build an ofed kernel.
>

I didn't want you to build that package, but rather the outer way 
around, namely
see what happens if uninstalling this package and running with the mlx4 
inbox PF
driver from the kernel provided from your distro of choice or an 
upstreamkernel installed
by you. Anyway, I hope the below patch would provide a quick band-aid 
and let
you to continue running upstream VFs over that PF config, let me know (I 
will be
OOO till Thu-Sun). Once we see how this behaves, will take it from there.

Or.


diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c 
b/drivers/net/ethernet/mellanox/mlx4/main.c
index 12fbfcb..a66cc6e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2273,6 +2273,10 @@ static int mlx4_allocate_default_counters(struct 
mlx4_dev *dev)
                 } else if (err == -ENOENT) {
                         err = 0;
                         continue;
+               } else if (mlx4_is_slave(dev) && err == -EINVAL) {
+                       priv->def_counter[port] = 
MLX4_SINK_COUNTER_INDEX(dev);
+                       mlx4_warn(dev, "can't allocate counter from old 
PF driver, using index %d\n",
+ MLX4_SINK_COUNTER_INDEX(dev));
                 } else {
                         mlx4_err(dev, "%s: failed to allocate default 
counter port %d err %d\n",
                                  __func__, port + 1, err);
