From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Mon, 21 Dec 2009 13:14:52 -0800
Message-ID: <4B2FE54C.2020209@redfish-solutions.com>
References: <4B298118.2000608@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:40982 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750760AbZLUVOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 16:14:54 -0500
Received: from [192.168.10.7] (builder.redfish-solutions.com [192.168.10.7])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.3/8.14.3) with ESMTP id nBLLEqak021579
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 21 Dec 2009 14:14:53 -0700
In-Reply-To: <4B298118.2000608@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Digging some more (at least through the 2.6.27.38 source) I also find:

/* Given a data frame determine the 802.1p/1d tag to use.  */
static unsigned int classify_1d(struct sk_buff *skb)
{
        unsigned int dscp;

        /* skb->priority values from 256->263 are magic values to
         * directly indicate a specific 802.1d priority.  This is used
         * to allow 802.1d priority to be passed directly in from VLAN
         * tags, etc.
         */
        if (skb->priority >= 256 && skb->priority <= 263)
                return skb->priority - 256;

        switch (skb->protocol) {
        case __constant_htons(ETH_P_IP):
                dscp = ip_hdr(skb)->tos & 0xfc;
                break;

        default:
                return 0;
        }

        if (dscp & 0x1c)
                return 0;
        return dscp >> 5;
}


in net/mac80211/wme.c

This won't work with DSCP values because they do set bits 0x10 and 0x80.  In fact... looking at netinet/ip.h:

/*
 * Definitions for IP type of service (ip_tos)
 */
#define IPTOS_TOS_MASK          0x1E
#define IPTOS_TOS(tos)          ((tos) & IPTOS_TOS_MASK)
#define IPTOS_LOWDELAY          0x10
#define IPTOS_THROUGHPUT        0x08
#define IPTOS_RELIABILITY       0x04
#define IPTOS_LOWCOST           0x02
#define IPTOS_MINCOST           IPTOS_LOWCOST


I'm not even sure why the IPTOS_LOWCOST bit is left out of the check...

-Philip





On 12/16/2009 04:53 PM, Philip A. Prindeville wrote:
> [ Posted to linux-net a couple of days ago and didn't hear back... so reposting here since this might be more appropriate. ]
>
> I'm looking at net/ipv4/ip_sockglue.c:
>
>    512		case IP_TOS:	/* This sets both TOS and Precedence */
>    513			if (sk->sk_type == SOCK_STREAM) {
>    514				val &= ~3;
>    515				val |= inet->tos & 3;
>    516			}
>    517			if (inet->tos != val) {
>    518				inet->tos = val;
>    519				sk->sk_priority = rt_tos2priority(val);
>    520				sk_dst_reset(sk);
>    521			}
>    522			break;
>
>
> and include/net/route.h:
>
>    141	extern const __u8 ip_tos2prio[16];
>    142	
>    143	static inline char rt_tos2priority(u8 tos)
>    144	{
>    145		return ip_tos2prio[IPTOS_TOS(tos)>>1];
>    146	}
>
> and finally net/ipv4/route.c:
>
>    165	#define ECN_OR_COST(class)	TC_PRIO_##class
>    166	
>    167	const __u8 ip_tos2prio[16] = {
>    168		TC_PRIO_BESTEFFORT,
>    169		ECN_OR_COST(FILLER),
>    170		TC_PRIO_BESTEFFORT,
>    171		ECN_OR_COST(BESTEFFORT),
>    172		TC_PRIO_BULK,
>    173		ECN_OR_COST(BULK),
>    174		TC_PRIO_BULK,
>    175		ECN_OR_COST(BULK),
>    176		TC_PRIO_INTERACTIVE,
>    177		ECN_OR_COST(INTERACTIVE),
>    178		TC_PRIO_INTERACTIVE,
>    179		ECN_OR_COST(INTERACTIVE),
>    180		TC_PRIO_INTERACTIVE_BULK,
>    181		ECN_OR_COST(INTERACTIVE_BULK),
>    182		TC_PRIO_INTERACTIVE_BULK,
>    183		ECN_OR_COST(INTERACTIVE_BULK)
>    184	};
>
>
>
> and it's slowly dawning on me that we're using an interpretation of the IP_TOS (and ip.ip_tos field) values that have been deprecated since 1998!  Quoting RFC 2474:
>
> 3.  Differentiated Services Field Definition
>
>    A replacement header field, called the DS field, is defined, which is
>    intended to supersede the existing definitions of the IPv4 TOS octet
>    [RFC791] and the IPv6 Traffic Class octet [IPv6].
>
>
>
> Seems pretty clear, right?  That DSCP is the new testament, here to replace the old testament... although if you look closely, the precedence values of IPTOS_PREC_ROUTINE looks a lot like IPTOS_CLASS_CS0, etc... so some backward compatibility was maintained.  (See http://sourceware.org/bugzilla/show_bug.cgi?id=11027 and http://sourceware.org/bugzilla/show_bug.cgi?id=10789 if your glibc doesn't yet include the the IPTOS_CLASS_CSn and IPTOS_DSCP_AFxx values).
>
> And indeed, only routers seem to pay attention to bits in the 0x1c space...  I.e. between the upper 3 bits which still mean precedence, and the lower 2 bits which now signify experienced-congestion-notification (ECN).
>
> Assuming that whatever the local host does to the output of the packet, that it's not going to sufficiently delay the packet enough because we're connected to some fast media (Fast ethernet, etc) then what we do locally shouldn't matter... unless of course we're using 802.1p tagging, in which case we can seriously mess up what happens next.
>
> So how is it that no one noticed this issue yet, and given that Linux is used in a fair number of commercial embedded real-time boxes (like satellite and IPTV set-top boxes)... how are they not impacted by this?
>
> Assuming my crusade to get various common apps and services (wget, TB, FF, Sendmail, Cyrus, ProFTPd, etc) to use DSCP/CS marking (very few apps currently use DSCP or precedence marking), then kernels with the proper default behavior will need to start shipping, right?  I.e. out-of-the-box kernels should handle such apps without further configuration, such as needing to have the DSCP iptables module installed.  They should "just work".
>
> Thanks,
>
> -Philip
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

