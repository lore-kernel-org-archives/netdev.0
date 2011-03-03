From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] VPN broken in net-next
Date: Thu, 3 Mar 2011 09:32:15 -0800
Message-ID: <20110303093215.40164b8c@nehalam>
References: <20110302.164333.116393112.davem@davemloft.net>
	<20110302164637.6651b34f@nehalam>
	<20110302.165009.200353108.davem@davemloft.net>
	<20110302.165421.258093056.davem@davemloft.net>
	<alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg>
	<alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41171 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471Ab1CCRcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 12:32:18 -0500
In-Reply-To: <alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  	Hello,
> 
> On Thu, 3 Mar 2011, Julian Anastasov wrote:
> 
> > 	May be the problem is in inet_hash_insert(), it should
> > hash ifa_local, not ifa_address. May be they are equal for  
> 
>  	... and of course the new __ip_dev_find should use
> ifa_local too.
> 
> > the common case but not for peer addresses. In devinet_ioctl()
> > we can see they are equal initially:
> >
> > ifa->ifa_address = ifa->ifa_local = sin->sin_addr.s_addr;
> >
> > 	but later SIOCSIFDSTADDR can change ifa_address which
> > is destination address from the same prefix:
> >
> > ifa->ifa_address = sin->sin_addr.s_addr;  
> 
>  	While checking for ifa_address usage I see other
> two places that look suspicious:
> 
> - inet_gifconf() exposes address from ifa_local but then
> devinet_ioctl() matches by ifa_address in the
> 'if (tryaddrmatch)' block. I think, we should use ifa_local.
> 
> - IN_DEV_ARP_NOTIFY: announces ifa_address instead of ifa_local.

Julian you are on the right track with the ifa_local being the issue.

1. Bring up VPN 
   (no errors)

2. Ping one address gets connect error

3. Instrumentation triggers. I added code so if __ip_dev_find failed,
   it walked the hash table.

net=ffffffff81a12d80

[  393.224228] __ip_dev_find(ffffffff81a12d80, 10.250.0.104) hash=108 failed
[  393.224232] 138: ffffffff81a12d80 ifa_addr=127.0.0.1 ifa_local=127.0.0.1
[  393.224236] 150: ffffffff81a12d80 ifa_addr=192.168.1.11 ifa_local=192.168.1.11
[  393.224239] 249: ffffffff81a12d80 ifa_addr=192.168.100.1 ifa_local=192.168.100.1
[  393.224242] 254: ffffffff81a12d80 ifa_addr=192.168.99.1 ifa_local=192.168.99.1
[  393.224245] 255: ffffffff81a12d80 ifa_addr=10.255.254.0 ifa_local=10.250.0.10



