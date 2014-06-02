From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net-sysfs: Report link speed as signed integer
Date: Mon, 02 Jun 2014 16:40:20 +0200
Message-ID: <87egz72x4b.fsf@nemi.mork.no>
References: <06d53256e3bf2d0deedb16249082200500da3ee6.1401718809.git.mprivozn@redhat.com>
	<20140602143557.GA2925@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Privoznik <mprivozn@redhat.com>, davem@davemloft.net,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140602143557.GA2925@minipsycho.orion> (Jiri Pirko's message of
	"Mon, 2 Jun 2014 16:35:57 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko <jiri@resnulli.us> writes:
> Mon, Jun 02, 2014 at 04:25:15PM CEST, mprivozn@redhat.com wrote:
>>The link speed is available at /sys/class/net/$nic/speed.
>>However, the speed is printed in unsigned integer format. This
>>makes userspace applications read an incorrect value (which
>>moreover changes through several architectures) while in fact
>>'-1' should be reported.
>>
>>Before the change:
>>  # cat /sys/class/net/eth0/speed
>>  4294967295
>>
>>After the change:
>>  # cat /sys/class/net/eth0/speed
>>  -1
>>
>>Signed-off-by: Michal Privoznik <mprivozn@redhat.com>
>>---
>> net/core/net-sysfs.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>>diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>>index 1cac29e..99afdea 100644
>>--- a/net/core/net-sysfs.c
>>+++ b/net/core/net-sysfs.c
>>@@ -173,7 +173,7 @@ static ssize_t speed_show(struct device *dev,
>> 	if (netif_running(netdev)) {
>> 		struct ethtool_cmd cmd;
>> 		if (!__ethtool_get_settings(netdev, &cmd))
>>-			ret =3D sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
>>+			ret =3D sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
>
> I wonder why this should be signed. What -1 means? What driver report=
s
> this?

I believe many drivers will do this when the speed is unknown, e.g
because the link is down.  For example:

bjorn@nemi:~$ grep . /sys/class/net/eth0/speed
4294967295
bjorn@nemi:~$ ls -l /sys/class/net/eth0/device/driver
lrwxrwxrwx 1 root root 0 Jun  2 10:48 /sys/class/net/eth0/device/driver=
 -> ../../../bus/pci/drivers/e1000e
bjorn@nemi:~$ ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Supported pause frame use: No
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Speed: Unknown!
        Duplex: Unknown! (255)
        Port: Twisted Pair
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: Unknown
Cannot get wake-on-lan settings: Operation not permitted
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: no



Bj=C3=B8rn
