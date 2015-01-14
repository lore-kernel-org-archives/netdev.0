From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next] bridge: fix setlink/dellink notifications
Date: Wed, 14 Jan 2015 23:22:00 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505DEE86A@ORSMSX101.amr.corp.intel.com>
References: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>
To: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33372 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbbANXWC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 18:22:02 -0500
In-Reply-To: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of roopa@cumulusnetworks.com
>Sent: Tuesday, January 13, 2015 10:49 PM
>To: netdev@vger.kernel.org; shemminger@vyatta.com; vyasevic@redhat.com;
>john.fastabend@gmail.com; tgraf@suug.ch; jhs@mojatatu.com; sfeldma@gmail.com;
>jiri@resnulli.us
>Cc: wkok@cumulusnetworks.com
>Subject: [PATCH net-next] bridge: fix setlink/dellink notifications
>
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
[..]
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index d06107d..4ac79ff 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -2876,13 +2876,6 @@ static int rtnl_bridge_notify(struct net_device *dev,
>u16 flags)

The 'flags' argument was only used for applying the same handling of
MASTER/SELF flags to notification as used for setlink/delink.
This patch eliminates the MASTER case and leaves only SELF notification.
It seems clearer to eliminate flags argument and rename the function to
something like rtnl_bridge_self_notify().
   
> 		goto errout;
> 	}
>
>-	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
>-	    br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
>-		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
>-		if (err < 0)
>-			goto errout;
>-	}
>-
> 	if ((flags & BRIDGE_FLAGS_SELF) &&
> 	    dev->netdev_ops->ndo_bridge_getlink) {
> 		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
>@@ -2958,16 +2951,19 @@ static int rtnl_bridge_setlink(struct sk_buff *skb,
>struct nlmsghdr *nlh)
> 			err = -EOPNOTSUPP;
> 		else
> 			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
>-
>-		if (!err)
>+		if (!err) {
> 			flags &= ~BRIDGE_FLAGS_SELF;
>+
>+			/* Generate event to notify upper layer of bridge
>+			 * change
>+			 */
>+			if (!err)
>+				err = rtnl_bridge_notify(dev, oflags);
>+		}
> 	}
>
> 	if (have_flags)
> 		memcpy(nla_data(attr), &flags, sizeof(flags));

What is the purpose of the above two lines (not changed by the patch)?
They seem to copy over the flags with the successfully applied cases
(MASTER and/or SELF) flags cleared back into the incoming netlink message.
I could not figure any place where the modified flags attribute is used

>-	/* Generate event to notify upper layer of bridge change */
>-	if (!err)
>-		err = rtnl_bridge_notify(dev, oflags);
> out:
> 	return err;
> }
>@@ -3032,15 +3028,19 @@ static int rtnl_bridge_dellink(struct sk_buff *skb,
>struct nlmsghdr *nlh)
> 		else
> 			err = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
>
>-		if (!err)
>+		if (!err) {
> 			flags &= ~BRIDGE_FLAGS_SELF;
>+
>+			/* Generate event to notify upper layer of bridge
>+			 * change
>+			 */
>+			err = rtnl_bridge_notify(dev, oflags);
>+		}
>+
> 	}
>
> 	if (have_flags)
> 		memcpy(nla_data(attr), &flags, sizeof(flags));
>-	/* Generate event to notify upper layer of bridge change */
>-	if (!err)
>-		err = rtnl_bridge_notify(dev, oflags);
> out:
> 	return err;
> }
>--
>1.7.10.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
