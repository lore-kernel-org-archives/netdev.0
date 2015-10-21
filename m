From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/3] switchdev: fix: pass correct obj size when
 deferring obj add
Date: Wed, 21 Oct 2015 09:40:40 +0200
Message-ID: <20151021074040.GB2210@nanopsycho.orion>
References: <1445369799-2345-1-git-send-email-sfeldma@gmail.com>
 <1445369799-2345-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34069 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbJUHkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 03:40:43 -0400
Received: by wikq8 with SMTP id q8so80016538wik.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 00:40:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445369799-2345-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 20, 2015 at 09:36:38PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Fixes: 0bc05d585d ("switchdev: allow caller to explicitly request attr_set as deferred")

This "fixes" is wrong. Should be:
4d429c5ddc5128fccd3048059ae26bb39f0d8284
"switchdev: introduce possibility to defer obj_add/del"


>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> net/switchdev/switchdev.c |   19 ++++++++++++++++++-
> 1 file changed, 18 insertions(+), 1 deletion(-)
>
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index 56d8479..be8ced1 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -489,7 +489,24 @@ static void switchdev_port_obj_del_deferred(struct net_device *dev,
> static int switchdev_port_obj_del_defer(struct net_device *dev,
> 					const struct switchdev_obj *obj)
> {
>-	return switchdev_deferred_enqueue(dev, obj, sizeof(*obj),
>+	size_t size = 0;
>+
>+	switch (obj->id) {
>+	case SWITCHDEV_OBJ_ID_PORT_VLAN:
>+		size = sizeof(struct switchdev_obj_port_vlan);
>+		break;
>+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
>+		size = sizeof(struct switchdev_obj_ipv4_fib);
>+		break;
>+	case SWITCHDEV_OBJ_ID_PORT_FDB:
>+		size = sizeof(struct switchdev_obj_port_fdb);
>+		break;
>+	default:
>+		WARN_ON(!size);
>+		return -EINVAL;
>+	}
>+
>+	return switchdev_deferred_enqueue(dev, obj, size,
> 					  switchdev_port_obj_del_deferred);

we need this for add as well. Perhaps some generic helper to get size of
obj?


> }
> 
>-- 
>1.7.10.4
>
