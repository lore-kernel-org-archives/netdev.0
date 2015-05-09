From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 10/23] switchdev: add bridge port flags attr
Date: Sat, 9 May 2015 20:47:53 +0200
Message-ID: <20150509184752.GB2290@nanopsycho>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
 <1431193225-807-11-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35893 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbbEISr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 14:47:59 -0400
Received: by wgiu9 with SMTP id u9so97230713wgi.3
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 11:47:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431193225-807-11-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 09, 2015 at 07:40:12PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>rocker: use switchdev get/set attr for bridge port flags
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>


>---
> drivers/net/ethernet/rocker/rocker.c |   24 ++++++++++++++++++++++++
> include/net/switchdev.h              |    2 ++
> 2 files changed, 26 insertions(+)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 048d4b7..f9281ea 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -4346,6 +4346,9 @@ static int rocker_port_attr_get(struct net_device *dev,
> 		attr->ppid.id_len = sizeof(rocker->hw.id);
> 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
> 		break;
>+	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
>+		attr->brport_flags = rocker_port->brport_flags;
>+		break;
> 	default:
> 		return -EOPNOTSUPP;
> 	}
>@@ -4363,6 +4366,23 @@ static void rocker_port_trans_abort(struct rocker_port *rocker_port)
> 	}
> }
> 
>+static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
>+					unsigned long brport_flags)
>+{
>+	unsigned long orig_flags;
>+	int err = 0;
>+
>+	orig_flags = rocker_port->brport_flags;
>+	rocker_port->brport_flags = brport_flags;
>+	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
>+		err = rocker_port_set_learning(rocker_port);
>+
>+	if (rocker_port->trans == SWITCHDEV_TRANS_PREPARE)
>+		rocker_port->brport_flags = orig_flags;
>+
>+	return err;
>+}
>+
> static int rocker_port_attr_set(struct net_device *dev,
> 				struct switchdev_attr *attr)
> {
>@@ -4386,6 +4406,10 @@ static int rocker_port_attr_set(struct net_device *dev,
> 	case SWITCHDEV_ATTR_PORT_STP_STATE:
> 		err = rocker_port_stp_update(rocker_port, attr->stp_state);
> 		break;
>+	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
>+		err = rocker_port_brport_flags_set(rocker_port,
>+						   attr->brport_flags);
>+		break;
> 	default:
> 		err = -EOPNOTSUPP;
> 		break;
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index e598c2d..6cf6de1 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -27,6 +27,7 @@ enum switchdev_attr_id {
> 	SWITCHDEV_ATTR_UNDEFINED,
> 	SWITCHDEV_ATTR_PORT_PARENT_ID,
> 	SWITCHDEV_ATTR_PORT_STP_STATE,
>+	SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS,
> };
> 
> struct switchdev_attr {
>@@ -36,6 +37,7 @@ struct switchdev_attr {
> 	union {
> 		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
> 		u8 stp_state;				/* PORT_STP_STATE */
>+		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
> 	};
> };
> 
>-- 
>1.7.10.4
>
