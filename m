From: Deepjyoti Kakati <dkakati73@gmail.com>
Subject: a problem with tap port insertion/deletion from bridge
Date: Sun, 19 Jul 2009 15:26:18 +0530
Message-ID: <9a2da8520907190256s8962398n896da94a1793fb71@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:63748 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbZGSJ4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2009 05:56:18 -0400
Received: by qw-out-2122.google.com with SMTP id 8so626665qwh.37
        for <netdev@vger.kernel.org>; Sun, 19 Jul 2009 02:56:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

am facing a issue with bridge that apparently stops fwding and
hoping someone can point out what is going wrong or give some
clues.

am using linux 2.6.27 and corresponding bridgeutils pkg.

my topology inside the machine is like this

(UDP Server daemon)
|
|
socket
|
|
[my_bridge 172.16.0.3]----tap1---Virtual machine2
|
|
tap0
|
virtual machine1
172.16.0.2

I create a few virtual machines using qemu and have their tap
interfaces hook into the bridge.

virtual machine1 internally assigns 172.16.0.2 to its virtual nic

the bridge itself has address 172.16.0.3

my server binds a UDP socket to a {fixed port, 172.16.0.3} and takes
heartbeats and messages from virtual machine1 who is UDP client
and binds to 172.16.0.2

things work fine and packets flow both ways

STP is turned off by default as per "brctl show"

trouble starts when I shut down virtual machine2 or 3 and detach the
tap1 or tap2 from the bridge. the detach sequence I used is:

ifconfig tap1 down
brctl delif br_internal tap1
ifconfig tap1 up

I would expect the bridge to keep on forwarding pkts to and from tap0
port which is still attached, however i see sometimes the bridge receives
frames from tap0 (heartbeats from virtual machine1) but my socket never
gets it and is blocked in recvfrom()

this condition lasts from 10-40 seconds before things get back to normal.

I think my socket is ok because I sent a message to it from another
thread while this condition was happening and this dummy message
instantly came to recvfrom().

tried turning on STP and setting fwd delay of 0 to no avail. also
tried explicitly setting the promiscuous flag with ifconfig.

/var/log/messages does not show tap0 going out of forwarding state. it
appears normal.

the port thats detached goes into disabled state which is expected.

if there is anything wrong with my approach or there is some known
issue with bridge forwarding during topology change, kindly let me know.

I need to be able to attach and detach taps dynamically without
affecting traffic on other ports as the VLANs used by the virtual machines
can be changed on the fly. multiple virtual machine tap's could be hooked
onto the same bridge (vlan) hence the issue.

thanks
Deepjyoti Kakati
