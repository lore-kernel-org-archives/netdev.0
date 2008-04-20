From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Sun, 20 Apr 2008 15:18:52 +0800
Message-ID: <480AEE5C.4090402@cn.fujitsu.com>
References: <480878CE.5040904@cn.fujitsu.com> <20080418.040949.87112742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62239 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbYDTHUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Apr 2008 03:20:37 -0400
In-Reply-To: <20080418.040949.87112742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-4-18 19:09:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 18 Apr 2008 18:32:46 +0800
> 
>> As RFC3542 mentions: An attempt to set IPV6_CHECKSUM for an
>> ICMPv6 socket will fail.
>> Add a check for that in do_rawv6_setsockopt().
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Enforcing these kinds of things we've allowed for so many years is
> rather pointless, especially if it breaks real applications.  Which I
> believe it does in this case.  The standards simply do not matter.
> 
> I seem to recall that traceroute6 in iputils does exactly this.
> 

Enforcing this can forbid disabling checksum for icmpv6 socket.
The real applications, such as ping6 & traceroute6, are just doing
what is default in kernel.
Why not remove the RFC-breaking code from applications?

See the source:
kernel->rawv6_init_sk()
---
	case IPPROTO_ICMPV6:
		rp->checksum = 1;
		rp->offset   = 2;
		break;
---

ping6->main()
---
	csum_offset = 2;
	sz_opt = sizeof(int);

	err = setsockopt(icmp_sock, SOL_RAW, IPV6_CHECKSUM, &csum_offset, sz_opt);
	if (err < 0) {
		perror("setsockopt(RAW_CHECKSUM)");
		exit(2);
	}
---

traceroute6->main()
---
	on = 2;
	if (setsockopt(icmp_sock, SOL_RAW, IPV6_CHECKSUM, &on, sizeof(on)) < 0) {
		perror("setsockopt(RAW_CHECKSUM)");
		exit(2);
	}
---


