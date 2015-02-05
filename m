From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: gre interfaces copied to new namespace
Date: Thu, 5 Feb 2015 15:51:58 -0800
Message-ID: <20150205155158.1b6a9782@urahara>
References: <EDD8E64855FBDA45ACDFE02112E795B7109CB5DC63@HQ1-EXCH03.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steve Biggs <sbiggs@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:42821 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753440AbbBFAWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:22:53 -0500
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.7/8.14.7) with SMTP id t15NKvFT022295
	for <netdev@vger.kernel.org>; Thu, 5 Feb 2015 15:52:02 -0800
Received: from brmwp-exchub01.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 1sc9949q61-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 15:52:02 -0800
In-Reply-To: <EDD8E64855FBDA45ACDFE02112E795B7109CB5DC63@HQ1-EXCH03.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Feb 2015 15:37:33 -0800
Steve Biggs <sbiggs@Brocade.com> wrote:

> (My first post to this list. I forgot to change my settings and I sent the previous version of this post using HTML mail. Terribly sorry if this caused anybody any problems; won't happen again... it may be that it never got to the list at all?)
> 
> I am going under the assumption that a newly created network namespace should have the loopback (lo) device as its only contents, with it being an error to have any other already existing interfaces in the default namespace also copied in. If this assumption is wrong, please advise and then if so, sorry for the noise.
> 
> I was able to reproduce this on a vanilla Debian Wheezy installation with the following sequence of commands. Debian Wheezy is running an older kernel version, so this is a long-standing issue. I am also able to reproduce this on a 3.14.y based kernel.
> 
> # ip netns list
> # ip a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>        valid_lft forever preferred_lft forever
>     inet6 ::1/128 scope host 
>        valid_lft forever preferred_lft forever
> # modprobe ip_gre
> # ip a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>        valid_lft forever preferred_lft forever
>     inet6 ::1/128 scope host 
>        valid_lft forever preferred_lft forever
> 12: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN group default 
>     link/gre 0.0.0.0 brd 0.0.0.0
> 13: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> # ip netns add foo
> # ip netns list
> foo
> # ip netns exec foo ip a
> 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN group default 
>     link/gre 0.0.0.0 brd 0.0.0.0
> 3: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> # rmmod ip_gre
> # ip netns exec foo ip a
> 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> # ip netns del foo
> # ip netns list
> #
> 

gre0 and friends are old weird legacy leftovers. They should be copied.
They are the tunnel of last resort for packets that match no defined tunnel.
Nothing should be using them directly.
