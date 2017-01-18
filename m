From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 18 Jan 2017 12:00:46 +0100
Message-ID: <3291b7c1-7bf6-d776-adab-b89c9cd9be38@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:51237 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754821AbdARLKS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 06:10:18 -0500
In-Reply-To: <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2017 12:32 AM, Timur Tabi wrote:
> On 10/24/2016 05:40 AM, Zefir Kurtisi wrote:
>> As a result, if you ever see a warning
>> '803x_aneg_done: SGMII link is not ok' you will
>> end up having an Ethernet link up but won't get
>> any data through. This should not happen, if it
>> does, please contact the module maintainer.
> 
> I am now seeing this:
> 
> ubuntu@ubuntu:~$ ifup eth1
> ubuntu@ubuntu:~$ [  588.687689] 803x_aneg_done: SGMII link is not ok
> [  588.694909] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow control
> rx/tx
> [  588.703985] qcom-emac QCOM8070:00 eth1: Link is Up - 1Gbps/Full - flow control
> rx/tx
> 
> ubuntu@ubuntu:~$ ping 192.168.3.1
> PING 192.168.3.1 (192.168.3.1) 56(84) bytes of data.
> 64 bytes from 192.168.3.1: icmp_seq=1 ttl=64 time=0.502 ms
> 64 bytes from 192.168.3.1: icmp_seq=2 ttl=64 time=0.244 ms
> 64 bytes from 192.168.3.1: icmp_seq=3 ttl=64 time=0.220 ms
> ^C
> --- 192.168.3.1 ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 2107ms
> rtt min/avg/max/mdev = 0.220/0.322/0.502/0.127 ms
> 
> So I do get the "SGMII link is not ok" message, but my connection is fine.  I
> don't know why the link-up message is displayed twice.  It's only displayed once
> if I use the genphy driver instead of the at803x driver.
> 
> I'm going to debug the at803x to see what it does that causes the double link-up
> message.
> 

The fact that you see the warning means external autoneg completes before the
SGMII side in best case or SGMII link remains down in worst case. To prevent this,
I am using a private variant of the at8031 driver that ensures that the SGMII
autoneg is never restarted. If you ever end up with a dead link, feel free to test
with the related functions below.


Cheers,
Zefir

---
static int nt_at8031_no_soft_reset(struct phy_device *phydev)
{
	return 0;
}

/*
 * Powering the chip down occasionally causes SGMII link loss, which in turn
 * causes the connection to gianfar to remain down.
 *
 * To prevent permanent link loss, instead of power down just isolate pins.
 */
static int nt_at8031_suspend(struct phy_device *phydev)
{
	mutex_lock(&phydev->lock);
	phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_ISOLATE);
	mutex_unlock(&phydev->lock);
	return 0;
}

static int nt_at8031_resume(struct phy_device *phydev)
{
	mutex_lock(&phydev->lock);
	phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) & ~BMCR_ISOLATE);
	mutex_unlock(&phydev->lock);
	return 0;
}
