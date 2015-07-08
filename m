From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v4 0/3] net: dsa: mv88e6xxx: add support for VLAN Table
 Unit
Date: Wed, 8 Jul 2015 13:13:16 -0400 (EDT)
Message-ID: <894793886.88178.1436375596747.JavaMail.zimbra@savoirfairelinux.com>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150708143805.GA32208@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:63909 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbbGHRNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 13:13:20 -0400
In-Reply-To: <20150708143805.GA32208@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Jul 8, 2015, at 10:38 AM, Andrew Lunn andrew@lunn.ch wrote:

> On Tue, Jul 07, 2015 at 05:18:17PM -0400, Vivien Didelot wrote:
>> Hi all,
>> 
>> This patchset brings full support for hardware VLANs in DSA, and the Marvell
>> 88E6xxx compatible switch chips.
> 
> Hi Vivien
> 
> I would like to do a proper review and testing of these patchset, but
> i go on vacation this afternoon. So it will be in about 2 weeks time.
> 
> I spent 15 minutes tests just now. I spotted two things:
> 
> 1) I played with a configuration, and then rebooted the machine. After
> login i see:
> 
> Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
> permitted by applicable law.
> # cat /sys/kernel/debug/dsa0/vtu
> VID  FID  SID  0  1  2  3  4  5  6
>   1    1    0  u  u  u  u  x  x  t
> 500  500    0  t  t  t  t  x  x  t
> 550  550    0  t  x  x  x  x  x  t
> # bridge vlan show
> port    vlan ids
> lan0     1 PVID Egress Untagged
> 
> lan0     1 PVID Egress Untagged
> 
> lan1
> lan2
> lan3
> lan4
> lan5
> lan6
> lan7
> lan8     1 PVID Egress Untagged
> 
> lan8     1 PVID Egress Untagged
> 
> optical3
> optical4
> br0      1 PVID Egress Untagged
> 
> 
> So the switch seems to have some VTU table entries, but the bridge
> command does not show them. I suspect that a warm boot does not clear
> out the VTU entries in the switch.
> 
> Until recently we had a similar problem with the statistics
> counters. I wounder if we have the same problem with other tables? Do
> static ATU entries get removed on a reboot?
> 

You're right. There's a single operation to clear the STU and VTU. I
will send a follow-up patch to send this command during the switch
setup.

> 2) I cold booted the machine, to be sure to have a clean state. Then:
> 
> # cat /sys/kernel/debug/dsa0/vtu
> VID  FID  SID  0  1  2  3  4  5  6
>   1    1    0  u  x  x  x  x  x  t
> 
> So a good initial state. I then configure two bridges:
> 
> # brctl show
> bridge name     bridge id               STP enabled     interfaces
> br0             8000.92647a2160c4       yes             lan0
>                                                        lan1
> br1             8000.92647a2160c4       yes             lan2
>                                                        lan3
> 
> and then add vlan 500 to the four interfaces.
> 
> # bridge vlan add vid 500 dev lan0 master
> # bridge vlan add vid 500 dev lan1 master
> # bridge vlan add vid 500 dev lan2 master
> # bridge vlan add vid 500 dev lan3 master
> 
> # cat /sys/kernel/debug/dsa0/vtu
> VID  FID  SID  0  1  2  3  4  5  6
>   1    1    0  u  u  u  u  x  x  t
> 500  500    0  t  t  t  t  x  x  t
> 
> Does this mean we have one hardware bridge? All four ports can talk to
> each other? I've not actually sent any frames to test this, so i'm
> just speculating. Given that i have two software bridges, this is not
> what i would expect, if frames from lan0 or lan1, also went out lan2
> or lan3.

Indeed, with the "master" keyword, we ask switchdev to populate the
parent's (i.e. the switch chip) to create VLANs. Marvell switch such as
the 88E66352 can only have a single VLAN table entry for a given VID.

Please note that this patchset only brings support to access the
hardware VLAN Table Unit through switchdev, that is to say add, delete,
and dump entries in this table. To have fully functional VLAN support in
Linux with this switch family, there is certainly more work to do.

>From what I see, the patchset works fine for you (from bridge commands
and debugfs).

If the patchset looks good to you guys, may I suggest to get some
acknowledgments from you, so it can get merged? Then we could continue
to work on better synchronization with the FDB, STU (already in
progress) and other switchdev objects.

Regards,
-v
