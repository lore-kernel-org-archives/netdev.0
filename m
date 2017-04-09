From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 1/8] rtnetlink: Do not generate notifications for
 MTU events
Date: Sat, 8 Apr 2017 21:36:32 -0400
Message-ID: <4ebd4c86-5fbe-f6d3-653b-5b9f0048f312@redhat.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
 <1491600340-8359-2-git-send-email-dsa@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36360 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752799AbdDIBge (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 21:36:34 -0400
In-Reply-To: <1491600340-8359-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2017 05:25 PM, David Ahern wrote:
> Changing MTU on a link currently causes 3 messages to be sent to userspace:
> 
> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1490 qdisc noqueue state UNKNOWN group default event PRE_CHANGE_MTU
>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
> 
> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default event CHANGE_MTU
>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
> 
> [LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
>     link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff
> 
> Remove the PRE_CHANGE_MTU and CHANGE_MTU messages.

Actually, I have plans for the CHANGE_MTU event.  The last message is not an event. If you
remove the event, it is much harder to track mtu changes.

-vlad
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/uapi/linux/if_link.h | 2 --
>  net/core/rtnetlink.c         | 8 -------
>  2 files changed, 10 deletions(-)
> 

> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 97f6d302f627..e8b7e9342cc0 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -903,7 +903,6 @@ enum {
>  enum {
>  	IFLA_EVENT_UNSPEC,
>  	IFLA_EVENT_REBOOT,
> -	IFLA_EVENT_CHANGE_MTU,
>  	IFLA_EVENT_CHANGE_ADDR,
>  	IFLA_EVENT_CHANGE_NAME,
>  	IFLA_EVENT_FEAT_CHANGE,
> @@ -912,7 +911,6 @@ enum {
>  	IFLA_EVENT_NOTIFY_PEERS,
>  	IFLA_EVENT_CHANGE_UPPER,
>  	IFLA_EVENT_RESEND_IGMP,
> -	IFLA_EVENT_PRE_CHANGE_MTU,
>  	IFLA_EVENT_CHANGE_INFO_DATA,
>  	IFLA_EVENT_PRE_CHANGE_UPPER,
>  	IFLA_EVENT_CHANGE_LOWER_STATE,
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index b2bd4c9ee860..72d365ae14b3 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1285,9 +1285,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
>  	case NETDEV_REBOOT:
>  		rtnl_event = IFLA_EVENT_REBOOT;
>  		break;
> -	case NETDEV_CHANGEMTU:
> -		rtnl_event = IFLA_EVENT_CHANGE_MTU;
> -		break;
>  	case NETDEV_CHANGEADDR:
>  		rtnl_event = IFLA_EVENT_CHANGE_ADDR;
>  		break;
> @@ -1312,9 +1309,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
>  	case NETDEV_RESEND_IGMP:
>  		rtnl_event = IFLA_EVENT_RESEND_IGMP;
>  		break;
> -	case NETDEV_PRECHANGEMTU:
> -		rtnl_event = IFLA_EVENT_PRE_CHANGE_MTU;
> -		break;
>  	case NETDEV_CHANGEINFODATA:
>  		rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
>  		break;
> @@ -4191,7 +4185,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  
>  	switch (event) {
>  	case NETDEV_REBOOT:
> -	case NETDEV_CHANGEMTU:
>  	case NETDEV_CHANGEADDR:
>  	case NETDEV_CHANGENAME:
>  	case NETDEV_FEAT_CHANGE:
> @@ -4200,7 +4193,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  	case NETDEV_NOTIFY_PEERS:
>  	case NETDEV_CHANGEUPPER:
>  	case NETDEV_RESEND_IGMP:
> -	case NETDEV_PRECHANGEMTU:
>  	case NETDEV_CHANGEINFODATA:
>  	case NETDEV_PRECHANGEUPPER:
>  	case NETDEV_CHANGELOWERSTATE:
> 
