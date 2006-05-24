From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 3/3] bridge: netlink interface for link management
Date: Wed, 24 May 2006 14:11:55 -0400
Message-ID: <1148494315.5325.18.camel@jzny2>
References: <20060524171216.706750000@localhost.localdomain>
	 <20060524171348.001557000@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:57226 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932761AbWEXSMA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 14:12:00 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fixpy-0007eK-DT
	for netdev@vger.kernel.org; Wed, 24 May 2006 14:12:02 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060524171348.001557000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Very nice.

On Wed, 2006-24-05 at 10:12 -0700, Stephen Hemminger wrote:
> plain text document attachment (bridge-netlink.patch)
> Add basic netlink support to the Ethernet bridge. Including:
>  * dump interfaces in bridges
>  * monitor link status changes
>  * change state of bridge port


> +static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *port,
> +			  u32 pid, u32 seq, int event, unsigned int flags)
> +{
> +	const struct net_bridge *br = port->br;
> +	const struct net_device *dev = port->dev;
> +	struct ifinfomsg *r;
> +	struct nlmsghdr *nlh;
> +	unsigned char *b = skb->tail;
> +	u32 mtu = dev->mtu;
> +	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
> +	u8 portstate = port->state;
> +
> +	pr_debug("br_fill_info event %d port %s master %s\n",
> +		 event, dev->name, br->dev->name);
> +
> +	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
> +	r = NLMSG_DATA(nlh);
> +	r->ifi_family = AF_BRIDGE;
> +	r->__ifi_pad = 0;
> +	r->ifi_type = dev->type;
> +	r->ifi_index = dev->ifindex;
> +	r->ifi_flags = dev_get_flags(dev);
> +	r->ifi_change = 0;
> +
> +	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
> +
> +	RTA_PUT(skb, IFLA_MASTER, sizeof(int), &br->dev->ifindex);
> +
> +	if (dev->addr_len)
> +		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
> +
> +	RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
> +	if (dev->ifindex != dev->iflink)
> +		RTA_PUT(skb, IFLA_LINK, sizeof(int), &dev->iflink);
> +
> +
> +	RTA_PUT(skb, IFLA_OPERSTATE, sizeof(operstate), &operstate);
> +
> +	if (event == RTM_NEWLINK)
> +		RTA_PUT(skb, IFLA_PROTINFO, sizeof(portstate), &portstate);
> +
> +	nlh->nlmsg_len = skb->tail - b;
> +
> +	return skb->len;
> +

Is it desirable to do the above? link events already happen for each
netdevice, no? If not it would probably make more sense to export the
link netlink code (instead of replicating it as above) and just call it
for each netdevice.
I think it is worth reporting all the children (their ifindices) of a
bridge when eventing.

BTW, Where is the bridge state (as in learning, blocking etc) carried? 
Having events for that i would deem as valuable.

> +static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
> +{
> +	struct rtattr  **rta = arg;
> +	struct ifinfomsg *ifm = NLMSG_DATA(nlh);
> +	struct net_device *dev;
> +	struct net_bridge_port *p;
> +	u8 new_state;
> +
> +	if (ifm->ifi_family != AF_BRIDGE)
> +		return -EPFNOSUPPORT;
> +
> +	/* Must pass valid state as PROTINFO */
> +	if (rta[IFLA_PROTINFO-1]) {

Why not a noun like IFLA_BRIDGE_STATE ?


> +	/* if kernel STP is running, don't allow changes */
> +	if (p->br->stp_enabled)
> +		return -EBUSY;

Hopefully above to die some day...

> +
> +	p->state = new_state;
> +	br_log_state(p);

Assuming the above will generate an event which reports things like the
children of the bridge and the STP state of the bridge etc i.e things in
struct net_bridge_port mostly.

cheers,
jamal



