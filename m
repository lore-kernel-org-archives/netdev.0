From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Fri, 25 Jul 2008 01:45:53 +0200
Message-ID: <20080724234553.GC20815@postel.suug.ch>
References: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, kaber@trash.net, menage@google.com
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33562 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686AbYGXXpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 19:45:33 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-07-22 10:44
> The implementation consists of two parts:
> 
> 1) A resource controller (cgroup_tc) that is used to associate packets from
>    a particular task belonging to a cgroup with a traffic control class id (
>    tc_classid). This tc_classid is propagated to all sockets created by 
>    tasks
>    in the cgroup and will be used for classifying packets at the link layer.
> 
> 2) A modified traffic control classifier (cls_flow) that can classify 
> packets
>    based on the tc_classid field in the socket to specific destination 
>    classes.
> 
> An example of the use of this resource controller would be to limit
> the traffic from all tasks from a file_server cgroup to 100Mbps. We could
> achieve this by doing:
> 
> # make a cgroup of file transfer processes and assign it a uniqe classid
> # of 0x10 - this will be used lated to direct packets.
> mkdir -p /dev/cgroup
> mount -t cgroup tc -otc /dev/cgroup
> mkdir /dev/cgroup/file_transfer
> echo 0x10 > /dev/cgroup/file_transfer/tc.classid
> echo $PID_OF_FILE_XFER_PROCESS > /dev/cgroup/file_transfer/tasks
> 
> # Now create a HTB class that rate limits traffic to 100mbits and attach
> # a filter to direct all traffic from cgroup file_transfer to this new 
> class.
> tc qdisc add dev eth0 root handle 1: htb
> tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit
> tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 flow map key 
> cgroup-classid baseclass 1:10

It might have been easier to simply write a classifier which maps pids
to classes. The interface could be as simple as two nested attributes,
ADD_MAPS, REMOVE_MAPS which both take lists of pid->class mappings to
either add or remove from the classifier.

I have been working on this over the past 2 weeks, it includes the
classifier as just stated, a cgroup module which sends notifications
about events as netlink messages and a daemon which creates qdiscs,
classes and filters on the fly according to the configured distribution.
It works both ingress (with some tricks) and egress.

IMHO, there is no point in a cgroup interface if the user has to create
qdiscs, classes and filters manually anyway.
