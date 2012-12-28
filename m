From: canqun zhang <canqunzhang@gmail.com>
Subject: Re: kernel panic when running /etc/init.d/iptables restart
Date: Fri, 28 Dec 2012 11:27:50 +0800
Message-ID: <CAFFEFTVXVV09jqje_02WaAGuHkuiYjNreEuJw=2OCOujgnjcUA@mail.gmail.com>
References: <CAFFEFTXxsPRf1Rmxyih0wL4O6q8G0OFmz0iRLX0tOYedYfajHw@mail.gmail.com>
	<50D93B43.8060303@cn.fujitsu.com>
	<CAFFEFTULzSysz+JCBC==VtKD8u1KO6EZnSdQ5XWM7um-zs9_pg@mail.gmail.com>
	<50D965F9.7090007@cn.fujitsu.com>
	<CAFFEFTWWNQ_NKw840mQ3gTfB9XR44EXb_=Ft4o+UoHwxv13VRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFFEFTWWNQ_NKw840mQ3gTfB9XR44EXb_=Ft4o+UoHwxv13VRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all
As discussed above,if the host machine create several linux
containers, there will be several  net namespaces.Resources with "nf
conntrack" are registered or unregistered on the first net
namespace(init_net),But init_net is not unregistered lastly,so
cleanuping other net namespaces  will triger painic.
If net namespaces are created  with the order of 1,2,...n,they should
be cleaned with the order of n,...2,1,so in this case init_net will be
unregistered lastly.
I fixed it up (see below)

diff -r 6a1a258923f5 -r 2667e89e6f50 net/core/net_namespace.c
--- a/net/core/net_namespace.c  Fri Dec 28 11:01:17 2012 +0800
+++ b/net/core/net_namespace.c  Fri Dec 28 11:05:12 2012 +0800
@@ -450,7 +450,7 @@

        list_del(&ops->list);
        for_each_net(net)
-               list_add_tail(&net->exit_list, &net_exit_list);
+              list_add(&net->exit_list, &net_exit_list);
        ops_exit_list(ops, &net_exit_list);
        ops_free_list(ops, &net_exit_list);
 }

2012/12/25 canqun zhang <canqunzhang@gmail.com>:
> Thanks for your suggestion,i will modify this patch and take tests.
>
> 2012/12/25 Gao feng <gaofeng@cn.fujitsu.com>:
>> On 2012/12/25 15:25, canqun zhang wrote:
>>> Hi Gao feng
>>> The stack information is as follows. The kenel will panic because the
>>> nf_ct_destroy is NULL.
>>>
>>> Reproduction:
>>> (1) starting a lxc container
>>> (2) iptables -t nat -A POSTROUTING -s 10.48.254.18 -o eth1 -j
>>> MASQUERADE (run it on host machine)
>>> (3) /etc/ini.d/iptables save (run it on host machine)
>>> (4)/etc/init.d/iptables restart (run it on host machine)
>>>
>>
>> Thanks!
>> It seems that nf_conntrack_l[3,4]proto_unregister doesn't make sure
>> nf_conns of the proto being destroyed.
>>
>> If I'm right, there is another problem even your fix this panic problem.
>> the l3,14proto will be unregistered before all of it's nf_conns being destroyed.
>> So even nf_ct_destroy is not NULL,in destroy_conntrack we are not able to
>> find the right l4proto,the l4proto->destroy will be incorrect.resources will
>> not be released correctly.
>>
>> So I think the root problem is we do register/unregister, set/unset both on the
>> first net (init_net), Maybe it's better to do register set on the first net, and
>> do unregister unset on the last net.
