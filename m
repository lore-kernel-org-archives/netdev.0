From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: [REGRESSION, bisect] net: ipv6: unregister_netdevice: waiting for lo
 to become free. Usage count = 2
Date: Wed, 2 Mar 2016 12:31:50 -0800
Message-ID: <20160302203150.GA2045@hudson.localdomain>
References: <6c735168f53548a39bd21e6e9857f512@HKXPR3004MB0088.064d.mgd.msft.net>
 <20160301200749.GA1611@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dexuan Cui <decui@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160301200749.GA1611@hudson.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Tue, Mar 01, 2016 at 12:07:49PM -0800, Jeremiah Mahler wrote:
> Hi all,
> 
> On Tue, Mar 01, 2016 at 08:11:54AM +0000, Dexuan Cui wrote:
> > Hi, I got this line every 10 seconds with today's linux-next in a Hyper-V guest, even
> > when I didn't configure any NIC for the guest:
> >  
> > [   72.604249] unregister_netdevice: waiting for lo to become free. Usage count = 2
> > [   82.708170] unregister_netdevice: waiting for lo to become free. Usage count = 2
> > [   92.788079] unregister_netdevice: waiting for lo to become free. Usage count = 2
> > [  102.808132] unregister_netdevice: waiting for lo to become free. Usage count = 2
> > [  112.928166] unregister_netdevice: waiting for lo to become free. Usage count = 2
> > [  122.952069] unregister_netdevice: waiting for lo to become free. Usage count = 2
> > 
> > I don't think this is related to the underlying host, since it's related to "lo".
> > 
> > This should be a recent regression, as I remember the January linux-next didn't have
> > this issue.
> > 
> > Any idea?
> > 
> > The gzip-ed kernel config is attached FYI.
> > 
> > Thanks,
> > -- Dexuan
> > 
> 
> Just a "me too", but I have this problem on a Lenovo Carbon X1 when
> running linux-next 20160301.  It worked with 20160225.
> 
> I can test patches and I will try to bisect the problem as time allows.
> 
> -- 
> - Jeremiah Mahler

I performed a bisect and found that the following patch introduced the
regression.

  From f1705ec197e705b79ea40fe7a2cc5acfa1d3bfac Mon Sep 17 00:00:00 2001
  From: David Ahern <dsa@cumulusnetworks.com>
  Date: Wed, 24 Feb 2016 09:25:37 -0800
  Subject: [PATCH] net: ipv6: Make address flushing on ifdown optional
  
  Currently, all ipv6 addresses are flushed when the interface is configured
  down, including global, static addresses:
  
      $ ip -6 addr show dev eth1
      3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
          inet6 2100:1::2/120 scope global
             valid_lft forever preferred_lft forever
          inet6 fe80::e0:f9ff:fe79:34bd/64 scope link
             valid_lft forever preferred_lft forever
      $ ip link set dev eth1 down
      $ ip -6 addr show dev eth1
      << nothing; all addresses have been flushed>>
  
  Add a new sysctl to make this behavior optional. The new setting defaults to
  flush all addresses to maintain backwards compatibility. When the set global
  addresses with no expire times are not flushed on an admin down. The sysctl
  is per-interface or system-wide for all interfaces
  
      $ sysctl -w net.ipv6.conf.eth1.keep_addr_on_down=1
  or
      $ sysctl -w net.ipv6.conf.all.keep_addr_on_down=1
  
  Will keep addresses on eth1 on an admin down.
  
      $ ip -6 addr show dev eth1
      3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
          inet6 2100:1::2/120 scope global
             valid_lft forever preferred_lft forever
          inet6 fe80::e0:f9ff:fe79:34bd/64 scope link
             valid_lft forever preferred_lft forever
      $ ip link set dev eth1 down
      $ ip -6 addr show dev eth1
      3: eth1: <BROADCAST,MULTICAST> mtu 1500 state DOWN qlen 1000
          inet6 2100:1::2/120 scope global tentative
             valid_lft forever preferred_lft forever
          inet6 fe80::e0:f9ff:fe79:34bd/64 scope link tentative
             valid_lft forever preferred_lft forever
  
  Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
  Signed-off-by: David S. Miller <davem@davemloft.net>
  ---
   Documentation/networking/ip-sysctl.txt |   9 +++
   include/linux/ipv6.h                   |   1 +
   include/uapi/linux/ipv6.h              |   1 +
   net/ipv6/addrconf.c                    | 136 +++++++++++++++++++++++++++++----
   4 files changed, 132 insertions(+), 15 deletions(-)
  
  diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
  index 24ce97f..d5df40c 100644
  [...]

-- 
2.7.0


-- 
- Jeremiah Mahler
