From: Bernd Naumann <bena@spreadshirt.net>
Subject: vhost_net: VM looses network when using vhost over time
Date: Wed, 20 Sep 2017 14:44:54 +0000 (UTC)
Message-ID: <872691802.5840849.1505918694826.JavaMail.zimbra@spreadshirt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: qemu-discuss@nongnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx30.spreadomat.net ([85.239.103.144]:35219 "EHLO
        mx30.spreadomat.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751570AbdITOx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:53:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi @all,

We have encountered/experience a bug which is more or less reproducible, bu=
t we do not know how to do it exactly or how to debug the issue in the firs=
t place.


# Background

In our setup we have a Ganti Cluser (kvm) with atm ~60 nodes running ~500 V=
Ms, we are using tap interfaces on L2 bridges, L3 routed tap interfaces, an=
d tap interfaces on a bridge with a VTEP attached to it. (For the vxlan set=
up we have a home grown daemon to maintain the FDB).


# The issue

On some VMs we loose network-connectivity under certain/unknown circumstanc=
es.=20
"Looseing" means that the VM is not reachable and can therefor not reach an=
y other host in the network.

However with `tcpdump` on the host (phy NIC + bridge) we can see the traffi=
c going in; but with `tcpdump` on the VM we only see arp goes in, but nothi=
ng goes out. Manually setting the ARP entry does not help at all, or only f=
or a moment, like `ip link set $DEV set arp off; ip link set $DEV arp on`. =
The only way we found to "fix" it, is rebooting the VM, or do `modprobe -r =
virtio_net; modprobe virtio_net`, but this seams also not the best workarou=
nd and can fail in a short time again. Also it is difficult to determinate =
when the issue is kicking in. Counting 'FAILED' neighbors is a indicator bu=
t nothing to rely on.

The frequence of the issue ranges from once in a few days, to multiple time=
s per day or even after some minutes after boot. Most impact we see on VMs =
with higher network traffic like our gateway-VMs (multiple NICs in differen=
t networks, IPsec, iptables, ...); ha-proxy-VMs (similar to our gateways), =
but also (with reduced frequency) on /normal/ application VMs.

For what we have found so far, it looks like kind of:=20
* https://bugs.launchpad.net/ubuntu/+source/qemu-kvm/+bug/997978 -- Bug #99=
7978 =E2=80=9CKVM images lose connectivity with bridged network=E2=80=9D : =
Bugs : qemu-kvm package : Ubuntu
* https://bugs.centos.org/view.php?id=3D5526 -- 0005526: KVM Guest with vir=
tio network loses network connectivity - CentOS Bug Tracker

Via `rtmon` we can observe that it starts with some "FAILED" neighbor entri=
es and that they increase over time. As we know that this is only one conse=
quence of not sending ARP replys to the requester; or that requested ARP is=
 unanswered (cause the packet is not leaving the VM), the increasing count =
of 'FAILED' neighbors is /normal/. BUT: This can start on any interface, br=
idged tap interface for WAN, bridged tap in VXLAN, routed tap; it does not =
matter, or is not directly linked to the "kind" of interface.


# General overview of the setup

* ganiti-cluster with ~60 nodes
* each node has 2 x 50G (mlnx5 dual-port) connected to 2 x MLNX SN2700 swit=
ches
* each node runs `bird` with OSPF and ECMP (and OSPF with ECMP on SN2700 to=
o)
* each VM has one or more vNICs in a bridged or routed network
* networks: bridged tap in WAN; bridged tap with attached VTEP; routed tap
* host OS: Ubuntu 16.04.3 with Ubuntu Kernel 4.12.13; first tested with qem=
u-kvm 1:2.5+dfsg-5ubuntu10.15, and later upgraded to qemu-kvm 2.10~rc3+dfsg=
-0ubuntu1, same issue; guest OS Ubutnu 14.04, Ubuntu 16.04 and Ubuntu 16.04=
 with latest Ubuntu mainline kernel PPA


# So far we can "verify" it is 'vhost'

Without "vhost=3Don" for the kvm process we can not observe this issue. Whi=
le using "vhost=3Don", a effected VM can be "fixed" by `rmmod` and `insmod =
virtio_net`, but reboot seams to provide a "fix" for a "longer" period. (Bu=
t as you may know, virtio has not the performance we expect.)


So we have some questions:

* How can we debug the main issue to provide a meaningful bug report? Debug=
 flags on the kernel but where to hang gdb on it? Sadly we are no kernel ha=
ckers :/, but we can compile our own kernel and qemu-kvm to test also relea=
se candidates and/or put patches in place.
* Does someone have seen this too? Can provide a better workaround, or patc=
h or anything?
* Where to file/reopen this issue? qemu, netdev?
* Is qemu-kvm even the right place to look for answers?

We are happy to provide more information or collect debug information if so=
meone wants to investigate.

Thanks for your time!
Best,
Bernd Naumann

Spreadshirt=20
Bernd Naumann=20
Systems Engineer, Networking & Operations=20
bernd.naumann@spreadshirt.net=20

http://www.spreadshirt.com=20

sprd.net AG=20
Gie=C3=9Ferstra=C3=9Fe 27=20
D-04229 Leipzig=20

Fon: +49 341 594 00 - 5900=20
Fax: +49 341 594 00 - 5149=20

Vorstand / executive board: Philip Rooke (CEO/Vorsitzender) =C2=B7 Tobias S=
chaugg=20
Aufsichtsratsvorsitzender / chairman of the supervisory board: Lukasz Gadow=
ski=20
Handelsregister / trade register: Amtsgericht Leipzig, HRB 22478=20
Umsatzsteuer-IdentNummer / VAT-ID: DE 8138 7149 4
