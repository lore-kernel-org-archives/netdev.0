From: qca_dlansky <qca_dlansky@qualcomm.com>
Subject: team driver MAC addresses questions
Date: Wed, 12 Feb 2014 13:04:45 +0000
Message-ID: <65502A17874025489B7D8479C16CFA634E91D1D0@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	qca_vkondrat <qca_vkondrat@qca.qualcomm.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:23144 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaBLNEr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 08:04:47 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

We have couple of questions about the team driver with regards to MAC addresses assignment.
For our testing, we have ath9k (wlan1) as the port being added into team0.

Q1:
When team device created it gets some random MAC address. When adding wlan1 into team device, team sticks to its random MAC and doesn't inherit from the added port.
This is because inside team_dev_type_check_change():

if (dev->type == port_dev->type)
        return 0;

What is the reason for this behavior? Doesn't it make sense to inherit MAC from the 1st port being added?

Q2:
We've noticed the following behavior:
- wlan1 has some MAC address - m1
- team0 created with random MAC address - m2

root@lx-foo:~# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 00:21:70:be:4f:68 brd ff:ff:ff:ff:ff:ff
4: wlan1: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN mode DORMANT qlen 1000
    link/ether 44:39:c4:18:b5:7a brd ff:ff:ff:ff:ff:ff
12: team0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
    link/ether 9a:ac:d5:91:df:aa brd ff:ff:ff:ff:ff:ff

- When adding port wlan1 into team0, m1 gets assigned to team0 and m2 gets assigned to wlan1

root@lx-foo:~# LD_LIBRARY_PATH=/usr/local/lib/ teamdctl team0 port add wlan1
root@lx-foo:~# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 00:21:70:be:4f:68 brd ff:ff:ff:ff:ff:ff
4: wlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master team0 state UP mode DORMANT qlen 1000
    link/ether 9a:ac:d5:91:df:aa brd ff:ff:ff:ff:ff:ff
12: team0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
    link/ether 44:39:c4:18:b5:7a brd ff:ff:ff:ff:ff:ff

This is a bit strange for us. We were expecting both of them to have the same MAC address.

Further investigation showed that when adding the port, the MAC address of the added port is set twice:
once by team_add_slave(), when wlan1 is still down. The MAC address is set to m2.
second time by team_set_mac_address(), after wlan1 is up. The MAC address is set to m1.

However, the 2nd call fails which leaves wlan1 with m2. The reason for the failure is because ath9k doesn't support IFF_LIVE_ADDR_CHANGE.

Our question: in team_set_mac_address(), in case there is a failure setting MAC address for any port inside port_list, doesn't it make sense to undo MAC address changes and report the failure up the stack?

Thanks,
  Vladimir & Dedy.
