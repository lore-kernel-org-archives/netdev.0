From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Still using IPTOS_TOS() in kernel? Really???
Date: Wed, 16 Dec 2009 16:53:44 -0800
Message-ID: <4B298118.2000608@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:50209 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751692AbZLQAxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 19:53:47 -0500
Received: from [192.168.10.7] (builder.redfish-solutions.com [192.168.10.7])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.3/8.14.3) with ESMTP id nBH0rjaq010528
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 17:53:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Posted to linux-net a couple of days ago and didn't hear back... so reposting here since this might be more appropriate. ]

I'm looking at net/ipv4/ip_sockglue.c:

   512		case IP_TOS:	/* This sets both TOS and Precedence */
   513			if (sk->sk_type == SOCK_STREAM) {
   514				val &= ~3;
   515				val |= inet->tos & 3;
   516			}
   517			if (inet->tos != val) {
   518				inet->tos = val;
   519				sk->sk_priority = rt_tos2priority(val);
   520				sk_dst_reset(sk);
   521			}
   522			break;


and include/net/route.h:

   141	extern const __u8 ip_tos2prio[16];
   142	
   143	static inline char rt_tos2priority(u8 tos)
   144	{
   145		return ip_tos2prio[IPTOS_TOS(tos)>>1];
   146	}

and finally net/ipv4/route.c:

   165	#define ECN_OR_COST(class)	TC_PRIO_##class
   166	
   167	const __u8 ip_tos2prio[16] = {
   168		TC_PRIO_BESTEFFORT,
   169		ECN_OR_COST(FILLER),
   170		TC_PRIO_BESTEFFORT,
   171		ECN_OR_COST(BESTEFFORT),
   172		TC_PRIO_BULK,
   173		ECN_OR_COST(BULK),
   174		TC_PRIO_BULK,
   175		ECN_OR_COST(BULK),
   176		TC_PRIO_INTERACTIVE,
   177		ECN_OR_COST(INTERACTIVE),
   178		TC_PRIO_INTERACTIVE,
   179		ECN_OR_COST(INTERACTIVE),
   180		TC_PRIO_INTERACTIVE_BULK,
   181		ECN_OR_COST(INTERACTIVE_BULK),
   182		TC_PRIO_INTERACTIVE_BULK,
   183		ECN_OR_COST(INTERACTIVE_BULK)
   184	};



and it's slowly dawning on me that we're using an interpretation of the IP_TOS (and ip.ip_tos field) values that have been deprecated since 1998!  Quoting RFC 2474:

3.  Differentiated Services Field Definition

   A replacement header field, called the DS field, is defined, which is
   intended to supersede the existing definitions of the IPv4 TOS octet
   [RFC791] and the IPv6 Traffic Class octet [IPv6].



Seems pretty clear, right?  That DSCP is the new testament, here to replace the old testament... although if you look closely, the precedence values of IPTOS_PREC_ROUTINE looks a lot like IPTOS_CLASS_CS0, etc... so some backward compatibility was maintained.  (See http://sourceware.org/bugzilla/show_bug.cgi?id=11027 and http://sourceware.org/bugzilla/show_bug.cgi?id=10789 if your glibc doesn't yet include the the IPTOS_CLASS_CSn and IPTOS_DSCP_AFxx values).

And indeed, only routers seem to pay attention to bits in the 0x1c space...  I.e. between the upper 3 bits which still mean precedence, and the lower 2 bits which now signify experienced-congestion-notification (ECN).

Assuming that whatever the local host does to the output of the packet, that it's not going to sufficiently delay the packet enough because we're connected to some fast media (Fast ethernet, etc) then what we do locally shouldn't matter... unless of course we're using 802.1p tagging, in which case we can seriously mess up what happens next.

So how is it that no one noticed this issue yet, and given that Linux is used in a fair number of commercial embedded real-time boxes (like satellite and IPTV set-top boxes)... how are they not impacted by this?

Assuming my crusade to get various common apps and services (wget, TB, FF, Sendmail, Cyrus, ProFTPd, etc) to use DSCP/CS marking (very few apps currently use DSCP or precedence marking), then kernels with the proper default behavior will need to start shipping, right?  I.e. out-of-the-box kernels should handle such apps without further configuration, such as needing to have the DSCP iptables module installed.  They should "just work".

Thanks,

-Philip

