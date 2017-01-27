From: Ivan Vecera <cera@cera.cz>
Subject: Re: [PATCH net] be2net: fix initial MAC setting
Date: Fri, 27 Jan 2017 16:21:14 +0100
Message-ID: <CA+Nub0YU8ZPsZ3Qa1vPSAkz55SoBOnPk8LSt0a_pC090okMEbA@mail.gmail.com>
References: <20170126102801.18914-1-cera@cera.cz> <CAHHeUGXitTaXqQk8zDymcCX09vFq3CtM20FHJPL6AeVhc2iBPQ@mail.gmail.com>
Reply-To: ivan.vecera@cera.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34095 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754817AbdA0PVs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:21:48 -0500
Received: by mail-io0-f193.google.com with SMTP id c80so8259778iod.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 07:21:15 -0800 (PST)
In-Reply-To: <CAHHeUGXitTaXqQk8zDymcCX09vFq3CtM20FHJPL6AeVhc2iBPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-01-27 13:38 GMT+01:00 Sriharsha Basavapatna
<sriharsha.basavapatna@broadcom.com>:
> Hi Ivan,
>
> This patch is a bit involved. We need some time to review and test
> this to make sure it works with other (non-BE3/VF - Skyhawk, Lancer)
> devices. Also, IIRC we shouldn't see this issue with the latest FW.
>
> Thanks,
> -Harsha

Btw. FW 11.1.215.0 is the latest available... As I described the
problem is reproducible after fresh boot.

1) After _FRESH_ boot we have enp1s0f0 interface that is BE3 PF with
SR-IOV enabled
[root@sm-02 ~]# uname -r
4.10.0-rc4-00189-ga47b70e
[root@sm-02 ~]# ethtool -i enp1s0f0 | egrep '(firm|bus)'
firmware-version: 11.1.215.0
bus-info: 0000:01:00.0
[root@sm-02 ~]# lspci -vv -s 0000:01:00.0 | egrep '(Name:|VFs)'
               Product Name: OCe11102-FM 2P 10GbE Tomcat Enterprise CNA, NIC PF
               Initial VFs: 32, Total VFs: 32, Number of VFs: 0,
Function Dependency Link: 00

2) Now we create 1 VF
[root@sm-02 ~]# ip link set enp1s0f1 up
be2net 0000:01:00.1 enp1s0f1: Link is Up
[root@sm-02 ~]# echo 1 > /sys/class/net/enp1s0f1/device/sriov_numvfs
...
be2net 0000:01:00.1: VF0 has FILTMGMT privilege
...
be2net 0000:01:08.0: Emulex OneConnect(be3): VF  port 1
be2net 0000:01:08.0 enp1s8f0: renamed from eth0

3) Now we have 1 privileged VF named enp1s8f0 that is down
[root@sm-02 ~]# ip link show dev enp1s8f0
12: enp1s8f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid
0200000000000000000000333630384254 state DOWN mode DEFAULT qlen 1000
   link/ether 00:00:c9:9c:5c:60 brd ff:ff:ff:ff:ff:ff

4) Now we set the interface up (this fails)
[root@sm-02 ~]# ip link set enp1s8f0 up
be2net 0000:01:08.0: opcode 59-1 failed:status 1-76
RTNETLINK answers: Input/output error

5) Delete VF and create 2 new VFs
[root@sm-02 ~]# echo 0 > /sys/class/net/enp1s0f1/device/sriov_numvfs
...
[root@sm-02 ~]# echo 2 > /sys/class/net/enp1s0f1/device/sriov_numvfs
...
be2net 0000:01:08.0 enp1s8f0: renamed from eth0
...
be2net 0000:01:08.1 enp1s8f1: renamed from eth0

6) We have 2 privileged VFs named enp1s8f0 and enp1s8f1, both down
[root@sm-02 ~]# ip link show dev enp1s8f0
13: enp1s8f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid
0200000000000000000000333630384254 state DOWN mode DEFAULT qlen 1000
   link/ether 00:00:c9:9c:5c:60 brd ff:ff:ff:ff:ff:ff
[root@sm-02 ~]# ip link show dev enp1s8f1
14: enp1s8f1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid
0200000000000000000000333630384254 state DOWN mode DEFAULT qlen 1000
   link/ether 00:00:c9:9c:5c:61 brd ff:ff:ff:ff:ff:ff

7) Now set them up
[root@sm-02 ~]# ip link set enp1s8f0 up
be2net 0000:01:08.0 enp1s8f0: Link is Up
[root@sm-02 ~]# ip link set enp1s8f1 up
be2net 0000:01:08.1: opcode 59-1 failed:status 1-76
RTNETLINK answers: Input/output error

As you can see the re-used interface enp1s8f0 is OK but not-yet-used
interface enp1s8f1 fails.

8) Try to set enp1s8f1 up again
[root@sm-02 ~]# ip link set enp1s8f1 up
be2net 0000:01:08.1 enp1s8f1: Link is Up

Now it is OK... This is because be_close() is called when
be_enable_if_filters() fails. be_close() calls be_disable_if_filters()
and there the MAC pre-programmed by PF is deleted by be_dev_mac_del().
So when you try to set the interface up again then the pre-programmed
MAC is away and be_dev_mac_add() succeeds.

Regards,
Ivan
