From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next V3 2/2] rtnl: Add support for netdev event
 attribute to link messages
Date: Sun, 23 Apr 2017 19:07:56 -0600
Message-ID: <877efb54-2aef-4d1e-c0b4-2ce6aa6562df@cumulusnetworks.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
 <1492795881-11914-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
        roopa <roopa@cumulusnetworks.com>, Jiri Pirko <jiri@resnulli.us>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38113 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163875AbdDXBIS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 21:08:18 -0400
Received: by mail-it0-f43.google.com with SMTP id e132so35815142ite.1
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 18:08:18 -0700 (PDT)
In-Reply-To: <1492795881-11914-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/17 11:31 AM, Vladislav Yasevich wrote:
> @@ -1276,9 +1277,40 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
>  	return err;
>  }
>  
> +static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
> +{
> +	u32 rtnl_event;
> +
> +	switch (event) {
> +	case NETDEV_REBOOT:
> +		rtnl_event = IFLA_EVENT_REBOOT;
> +		break;
> +	case NETDEV_FEAT_CHANGE:
> +		rtnl_event = IFLA_EVENT_FEAT_CHANGE;
> +		break;
> +	case NETDEV_BONDING_FAILOVER:
> +		rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
> +		break;
> +	case NETDEV_NOTIFY_PEERS:
> +		rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
> +		break;
> +	case NETDEV_RESEND_IGMP:
> +		rtnl_event = IFLA_EVENT_RESEND_IGMP;
> +		break;
> +	case NETDEV_CHANGEINFODATA:
> +		rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	return nla_put_u32(skb, IFLA_EVENT, rtnl_event);
> +}
> +

I still have doubts about encoding kernel events into a uapi.

For example, NETDEV_CHANGEINFODATA is only for bonds though nothing
about the name suggests it is a bonding notification. This one was added
specifically to notify userspace (d4261e5650004), yet seems to happen
only during a changelink and that already generates a RTM_NEWLINK
message via do_setlink. Since the rtnetlink_event message does not
contain anything "NETDEV_CHANGEINFODATA" related what purpose does it
really serve besides duplicating netlink messages to userspace.

The REBOOT, IGMP, FEAT_CHANGE and BONDING_FAILOVER seem to be unique
messages (code analysis only) which I get for notifying userspace.

NETDEV_NOTIFY_PEERS is not so clear in how often it duplicates other
messages.
