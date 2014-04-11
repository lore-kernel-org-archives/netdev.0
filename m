From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: Should linux send netlink message as it is deleting that routing
 entry?
Date: Fri, 11 Apr 2014 17:15:48 +0800
Message-ID: <5347B2C4.6040103@gmail.com>
References: <534654FE.3040804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	ebiederm@xmission.com, ja@ssi.bg,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	"Zadoyan, Grant" <Grant.Zadoyan@windriver.com>,
	eric.dumazet@gmail.com, socketcan@hartkopp.net,
	hannes@stressinduktion.org, cwang@twopensource.com,
	zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:37012 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbaDKJPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 05:15:50 -0400
Received: by mail-qa0-f43.google.com with SMTP id j15so5044872qaq.2
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 02:15:49 -0700 (PDT)
In-Reply-To: <534654FE.3040804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

Please help to look at this problem. And give us an official 
explanation. Should linux send netlink message as it is deleting that 
routing entry?

Thanks a lot.
Zhu Yanjun

On 04/10/2014 04:23 PM, zhuyj wrote:
> Hi, David
>
> With ubuntu 12.04, I run the following to reproduce this defect.
>
> 1) Configure an interface
> ifconfig eth1 150.0.0.1/24 up
>
> 2) Add routing entry via that interface address
> route add -net 200.0.0.0/24 gw 150.0.0.1
>
> 3) Change the ip address on that interface as shown below.
> ifconfig eth1 151.0.0.1/24 up
>
> 4) Check netlink messages with "ip monitor all". There is no route 
> delete netlink message.
>
> [ADDR]Deleted 3: eth1    inet 150.0.0.1/24 brd 150.0.0.255 scope 
> global eth1
> [ROUTE]Deleted 150.0.0.0/24 dev eth1  proto kernel  scope link src 
> 150.0.0.1
> [ROUTE]Deleted broadcast 150.0.0.255 dev eth1  table local  proto 
> kernel  scope link  src 150.0.0.1
> [ROUTE]Deleted broadcast 150.0.0.0 dev eth1  table local  proto 
> kernel  scope link  src 150.0.0.1
> [ROUTE]Deleted local 150.0.0.1 dev eth1  table local  proto kernel 
> scope host  src 150.0.0.1
> [NEIGH]224.0.0.251 dev eth1 lladdr 01:00:5e:00:00:fb NOARP
> [NEIGH]224.0.0.22 dev eth1 lladdr 01:00:5e:00:00:16 NOARP
> [ADDR]3: eth1    inet 151.0.0.1/16 brd 151.0.255.255 scope global eth1
> [ROUTE]local 151.0.0.1 dev eth1  table local  proto kernel  scope 
> host  src 151.0.0.1
> [ROUTE]broadcast 151.0.255.255 dev eth1  table local  proto kernel 
> scope link  src 151.0.0.1
> [ROUTE]151.0.0.0/16 dev eth1  proto kernel  scope link  src 151.0.0.1
> [ROUTE]broadcast 151.0.0.0 dev eth1  table local  proto kernel scope 
> link  src 151.0.0.1
> [ADDR]Deleted 3: eth1    inet 151.0.0.1/16 brd 151.0.255.255 scope 
> global eth1
> [ROUTE]Deleted 151.0.0.0/16 dev eth1  proto kernel  scope link src 
> 151.0.0.1
> [ROUTE]Deleted broadcast 151.0.255.255 dev eth1  table local proto 
> kernel  scope link  src 151.0.0.1
> [ROUTE]Deleted broadcast 151.0.0.0 dev eth1  table local  proto 
> kernel  scope link  src 151.0.0.1
> [ROUTE]Deleted local 151.0.0.1 dev eth1  table local  proto kernel 
> scope host  src 151.0.0.1
> [NEIGH]224.0.0.22 dev eth1 lladdr 01:00:5e:00:00:16 NOARP
> [ADDR]3: eth1    inet 151.0.0.1/24 brd 151.0.0.255 scope global eth1
> [ROUTE]local 151.0.0.1 dev eth1  table local  proto kernel  scope 
> host  src 151.0.0.1
> [ROUTE]broadcast 151.0.0.255 dev eth1  table local  proto kernel scope 
> link  src 151.0.0.1
> [ROUTE]151.0.0.0/24 dev eth1  proto kernel  scope link  src 151.0.0.1
> [ROUTE]broadcast 151.0.0.0 dev eth1  table local  proto kernel scope 
> link  src 151.0.0.1
>
> There is no netlink message to notify that 200.0.0.0/24 is deleted. 
> But in fact, this 200.0.0.0/24 route item disappears.
>
> I checked the source code, and I found the following is the process to 
> delete static routes when the attached interface is deleted.
>
>  1)               |  fib_netdev_event() {
>  1)               |    fib_disable_ip() {
>  1)   1.284 us    |      fib_sync_down_dev();
>  1)               |      fib_flush() {
>  1)               |        fib_table_flush() {
>  1)   0.129 us    |          fib_release_info();
>  1)   0.351 us    |          fib_release_info();
>  1)   4.605 us    |        }
>  1)               |        fib_table_flush() {
>  1)   0.096 us    |          fib_release_info();
>  1)   0.255 us    |          fib_release_info();
>  1)   4.770 us    |        }
>  1) + 11.787 us   |      }
>  1) ! 315.273 us  |    }
>  1) ! 315.888 us  |  }
>
> But there is no netlink message sent here.
>
> Should linux send netlink message as it is deleting that 200.0.0.0/24 
> routing entry?
>
> Best Regards!
> Zhu Yanjun
>
>
