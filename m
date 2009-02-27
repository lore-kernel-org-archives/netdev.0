From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH v3] net: more timeouts that reach -1
Date: Fri, 27 Feb 2009 17:43:06 +0100
Message-ID: <49A8181A.5030106@gmail.com>
References: <49A5286D.80304@gmail.com> <20090227114015.M80857@cooldavid.org> <25e057c00902270737x529fb5b8m2fdbb044fa75ab0d@mail.gmail.com> <20090227154440.M53654@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:55365 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126AbZB0QnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 11:43:09 -0500
Received: by an-out-0708.google.com with SMTP id c2so925145anc.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 08:43:06 -0800 (PST)
In-Reply-To: <20090227154440.M53654@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guo-Fu Tseng wrote:
> On Fri, 27 Feb 2009 16:37:30 +0100, roel kluin wrote
>> On Fri, Feb 27, 2009 at 12:43 PM, Guo-Fu Tseng <cooldavid@cooldavid.org> wrote:
>>> There should be no difference after this modification.
>>> The return value of this function is: "limit > 0 ? limit : 0;"
>> There is:
>> In the last iteration limit is 1 during the test before it is decremented to 0.
>>
>> rxdesc = rxring->desc;
>> rxdesc += i;
>>
>> If then we break out of the loop by the 'goto out;', we continue with:
>>
>> out:
>>         atomic_set(&rxring->next_to_clean, i);
>>
>> out_inc:
>>         atomic_inc(&jme->rx_cleaning);
>>
>> but since limit is already decremented, 0 is returned.
>>
>>> Guo-Fu Tseng
>>>
>> Roel
> I see.
> But the correct patch should be following one, right?
> 
> ===================================================================
> --- jme.c	(revision 580)
> +++ jme.c	(working copy)
> @@ -958,13 +958,14 @@
>  		goto out_inc;
>  
>  	i = atomic_read(&rxring->next_to_clean);
> -	while (limit-- > 0) {
> +	while (limit > 0) {
>  		rxdesc = rxring->desc;
>  		rxdesc += i;
>  
>  		if ((rxdesc->descwb.flags & RXWBFLAG_OWN) ||
>  		!(rxdesc->descwb.desccnt & RXWBDCNT_WBCPL))
>  			goto out;
> +		--limit;
>  
>  		desccnt = rxdesc->descwb.desccnt & RXWBDCNT_DCNT;
>  
> 
> 
> 
> Guo-Fu Tseng

Correct, thanks.
Here are all three patches again with another issue I spotted in 
drivers/net/ucc_geth_mii.c:

After my patch it still wouldn't err, because timeout was unsigned.
------------------------------>8-------------8<---------------------------------
with while (timeout-- > 0); timeout reaches -1 after the loop, so the tests
below are off by one. also don't do an '< 0' test on an unsigned.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 1cf2f94..f3a1274 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -560,7 +560,7 @@ ks8695_reset(struct ks8695_priv *ksp)
 		msleep(1);
 	}
 
-	if (reset_timeout == 0) {
+	if (reset_timeout < 0) {
 		dev_crit(ksp->dev,
 			 "Timeout waiting for DMA engines to reset\n");
 		/* And blithely carry on */
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 08b3405..a6e1a35 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -957,13 +957,14 @@ jme_process_receive(struct jme_adapter *jme, int limit)
 		goto out_inc;
 
 	i = atomic_read(&rxring->next_to_clean);
-	while (limit-- > 0) {
+	while (limit > 0) {
 		rxdesc = rxring->desc;
 		rxdesc += i;
 
 		if ((rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_OWN)) ||
 		!(rxdesc->descwb.desccnt & RXWBDCNT_WBCPL))
 			goto out;
+		--limit;
 
 		desccnt = rxdesc->descwb.desccnt & RXWBDCNT_DCNT;
 
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 5463591..0ada4ed 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -107,7 +107,7 @@ int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 static int uec_mdio_reset(struct mii_bus *bus)
 {
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
-	unsigned int timeout = PHY_INIT_TIMEOUT;
+	int timeout = PHY_INIT_TIMEOUT;
 
 	mutex_lock(&bus->mdio_lock);
 
@@ -123,7 +123,7 @@ static int uec_mdio_reset(struct mii_bus *bus)
 
 	mutex_unlock(&bus->mdio_lock);
 
-	if (timeout <= 0) {
+	if (timeout < 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
 		return -EBUSY;
 	}
