From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual
 net_device
Date: Mon, 9 Sep 2013 17:57:06 -0700
Message-ID: <20130909175706.39c1f210@nehalam.linuxnetplumber.net>
References: <1378768511-27866-1-git-send-email-fruggeri@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:51033 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075Ab3IJA5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 20:57:11 -0400
Received: by mail-pd0-f171.google.com with SMTP id g10so6845164pdj.2
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 17:57:10 -0700 (PDT)
In-Reply-To: <1378768511-27866-1-git-send-email-fruggeri@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  9 Sep 2013 16:15:11 -0700
Francesco Ruggeri <fruggeri@aristanetworks.com> wrote:

> There is a race condition when removing a net_device while its net namespace
> is also being removed.
> This can result in a crash or other unpredictable behavior.
> This is a sample scenario with veth, but the same applies to other virtual
> devices such as vlan and macvlan.
> veth pair v0-v1 is created, with v0 in namespace ns0 and v1 in ns1.
> Process p0 deletes v0. v1 is also unregistered (in veth_dellink), so when p0
> gets to netdev_run_todo both v0 and v1 are in net_todo_list, and they have both
> been unlisted from their respective namespaces. If all references to v1 have not
> already been dropped then netdev_run_todo/netdev_wait_allrefs will call netdev
> notifiers for v1, releasing the rtnl lock between calls.
> Now process p1 removes namespace ns1. v1 will not prevent this from happening
> (in default_device_exit_batch) since it was already unlisted by p0.
> Next time p0 invokes the notifiers for v1 any notifiers that use dev_net(v1)
> will get a pointer to a namespace that has been or is being removed.

Namespace's should be ref counted.
