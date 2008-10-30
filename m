From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: pkt_sched: Control group classifier
Date: Thu, 30 Oct 2008 06:29:14 -0700
Message-ID: <166fe7950810300629v714c8860ke38255275b57a523@mail.gmail.com>
References: <20081027.123056.22851224.davem@davemloft.net>
	 <20081027.170524.124746723.davem@davemloft.net>
	 <20081030105431.GI20815@postel.suug.ch>
	 <166fe7950810300457h3b1c11c9m437aab08ddc8afa3@mail.gmail.com>
	 <20081030131008.GK20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:59242 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734AbYJ3N3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 09:29:18 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id m9UDTGDv015225
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 06:29:16 -0700
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by wpaz29.hot.corp.google.com with ESMTP id m9UDTEjC022024
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 06:29:15 -0700
Received: by rv-out-0708.google.com with SMTP id k29so1072594rvb.2
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 06:29:14 -0700 (PDT)
In-Reply-To: <20081030131008.GK20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 6:10 AM, Thomas Graf <tgraf@suug.ch> wrote:
> * Ranjit Manomohan <ranjitm@google.com> 2008-10-30 04:57
>> The complexity of migrating open sockets across cgroups can easily be
>> fixed if it is deemed to be a problem but is unlikely to be a big
>> issue for most workloads like browsers or web servers.
>
> Can you explain how to assign the PIDs to cgroups before the process
> is created?

By assigning the parent to the cgroup before the new process is forked.

> Are there any special tools to achieve that? Or do you
> intentionally limit the functionality to sockets which are created
> after the process is assigned to the cgroup? I would be interested to
> see a typical usage example of your approach in order to understand
> it better.

An excerpt from the patch I had sent out:

An example of the use of this resource controller would be to limit
the traffic from all tasks from a file_server cgroup to 100Mbps. We could
achieve this by doing:

# make a cgroup of file transfer processes and assign it a arbitrary unique
# classid of 0x1234 - this will be used later to direct packets.
mkdir -p /dev/cgroup
mount -t cgroup tc -otc /dev/cgroup
mkdir /dev/cgroup/file_transfer
echo 0x1234 > /dev/cgroup/file_transfer/tc.classid


# Now create a HTB class that rate limits traffic to 100mbits and attach
# a filter to direct all traffic from cgroup file_transfer to this new class.
tc qdisc add dev eth0 root handle 1: htb
tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit
tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 cgroup
value 0x1234 classid 1:10

# write the current shell pid to the cgroup
echo $$ > /dev/cgroup/file_transfer/tasks
#start the new task (e.g. ftp)
ftp foo.bar.com

>
> Fixing the migration of open sockets is definitely not a problem but
> how do you plan on assigning the class identifier to sockets which
> already exist when a process is assigned to a cgroup? Do you intend
> to walk through all open file descriptors?

That is one possible solution (maybe a bit too heavyweight) or the
other technique suggested was for the socket to hold a reference to
the cgroup and then the id could be changed on the fly without having
to walk all the sockets.

Again in practice both these may be overkill since it should be
relatively easy for a resource management daemon on the system to
start new processes in a cgroup instead of attempting live migration.

-Thanks,
Ranjit

>
