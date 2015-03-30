From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
Date: Mon, 30 Mar 2015 22:46:12 +0200
Message-ID: <20150330204612.GA10481@nanopsycho.orion>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
 <1427704836-8776-3-git-send-email-sfeldma@gmail.com>
 <E4CD12F19ABA0C4D8729E087A761DC35067FA6FE@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38461 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbbC3UqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 16:46:15 -0400
Received: by wibgn9 with SMTP id gn9so375337wib.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 13:46:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FA6FE@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 30, 2015 at 08:32:09PM CEST, ronen.arad@intel.com wrote:
>
>
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>Behalf Of sfeldma@gmail.com
>>Sent: Monday, March 30, 2015 1:40 AM
>>To: netdev@vger.kernel.org
>>Cc: jiri@resnulli.us; roopa@cumulusnetworks.com; linux@roeck-us.net;
>>f.fainelli@gmail.com
>>Subject: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
>>
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Add the basic algorithms for get/set attr ops.  Use the same recusive algo to
>>walk lower devs we've used for STP updates, for example.  For get, compare
>>attr
>>value for each lower dev and only return success if attr values match across
>>all lower devs.  For sets, set the same attr value for all lower devs.  If
>>something goes wrong on one of the lower devs, revert all back to previous
>>attr
>>value.
>>
>>If lower dev recusion isn't desired, allow a flag SWDEV_ATTR_F_NO_RECURSE to
>>indicate get/set only work on port (lowest) device.
>>
>>On set, allow a flag SWDEV_ATTR_F_NO_RECOVER to turn off automatic err
>>recovery.
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>> include/net/switchdev.h   |    4 +++
>> net/switchdev/switchdev.c |   71 +++++++++++++++++++++++++++++++++++++++++++-
>>-
>> 2 files changed, 73 insertions(+), 2 deletions(-)
>>
>>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>index 7b72a4f..dcf0cb7 100644
>>--- a/include/net/switchdev.h
>>+++ b/include/net/switchdev.h
>>@@ -18,8 +18,12 @@ enum swdev_attr_id {
>> 	SWDEV_ATTR_UNDEFINED,
>> };
>>
>>+#define SWDEV_ATTR_F_NO_RECURSE		BIT(0)
>>+#define SWDEV_ATTR_F_NO_RECOVER		BIT(1)
>>+
>> struct swdev_attr {
>> 	enum swdev_attr_id attr;
>>+	u32 flags;
>> };
>>
>> struct fib_info;
>>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>>index a894fa5..f3cac92 100644
>>--- a/net/switchdev/switchdev.c
>>+++ b/net/switchdev/switchdev.c
>>@@ -44,10 +44,67 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
>>  */
>> int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
>> {
>>-	return -EOPNOTSUPP;
>>+	const struct swdev_ops *ops = dev->swdev_ops;
>>+	struct net_device *lower_dev;
>>+	struct list_head *iter;
>>+	struct swdev_attr first = {
>>+		.attr = SWDEV_ATTR_UNDEFINED
>>+	};
>>+	int err = -EOPNOTSUPP;
>>+
>>+	if (ops && ops->swdev_port_attr_get)
>>+		return ops->swdev_port_attr_get(dev, attr);
>>+
>>+	if (attr->flags & SWDEV_ATTR_F_NO_RECURSE)
>>+		return err;
>>+
>>+	/* Switch device port(s) may be stacked under
>>+	 * bond/team/vlan dev, so recurse down to get attr on
>>+	 * each port.  Return -ENODATA if attr values don't
>>+	 * compare across ports.
>>+	 */
>>+
>>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>+		err = swdev_port_attr_get(lower_dev, attr);
>>+		if (err)
>>+			break;
>>+		if (first.attr == SWDEV_ATTR_UNDEFINED)
>>+			first = *attr;
>>+		else if (memcmp(&first, attr, sizeof(*attr)))
>>+			return -ENODATA;
>>+	}
>>+
>>+	return err;
>> }
>> EXPORT_SYMBOL_GPL(swdev_port_attr_get);
>>
>>+static int _swdev_port_attr_set(struct net_device *dev, struct swdev_attr
>>*attr)
>>+{
>>+	const struct swdev_ops *ops = dev->swdev_ops;
>>+	struct net_device *lower_dev;
>>+	struct list_head *iter;
>>+	int err = -EOPNOTSUPP;
>>+
>>+	if (ops && ops->swdev_port_attr_set)
>>+		return ops->swdev_port_attr_set(dev, attr);
>>+
>>+	if (attr->flags & SWDEV_ATTR_F_NO_RECURSE)
>>+		return err;
>>+
>>+	/* Switch device port(s) may be stacked under
>>+	 * bond/team/vlan dev, so recurse down to set attr on
>>+	 * each port.
>>+	 */
>>+
>>+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>+		err = _swdev_port_attr_set(lower_dev, attr);
>>+		if (err)
>>+			break;
>>+	}
>>+
>>+	return err;
>>+}
>>+
>> /**
>>  *	swdev_port_attr_set - Set port attribute
>>  *
>>@@ -56,7 +113,17 @@ EXPORT_SYMBOL_GPL(swdev_port_attr_get);
>>  */
>> int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>> {
>>-	return -EOPNOTSUPP;
>>+	struct swdev_attr prev = *attr;
>>+	int err, get_err;
>>+
>>+	get_err = swdev_port_attr_get(dev, &prev);
>>+
>>+	err = _swdev_port_attr_set(dev, attr);
>>+	if (err && !get_err && !(attr->flags & SWDEV_ATTR_F_NO_RECOVER))
>>+		/* Some err on set: revert to previous value */
>>+		_swdev_port_attr_set(dev, &prev);
>
>Could revering to previous value fail?

I believe that it certainly could

>Should such failure be logged?

That is a good point.

Also, looking at the function name, seems nicer to me to use "__"
instead of "_" as a function prefix. Not sure if that is some rule
somewhere.

>
>>+
>>+	return err;
>> }
>> EXPORT_SYMBOL_GPL(swdev_port_attr_set);
>>
>>--
>>1.7.10.4
>>
>>--
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
