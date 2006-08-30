From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: PATCH: br_stp.c:271: ignoring BPDUs if cost goes up
Date: Wed, 30 Aug 2006 14:24:39 -0700
Message-ID: <20060830142439.5144d495@localhost.localdomain>
References: <44F5D334.7050205@bristyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh_mish@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11209 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932078AbWH3VYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 17:24:42 -0400
To: Brian Braunstein <brian@bristyle.com>
In-Reply-To: <44F5D334.7050205@bristyle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a comparison of the existing implementation against 802.1d standard
pseudo-code.

/* Spec */
Boolean supersedes_port_info(port_no, config)	/* (8.6.2.2) */
Int port_no;
Config_bpdu *config;
{
	return config->root_id < port_info[port_no].designated_root	/* (8.6.2.2 a) */
		|| (config->root_id == port_info[port_no].designated_root
		    && (config->root_path_cost < port_info[port_no].designated_cost	/* (8.6.2.2 b) */
			(config->root_path_cost == port_info[port_no].designated_cost
			 && (config->bridge_id < port_info[port_no].designated_bridge	/* (8.6.2.2 c) */
			     || (config->bridge_id == port_info[port_no].designated_bridge	/* (8.6.2.2 d) */
				&& (config->bridge_id != bridge_info.bridge_id	/* (8.6.2.2 d1) */
				   || config->port_id <= port_info[port_no].designated_port	/* (8.6.2.2 d2) */
					))))));
}

/* Implementation */
static int br_supersedes_port_info(struct net_bridge_port *p, struct br_config_bpdu *bpdu)
{
	int t;

	t = memcmp(&bpdu->root, &p->designated_root, 8);
	if (t < 0)
		return 1;	/* 8.6.2.2 a */
	else if (t > 0)
		return 0;

	if (bpdu->root_path_cost < p->designated_cost) /* 8.6.2.2 b */
		return 1;
	else if (bpdu->root_path_cost > p->designated_cost)
		return 0;

	t = memcmp(&bpdu->bridge_id, &p->designated_bridge, 8); /* 8.6.2.2 c */
	if (t < 0)
		return 1;
	else if (t > 0)
		return 0;

	if (memcmp(&bpdu->bridge_id, &p->br->bridge_id, 8)) /* 8.6.2.2 d */
		return 1;

	if (bpdu->port_id <= p->designated_port)
		return 1;

	return 0;
}

You are questioning the part related to 8.6.2.2 of the spec:

8.6.2.2 Use
Following the receipt of a Configuration BPDU conveying protocol information that 
supersedes that already held, i.e., if
  a) Case 1. The Root Identifier denotes a Bridge of higher priority than that
	recorded as the Designated Root, or
  b) Case 2. The Root Identifier is the same as the Designated Root, and the Root
	Path Cost is lower than that recorded as the Designated Cost for the Port, or
  c) Case 3. The Root Identifier and Root Path Cost are as recorded for the Port, and 
	the Bridge Identifier denotes a Bridge of higher priority than that recorded
	as the Designated Bridge for the Port, or
  d) Case 4. The Root Identifier and Root Path Cost are as recorded for the Port,
	and the Bridge Identifier is the same as that recorded as the Designated Bridge
	for the Port, and either
	  1) The Bridge receiving the BPDU is not the Designated Bridge for the Port, or
	  2) The Port Identifier denotes a Port of priority not less than that recorded
	     as the Designated Port.

Linux follows the specification; there is no reason to deviate for this.

