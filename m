From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 193911] New: net_prio.ifpriomap is not aware of the
 network namespace, and discloses all network interface
Date: Fri, 3 Feb 2017 15:53:30 -0800
Message-ID: <20170203155330.06edece4@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
        "ric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33109 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752825AbdBCXxd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:53:33 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so9183328pfb.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:53:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 03 Feb 2017 21:14:28 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 193911] New: net_prio.ifpriomap is not aware of the network n=
amespace, and discloses all network interface


https://bugzilla.kernel.org/show_bug.cgi?id=3D193911

            Bug ID: 193911
           Summary: net_prio.ifpriomap is not aware of the network
                    namespace, and discloses all network interface
           Product: Networking
           Version: 2.5
    Kernel Version: 4.9
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: xgao01@email.wm.edu
        Regression: No

The pseudo file net_prio.ifpriomap (under /sys/fs/cgroup/net_prio) contains=
 a
map of the priorities assigned to traffic starting from processes in a cgro=
up
and leaving the system on various interfaces. The data format is in the for=
m of
[ifname priority].=20

We find that the kernel handler function hooked at net_prio.ifpriomap is not
aware of the network namespace, and thus it discloses all network interface=
s on
the physical machine to the containerized applications.=20

To be more specific, the read operation of net_prio.ifpriomap is handled by=
 the
function read_priomap. Tracing from this function, we can find it invokes
for_each_netdev_rcu and set the first parameter as the address of init_net.=
 It
iterates all network devices of the host regardless of the network namespac=
e.
Thus, from the view of a container, it can read the names of all network
devices of the host.

Here is an example. I checked it on Linux kernel 4.4 with Docker version
1.12.1. I do not have the latest kernel at hand. But there is no code change
between 4.4 and 4.9 for this function. It should be reproducible in the lat=
est
kernel.=20

I initiated a Docker container and checked the net_prio.ifpriomap inside the
container. It displayed all network interfaces information on the host.

Container:=20
root@25e25d553c3b:/# cat /sys/fs/cgroup/net_prio/net_prio.ifpriomap=20
lo 0
eth0 0
eth1 0
xenbr0 0
lxdbr0 0
virbr0 0
virbr0-nic 0
docker0 0
vnet0 0
vnet1 0
veth132de4a 0

Host:
XXXX@XXXX:~$ cat /sys/fs/cgroup/net_prio/net_prio.ifpriomap=20
lo 0
eth0 0
eth1 0
xenbr0 0
lxdbr0 0
virbr0 0
virbr0-nic 0
docker0 0
vnet0 0
vnet1 0
veth132de4a 0

=46rom the information displayed above, this file exposes the same network
interface information in a container and on a host, which we considered to =
be a
leakage for the network namespace.

--=20
You are receiving this mail because:
You are the assignee for the bug.
