From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 19:14:04 +0000
Message-ID: <6CE81A2095B0024BBC77007BD04E553823E85BC2@xmb-aln-x02.cisco.com>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>
To: David Gibson <dgibson@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-7.cisco.com ([173.37.142.94]:36091 "EHLO
	alln-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaDVTXf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 15:23:35 -0400
In-Reply-To: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

> -----Original Message-----
> From: David Gibson [mailto:dgibson@redhat.com]
> Sent: Monday, April 21, 2014 9:14 PM
> To: netdev@vger.kernel.org
> Cc: Christian Benvenuti (benve); Sujith Sankar (ssujith); Govindarajulu
> Varadarajan; Neel Patel (neepatel); Nishank Trivedi
> Subject: RFC: rtnetlink problems with Cisco enic and VFs
> 
> I believe I've found a problem with netlink handling which can be triggered
> on Cisco enic devices with a large number (30-40) of virtual functions.  I
> believe this is the cause of a real customer problem we've seen.
> 
>  * When requesting a list of interfaces with RTM_GETLINK, enic devices
>    (and currently, _only_ enic devices) report IFLA_VF_PORTS
>    information

Is the fact that Enic is the only driver implementing ndo_get_vf_port [1]
the root cause of the problem and the reason why this happens only with Enic?

/Chris

[1]
This is what makes rtnl_port_size to account for vf_port_size*dev_num_vf(...)
and rtnl_port_fill to add IFLA_VF_PORTS.
 
>  * IFLA_VF_PORTS information has at least 90 bytes ber virtual function
> 
>  * Unlike IFLA_VFINFO_LIST, the ports information is always reported,
>    regardless of the setting of the IFLA_EXT_MASK parameter
> 
>  * When IFLA_EXT_MASK is not specified, the reply packets have maximum
>    size NLMSG_GOODSIZE (4k - overheads)
> 
>  * If there are enough virtual functions the IFLA_VF_PORTS information
>    can cause a single interface's info to exceed NLMSG_GOODSIZE
> 
>  * The number of interfaces necessary to trigger this is reduced
>    substantially if both IPv4 and IPv6 IFLA_AF_SPEC information is
>    present (~972 bytes)
> 
>  * If the dump function returns -EMSGSIZE on the first message in a
>    packet, netlink_dump() incorrectly assumes the listing is done,
>    omitting information for that interface and any later ones.
> 
>  * This can cause getifaddrs(3) to go into an infinite loop
> 
>  * 'ip link' is not affected, because it supplies IFLA_EXT_MASK which
>    triggers rtnl_calcit() to recalculate the required packet size to
>    greater than NLMSG_GOODSIZE.
> 
> 
> I can see several possible ways to fix this, but they all have possible
> problems.  I'm hoping someone here can determine which, if any, are real
> problems, and therefore what's the right approach to fix this.
> 
>     A) Always calculate the RTM_NEWLINK packet size, rather than
>        assuming NLMSG_GOODSIZE.
>     Problem: The NLMSG_GOODSIZE limit was introduced to stop broken
>              user tools with limited buffers encountering problems
>              (see 115c9b81928360d769a76c632bae62d15206a94a). This
>              approach might mean that such tools break again.
> 
>     B) Don't issue the VF port information when RTEXT_FILTER_VF isn't
>        set
>     Problem: Do tools using the port information already set this flag?
> 
>     C) Don't include the VF port info when listing interfaces, only
>        when doing GETLINK on a specific interface.
>     Problem: As (B), plus it's ugly.
> 
>     D) Detect the case when the first interface in a packet doesn't fit
>        reallocate the packet buffer
>     Problem: As (A), plus more complicated.
> 
> As an interim band-aid, here's a patch which adds a WARN_ON() in this
> situation, which will at least make the problem easier to locate for the next
> person to encounter it.
> 
> From: David Gibson <david@gibson.dropbear.id.au>
> Subject: [PATCH] rtnetlink: Warn when interface's information won't fit
>          in our packet
> 
> Without IFLA_EXT_MASK specified, the information reported for a single
> interface in response to RTM_GETLINK is expected to fit within a netlink
> packet of NLMSG_GOODSIZE.
> 
> If it doesn't, however, things will go badly wrong,  When listing all
> interfaces, netlink_dump() will incorrectly treat -EMSGSIZE on the first
> message in a packet as the end of the listing and omit information for that
> interface and all subsequent ones.  This can cause getifaddrs(3) to enter an
> infinite loop.
> 
> This patch won't fix the problem, but it will WARN_ON() making it easier to
> track down what's going wrong.
> 
> 
> Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> ---
>  net/core/rtnetlink.c | 16 +++++++++++-----
>  1 file changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c index
> d4ff417..5331db2 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1198,6 +1198,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb,
> struct netlink_callback *cb) struct hlist_head *head;
>  	struct nlattr *tb[IFLA_MAX+1];
>  	u32 ext_filter_mask = 0;
> +	int err;
> 
>  	s_h = cb->args[0];
>  	s_idx = cb->args[1];
> @@ -1218,11 +1219,16 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb,
> struct netlink_callback *cb) hlist_for_each_entry_rcu(dev, head,
> index_hlist) { if (idx < s_idx)
>  				goto cont;
> -			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
> -					     NETLINK_CB
> (cb->skb).portid,
> -					     cb->nlh->nlmsg_seq, 0,
> -					     NLM_F_MULTI,
> -					     ext_filter_mask) <= 0)
> +			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
> +					       NETLINK_CB
> (cb->skb).portid,
> +					       cb->nlh->nlmsg_seq, 0,
> +					       NLM_F_MULTI,
> +					       ext_filter_mask);
> +			/* If we ran out of room on the first message,
> +			 * we're in trouble */
> +			WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
> +
> +			if (err <= 0)
>  				goto out;
> 
>  			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
> --
> 1.9.0
> 
> 
> 
> --
> David Gibson <dgibson@redhat.com>
