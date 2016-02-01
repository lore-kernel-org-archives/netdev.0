From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC net-next 2/9] net/switchdev: Introduce hardware offload
 support
Date: Mon, 1 Feb 2016 10:06:27 +0100
Message-ID: <20160201090626.GA2174@nanopsycho.orion>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
 <1454315685-32202-3-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33745 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbcBAJG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 04:06:29 -0500
Received: by mail-wm0-f65.google.com with SMTP id r129so8094864wmr.0
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 01:06:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1454315685-32202-3-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 01, 2016 at 09:34:38AM CET, amir@vadai.me wrote:
>Extend the switchdev API with new operations: switchdev_port_flow_add()
>and switchdev_port_flow_del().
>It allows the user to add/del a hardware offloaded flow classification
>and actions.
>For every new flow object a cookie is supplied. This cookie will be
>used later on to identify the flow when removed.
>
>In order to make the API as flexible as possible, flow_dissector is
>being used to describe the flow classifier.
>
>Every new flow object is consists of a flow_dissector+key+mask to
>describe the classifier and a switchdev_obj_port_flow_act to describe
>the actions and their attributes.
>
>object is passed to the lower layer driver to be pushed into the
>hardware.
>
>Signed-off-by: Amir Vadai <amir@vadai.me>
>---
> include/net/switchdev.h   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
> net/switchdev/switchdev.c | 33 +++++++++++++++++++++++++++++++++
> 2 files changed, 79 insertions(+)
>
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index d451122..c5a5681 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -15,6 +15,7 @@
> #include <linux/notifier.h>
> #include <linux/list.h>
> #include <net/ip_fib.h>
>+#include <net/flow_dissector.h>
> 
> #define SWITCHDEV_F_NO_RECURSE		BIT(0)
> #define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
>@@ -69,6 +70,7 @@ enum switchdev_obj_id {
> 	SWITCHDEV_OBJ_ID_IPV4_FIB,
> 	SWITCHDEV_OBJ_ID_PORT_FDB,
> 	SWITCHDEV_OBJ_ID_PORT_MDB,
>+	SWITCHDEV_OBJ_ID_PORT_FLOW,
> };
> 
> struct switchdev_obj {
>@@ -124,6 +126,30 @@ struct switchdev_obj_port_mdb {
> #define SWITCHDEV_OBJ_PORT_MDB(obj) \
> 	container_of(obj, struct switchdev_obj_port_mdb, obj)
> 
>+/* SWITCHDEV_OBJ_ID_PORT_FLOW */
>+enum switchdev_obj_port_flow_action {
>+	SWITCHDEV_OBJ_PORT_FLOW_ACT_DROP = 0,
>+	SWITCHDEV_OBJ_PORT_FLOW_ACT_MARK = 1,
>+};
>+
>+struct switchdev_obj_port_flow_act {
>+	u32 actions; /* Bitmap of requested actions */
>+	u32 mark; /* Value for mark action - if requested */

This approach is certainly not correct. We need a list of actions here
instead of bitmap.
