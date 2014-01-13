From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: build_skb() and data corruption
Date: Mon, 13 Jan 2014 12:47:42 +0100
Message-ID: <CACmBeS35RAEQ+t2vtYtFTKNT-VdQw20hURjTi193Jk8HG7UECA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	bhutchings@solarflare.com, alexander.h.duyck@intel.com,
	Arnd Bergmann <arnd@arndb.de>,
	Florian Fainelli <florian@openwrt.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please help,

I think I see memory corruption with a driver recently added to linux-next.

The following error occur downloading a large file with wget (or
ncftp): "read error: Bad address"
wget exits and leaves the file unfinished.

The error goes away when build_skb() is patched out, in this case by
allocating pages directly in RX loop.

I currently have two branches with code placed under ifdef USE_BUILD_SKB:
https://bitbucket.org/Kasreyn/linux-next/src/faa7c408a655fdfd7c383f79259031da5a05d61e/drivers/net/ethernet/moxa/moxart_ether.c#cl-472

If build_skb() is the cause, is there something the driver can do about it?

A quick search on "build_skb memory corruption" reveals the following
commit, "igb: Revert support for build_skb in igb"
f9d40f6a9921cc7d9385f64362314054e22152bd:

"The reason for reverting this patch is that it can lead to data corruption.
The following flow was pointed out by Ben Hutchings:
1. skb is forwarded to another device
2. Packet headers are modified and it's put into a queue
3. Second packet is received into the other half of this page
4. Page cannot be reused, so is DMA-unmapped
5. The DMA mapping was non-coherent, so unmap copies or invalidates
cache
The headers added in step 2 get trashed in step 5."


This is extra interesting, errors only happen on a locally mounted
ext3 filesystem, never on tmpfs e.g.:

# mount
/dev/mmcblk0p1 on / type ext3
(rw,relatime,errors=continue,barrier=1,data=ordered)
tmpfs on /dev/shm type tmpfs (rw,relatime,mode=777)
tmpfs on /tmp type tmpfs (rw,relatime)

#cd /tmp
# wget -c ftp://149.20.4.69/pub/linux/kernel/v2.6/linux-2.6.11.11.tar.gz
Connecting to 149.20.4.69 (149.20.4.69:21)
linux-2.6.11.11.tar.  25% |*******                        | 11374k
0:01:36 ETAwget: short write
[  153.560000] wget (383) used greatest stack depth: 4776 bytes left
# rm linux-2.6.11.11.tar.gz
# wget -c ftp://149.20.4.69/pub/linux/kernel/v2.6/linux-2.6.11.11.tar.gz
Connecting to 149.20.4.69 (149.20.4.69:21)
linux-2.6.11.11.tar.  25% |*******                        | 11315k
0:01:34 ETAwget: short write
# rm linux-2.6.11.11.tar.gz
# wget -c ftp://149.20.4.69/pub/linux/kernel/v2.6/linux-2.6.11.11.tar.gz
Connecting to 149.20.4.69 (149.20.4.69:21)
linux-2.6.11.11.tar.  25% |*******                        | 11473k
0:01:38 ETAwget: short write
[  237.300000] wget (387) used greatest stack depth: 4752 bytes left

# cd /root/
# wget -c ftp://149.20.4.69/pub/linux/kernel/v2.6/linux-2.6.11.11.tar.gz
Connecting to 149.20.4.69 (149.20.4.69:21)
linux-2.6.11.11.tar.   3% |*                              |  1647k  0:03:02 ETA
wget: read error: Bad address


Regards,
Jonas
