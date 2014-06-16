From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH iproute2] fix ip tunnel for vti tunnels with ikey
Date: Mon, 16 Jun 2014 21:43:18 +0400
Message-ID: <20140616214318.161d53c7c0f3758dfccb3ea7@qrator.net>
References: <20140607003349.d8b0fd526cb6403437c88c33@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:40798 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbaFPRnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 13:43:25 -0400
Received: by mail-lb0-f172.google.com with SMTP id c11so3343037lbj.3
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 10:43:23 -0700 (PDT)
In-Reply-To: <20140607003349.d8b0fd526cb6403437c88c33@qrator.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 7 Jun 2014 00:33:49 +0400
Dmitry Popov <ixaphire@qrator.net> wrote:

> Consider the following command:
> 
> ip tunnel add mode vti remote 12.0.0.1 local 12.0.0.3 ikey 15
> 
> ...

I re-read commit message and found that the issue described may be not that
obvious. So I decided to show the commands to reproduce the bug:

* Note, that there also was a bug in ip_tunnel/ip_vti, see
commit 7c8e6b9c281(ip_vti: Fix 'ip tunnel add' with 'key' parameters),
https://lkml.org/lkml/2014/6/7/125.
Even patched iproute could be unable to create vti tunnels with non-zero keys.

1) Unpatched iproute2:
[root@vm ~]# ip tunnel show
[root@vm ~]# lsmod | egrep '(ipip|vti)'
[root@vm ~]# ip tunnel add mode vti ikey 1
[root@vm ~]# lsmod | egrep '(ipip|vti)'
ipip                    4197  0 
tunnel4                 1659  1 ipip
ip_tunnel               9295  1 ipip
[root@vm ~]# ip tunnel show
tunl0: ip/ip  remote any  local any  ttl inherit
[root@vm ~]# ip tunnel add mode vti remote 1.2.3.4 ikey 2
[root@vm ~]# ip tunnel show
ipip0: ip/ip  remote 1.2.3.4  local any  ttl inherit 
tunl0: ip/ip  remote any  local any  ttl inherit 
[root@vm ~]# lsmod | egrep '(ipip|vti)'
ipip                    4197  0 
tunnel4                 1659  1 ipip
ip_tunnel               9295  1 ipip

# ipip tunnels are created instead of vti

2) Patched iproute2:
[root@vm ~]# ip tunnel show
[root@vm ~]# lsmod | egrep '(ipip|vti)'
[root@vm ~]# ip tunnel add mode vti ikey 1
[root@vm ~]# lsmod | egrep '(ipip|vti)'
ip_vti                  5258  0 
ip_tunnel               9295  1 ip_vti
[root@vm ~]# ip tunnel show
vti0: ip/ip  remote any  local any  ttl inherit  ikey 1  okey 0 
ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0
[root@vm ~]# ip tunnel add mode vti remote 1.2.3.4 ikey 2
[root@vm ~]# ip tunnel show
vti0: ip/ip  remote any  local any  ttl inherit  ikey 1  okey 0
vti1: ip/ip  remote 1.2.3.4  local any  ttl inherit  ikey 2  okey 0 
ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0

# Vti tunnels are created as expected
# * If you have unpatched kernel your vti tunnels will have ikey == okey == 0

Same story exists with ip tunnel show/del with non-zero [io]key: requests are 
routed to tunl0 instead of ip_vti0.
