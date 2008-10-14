From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Tue, 14 Oct 2008 19:03:31 +0200
Message-ID: <20081014170331.GC20815@postel.suug.ch>
References: <20081013155715.GZ20815@postel.suug.ch> <loom.20081014T115257-383@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chei-yol Kim <gauri@etri.re.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:41378 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891AbYJNRDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 13:03:10 -0400
Content-Disposition: inline
In-Reply-To: <loom.20081014T115257-383@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Chei-yol Kim <gauri@etri.re.kr> 2008-10-14 11:56
> Thomas Graf <tgraf <at> suug.ch> writes:
> 
> > 
> > This patch implements a very basic cgroup subsystem which allows
> > assigning classids to cgroups. It also adds a trivial classifier
> > to filter packets based on that classid and map them to classes.
> > 
> 
> In order to test your patch, I need more programs such as iproute-x.x.x 
> package modified for using your cgroup classifier.
> You seem to test your code now. Please send me additional code and patch for 
> testing environments.

Here is an example of how to use it:

mkdir -p /dev/cgroup
mount -t cgroup net_cls -onet_cls /dev/cgroup
mkdir /dev/cgroup/foo

# packets in cgroup foo go to class 10:1
echo 0xA0001 > /dev/cgroup/foo/net_cls.classid

tc qdisc add dev eth0 root handle 10: htb
tc class add dev eth0 parent 10:0 classid 10:1 htb rate 10mbit
tc class add dev eth0 parent 10:0 classid 10:2 htb rate 10mbit

# cgroup filter -> 10:X
tc filter add dev eth0 parent 10: protocol ip prio 10 handle 20: cgroup
# everything else -> 10:1
tc filter add dev eth0 parent 10: protocol ip prio 20 basic classid 10:2

