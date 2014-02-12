From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: team driver MAC addresses questions
Date: Wed, 12 Feb 2014 17:16:27 +0100
Message-ID: <20140212161627.GB3027@minipsycho.orion>
References: <65502A17874025489B7D8479C16CFA634E91D1D0@nasanexd02f.na.qualcomm.com>
 <20140212133726.GA3027@minipsycho.orion>
 <65502A17874025489B7D8479C16CFA634E91D236@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	qca_vkondrat <qca_vkondrat@qca.qualcomm.com>
To: qca_dlansky <qca_dlansky@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:50628 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbaBLQSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:18:39 -0500
Received: by mail-ee0-f43.google.com with SMTP id c41so4420750eek.16
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 08:18:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <65502A17874025489B7D8479C16CFA634E91D236@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 12, 2014 at 03:17:10PM CET, qca_dlansky@qualcomm.com wrote:
>>Q2:
>>We've noticed the following behavior:
>>- wlan1 has some MAC address - m1
>>- team0 created with random MAC address - m2
>>
>>root@lx-foo:~# ip link
>>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT 
>>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>>2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
>>    link/ether 00:21:70:be:4f:68 brd ff:ff:ff:ff:ff:ff
>>4: wlan1: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN mode DORMANT qlen 1000
>>    link/ether 44:39:c4:18:b5:7a brd ff:ff:ff:ff:ff:ff
>>12: team0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
>>    link/ether 9a:ac:d5:91:df:aa brd ff:ff:ff:ff:ff:ff
>>
>>- When adding port wlan1 into team0, m1 gets assigned to team0 and m2 
>>gets assigned to wlan1
>>
>>root@lx-foo:~# LD_LIBRARY_PATH=/usr/local/lib/ teamdctl team0 port add 
>>wlan1 root@lx-foo:~# ip link
>>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT 
>>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>>2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
>>    link/ether 00:21:70:be:4f:68 brd ff:ff:ff:ff:ff:ff
>>4: wlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master team0 state UP mode DORMANT qlen 1000
>>    link/ether 9a:ac:d5:91:df:aa brd ff:ff:ff:ff:ff:ff
>>12: team0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT 
>>    link/ether 44:39:c4:18:b5:7a brd ff:ff:ff:ff:ff:ff
>>
>>This is a bit strange for us. We were expecting both of them to have the same MAC address.
>>
>>Further investigation showed that when adding the port, the MAC address of the added port is set twice:
>>once by team_add_slave(), when wlan1 is still down. The MAC address is set to m2.
>>second time by team_set_mac_address(), after wlan1 is up. The MAC address is set to m1.
>
>Are you using teamd? What config?
>
>[DL]  just 'teamd -d', no config at all


Ok. So here's what is going on:

During the port enslave when the port device is down, team driver
changes hwaddr of the port to team one (round robin mode does that).

After that, teamd detects that port was added and sets team hwaddr
according to the first enslaved port. That will lead to change of hwaddr
of port again, now it is upped.

The reason for this behaviour is that userspace controls hwaddr
assignement.

So for you case the workaround is to specify hwaddr in teamd config.
After that, teamd will not set hwaddr according to first enslaved port.

>
>>
>>However, the 2nd call fails which leaves wlan1 with m2. The reason for the failure is because ath9k doesn't support IFF_LIVE_ADDR_CHANGE.
>>
>>Our question: in team_set_mac_address(), in case there is a failure setting MAC address for any port inside port_list, doesn't it make sense to undo MAC address changes and report the failure up the stack?
>>
>
>Yes. That would be probably the proper thing to do. WOuld you send the patch or I should do it? Would be needed to do something similar what bonding does.
>
>[DL] Let us think about it. We want to prepare patch, but we need time to do so.
>

Feel free to send me draft, questions, anything you need.

Jiri

>>Thanks,
>>  Vladimir & Dedy.
