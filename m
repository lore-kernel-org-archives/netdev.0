From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] bridge: Check return of dev_set_promiscuity (v3)
Date: Sat, 21 Jun 2008 13:45:40 +0800
Message-ID: <485C9584.3090702@cn.fujitsu.com>
References: <485AFFE4.4000300@cn.fujitsu.com>	<20080619181819.15b2cc9d@extreme>	<485B16BB.1000604@cn.fujitsu.com> <20080620204855.351c3cbb@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62297 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbYFUFto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jun 2008 01:49:44 -0400
In-Reply-To: <20080620204855.351c3cbb@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2008-6-21 11:48:
> Alternate version of Wang Chen's patch to handle dev_set_promiscuity
> errors.  I tried and make unwinds clearer here. The kobject_put can
> just be replace by immediate kfree since object never gets registered
> if going through that path.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 

oops, In my previous patch, I said I want to add your sof, but
obviously I made a typo and add Patrick's sof instead of yours.
Sorry for that.

> --- a/net/bridge/br_if.c	2008-06-20 15:57:51.000000000 -0700
> +++ b/net/bridge/br_if.c	2008-06-20 16:15:47.000000000 -0700
> @@ -373,10 +373,15 @@ int br_add_if(struct net_bridge *br, str
>  	if (IS_ERR(p))
>  		return PTR_ERR(p);
>  
> +	err = dev_set_promiscuity(dev, 1);
> +	if (err)
> +		goto err_free;
> +
> +
>  	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
>  				   SYSFS_BRIDGE_PORT_ATTR);
>  	if (err)
> -		goto err0;
> +		goto err_unset_promiscuity;
>  
>  	err = br_fdb_insert(br, p, dev->dev_addr);
>  	if (err)
> @@ -388,7 +393,6 @@ int br_add_if(struct net_bridge *br, str
>  
>  	rcu_assign_pointer(dev->br_port, p);
>  	dev_disable_lro(dev);
> -	dev_set_promiscuity(dev, 1);
>  
>  	list_add_rcu(&p->list, &br->port_list);
>  
> @@ -408,14 +412,17 @@ int br_add_if(struct net_bridge *br, str
>  	kobject_uevent(&p->kobj, KOBJ_ADD);
>  
>  	return 0;
> +
>  err2:
>  	br_fdb_delete_by_port(br, p, 1);
>  err1:
>  	kobject_del(&p->kobj);
>  	goto put_back;

can't just goto put_back;
need to unset promiscuity.

> -err0:
> -	kobject_put(&p->kobj);
>  

Still needs kobject_put().
Because although kobject_init_and_add() failed,
part of it maybe done, such as init part.
And init of kobject will set kobj->ref to 1.

> +err_unset_promiscuity:
> +	dev_set_promiscuity(dev, -1);
> +err_free:
> +	kfree(p);
>  put_back:
>  	dev_put(dev);
>  	return err;
> 

Here is v3. (Stephen, I put your SOF in, if you disagree, please let David know.)
- if kobject_init_and_add() failed, do kobject_put().
  if error happen after kobject_init_and_add() being done, do kobjct_del and put.
- kfree after dev_put.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/bridge/br_if.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c2397f5..58bbfb8 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -375,6 +375,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	err = dev_set_promiscuity(dev, 1);
+	if (err)
+		goto put_back;
+
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
 	if (err)
@@ -389,7 +393,6 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
-	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
 
@@ -413,12 +416,12 @@ err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
 	kobject_del(&p->kobj);
-	goto put_back;
 err0:
 	kobject_put(&p->kobj);
-
+	dev_set_promiscuity(dev, -1);
 put_back:
 	dev_put(dev);
+	kfree(p);
 	return err;
 }
 
-- 
1.5.3.4

