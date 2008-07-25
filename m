From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Thu, 24 Jul 2008 18:16:26 -0700
Message-ID: <166fe7950807241816y6bbcc17evc934524a4511f4ae@mail.gmail.com>
References: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com>
	 <20080724234553.GC20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, kaber@trash.net, menage@google.com
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:5935 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbYGYBQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 21:16:43 -0400
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out3.google.com with ESMTP id m6P1GSNB007941
	for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 02:16:28 +0100
Received: from an-out-0708.google.com (anac36.prod.google.com [10.100.54.36])
	by spaceape11.eur.corp.google.com with ESMTP id m6P1GQKT002698
	for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 18:16:27 -0700
Received: by an-out-0708.google.com with SMTP id c36so673824ana.22
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 18:16:26 -0700 (PDT)
In-Reply-To: <20080724234553.GC20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 4:45 PM, Thomas Graf <tgraf@suug.ch> wrote:
> * Ranjit Manomohan <ranjitm@google.com> 2008-07-22 10:44
>> The implementation consists of two parts:
>>
>> 1) A resource controller (cgroup_tc) that is used to associate packets from
>>    a particular task belonging to a cgroup with a traffic control class id (
>>    tc_classid). This tc_classid is propagated to all sockets created by
>>    tasks
>>    in the cgroup and will be used for classifying packets at the link layer.
>>
>> 2) A modified traffic control classifier (cls_flow) that can classify
>> packets
>>    based on the tc_classid field in the socket to specific destination
>>    classes.
>>
>> An example of the use of this resource controller would be to limit
>> the traffic from all tasks from a file_server cgroup to 100Mbps. We could
>> achieve this by doing:
>>
>> # make a cgroup of file transfer processes and assign it a uniqe classid
>> # of 0x10 - this will be used lated to direct packets.
>> mkdir -p /dev/cgroup
>> mount -t cgroup tc -otc /dev/cgroup
>> mkdir /dev/cgroup/file_transfer
>> echo 0x10 > /dev/cgroup/file_transfer/tc.classid
>> echo $PID_OF_FILE_XFER_PROCESS > /dev/cgroup/file_transfer/tasks
>>
>> # Now create a HTB class that rate limits traffic to 100mbits and attach
>> # a filter to direct all traffic from cgroup file_transfer to this new
>> class.
>> tc qdisc add dev eth0 root handle 1: htb
>> tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit
>> tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 flow map key
>> cgroup-classid baseclass 1:10
>
> It might have been easier to simply write a classifier which maps pids
> to classes. The interface could be as simple as two nested attributes,
> ADD_MAPS, REMOVE_MAPS which both take lists of pid->class mappings to
> either add or remove from the classifier.
>

The current patch is extremely lightweight and has virtually no
performance overhead compared to a more dynamic technique like you
suggest.

> I have been working on this over the past 2 weeks, it includes the
> classifier as just stated, a cgroup module which sends notifications
> about events as netlink messages and a daemon which creates qdiscs,
> classes and filters on the fly according to the configured distribution.
> It works both ingress (with some tricks) and egress.

I will send a follow up patch that handles ingress as well which
should be a fairly simple addition to the current scheme.  IMO it may
be preferable not to tie the implementation to any specific dependency
in user space leaving it maximum flexibility. Our cluster management
component sets up these rules depending upon the configuration and we
have this scheme working in our clusters for quite some time with no
issues.

>
> IMHO, there is no point in a cgroup interface if the user has to create
> qdiscs, classes and filters manually anyway.

In my view it is a trade off to allow more flexibility in the
configuration. I would think someone configuring the current tc setup
in Linux is already pretty knowledgeable about its working and can do
this extra step without much difficulty.

That said I will look for your alternative implementation to compare
the benefits.

-Thanks for your review and comments,
Ranjit

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
