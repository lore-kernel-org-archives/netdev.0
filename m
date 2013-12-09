From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: cgroup filter on physics interface can't container
Date: Mon, 9 Dec 2013 10:32:31 +0800
Message-ID: <52A52BBF.6030105@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <edumazet@google.com>, <fbl@redhat.com>, <ebiederm@xmission.com>,
	<jeff@garzik.org>, <edumazet@google.com>, <peterz@infradead.org>,
	<honkiko@gmail.com>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	"zhangwei(Jovi)" <jovi.zhangwei@huawei.com>,
	Huang Qiang <h.huangqiang@huawei.com>,
	Wengmeiling <wengmeiling.weng@huawei.com>
To: David Miller <davem@davemloft.net>, <kaber@trash.net>,
	<xemul@openvz.org>, Serge Hallyn <serge.hallyn@canonical.com>,
	<ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:40578 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552Ab3LIClO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 21:41:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello network hackers,

	A linux container was builded with veth pair(veth0 inside container, veth1 outside container),

the config as below:

  lxc.network.type = veth
  lxc.network.flags = up
  lxc.network.link = br0  // base on eth0
  lxc.network.name = eth0
  lxc.network.ipv4 = 128.5.130.26/24

then I use tc command with cgroup filter on veth0, it works well. But when setting on eth0, it doesn`t work.

The reason is dev_forward_skb() in veth_xmit will call skb_scrub_packet and clean all information including skb->sk
in the skb, so if cls_cgroup_classify is working in serving softirq state, it will return failer, see below:

	if (in_serving_softirq()) {
		/* If there is an sk_classid we'll use that. */
		if (!skb->sk)
			return -1;
		classid = skb->sk->sk_classid;
	}


Qdisc with cgroup filter on physics interface can not control a container network, it is disappointed.

we can save sk_classid before skb_scrub_packet and restore it after that. Is it reasonable?  or any way to achieve this?

thanks,
Libo
